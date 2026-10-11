<#
.SYNOPSIS
  Comprueba si un modelo responde AHORA, y elige el primero que lo haga.

.DESCRIPTION
  Es la mitad que faltaba del watchdog. El watchdog vigila DURANTE el trabajo; esto
  decide ANTES de lanzar. No hay ranking ni columna de disponibilidad en documentos:
  la disponibilidad se pregunta en el momento de usarla, y esto es la pregunta.

  NO HAY UMBRALES AQUI. Ni tope de espera, ni memoria de resultado, ni ventana de
  paralelismo. Los tres se propusieron en su dia y los tres eran invencion: no habia
  medida que los sostuviera. Principio 10 de CONSTITUTION.md. Si se quieren, se
  miden primero.

.PARAMETER Elegir
  Lista de modelos en orden de preferencia. Devuelve el primero que responde.

.PARAMETER Comprobar
  Un solo modelo. Pregunta si o no.

.PARAMETER Todos
  Los 18 modelos configurados, uno a uno.

.PARAMETER TopeSegundos
  Segundos antes de dar un modelo por muerto. 0 = sin tope. Sin valor por defecto a
  proposito: no hay medicion de la latencia de sonda. Pasalo tu y di de donde sale.

.PARAMETER Binario
  Ruta al opencode-cli.exe. No esta en el PATH del shell.

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
  [int]$TopeSegundos = 0,
  [string]$Binario = "C:\Users\Pablo\AppData\Local\opencode\opencode-cli.exe"
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Binario)) { Write-Error "No encuentro el binario en $Binario"; exit 1 }

# Desde la linea de comandos, `-Elegir a,b,c` llega como UNA cadena. Se parte por comas
# para que funcione igual que `-Elegir a b c`.
if ($Elegir) { $Elegir = @($Elegir -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) }

if (-not $Elegir -and -not $Comprobar -and -not $Todos) {
  Write-Host "Uso: modelos.ps1 -Elegir <modelos...> | -Comprobar <modelo> | -Todos"
  Write-Host "     [-TopeSegundos n]   n=0 significa sin tope (por defecto)"
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

  $argLine = "run -m `"$Modelo`" --format json ok"
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $Binario
  $psi.Arguments = $argLine
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.UseShellExecute = $false
  $psi.CreateNoWindow = $true

  $timer = [System.Diagnostics.Stopwatch]::StartNew()
  try {
    $proc = [System.Diagnostics.Process]::Start($psi)
    if ($TopeSegundos -gt 0) {
      if (-not $proc.WaitForExit($TopeSegundos * 1000)) {
        try { $proc.Kill() } catch { }
        $timer.Stop()
        return [pscustomobject]@{ Ok = $false; Ms = -1; Note = 'tope agotado' }
      }
    } else {
      $proc.WaitForExit()
    }
    $timer.Stop()
    $stdout = $proc.StandardOutput.ReadToEnd()
    $stderr = $proc.StandardError.ReadToEnd()
    $exitCode = $proc.ExitCode
    $note = ''
    if ($stdout -match '"type"\s*:\s*"error"') { $note = 'error en la respuesta' }
    elseif ($stderr -match 'no disponible|not available|unavailable|Insufficient balance') {
      $note = ($stderr -split "`n" | Where-Object { $_ -match 'no disponible|not available|unavailable|Insufficient balance' } | Select-Object -First 1).Trim()
    }
    elseif ($exitCode -ne 0) { $note = "codigo de salida $exitCode" }
    [pscustomobject]@{ Ok = ($exitCode -eq 0 -and $note -eq ''); Ms = [int]$timer.ElapsedMilliseconds; Note = $note }
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
  Show-Result (Probe-Model -Modelo $Comprobar) $Comprobar
  if (-not (Probe-Model -Modelo $Comprobar).Ok) { exit 1 }
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
