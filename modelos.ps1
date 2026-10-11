<#
.SYNOPSIS
  Comprueba si un modelo responde AHORA, y elige el primero que lo haga.

.DESCRIPTION
  Es la mitad que faltaba del watchdog. El watchdog vigila DURANTE el trabajo; esto
  decide ANTES de lanzar. No hay ranking ni columna de disponibilidad en documentos:
  la disponibilidad se pregunta en el momento de usarla, y esto es la pregunta.

  POR QUE NO SE USA EL CLI. La primera version llamaba a `opencode run -m <modelo>`.
  Eso dejo de funcionar: OpenCode responde 403 con un texto explicito, "OpenCode's
  free tier can only be used from within OpenCode". El nivel gratuito solo es valido
  desde dentro de la propia aplicacion, no desde una llamada externa. Verificado a mano
  el 2026-10-11 contra https://opencode.ai/zen/v1/chat/completions.

  Ahora se pregunta al SERVIDOR de OpenCode, que si es "dentro de OpenCode". Se le
  crea una sesion desechable por sonda y se le manda un mensaje minimo.

  NO HAY UMBRALES AQUI. Ni memoria de resultado, ni ventana de paralelismo, ni espera
  maxima. Se propusieron en su dia y eran invencion: no habia medida que los sostuviera.
  Principio 10 de CONSTITUTION.md. Si se quieren, se miden primero.

.PARAMETER Elegir
  Lista de modelos en orden de preferencia. Devuelve el primero que responde.

.PARAMETER Comprobar
  Un solo modelo. Pregunta si o no.

.PARAMETER Todos
  Los 18 modelos configurados, uno a uno.

.PARAMETER Servidor
  URL del servidor de OpenCode. Por defecto el puerto 4096, que es el que usa Zed.

.EXAMPLE
  powershell -File modelos.ps1 -Comprobar opencode/space-bunny-free
  powershell -File modelos.ps1 -Elegir opencode/space-bunny-free,opencode/big-pickle
  powershell -File modelos.ps1 -Todos
#>
[CmdletBinding()]
param(
  [string[]]$Elegir,
  [string]$Comprobar,
  [switch]$Todos,
  [string]$Servidor = "http://127.0.0.1:4096"
)

$ErrorActionPreference = 'Stop'

if (-not $Elegir -and -not $Comprobar -and -not $Todos) {
  Write-Host "Uso: modelos.ps1 -Elegir <modelos...> | -Comprobar <modelo> | -Todos"
  Write-Host "     [-Servidor url]   por defecto $Servidor"
  exit 1
}

# Desde la linea de comandos, `-Elegir a,b,c` llega como UNA cadena. Se parte por comas
# para que funcione igual que `-Elegir a b c`.
if ($Elegir) { $Elegir = @($Elegir -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }

# El servidor tiene que estar en pie ANTES de sondear nada. Si no esta, el fallo por
# modelo seria "no responde" para todos, que se lee como si los modelos estuvieran caidos
# y no es verdad: lo que no esta es el servidor.
try {
  $null = Invoke-RestMethod -Uri "$Servidor/global/health" -TimeoutSec 10
} catch {
  # Write-Error con ErrorActionPreference = Stop lanza una excepcion que sube y deja
  # la salida a medias. Aqui se avisa y se sale, que es lo que se quiere decir.
  Write-Host "No hay servidor OpenCode en $Servidor." -ForegroundColor Red
  Write-Host "Es el que responde de verdad: el nivel gratuito no se puede usar desde fuera." -ForegroundColor Red
  Write-Host "Arranca OpenCode, o pasa -Servidor con la URL correcta." -ForegroundColor Red
  exit 1
}

# Lista completa de los modelos configurados. Fuente: `opencode models`, verificada el
# 2026-10-10. 11 del proveedor opencode y 7 de zai-coding-plan.
$catalog = @(
  'opencode/space-bunny-free', 'opencode/big-pickle', 'opencode/step-5-preview-free',
  'opencode/ling-3.0-flash-fin-free', 'opencode/ling-3.1-flash-free',
  'opencode/nemotron-3-ultra-free', 'opencode/nemotron-3.5-lightning-free',
  'opencode/longcat-2.5-preview-free', 'opencode/mimo-v2.6-flash-free',
  'opencode/muse-spark-1.3-contributor-free', 'opencode/exo-free',
  'zai-coding-plan/glm-4.7', 'zai-coding-plan/glm-5-turbo', 'zai-coding-plan/glm-5.2',
  'zai-coding-plan/glm-5.2-highspeed', 'zai-coding-plan/glm-5.3',
  'zai-coding-plan/glm-5.3-flash', 'zai-coding-plan/glm-5.3-highspeed'
)

# Orden por defecto para -Elegir. NO es un ranking de calidad: es orden por historial
# medido, que es lo unico que se puede sostener. space-bunny-free va primero porque
# tiene 1.494 usos sin un error de disponibilidad, no porque sea el mejor.
$measuredOrder = @(
  'opencode/space-bunny-free', 'opencode/big-pickle', 'opencode/muse-spark-1.3-contributor-free',
  'opencode/nemotron-3-ultra-free', 'opencode/exo-free', 'opencode/longcat-2.5-preview-free',
  'opencode/nemotron-3.5-lightning-free', 'opencode/mimo-v2.6-flash-free',
  'opencode/ling-3.1-flash-free', 'opencode/step-5-preview-free'
)

function Probe-Model {
  param([string]$Modelo)

  # El id viene como "proveedor/modelo". La API los quiere separados.
  $slash = $Modelo.IndexOf('/')
  if ($slash -lt 1 -or $slash -ge ($Modelo.Length - 1)) {
    return [pscustomobject]@{ Ok = $false; Ms = -1; Note = 'id mal formado, se espera proveedor/modelo' }
  }
  $providerId = $Modelo.Substring(0, $slash)
  $modelId = $Modelo.Substring($slash + 1)

  $timer = [System.Diagnostics.Stopwatch]::StartNew()
  try {
    # Una sesion propia y desechable por sonda. Se crea en un directorio temporal
    # para que la sonda no toque el proyecto de quien la lanza.
    $workDir = Join-Path ([System.IO.Path]::GetTempPath()) ('sonda-modelo-' + [System.Guid]::NewGuid().ToString('N').Substring(0, 8))
    New-Item -ItemType Directory -Path $workDir -Force | Out-Null
    try {
      $s = Invoke-RestMethod -Method Post -Uri "$Servidor/session" `
        -Body (@{ directory = $workDir } | ConvertTo-Json) `
        -ContentType 'application/json' -TimeoutSec 30
      $sid = if ($s.id) { $s.id } else { $s.info.id }

      $payload = @{
        model = @{ providerID = $providerId; modelID = $modelId }
        parts = @(@{ type = 'text'; text = 'ok' })
      } | ConvertTo-Json -Depth 6

      $r = Invoke-RestMethod -Method Post -Uri "$Servidor/session/$sid/message" `
        -Body $payload -ContentType 'application/json' -TimeoutSec 600
    } finally {
      Remove-Item $workDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    $timer.Stop()
    $note = ''
    if ($r.info.error) {
      $note = $r.info.error.name + ': ' + $r.info.error.data.message
    } elseif ($r.info.providerID -ne $providerId -or $r.info.modelID -ne $modelId) {
      # La API puede atender con otro modelo. Si eso pasa, el dato NO es de este.
      $note = "respondio otro modelo: $($r.info.providerID)/$($r.info.modelID)"
    }
    [pscustomobject]@{ Ok = ($note -eq ''); Ms = [int]$timer.ElapsedMilliseconds; Note = $note }
  } catch {
    $timer.Stop()
    [pscustomobject]@{ Ok = $false; Ms = -1; Note = $_.Exception.Message }
  }
}

function Show-Result {
  param($result, $Modelo)
  $state = if ($result.Ok) { 'RESPONDE' } else { 'NO' }
  $color = if ($result.Ok) { 'Green' } else { 'Red' }
  $latency = if ($result.Ms -ge 0) { "$($result.Ms) ms" } else { '-' }
  Write-Host ("  {0,-40} {1,-9} {2,-10} {3}" -f $Modelo, $state, $latency, $result.Note) -ForegroundColor $color
  if ($result.Ok) { $script:latencies += [pscustomobject]@{ Modelo = $Modelo; Ms = $result.Ms } }
}

$script:latencies = @()

if ($Comprobar) {
  Write-Host "Comprobando un modelo..."
  # El resultado se guarda. Antes se llamaba a Probe-Model dos veces, una para mostrar y
  # otra para el exit: la sonda se repetia y todo esperaba el doble para nada.
  $result = Probe-Model -Modelo $Comprobar
  Show-Result $result $Comprobar
  if (-not $result.Ok) { exit 1 }
  exit 0
}

if ($Elegir) {
  Write-Host "Eligendo modelo en orden. Se para en el primero que responda..."
  foreach ($m in $Elegir) {
    $result = Probe-Model -Modelo $m
    Show-Result $result $m
    if ($result.Ok) {
      Write-Host ""
      Write-Host "ELEGIDO: $m" -ForegroundColor Green
      Write-Host "para asignar desde un script: `$modelo = `"$m`"" -ForegroundColor DarkGray
      # Sale 0 y deja el nombre en stdout por si alguien lo quiere capturar
      Write-Output $m
      exit 0
    }
  }
  Write-Host ""
  Write-Host "NINGUNO DE LOS $($Elegir.Count) MODELOS RESPONDE." -ForegroundColor Red
  Write-Host "No se lanza nada. Comprueba la cuota y el estado del proveedor." -ForegroundColor Red
  exit 1
}

if ($Todos) {
  Write-Host "Comprobando los $($catalog.Count) modelos configurados, uno a uno..."
  Write-Host "  (orden del catalogo, no de preferencia)" -ForegroundColor DarkGray
  Write-Host ""
  foreach ($m in $catalog) { Show-Result (Probe-Model -Modelo $m) $m }
  Write-Host ""
  $alive = @($script:latencies).Count
  Write-Host ("responden {0} de {1}" -f $alive, $catalog.Count) -ForegroundColor Cyan
  if ($alive -gt 0) {
    Write-Host ""
    Write-Host "Los tres mas rapidos de esta pasada (dato de esta ejecucion, no un ranking):" -ForegroundColor Cyan
    $script:latencies | Sort-Object Ms | Select-Object -First 3 | ForEach-Object {
      Write-Host ("  {0,-40} {1} ms" -f $_.Modelo, $_.Ms) -ForegroundColor DarkGray
    }
  }
  if ($alive -eq 0) { exit 1 }
  exit 0
}
