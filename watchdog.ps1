<#
.SYNOPSIS
  Vigilante de subagentes. Detecta bloqueos, los cancela, y reanuda el trabajo.

.DESCRIPTION
  Un subagente atascado no da error: deja de escribir en el log. Este script lo detecta,
  actua solo, y deja constancia.

  LAS CINCO CAUSAS DE BLOQUEO, todas medidas sobre el log real de opencode 1.4.0
  (25.573 lineas, varias semanas, seis modelos distintos):

    1. Límite de uso del modelo.
       "AI_APICallError: Rate limit exceeded" - 8 veces. Incluido space-bunny-free.
       Causa: paralelizar. Tres subagentes creados en el mismo milisegundo (01:157,
       01:188, 01:214)_nodejs_nodejs_producen rate limit 0,6 s después.

    2. Saldo o cuota del proveedor agotada.
       "Insufficient balance or no resource package" - 32 veces, todas de zai-coding-plan.
       No tiene arreglo: hay que cambiar de modelo o recargar.

    3. Modelo no disponible.
       "Upstream request failed: Model is unavailable" - 6 veces.

    4. Contexto excedido.
       "Input token count (382306) exceeded" - 1 vez. Ocurre cuando la sesion crece.

    5. Stream estéril: el modelo abre el stream y no devuelve nada.
       Sin error, sin 429, sin tool calls. Un solo loop y tres minutos de silencio.
       Es el más dificil de detectar porque no deja rastro de error.

  El script distingue las cinco por la clase de bloqueo:

    - Con "stream error" en el log  -> es 1, 2, 3 o 4. Se lee el mensaje y se dice cuál.
    - Sin error y con silencio       -> es 5. Se cancela y se registra.

  ACCION: cancela la sesion por POST /session/<id>/abort (verificado, devuelve 200). Con
  -SinCancelar solo avisa.

  NO PIERDE INFORMACION: solo cancela subagentes que no han hecho nada. Si un subagente ha
  hecho tool calls, se avisa pero no se toca, porque ahí hay trabajo que perder.

.PARAMETER Umbral
  Segundos de silencio para considerar sospechoso. Por defecto 90.

.PARAMETER CancelarSegundos
  Segundos de silencio para cancelar. 0 desactiva la cancelación. Por defecto 240.

.PARAMETER Intervalo
  Segundos entre lecturas. Por defecto 15.

.PARAMETER SinCancelar
  Solo informa, no cancela.

.PARAMETER UnaVez
  Informe puntual y salida. Código 1 si hay un atasco crítico.

.PARAMETER Log
  Ruta del log. Por defecto, la ubicación estándar.

.EXAMPLE
  powershell -File vigilar-agentes.ps1
  powershell -File watchdog.ps1 -Umbral 45 -CancelarSegundos 120
  powershell -File watchdog.ps1 -UnaVez
#>
[CmdletBinding()]
param(
  [int]$Umbral = 90,
  [int]$CancelarSegundos = 240,
  [int]$Intervalo = 15,
  [switch]$SinCancelar,
  [switch]$UnaVez,
  [string]$Log,
  [string]$Registro
)

$ErrorActionPreference = 'Stop'

if (-not $Log) { $Log = Join-Path $env:USERPROFILE '.local\share\opencode\log\opencode.log' }
if (-not (Test-Path -LiteralPath $Log)) { Write-Error "No encuentro el log en $Log"; exit 1 }
if (-not $Registro) { $Registro = Join-Path (Split-Path -Parent $Log) 'watchdog-registro.md' }

# --- Lectura -----------------------------------------------------------------
# El log lo tiene abierto el propio opencode en exclusiva: ReadAllLines falla con
# "el proceso no puede obtener acceso al archivo". Se abre con FileShare. Un vigilante
# que solo lee con el log cerrado solo sirve cuando el agente ya está parado.

function Leer-Log {
  try { $fs = [System.IO.File]::Open($Log, 'Open', 'Read', 'ReadWrite') } catch { return $null }
  try {
    $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::UTF8)
    $t = @(); while (-not $sr.EndOfStream) { $t += $sr.ReadLine() }; $sr.Close()
  } catch { return $null } finally { $fs.Close() }
  if ($t.Count -gt 20000) { return , @($t[($t.Count - 20000)..($t.Count - 1)]) }
  return , $t
}

# --- Clasificacion de causas -------------------------------------------------

function Get-Causa {
  <#
    Traduce el mensaje de un "stream error" a una de las cuatro causas con arreglo.
    Devuelve $null si el mensaje no es ninguno de esos: entonces no sabemos cual es,
    y hay que decirlo en vez de inventarlo.
  #>
  param([string]$Mensaje, [string]$Modelo)

  if (-not $Mensaje) { return $null }
  switch -Regex ($Mensaje) {
    'Rate limit exceeded'      { return @{ Id = 'rate-limit';   Texto = "Límite de uso del modelo $Modelo. Con más subagentes en paralelo, más probable."; Cambio = 'Menos subagentes a la vez, o cambiar de modelo.' } }
    'Insufficient balance'     { return @{ Id = 'sin-saldo';    Texto = "El proveedor no tiene saldo o paquete para $Modelo."; Cambio = 'Cambiar de modelo o recargar. No tiene arreglo desde aquí.' } }
    'Model is unavailable'     { return @{ Id = 'no-disponible'; Texto = "El modelo $Modelo no está disponible ahora mismo."; Cambio = 'Usar otro modelo en /models.' } }
    'Input token count.*exceed'{ return @{ Id = 'contexto';      Texto = "Se superó la ventana de contexto de $Modelo."; Cambio = 'Sesión demasiado larga. /compact o sesión nueva.' } }
  }
  return $null
}

# --- Analisis ----------------------------------------------------------------

function Get-Sesiones {
  param([string[]]$Lineas)

  $ses = @{}
  $orden = New-Object System.Collections.Generic.List[string]
  $errores = @{}

  # La sesion principal es la que mas veces aparece; no se vigila.
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

    if ($id -and -not $ses.ContainsKey($id)) { $ses[$id] = @{ Loops = 0; Tools = 0 }; $orden.Add($id) }
    if ($id -and $ts) { $ses[$id].Ultima = $ts }
    if ($id -and $l -match 'message=loop session\.id=') { $ses[$id].Loops++ }
    if ($id -and $l -match 'message=(bash|read|write|edit|glob|grep|patch|webfetch|websearch)\b') { $ses[$id].Tools++ }

    # Errores de stream. NO llevan session.id: es el mismo problema que el
    # "evaluated" sin id. Por eso se atribuyen a la subsesion mas reciente que este
    # viva en ese momento, que es a quien corresponde: el stream que fallo es el suyo.
    if ($l -match '"stream error"') {
      $mod = if ($l -match 'modelID=(\S+)') { $matches[1] } else { '?' }
      $msg = if ($l -match 'error\.error="([^"]+)"') { $matches[1] } else { $l }
      $e = Get-Causa -Mensaje $msg -Modelo $mod
      if ($e) {
        $e.Hora = $ts; $e.Modelo = $mod
        $destino = $null
        if ($id) { $destino = $id }
        elseif ($orden.Count -gt 0) { $destino = $orden[$orden.Count - 1] }
        if ($destino) { $errores[$destino] = $e }
      }
    }

    if ($l -match 'message=created id=(ses_\w+) slug=(\S+)') {
      $n = $matches[1]; $s = $matches[2]
      if (-not $ses.ContainsKey($n)) { $ses[$n] = @{ Loops = 0; Tools = 0 }; $orden.Add($n) }
      $ses[$n].Slug = $s
    }
    if ($l -match 'message=(cancel|revert) session\.id=(ses_\w+)') {
      $c = $matches[2]
      if ($ses.ContainsKey($c)) { $ses[$c].Cancelada = $true }
    }
  }

  $salida = New-Object System.Collections.Generic.List[object]
  foreach ($id in $orden) {
    if ($id -eq $principal) { continue }
    $s = $ses[$id]
    $salida.Add([pscustomobject]@{
      Id = $id
      Slug = $(if ($s.Slug) { $s.Slug } else { $id.Substring(0, 12) })
      Ultima = $s.Ultima
      Loops = $s.Loops
      Tools = $s.Tools
      Cancelada = [bool]$s.Cancelada
      Error = $(if ($errores.ContainsKey($id)) { $errores[$id] } else { $null })
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
    $nadaHizo = ($s.Tools -eq 0 -and $s.Loops -le 1)

    $clase = 'ok'; $causa = $null; $accion = ''
    if ($s.Cancelada) { $clase = 'cancelada' }
    elseif ($s.Error) {
      # Error de stream: la causa se lee del propio error, no se infiere del silencio.
      $clase = 'error'; $causa = $s.Error
      $accion = $s.Error.Cambio
    }
    elseif ($nadaHizo -and $CancelarSeg -gt 0 -and $silencio -ge $CancelarSeg) {
      $clase = 'ATASCO'
      $causa = @{ Id = 'stream-esteril'; Texto = 'El modelo abrió el stream y no devolvió nada. Sin error ni tool calls.' }
      $accion = 'Se cancela y el agente principal retoma la tarea.'
    }
    elseif ($nadaHizo -and $silencio -ge $Umbral) {
      $clase = 'sospechoso'
      $causa = @{ Id = 'stream-esteril'; Texto = 'Silencio sin hacer nada. Todavía dentro del margen.' }
      $accion = 'Esperar. Si llega al umbral de cancelación, se cancela.'
    }
    elseif ($silencio -ge $CancelarSeg -and $CancelarSeg -gt 0) {
      $clase = 'pensando'
    }

    $salida.Add([pscustomobject]@{
      Sesion = $s; Clase = $clase; Silencio = $silencio
      Causa = $causa; Accion = $accion; NadaHizo = $nadaHizo
    })
  }
  return $salida
}

# --- Acciones ----------------------------------------------------------------

function Cancelar-Sesion {
  param([string]$Id)
  foreach ($p in @(4096, 4097, 7575, 8080)) {
    foreach ($a in @('abort', 'cancel')) {
      try {
        $r = Invoke-WebRequest -Uri "http://127.0.0.1:$p/session/$Id/$a" -Method POST -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop
        if ($r.StatusCode -eq 200) { return $true }
      } catch { }
    }
  }
  return $false
}

function Registrar {
  param([string]$Linea)
  $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
  $c = "## $ts`n`n$Linea`n`n"
  Add-Content -LiteralPath $Registro -Value $c -Encoding UTF8
}

function Accionar {
  param($Estados, [switch]$SoloInformar)

  $n = 0
  foreach ($e in ($Estados | Where-Object { $_.Clase -in @('ATASCO', 'error') })) {
    $s = $e.Sesion
    # NUNCA se toca un subagente que ha hecho trabajo: ahí hay información que perder.
    if (-not $e.NadaHizo -and $e.Clase -eq 'ATASCO') {
      Write-Host ("  >> AVISO: {0} lleva {1}s parado pero HA HECHO trabajo ({2} tools). No se toca." -f $s.Slug, $e.Silencio, $s.Tools) -ForegroundColor Yellow
      continue
    }
    $causa = $e.Causa
    $cancelo = $false
    if ($e.Clase -eq 'ATASCO' -and -not $SoloInformar) { $cancelo = Cancelar-Sesion -Id $s.Id }

    if ($cancelo) {
      Write-Host ("  >> CANCELADO {0}  causa: {1}" -f $s.Slug, $causa.Texto) -ForegroundColor Red
      Registrar -Linea ("- **CANCELADO** `{0}` tras {1}s sin actividad. Causa: {2} Accion: {3}" -f $s.Slug, $e.Silencio, $causa.Texto, $causa.Cambio)
      $n++
    } elseif ($e.Clase -eq 'error') {
      Write-Host ("  >> ERROR {0}: {1}" -f $s.Slug, $causa.Texto) -ForegroundColor Red
      Write-Host ("     Que hacer: {0}" -f $causa.Cambio) -ForegroundColor Cyan
      Registrar -Linea ("- **ERROR** `{0}` ({1}): {2} Cambiar: {3}" -f $s.Slug, $causa.Id, $causa.Texto, $causa.Cambio)
      $n++
    } else {
      Write-Host ("  >> SOSPECHOSO {0}: {1} lleva {2}s" -f $s.Slug, $causa.Texto, $e.Silencio) -ForegroundColor Yellow
    }
  }
  return $n
}

function Mostrar {
  param($Estados, [datetime]$AhoraUtc, [int]$Umbral, [int]$CancelarSeg)

  $ok = $Estados | Where-Object { $_.Clase -eq 'ok' }
  $sosp = $Estados | Where-Object { $_.Clase -eq 'sospechoso' }
  $atas = $Estados | Where-Object { $_.Clase -eq 'ATASCO' }
  $err = $Estados | Where-Object { $_.Clase -eq 'error' }

  Write-Host ''
  Write-Host ("[WATCHDOG] {0}  aviso {1}s  cancelar {2}s" -f $AhoraUtc.ToString('HH:mm:ss'), $Umbral, $CancelarSeg) -ForegroundColor Cyan

  foreach ($e in $err) {
    Write-Host ("  ERROR    {0,-16} {1}" -f $e.Sesion.Slug, $e.Causa.Texto) -ForegroundColor Red
  }
  foreach ($a in $atas) {
    Write-Host ("  ATASCO   {0,-16} hace {1}s  loops={2} tools={3}" -f $a.Sesion.Slug, $a.Silencio, $a.Sesion.Loops, $a.Sesion.Tools) -ForegroundColor Red
  }
  foreach ($s in $sosp) {
    Write-Host ("  sospecha {0,-16} hace {1}s" -f $s.Sesion.Slug, $s.Silencio) -ForegroundColor Yellow
  }
  foreach ($o in ($ok | Sort-Object Silencio -Descending | Select-Object -First 3)) {
    Write-Host ("  ok       {0,-16} hace {1}s  loops={2} tools={3}" -f $o.Sesion.Slug, $o.Silencio, $o.Sesion.Loops, $o.Sesion.Tools) -ForegroundColor DarkGray
  }
  if (-not $err -and -not $atas -and -not $sosp) { Write-Host '  sin incidencias' -ForegroundColor Green }
}

# --- Ejecucion ---------------------------------------------------------------

if ($UnaVez) {
  $l = Leer-Log
  if (-not $l) { Write-Error 'No se pudo leer el log.'; exit 1 }
  $est = Get-Estado -Sesiones (Get-Sesiones -Lineas $l) -AhoraUtc ([datetime]::UtcNow) -Umbral $Umbral -CancelarSeg $CancelarSegundos
  Mostrar -Estados $est -AhoraUtc ([datetime]::UtcNow) -Umbral $Umbral -CancelarSeg $CancelarSegundos
  if ($est | Where-Object { $_.Clase -in @('ATASCO', 'error') }) { exit 1 }
  exit 0
}

Write-Host 'Watchdog de subagentes. Ctrl+C para salir.' -ForegroundColor Cyan
Write-Host "  aviso a ${Umbral}s | cancelar a ${CancelarSegundos}s | cada ${Intervalo}s" -ForegroundColor DarkGray
Write-Host "  solo informa: $($SinCancelar.IsPresent)" -ForegroundColor DarkGray
Write-Host "  registro: $Registro" -ForegroundColor DarkGray
Write-Host ''

$previos = @{}
while ($true) {
  $l = Leer-Log
  if ($l) {
    $ahora = [datetime]::UtcNow
    $est = Get-Estado -Sesiones (Get-Sesiones -Lineas $l) -AhoraUtc $ahora -Umbral $Umbral -CancelarSeg $CancelarSegundos
    $problemas = $est | Where-Object { $_.Clase -in @('ATASCO', 'error') }
    # Solo imprime si hay problema, o si el estado ha cambiado. Evita ruido.
    $firma = ($problemas | ForEach-Object { "$($_.Sesion.Id):$($_.Clase)" }) -join ','
    if ($firma -ne $script:prevFirma) {
      Mostrar -Estados $est -AhoraUtc $ahora -Umbral $Umbral -CancelarSeg $CancelarSegundos
      if ($problemas) {
        Accionar -Estados $est -SoloInformar:$SinCancelar | Out-Null
      }
      $script:prevFirma = $firma
    }
  }
  Start-Sleep -Seconds $Intervalo
}