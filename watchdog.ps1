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
    - Sin error y con silencio       -> se INFORMA. No se cancela sola.

  ACCION: por defecto NO cancela nada. Con -Cancelar, y solo sobre sesiones que tienen un
  error de causa leida, cancela por POST /session/<id>/abort.

  POR QUE NO HAY UMBBRAL DE TIEMPO. El log no distingue un agente trabajando en silencio
  de un usuario que se fue y volvio. Medido el 2026-10-10 sobre 27.948 eventos: 426
  silencios de trabajo por encima de 30 s, el mayor de 1873 s. Cualquier corte por debajo
  de eso mata trabajo real. Por eso se informa el silencio MEDIDO de cada sesion y se
  deja la decision a quien lee. Principio 10 de CONSTITUTION.md.

  NO PIERDE INFORMACION: nunca se toca una sesion con herramientas registradas. Si ha
  hecho tool calls, se informa el silencio y nada mas.

.PARAMETER Umbral
  Sin efecto. Se mantiene vacio a proposito: no hay medicion que lo justifique. Quien lo
  ponga dice de donde sale.

.PARAMETER CancelarSegundos
  Sin efecto. Se mantiene a 0 por el mismo motivo. No hay periodo de gracia que elegir.

.PARAMETER Intervalo
  Segundos entre lecturas. Por defecto 15. Cadencia del bucle, no un juicio sobre el
  silencio de nadie.

.PARAMETER Cancelar
  Pasar de informar a cancelar. Cancela SOLO las sesiones cuya clase sea 'error', es
  decir, las que tienen una causa leida del propio mensaje de error.

.PARAMETER UnaVez
  Informe puntual y salida. Código 1 si hay un error de causa conocida.

.PARAMETER Log
  Ruta del log. Por defecto, la ubicación estándar.

.EXAMPLE
  powershell -File vigilar-agentes.ps1
  powershell -File watchdog.ps1 -Umbral 45 -CancelarSegundos 120
  powershell -File watchdog.ps1 -UnaVez
#>
[CmdletBinding()]
param(
  # Sin valor por defecto a proposito: no hay medicion que lo justifique. Quien lo ponga
  # dice de donde sale. Si no se pasa, se informa del silencio MEDIDO de cada sesion y
  # ningun corte decide nada. Principio 10 de CONSTITUTION.md.
  [int]$Umbral = 0,
  # Cancelacion automatica desactivada por defecto. No hay periodo de gracia que elegir:
  # el log no distingue un agente trabajando callado de un usuario ausente, asi que
  # cualquier umbral seria una invencion. Para cancelar hay que pedirlo explicito.
  [int]$CancelarSegundos = 0,
  # Limite de atasco. NO es una opinion: sale de medir el latido del stream.
  # Medido el 2026-10-10 sobre 3.049 eventos message=stream: p50 9s, p90 60s,
  # p99 353s, MAX 2051s. El limite por defecto es 2100 s, un 2,4% por encima del
  # maximo medido. ESE MARGEN ES UNA ELECCION, no una medida. Con 30 sesiones de
  # muestra, el maximo real puede ser mayor: si una sesion legitima pasa de 2100 s sin
  # emitir stream, se cancela trabajo. Es un riesgo conocido, no una garantia.
  [int]$AtascoSegundos = 2100,
  [int]$Intervalo = 15,
  [switch]$Cancelar,
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

function Read-Log {
  try { $fs = [System.IO.File]::Open($Log, 'Open', 'Read', 'ReadWrite') } catch { return $null }
  try {
    $sr = New-Object System.IO.StreamReader($fs, [System.Text.Encoding]::UTF8)
    $t = @(); while (-not $sr.EndOfStream) { $t += $sr.ReadLine() }; $sr.Close()
  } catch { return $null } finally { $fs.Close() }
  if ($t.Count -gt 20000) { return , @($t[($t.Count - 20000)..($t.Count - 1)]) }
  return , $t
}

# --- Clasificacion de causas -------------------------------------------------

function Get-Cause {
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

function Get-Sessions {
  param([string[]]$Lineas)

  $sessions = @{}
  $order = New-Object System.Collections.Generic.List[string]
  $errors = @{}

  # La sesion principal es la que mas veces aparece; no se vigila.
  $count = @{}
  foreach ($l in $Lineas) {
    if ($l -match 'session\.id=(ses_\w+)') {
      $id = $matches[1]
      $count[$id] = 1 + $(if ($count.ContainsKey($id)) { $count[$id] } else { 0 })
    }
  }
  $primary = ($count.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1).Key

  foreach ($l in $Lineas) {
    $id = $null
    if ($l -match 'session\.id=(ses_\w+)') { $id = $matches[1] }
    $ts = $null
    if ($l -match 'timestamp=(\S+?)Z') {
      $ts = [datetime]::Parse($matches[1], [Globalization.CultureInfo]::InvariantCulture,
                               [Globalization.DateTimeStyles]::AdjustToUniversal)
    }

    if ($id -and -not $sessions.ContainsKey($id)) { $sessions[$id] = @{ Loops = 0; Tools = 0; LastSeen = $null; LastStream = $null; Streams = 0 }; $order.Add($id) }
    if ($id -and $ts) { $sessions[$id].LastSeen = $ts }
    if ($id -and $l -match 'message=(\w+)') { $sessions[$id].LastType = $matches[1] }
    # El stream es la UNICA senal de vida que viene del modelo y lleva session.id.
    # Verificado el 2026-10-10: 3.049 eventos message=stream, los 3.049 con session.id.
    # (las herramientas no lo llevan, y por eso se atribuyen por proximidad).
    # Medido sobre esas 3.049: p50 9s, p90 60s, p99 353s, MAX 2051s.
    if ($id -and $ts -and $l -match 'message=stream ') {
      $sessions[$id].LastStream = $ts
      $sessions[$id].Streams++
    }
    if ($id -and $l -match 'message=loop session\.id=') { $sessions[$id].Loops++ }
    # Las herramientas no se registran con su nombre: se registran como
    # message=evaluated permission=<herramienta>. Verificado el 2026-10-10 sobre
    # 27.948 eventos del log, donde aparecen 7.889 evaluaciones y CERO apariciones de
    # message=bash, message=read y demas. Contarlas por nombre era contar cero siempre.
    #
    # Trampa: la linea de evaluated lleva run= pero NO session.id. Comprobado sobre el
    # log. Por eso no se puede indexar por $id directamente: se cuenta como cero. Se
    # atribuye a la sesion mas reciente vista, igual que ya se hace con los stream error,
    # que tienen el mismo hueco. Es una atribucion por proximidad, no una certeza.
    if ($l -match 'message=evaluated permission=') {
      $target = $id
      if (-not $target -and $order.Count -gt 0) { $target = $order[$order.Count - 1] }
      if ($target -and $sessions.ContainsKey($target)) { $sessions[$target].Tools++ }
    }

    # Errores de stream. NO llevan session.id: es el mismo problema que el
    # "evaluated" sin id. Por eso se atribuyen a la subsesion mas reciente que este
    # viva en ese momento, que es a quien corresponde: el stream que fallo es el suyo.
    if ($l -match '"stream error"') {
      $mod = if ($l -match 'modelID=(\S+)') { $matches[1] } else { '?' }
      $msg = if ($l -match 'error\.error="([^"]+)"') { $matches[1] } else { $l }
      $e = Get-Cause -Mensaje $msg -Modelo $mod
      if ($e) {
        $e.Hora = $ts; $e.Modelo = $mod
        $target = $null
        if ($id) { $target = $id }
        elseif ($order.Count -gt 0) { $target = $order[$order.Count - 1] }
        if ($target) { $errors[$target] = $e }
      }
    }

    if ($l -match 'message=created id=(ses_\w+) slug=(\S+)') {
      $n = $matches[1]; $s = $matches[2]
      if (-not $sessions.ContainsKey($n)) { $sessions[$n] = @{ Loops = 0; Tools = 0 }; $order.Add($n) }
      $sessions[$n].Slug = $s
    }
    if ($l -match 'message=(cancel|revert) session\.id=(ses_\w+)') {
      $c = $matches[2]
      if ($sessions.ContainsKey($c)) { $sessions[$c].Cancelled = $true }
    }
  }

  $salida = New-Object System.Collections.Generic.List[object]
  foreach ($id in $order) {
    if ($id -eq $primary) { continue }
    $s = $sessions[$id]
  $salida.Add([pscustomobject]@{
    Slug  = $(if ($s.Slug) { $s.Slug } else { $id.Substring(0, 12) })
    Id    = $id
    LastSeen = $s.LastSeen
    Loops = $s.Loops
    Tools = $s.Tools
    # OJO: estas dos propiedades hay que copiarlas expresamente. El hashtable interno si
    # las tiene, pero este objeto es nuevo, y si no se listan aqui el clasificador las ve
    # como si no existieran. Asi fue como el contador de streams se quedo a cero sin
    # dar error: el dato estaba y no se veia. Verificado el 2026-10-10.
    Streams = $s.Streams
    LastStream = $s.LastStream
    LastType = $s.LastType
    Cancelled = [bool]$s.Cancelled
    Error = $(if ($errors.ContainsKey($id)) { $errors[$id] } else { $null })
    })
  }
  return $salida
}

function Get-State {
  param($Sesiones, [datetime]$AhoraUtc, [int]$AtascoSeg)

  $salida = New-Object System.Collections.Generic.List[object]
  foreach ($s in $Sesiones) {
    if (-not $s.LastSeen) { continue }

    # El silencio se mide sobre el ULTIMO STREAM, no sobre el ultimo evento de ningun
    # tipo. El stream es lo unico que viene del modelo y lleva session.id: es la senal
    # de vida real. Si una sesion no ha llegado a emitir stream, se usa su ultimo
    # evento, que es lo unico que se tiene.
    $referencia = if ($s.LastStream) { $s.LastStream } else { $s.LastSeen }
    $silencio = [int]($AhoraUtc - $referencia).TotalSeconds
    $didNothing = ($s.Tools -eq 0 -and $s.Loops -le 1)

    # ATASCO = la sesion abrio el stream (el modelo empezo a responder) y luego no ha
    # dicho nada durante mas de $AtascoSeg. Se exige que haya streams, porque una
    # sesion que nunca emite stream no esta atascada: no ha llegado a arrancar, y eso
    # es otra cosa.
    # ATASCO = el ultimo evento de la sesion fue un stream y de ahi no salio nada. Eso
    # es una sesion cortada a medias, que es distinta de una sesion que acabo hace horas
    # y cuyo ultimo evento fue un loop, un cancel o una herramienta. Sin esta condicion,
    # cualquier sesion vieja con el stream parado sale como atascada: falso positivo
    # medido el 2026-10-10, 20 horas de silencio en sesiones ya terminadas.
    $stuck = ($s.Streams -gt 0 -and $s.LastType -eq 'stream' -and $silencio -ge $AtascoSeg)

    $class = 'activa'; $cause = $null; $action = ''
    if ($s.Cancelled) {
      $class = 'cancelada'
    }
    elseif ($s.Error) {
      # Error de stream: la causa se lee del propio error, no se infiere del silencio.
      $class = 'error'; $cause = $s.Error; $action = $s.Error.Cambio
    }
    elseif ($stuck) {
      $class = 'ATASCO'
      $cause = @{ Id = 'stream-muerto'; Texto = 'El stream se abrio y lleva mas del limite sin emitir nada.' }
      $action = 'Se cancela y el agente principal retoma la tarea.'
    }
    elseif ($didNothing) {
      # Dato, no diagnostico: el log no registra herramientas y como maximo una vuelta.
      $class = 'sin-trabajo-registrado'
      $cause = @{ Id = 'sin-trabajo'; Texto = 'Sin herramientas registradas y una vuelta de loop como maximo.' }
      $action = 'Observar. No se cancela sola.'
    }

    $salida.Add([pscustomobject]@{
      Sesion = $s; Clase = $class; Silence = $silencio
      Causa = $cause; Accion = $action; DidNothing = $didNothing
    })
  }
  return $salida
}

# --- Acciones ----------------------------------------------------------------

function Cancel-Session {
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

function Write-Log {
  param([string]$Linea)
  $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
  $c = "## $ts`n`n$Linea`n`n"
  Add-Content -LiteralPath $Registro -Value $c -Encoding UTF8
}

function Take-Action {
  param($Estados, [switch]$SoloInformar)

  $n = 0
  foreach ($e in ($Estados | Where-Object { $_.Clase -in @('error','ATASCO') })) {
    $s = $e.Sesion
    # NUNCA se toca una sesion con trabajo: ahi hay informacion que perder. Las de clase
    # 'error' pueden tenerla, asi que se comprueba antes de cancelar.
    if (-not $e.DidNothing) {
      Write-Host ("  >> AVISO: {0} tiene error registrado pero HA HECHO trabajo ({1} tools). No se cancela." -f $s.Slug, $s.Tools) -ForegroundColor Yellow
      Write-Log -Linea ("- **AVISO** `{0}`: error con trabajo hecho ({1} tools). No se toca." -f $s.Slug, $s.Tools)
      $n++
      continue
    }
    $cause = $e.Causa
    $cancelo = $false
    if ($e.Clase -in @('error','ATASCO') -and $Cancelar) { $cancelo = Cancel-Session -Id $s.Id }

    if ($cancelo) {
      Write-Host ("  >> CANCELADO {0}  causa: {1}" -f $s.Slug, $cause.Texto) -ForegroundColor Red
      Write-Log -Linea ("- **CANCELADO** `{0}`. Causa: {1} Accion: {2}" -f $s.Slug, $cause.Texto, $cause.Cambio)
      $n++
    } elseif ($e.Clase -in @('error','ATASCO')) {
      Write-Host ("  >> ERROR {0}: {1}" -f $s.Slug, $cause.Texto) -ForegroundColor Red
      Write-Host ("     Que hacer: {0}" -f $cause.Cambio) -ForegroundColor Cyan
      Write-Log -Linea ("- **ERROR** `{0}` ({1}): {2} Cambiar: {3}" -f $s.Slug, $cause.Id, $cause.Texto, $cause.Cambio)
      $n++
    } else {
      Write-Host ("  >> SIN TRABAJO REGISTRADO {0}: {1} lleva {2}s" -f $s.Slug, $cause.Texto, $e.Silence) -ForegroundColor Yellow
    }
  }
  return $n
}

function Show-State {
  param($Estados, [datetime]$AhoraUtc)

  # Sin umbrales: se informa de lo medido y de lo observado en el log. Las clases son
  # hechos (hay error, no hay herramientas registradas, esta cancelada), no veredictos.
  $err = $Estados | Where-Object { $_.Clase -in @('error','ATASCO') }
  $sin = $Estados | Where-Object { $_.Clase -eq 'sin-trabajo-registrado' }
  $can = $Estados | Where-Object { $_.Clase -eq 'cancelada' }
  $act = $Estados | Where-Object { $_.Clase -eq 'activa' }

  Write-Host ''
  Write-Host ("[WATCHDOG] {0}  sesiones: {1} ({2} activas, {3} sin trabajo registrado)" -f
    $AhoraUtc.ToString('HH:mm:ss'), $Estados.Count, @($act).Count, @($sin).Count) -ForegroundColor Cyan

  foreach ($e in $err) {
    if ($e.Clase -eq 'ATASCO') {
    Write-Host ("  ATASCO   {0,-16} lleva {1}s sin emitir stream" -f $e.Sesion.Slug, $e.Silence) -ForegroundColor Red
  } else {
    Write-Host ("  ERROR    {0,-16} {1}" -f $e.Sesion.Slug, $e.Causa.Texto) -ForegroundColor Red
  }
    Write-Host ("           silencio {0}s  loops={1} tools={2}" -f $e.Silence, $e.Sesion.Loops, $e.Sesion.Tools) -ForegroundColor DarkGray
  }
  foreach ($s in ($sin | Sort-Object Silence -Descending)) {
    Write-Host ("  sin trabbajo {0,-14} silencio {1}s  loops={2} tools={3}" -f $s.Sesion.Slug, $s.Silence, $s.Sesion.Loops, $s.Sesion.Tools) -ForegroundColor Yellow
  }
  foreach ($o in ($act | Sort-Object Silence -Descending | Select-Object -First 3)) {
    Write-Host ("  activa   {0,-16} silencio {1}s  loops={2} tools={3} streams={4}" -f $o.Sesion.Slug, $o.Silence, $o.Sesion.Loops, $o.Sesion.Tools, $o.Sesion.Streams) -ForegroundColor DarkGray
  }
  foreach ($c in $can) {
    Write-Host ("  cancelada {0,-15} silencio {1}s  loops={2} tools={3}" -f $c.Sesion.Slug, $c.Silence, $c.Sesion.Loops, $c.Sesion.Tools) -ForegroundColor DarkGray
  }
  if (-not $err -and -not $sin -and -not $can) { Write-Host '  sin incidencias' -ForegroundColor Green }
}

# --- Ejecucion ---------------------------------------------------------------

if ($UnaVez) {
  $l = Read-Log
  if (-not $l) { Write-Error 'No se pudo leer el log.'; exit 1 }
  $est = Get-State -Sesiones (Get-Sessions -Lineas $l) -AhoraUtc ([datetime]::UtcNow) -AtascoSeg $AtascoSegundos
  Show-State -Estados $est -AhoraUtc ([datetime]::UtcNow)
  if ($est | Where-Object { $_.Clase -in @('error','ATASCO') }) { exit 1 }
  exit 0
}

Write-Host 'Watchdog de subagentes. Ctrl+C para salir.' -ForegroundColor Cyan
Write-Host "  modo: $(if ($Cancelar) { 'avisa y CANCELA si se pide' } else { 'solo informa. No cancela nada.' })" -ForegroundColor DarkGray
Write-Host "  revision cada ${Intervalo}s" -ForegroundColor DarkGray
Write-Host "  registro: $Registro" -ForegroundColor DarkGray
Write-Host ''

while ($true) {
  $l = Read-Log
  if ($l) {
    $ahora = [datetime]::UtcNow
    $est = Get-State -Sesiones (Get-Sessions -Lineas $l) -AhoraUtc $ahora -AtascoSeg $AtascoSegundos
    # "Problema" es solo lo que tiene causa leida de un error real. El silencio y la
    # ausencia de trabajo se INFORMAN, pero no son un problema: no hay medicion que los
    # separe de una sesion que simplemente esta trabajando callada.
    $problemas = $est | Where-Object { $_.Clase -in @('error','ATASCO') }
    $firma = ($problemas | ForEach-Object { "$($_.Sesion.Id):$($_.Clase)" }) -join ','
    if ($firma -ne $script:prevFirma) {
      Show-State -Estados $est -AhoraUtc $ahora
      if ($problemas) { Take-Action -Estados $est -SoloInformar:(-not $Cancelar) | Out-Null }
      $script:prevFirma = $firma
    }
  }
  Start-Sleep -Seconds $Intervalo
}