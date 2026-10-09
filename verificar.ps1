param([string]$Ruta = "directrices")

# Verificador de documentos: detecta lo que la relectura visual no caza.
#   1. Caracteres cirílicos / CJK / reemplazo — tipografía colada en texto español.
#   2. Puntuación CJK (comas, comillas de ancho completo) — casi siempre corruptas.
#   3. Palabras inglesas — fallos de generación que no son de codificación.
#
# Uso:  powershell -File verificar.ps1
#       powershell -File verificar.ps1 -Ruta plantilla

$ErrorActionPreference = 'Stop'
$raiz = Resolve-Path $Ruta
$patrones = @{
  'cirilico/CJK' = '[\u0400-\u04FF\u4E00-\u9FFF\uFFFD]'
  'puntuacion CJK' = '[\u3000-\u303F\uFF00-\uFFEF]'
  'palabra inglesa' = '\b(the|and|with|this|that|from|have|about|should|would|there|their|when|then|only|more|what|which|will|been)\b'
}

$fallos = 0
$archivos = Get-ChildItem -Path $raiz -Recurse -Filter *.md

foreach ($f in $archivos) {
  $lineas = [System.IO.File]::ReadAllLines($f.FullName, [System.Text.Encoding]::UTF8)
  foreach ($nombre in $patrones.Keys) {
    for ($i = 0; $i -lt $lineas.Count; $i++) {
      if ($lineas[$i] -match $patrones[$nombre]) {
        Write-Host ("  [{0}] {1}:{2}" -f $nombre, $f.Name, ($i + 1))
        Write-Host ("      {0}" -f $lineas[$i].Trim())
        $fallos++
      }
    }
  }
}

Write-Host ''
if ($fallos -eq 0) {
  Write-Host ("OK - {0} archivos, sin incidencias" -f $archivos.Count)
} else {
  Write-Host ("{0} incidencias en {1} archivos" -f $fallos, $archivos.Count)
  exit 1
}
