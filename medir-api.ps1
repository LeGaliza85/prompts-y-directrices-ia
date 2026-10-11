param(
  [string]$Servidor = "http://127.0.0.1:4096",
  [switch]$Json
)

# Mide como de larga dura cada tipo de herramienta, leyendo la API de OpenCode y no el
# log. El objetivo es NO escribir umbrales de memoria: se miden y se anotan.
#
# Por que desde la API y no desde el log: el log no sabe cuando empezo una llamada que
# nunca termino. La API si: cada parte de herramienta lleva state.time.start y, si sigue
# en marcha, state.time.end vacio.
#
# Uso:
#   powershell -File medir-api.ps1
#   powershell -File medir-api.ps1 -Json

$ErrorActionPreference = 'Stop'

function Invoke-Api {
  param([string]$Ruta, [string]$Metodo = 'GET', $Cuerpo = $null)
  $p = @{ Uri = "$Servidor$Ruta"; Method = $Metodo; TimeoutSec = 120 }
  if ($Cuerpo) { $p.Body = $Cuerpo; $p.ContentType = 'application/json' }
  Invoke-RestMethod @p
}

$medicion = @{
  servidor   = $Servidor
  fecha      = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
  sesiones   = 0
  herramientas = 0
  porTool    = @{}
  anomalias  = @()
}

# OJO, y esto costó una hora: @(Invoke-Api '/session') devuelve UN elemento que es el
# array entero, no 59 elementos. En cambio `$x = Invoke-Api ...` devuelve los 59. El
# operador @() no aplana lo que devuelve una función; la asignación sí. Por eso aquí
# SIEMPRE se asigna primero y se envuelve después. Está explicado en los dos sitios en
# los que se hace.
$sessionsCrudas = Invoke-Api '/session'
$sessions = @($sessionsCrudas)
$medicion.sesiones = $sessions.Count

foreach ($s in $sessions) {
  if (-not $s.id) { continue }
  $msgsCrudas = $null
  try { $msgsCrudas = Invoke-Api "/session/$($s.id)/message" } catch { continue }
  $msgs = @($msgsCrudas)
  if ($msgs.Count -eq 0) { continue }

  $medicion.herramientas += (@($msgs | ForEach-Object { $_.parts } | Where-Object { $_.type -eq 'tool' })).Count

  # Herramientas terminadas: duración medible.
  foreach ($t in ($msgs | ForEach-Object { $_.parts } | Where-Object { $_.type -eq 'tool' -and $_.state.time.end })) {
    $seg = [double](($t.state.time.end - $t.state.time.start) / 1000)
    if (-not $medicion.porTool.ContainsKey($t.tool)) { $medicion.porTool[$t.tool] = New-Object System.Collections.Generic.List[double] }
    $medicion.porTool[$t.tool].Add($seg)
  }

  # Herramientas sin fin: si llevan mucho, la sesión está colgada AHORA.
  foreach ($t in ($msgs | ForEach-Object { $_.parts } | Where-Object { $_.type -eq 'tool' -and -not $_.state.time.end })) {
    $desde = [int](((Get-Date).ToUniversalTime() - [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$t.state.time.start).UtcDateTime).TotalSeconds)
    $medicion.anomalias += [pscustomobject]@{
      sesion = $s.id; tool = $t.tool; estado = $t.state.status
      segundos = $desde; titulo = $t.state.title
    }
  }
}

if ($Json) { $medicion | ConvertTo-Json -Depth 6; exit 0 }

Write-Host ''
Write-Host "Medición de duraciones desde $Servidor" -ForegroundColor Cyan
Write-Host ("Fecha: {0}   Sesiones: {1}   Herramientas: {2}" -f $medicion.fecha, $medicion.sesiones, $medicion.herramientas) -ForegroundColor DarkGray
Write-Host ''
Write-Host 'Herramienta    n      p50      p90      p99      max' -ForegroundColor DarkGray
Write-Host '-------------------------------------------------------------' -ForegroundColor DarkGray

$resumen = @()
foreach ($k in ($medicion.porTool.Keys | Sort-Object)) {
  $d = @($medicion.porTool[$k] | Sort-Object)
  if ($d.Count -eq 0) { continue }
  $p50 = [int]$d[[int][math]::Floor(($d.Count - 1) * 0.5)]
  $p90 = [int]$d[[int][math]::Floor(($d.Count - 1) * 0.9)]
  $p99 = [int]$d[[int][math]::Floor(($d.Count - 1) * 0.99)]
  $resumen += [pscustomobject]@{ tool = $k; n = $d.Count; p50 = $p50; p90 = $p90; p99 = $p99; max = [int]$d[-1] }
}
$resumen | Format-Table -AutoSize | Out-String | Write-Host

Write-Host 'Anomalías: herramientas sin fin ahora mismo' -ForegroundColor DarkGray
if ($medicion.anomalias.Count -eq 0) {
  Write-Host '  ninguna' -ForegroundColor DarkGray
} else {
  $medicion.anomalias | ForEach-Object {
    Write-Host ("  {0,-42} {1,-10} {2,6} s  {3}" -f $_.sesion, $_.tool, $_.segundos, $_.titulo) -ForegroundColor Yellow
  }
}
