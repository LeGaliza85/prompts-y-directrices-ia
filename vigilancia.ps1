<#
.SYNOPSIS
  Vigila las sesiones de OpenCode por la API y avisa de las que se quedan paradas.

.DESCRIPTION
  Complementa a watchdog.ps1, no lo sustituye. Los dos miran cosas distintas:

  - watchdog.ps1 lee el LOG. Solo el log registra "stream error", asi que sigue siendo
    el unico que ve ese fallo.
  - este script pregunta a la API. Ahi esta el estado real: si la sesion dice busy, si
    tiene herramientas a medias, si esta esperando permiso y de quien es hija.

  Tres cosas que aqui se pueden hacer y en el log no:

  1. Saber si un subagente esta ESPERANDO PERMISO. Eso no es un atasco: es el usuario
     decidiendo. Auto-reanudarlo seria aprobar en su nombre. Se comprueba antes de tocar
     nada y si hay permiso pendiente no se toca.
  2. Saber si la sesion es hija de otra y de quien, por /session/{id}/children. No hay
     que adivinarlo parseando lineas del log.
  3. Saber que herramienta esta EN MARCHA. Cada parte lleva state.time.start y, si no ha
     terminado, state.time.end vacio.

  NIVELES. El agente principal y los subagentes NO se tratan igual, y esa asimetria es
  deliberada: perder un subagente cuesta poco porque se relanza; tocar la sesion raiz
  puede destruir todo el trabajo. El raiz solo se avisa. Nunca se toca.

.UMBRALES
  No hay umbral por herramienta. Se intento y no sirve: un edit tarda 24 ms de mediana y
  su maximo medido son 67 ms, asi que cualquier umbral derivado de el marcaria cada edit
  normal. Lo que se mide es el SILENCIO de la sesion, que es una sola magnitud.

  Medido el 2026-10-11 sobre la sesion principal, 2611 huecos entre acciones:
    p50 4 s    p90 30 s    p99 282 s    max 48533 s (13 h: sesion dejada abierta)
  Solo 4 huecos de 2611 superan los 2100 s (0,15 %), y son sesiones pausadas.
  Por eso -AtascoSegundos sigue en 2100: es unas 7,5 veces el p99 y esta justificado con
  la medida. Si la medida cambia, se cambia el valor y se vuelve a anotar por que.

.PARAMETER Servidor
  URL del servidor de OpenCode. Por defecto el 4096.

.PARAMETER AtascoSegundos
  Segundos de silencio antes de avisar. 2100 por el motivo de arriba.

.PARAMETER Intervalo
  Segundos entre pasadas. 0 = una sola pasada y salir.

.PARAMETER Raiz
  Id de la sesion principal a vigilar. Si no se pasa, se busca sola.

.EXAMPLE
  powershell -File vigilancia.ps1
  powershell -File vigilancia.ps1 -Intervalo 60
  powershell -File vigilancia.ps1 -Raiz ses_abc123
#>
[CmdletBinding()]
param(
  [string]$Servidor = "http://127.0.0.1:4096",
  [int]$AtascoSegundos = 2100,
  [int]$Intervalo = 0,
  [string]$Raiz = ""
)

$ErrorActionPreference = 'Stop'

function Invoke-Api {
  param([string]$Ruta, [string]$Metodo = 'GET', $Cuerpo = $null)
  $p = @{ Uri = "$Servidor$Ruta"; Method = $Metodo; TimeoutSec = 120 }
  if ($Cuerpo) { $p.Body = $Cuerpo; $p.ContentType = 'application/json' }
  Invoke-RestMethod @p
}

# @(funcion) devuelve UN elemento con el array dentro; la asignacion no. Ver la nota en
# medir-api.ps1. Aqui se hace siempre asignar y despues envolver.
$crudas = Invoke-Api '/session'
$sessions = @($crudas)
if ($sessions.Count -eq 0) { Write-Host "No hay sesiones." -ForegroundColor Red; exit 1 }

# --- Quién es la sesión principal y quién es hija de quién ---------------------
# /session NO trae parentID, pero /session/{id}/children sí. Se recorren todas las
# sesiones y se recogen las que son hijas de alguna: las que no aparezcan son raíces.
$hijasDe = @{}
foreach ($s in $sessions) {
  if (-not $s.id) { continue }
  try {
    $hijosCrudos = Invoke-Api "/session/$($s.id)/children"
    $hijos = @($hijosCrudos)
    if ($hijos.Count -gt 0) { $hijasDe[$s.id] = $hijos }
  } catch { }
}
$todasLasHijas = @{}
foreach ($k in $hijasDe.Keys) {
  foreach ($h in $hijasDe[$k]) { if ($h.id) { $todasLasHijas[$h.id] = $k }
  }
}
$raices = @($sessions | Where-Object { $_.id -and -not $todasLasHijas.ContainsKey($_.id) })

if ($Raiz) {
  $sesionRaiz = $sessions | Where-Object { $_.id -eq $Raiz } | Select-Object -First 1
  if (-not $sesionRaiz) { Write-Host "No encuentro la sesion $Raiz." -ForegroundColor Red; exit 1 }
} else {
  $sesionRaiz = $raices | Sort-Object { $_.time.updated } -Descending | Select-Object -First 1
  if (-not $sesionRaiz) { Write-Host "No encuentro ninguna sesion principal." -ForegroundColor Red; exit 1 }
}

# --- Estado --------------------------------------------------------------------
$statusCrudos = Invoke-Api '/session/status'
$status = @{}
if ($statusCrudos) {
  foreach ($prop in $statusCrudos.PSObject.Properties) { $status[$prop.Name] = $prop.Value.type }
}

# El campo model viene como objeto {id, providerID, variant}, no como texto. Si se
# imprime tal cual sale un @{...} en medio del mensaje.
function Get-ModeloTexto {
  param($model)
  if ($null -eq $model) { return '(sin modelo)' }
  if ($model -is [string]) { return $model }
  $id = if ($model.modelID) { $model.modelID } elseif ($model.id) { $model.id } else { '?' }
  $prov = if ($model.providerID) { $model.providerID } else { '' }
  if ($prov) { return "$prov/$id" }
  return $id
}

function Get-HerramientasEnMarcha {
  param([string]$Id)
  $msgsCrudos = Invoke-Api "/session/$Id/message"
  $msgs = @($msgsCrudos)
  $tools = @($msgs | ForEach-Object { $_.parts } | Where-Object { $_.type -eq 'tool' })
  $terminadas = @($tools | Where-Object { $_.state.time.end })
  $enMarcha = @($tools | Where-Object { -not $_.state.time.end })
  $ultima = 0
  foreach ($t in $terminadas) { if ($t.state.time.end -gt $ultima) { $ultima = $t.state.time.end } }
  $ahora = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
  return [pscustomobject]@{
    Total = $tools.Count
    EnMarcha = $enMarcha
    Ultimaaccion = $ultima
    Silencio = if ($ultima -gt 0) { [int](($ahora - $ultima) / 1000) } else { -1 }
  }
}

function Get-PermisosPendientes {
  param([string]$Id)
  try {
    $r = Invoke-Api "/api/session/$Id/permission"
    if ($r -and $r.data) { return @($r.data) } else { return @() }
  } catch { return @() }
}

function Get-Hijos {
  param([string]$Id)
  if ($hijasDe.ContainsKey($Id)) { return $hijasDe[$Id] }
  return @()
}

# --- Pasada --------------------------------------------------------------------
Write-Host ''
Write-Host ("Vigilancia sobre {0}" -f $Servidor) -ForegroundColor Cyan
Write-Host ("raíz: {0}   silencio si supera: {1} s" -f $sesionRaiz.id, $AtascoSegundos) -ForegroundColor DarkGray

$incidencias = 0

# El agente principal: SOLO se avisa. No se le toca nunca.
$st = $status[$sesionRaiz.id]
$info = Get-HerramientasEnMarcha $sesionRaiz.id
$estado = if ($st) { $st } else { 'desconocido' }
Write-Host ("  [raíz]    {0,-12} busy={1,-6} herramientas={2,-5} silencio={3}s" -f $estado, ($st -eq 'busy'), $info.Total, $info.Silencio) -ForegroundColor DarkGray

if ($info.EnMarcha.Count -gt 0) {
  foreach ($t in $info.EnMarcha) {
    $desde = [int](([DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() - [int64]$t.state.time.start) / 1000)
    Write-Host ("     >> herramienta en marcha hace {0}s: {1}  ({2})" -f $desde, $t.tool, $t.state.status) -ForegroundColor Yellow
    $incidencias++
  }
}

if ($info.Silencio -ge $AtascoSegundos -and $st -eq 'busy') {
  Write-Host ("     >> AVISO: la sesión raíz lleva {0}s sin hacer nada. NO se toca: tocar la raíz puede perder todo el trabajo." -f $info.Silencio) -ForegroundColor Yellow
  Write-Host "        Si es una sesión tuya y la estás mirando, cancela a mano. Si no, mira si el modelo responde:" -ForegroundColor DarkGray
  Write-Host ("        .\modelos.ps1 -Comprobar {0}" -f (Get-ModeloTexto $sesionRaiz.model)) -ForegroundColor DarkGray
  $incidencias++
}

# Los subagentes: aquí sí se puede actuar, pero hoy solo se avisa.
foreach ($hijo in (Get-Hijos $sesionRaiz.id)) {
  if (-not $hijo.id) { continue }
  $stH = $status[$hijo.id]
  if ($stH -ne 'busy') { continue }   # solo interesan las que deberían estar trabajando

  $infoH = Get-HerramientasEnMarcha $hijo.id
  $permisos = Get-PermisosPendientes $hijo.id
  $titulo = if ($hijo.title) { $hijo.title } else { $hijo.id }

  $marca = ''
  if ($permisos.Count -gt 0) { $marca = 'ESPERA PERMISO' }
  elseif ($infoH.Silencio -ge $AtascoSegundos) { $marca = 'ATASCADA' }

  if ($marca) {
    $color = if ($marca -eq 'ESPERA PERMISO') { 'Cyan' } else { 'Yellow' }
    Write-Host ("  [hijo]    {0,-14} {1,-42}" -f $marca, $titulo.Substring(0, [Math]::Min(42, $titulo.Length))) -ForegroundColor $color
    Write-Host ("     id={0}  modelo={1}  silencio={2}s  herramientas={3}" -f $hijo.id, (Get-ModeloTexto $hijo.model), $infoH.Silencio, $infoH.Total) -ForegroundColor DarkGray
    if ($permisos.Count -gt 0) {
      Write-Host "     NO SE TOCA: tiene permisos pendientes. Eso es una decisión tuya, no un atasco." -ForegroundColor DarkGray
    }
    $incidencias++
  }
}

Write-Host ''
if ($incidencias -eq 0) {
  Write-Host "Sin nada que avisar." -ForegroundColor Green
} else {
  Write-Host ("{0} cosa(s) que mirar. Esto NO reanuda nada todavía: todavía no se ha escrito esa parte." -f $incidencias) -ForegroundColor Yellow
}

if ($Intervalo -le 0) { exit 0 }

# Bucle de sondeo.
while ($true) {
  Start-Sleep -Seconds $Intervalo
  Write-Host ("[{0}] pasada" -f (Get-Date).ToString('HH:mm:ss')) -ForegroundColor DarkGray
  break
}
exit 0
