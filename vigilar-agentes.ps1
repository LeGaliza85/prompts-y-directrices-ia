<#
.SYNOPSIS
  Vigila los subagentes en tiempo real y actúa solo cuando uno se queda parado.

.DESCRIPTION
  Un subagente que se atasca no da error: simplemente deja de escribir en el log. Este
  script lee el log continuamente y, cuando detecta que un subagente lleva demasiado tiempo
  sin avanzar, cancela su sesión para que el trabajo no se quede colgado.

  CÓMO SE DETECTA UN ATASCO, y por qué se mide así.

  La señal no es el permiso pendiente sino el SILENCIO. Medido sobre el log real de la
  sesion del 2026-10-10:

    - Un subagente sano hace bucles de trabajo: loop -> tool call -> respuesta. El que
      funciono hizo 11 iteraciones en 4 minutos.
    - Un subagente atascado hace UN solo loop, abre el stream contra el modelo, y se para:
      09:03:03.467 loop, 09:03:03.779 stream, 09:03:05.335 ultimo evento, y 3 minutos de
      silencio hasta el cancel. Cero tool calls.
    - El motivo no es el modelo ni un dialogo de permiso: termina en "error=Aborted" al
      cancelarlo, no con un 429 ni un rate limit.

  Un subagente que espera una respuesta larga del modelo tambien esta en silencio unos
  segundos. Por eso el umbral no es 0: por defecto 90 segundos de silencio se consideran
  sospechoso, y solo se cancela a los -CancelarSegundos- (por defecto 240) segundos. Asi
  un subagente lento pero vivo no se toca, y uno muerto no ocupa la sesion.

.PARAMETER Umbral
  Segundos de silencio a partir de los cuales se avisa. Por defecto 90.

.PARAMETER CancelarSegundos
  Segundos de silencio a partir de los cuales se cancela el subagente. 0 desactiva.

.PARAMETER UnaVez
  Informe puntual y salida. Es lo que se usa desde otro proceso.

.PARAMETER Intervalo
  Segundos entre lecturas del log en modo vigilancia. Por defecto 10.

.PARAMETER Log
  Ruta del log. Si se omite, se busca en la ubicacion por defecto.

.EXAMPLE
  powershell -File vigilar-agentes.ps1
  powershell -File vigilar-agentes.ps1 -Umbral 60 -CancelarSegundos 180
  powershell -File vigilar-agentes.ps1 -UnaVez -Umbral 30
#>
[CmdletBinding()]
param(
  [int]$Umbral = 90,
  [int]$CancelarSegundos = 240,
  [int]$Intervalo = 10,
  [switch]$UnaVez,
  [string]$Log
)

$ErrorActionPreference = 'Stop'

if (-not $Log) {
  $Log = Join-Path $env:USERPROFILE '.local\share\opencode\log\opencode.log'
}
if (-not (Test-Path -LiteralPath $Log)) {
  Write-Error "No encuentro el log en $Log"
  exit 1
}

# --- Lectura del log -------------------------------------------------------
# El log lo tiene abierto el propio opencode en exclusiva. ReadAllLines falla con
# "el proceso no puede obtener acceso al archivo". Se abre con FileShare para poder
# leer mientras se escribe: un vigilante que solo funciona con el log cerrado solo
# serviria cuando el agente ya esta parado, que es justo cuando no sirve.

function Leer-LogCompartido {
  param([int]$Ultimas = 0)
  try {
    $fs = [System.IO.File]::Open($Log, 'Open', 'Read', 'ReadWrite')
  } catch {
    return $null
  }
  try {
    $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::UTF8)
    $todas = @()
    while (-not $sr.EndOfStream) { $todas += $sr.ReadLine() }
    $sr.Close()
  } catch {
    return $null
  } finally {
    $fs.Close()
  }
  if ($Ultimas -gt 0 -and $todas.Count -gt $Ultimas) {
    return , @($todas[($todas.Count - $Ultimas)..($todas.Count - 1)])
  }
  return , $todas
}

# --- Analisis -------------------------------------------------------------
# Devuelve un objeto por sesion de SUBAGENTE con su estado. Solo se consideran los
# subagentes: la sesion principal es la que nos esta hablando, y su silencio es normal.

function Get-Sesiones {
  param([string[]]$Lineas)

  $ses = @{}
  $orden = New-Object System.Collections.Generic.List[string]
  # Identifica la sesion principal: la que mas veces aparece en el log.
  $cuenta = @{}
  foreach ($l in $Lineas) {
    if ($l -match 'session\.id=(ses_\w+)') {
      $id = $matches[1]
      $cuenta[$id] = 1 + $(if ($cuenta.ContainsKey($id)) { $cuenta[$id] } else { 0 })
    }
  }
  $principal = ($cuenta.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1).Key

  foreach ($l in $Lineas) {
    $id = $null
    if ($l -match 'session\.id=(ses_\w+)') { $id = $matches[1] }

    $ts = $null
    if ($l -match 'timestamp=(\S+?)Z') {
      $ts = [datetime]::Parse($matches[1], [Globalization.CultureInfo]::InvariantCulture,
                               [Globalization.DateTimeStyles]::AdjustToUniversal)
    }

    # Alta de sesion. Se registra siempre que aparezca su id, para no tener que
    # suponer el orden: una linea de loop puede llegar antes que su primer mensaje.
    if ($id -and -not $ses.ContainsKey($id)) {
      $ses[$id] = @{ Loops = 0; Tools = 0 }
      $orden.Add($id)
    }

    if ($id -and $ts) { $ses[$id].Ultima = $ts; $ses[$id].Sesion = $id }

    # Bucles y tool calls: se cuentan sobre la sesion a la que pertenece la linea.
    if ($id -and $l -match 'message=loop session\.id=') { $ses[$id].Loops++ }
    if ($id -and $l -match 'message=(bash|read|write|edit|glob|grep|patch|webfetch|websearch)\b') {
      $ses[$id].Tools++
    }

    if ($l -match 'message=created id=(ses_\w+) slug=(\S+)') {
      $nuevo = $matches[1]; $nombre = $matches[2]
      if (-not $ses.ContainsKey($nuevo)) { $ses[$nuevo] = @{ Loops = 0; Tools = 0 }; $orden.Add($nuevo) }
      $ses[$nuevo].Slug = $nombre
    }
    if ($l -match 'message=(cancel|revert) session\.id=(ses_\w+)') {
      $cerrada = $matches[2]
      if ($ses.ContainsKey($cerrada)) { $ses[$cerrada].Cancelada = $true }
    }
  }

  $salida = New-Object System.Collections.Generic.List[object]
  foreach ($id in $orden) {
    if ($id -eq $principal) { continue }   # la principal no se vigila
    $s = $ses[$id]
    $salida.Add([pscustomobject]@{
      Id = $id
      Slug = $(if ($s.Slug) { $s.Slug } else { $id.Substring(0, 12) })
      Ultima = $s.Ultima
      Loops = $s.Loops
      Tools = $s.Tools
      Cancelada = [bool]$s.Cancelada
    })
  }
  return $salida
}

function Get-Estado {
  param($Sesiones, [datetime]$AhoraUtc, [int]$Umbral, [int]$CancelarSeg)

  $salida = New-Object System.Collections.Generic.List[object]
  foreach ($s in $Sesiones) {
    if (-not $s.Ultima) { continue }
    $silencio = [int]($AhoraUtc - $s.Ultima).TotalSeconds

    # Un subagente atascado se distingue por dos cosas a la vez:
    #   1. lleva demasiado tiempo en silencio, y
    #   2. no ha hecho NADA: ni una sola tool call y un solo loop.
    # Un subagente sano, aunque este pensando, tiene loops o tools. Medido: el atascado
    # de esta sesion tenia loops=1 tools=0; los sanos, loops entre 5 y 18.
    # Pedir las dos condiciones evita marcar como atascado a uno que solo esta pensando.
    $nadaHizo = ($s.Tools -eq 0 -and $s.Loops -le 1)

    $estado = 'ok'
    if ($s.Cancelada) { $estado = 'cancelada' }
    elseif ($nadaHizo -and $silencio -ge $CancelarSeg -and $CancelarSeg -gt 0) { $estado = 'ATASCO_CRITICO' }
    elseif ($nadaHizo -and $silencio -ge $Umbral) { $estado = 'ATASCO' }
    elseif (-not $nadaHizo -and $silencio -ge $CancelarSeg -and $CancelarSeg -gt 0) { $estado = 'pensando' }

    $salida.Add([pscustomobject]@{
      Sesion = $s; Estado = $estado; Silencio = $silencio; NadaHizo = $nadaHizo
    })
  }
  return $salida
}

function Mostrar {
  param($Estados, [datetime]$AhoraUtc, [int]$Umbral, [int]$CancelarSeg)

  $atasco = $Estados | Where-Object { $_.Estado -like 'ATASCO*' }
  $pensando = $Estados | Where-Object { $_.Estado -eq 'pensando' }
  $vivos = $Estados | Where-Object { $_.Estado -eq 'ok' }

  Write-Host ''
  Write-Host ("[VIGILANCIA] {0}  |  umbral {1}s  cancelar {2}s" -f $AhoraUtc.ToString('HH:mm:ss'), $Umbral, $CancelarSeg) -ForegroundColor Cyan

  foreach ($v in ($vivos | Sort-Object Silencio -Descending | Select-Object -First 4)) {
    Write-Host ("  ok        {0,-16} hace {1}s  loops={2} tools={3}" -f $v.Sesion.Slug, $v.Silencio, $v.Sesion.Loops, $v.Sesion.Tools) -ForegroundColor DarkGray
  }

  foreach ($a in $atasco) {
    $critico = $a.Estado -eq 'ATASCO_CRITICO'
    $color = if ($critico) { 'Red' } else { 'Yellow' }
    $marca = if ($critico) { 'ATASCO*' } else { 'ATASCO ' }
    Write-Host ("  {0}  {1,-16} hace {2}s  loops={3} tools={4}" -f $marca, $a.Sesion.Slug, $a.Silencio, $a.Sesion.Loops, $a.Sesion.Tools) -ForegroundColor $color
  }

  foreach ($p in $pensando) {
    Write-Host ("  pensando  {0,-16} hace {1}s  loops={2} tools={3}" -f $p.Sesion.Slug, $p.Silencio, $p.Sesion.Loops, $p.Sesion.Tools) -ForegroundColor DarkYellow
  }

  if (-not $atasco) { Write-Host '  sin atascos' -ForegroundColor Green }
}

function Cancelar-Subagente {
  <#
    Cancela un subagente atascado usando la API del servidor de opencode en localhost.

    Por que una peticion HTTP y no un comando de opencode CLI: el servidor expone
    POST /session/<id>/abort, que cancela la sesion en caliente. Un comando CLI abriria
    una sesion nueva, que es justo lo que no queremos mientras la otra esta colgada.

    Verificado contra la sesion real: POST /session/<id>/abort devuelve 200.
  #>
  param([string]$Id, [string]$Slug)

  $puertos = @(4096, 4097, 7575, 8080)
  $abortOk = $false
  foreach ($p in $puertos) {
    $base = "http://127.0.0.1:$p"
    foreach ($accion in @('abort', 'cancel')) {
      try {
        $r = Invoke-WebRequest -Uri "$base/session/$Id/$accion" -Method POST -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
        if ($r.StatusCode -eq 200) { $abortOk = $true; break }
      } catch { }
    }
    if ($abortOk) { break }
  }
  return $abortOk
}

function Accionar-Atascos {
  param($Estados, [int]$Umbral, [int]$CancelarSeg)

  $criticos = $Estados | Where-Object { $_.Estado -eq 'ATASCO_CRITICO' }
  $n = 0
  foreach ($c in $criticos) {
    $hecho = $false
    if ($CancelarSeg -gt 0) { $hecho = Cancelar-Subagente -Id $c.Sesion.Id -Slug $c.Sesion.Slug }
    if ($hecho) {
      Write-Host ("  >> CANCELADO {0} (loops={1} tools={2}, {3}s parado)" -f $c.Sesion.Slug, $c.Sesion.Loops, $c.Sesion.Tools, $c.Silencio) -ForegroundColor Red
      $n++
    } else {
      Write-Host ("  >> AVISO: {0} lleva {1}s parado y no se pudo cancelar solo. Cancela con ESC en el editor." -f $c.Sesion.Slug, $c.Silencio) -ForegroundColor Yellow
    }
  }
  return $n
}

# --- Ejecucion ------------------------------------------------------------

if ($UnaVez) {
  $lineas = Leer-LogCompartido -Ultimas 12000
  if (-not $lineas) { Write-Error 'No se pudo leer el log (puede estar bloqueado).'; exit 1 }
  $sesiones = Get-Sesiones -Lineas $lineas
  $estados = Get-Estado -Sesiones $sesiones -AhoraUtc ([datetime]::UtcNow) -Umbral $Umbral -CancelarSeg $CancelarSegundos
  Mostrar -Estados $estados -AhoraUtc ([datetime]::UtcNow) -Umbral $Umbral -CancelarSeg $CancelarSegundos
  # Codigo de salida: 0 si nada mal, 1 si hay un atasco critico.
  if ($estados | Where-Object { $_.Estado -eq 'ATASCO_CRITICO' }) { exit 1 }
  exit 0
}

Write-Host "Vigilando subagentes. Ctrl+C para salir." -ForegroundColor Cyan
Write-Host "Umbral: ${Umbral}s | cancelar a los ${CancelarSegundos}s | cada ${Intervalo}s" -ForegroundColor DarkGray
Write-Host "Un subagente se marca ATASCO cuando lleva ${Umbral}s parado SIN hacer nada (tools=0, loops<=1)." -ForegroundColor DarkGray
Write-Host "Se cancela solo al llegar a ${CancelarSegundos}s, por la API del servidor. 0 = no cancelar." -ForegroundColor DarkGray

$yaAvisados = @{}
while ($true) {
  $lineas = Leer-LogCompartido -Ultimas 12000
  if ($lineas) {
    $sesiones = Get-Sesiones -Lineas $lineas
    $ahora = [datetime]::UtcNow
    $estados = Get-Estado -Sesiones $sesiones -AhoraUtc $ahora -Umbral $Umbral -CancelarSeg $CancelarSegundos
    Mostrar -Estados $estados -AhoraUtc $ahora -Umbral $Umbral -CancelarSeg $CancelarSegundos

    $n = Accionar-Atascos -Estados $estados -Umbral $Umbral -CancelarSeg $CancelarSegundos
    if ($n -gt 0) {
      Write-Host ''
      Write-Host "Se cancelaron $n subagente(s) atascados para que el trabajo siga." -ForegroundColor Red
      Write-Host 'Sintoma: abren el stream contra el modelo y no hacen ninguna tool call.' -ForegroundColor Yellow
      Write-Host 'No es un dialogo de permiso ni un limite de uso: no hay ni 429 ni error de cuota.' -ForegroundColor Yellow
    }
  }
  Start-Sleep -Seconds $Intervalo
}