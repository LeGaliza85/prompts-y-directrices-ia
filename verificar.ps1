param([string]$Ruta = ".")

# Verificador de documentos: detecta lo que la relectura visual no caza.
#   1. Caracteres cirilicos / CJK / reemplazo - tipografia colada en texto espanol.
#   2. Puntuacion CJK (comas, comillas de ancho completo) - casi siempre corruptas.
#   3. Palabras inglesas - fallos de generacion que no son de codificacion.
#
# Uso:  powershell -File verificar.ps1
#       powershell -File verificar.ps1 -Ruta plantilla
#
# Comprueba TODO el repositorio por defecto, no solo directrices/.

$ErrorActionPreference = 'Stop'
$raiz = (Resolve-Path $Ruta).Path
$patrones = [ordered]@{
  'cirilico/CJK' = '[\u0400-\u04FF\u4E00-\u9FFF\uFFFD]'
  'puntuacion CJK' = '[\u3000-\u303F\uFF00-\uFFEF]'
  'palabra inglesa' = '\b(the|and|with|this|that|from|have|about|should|would|there|their|when|then|only|more|what|which|will|been)\b'
}

# Los ejemplos documentados de erroresusan estos caracteres a proposito.
# Se listan aqui para no marcarlos como fallo.
$excepciones = @(
  'directrices\aprendido.md'
)

$fallos = 0
# node_modules no es nuestro: son README de terceros en inglés. Recorrerlos solo produce
# falsos positivos que hacen ignorable el informe.
$archivos = Get-ChildItem -Path $raiz -Recurse -Include *.md -File |
  Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\node_modules\\' }

foreach ($f in $archivos) {
  $lineas = [System.IO.File]::ReadAllLines($f.FullName, [System.Text.Encoding]::UTF8)
  $relativo = $f.FullName.Replace($raiz + [System.IO.Path]::DirectorySeparatorChar, '')
  $enBloqueCodigo = $false
  for ($i = 0; $i -lt $lineas.Count; $i++) {
    $linea = $lineas[$i]

    # Los bloques de codigo son ejemplos: su contenido puede ser JavaScript, YAML o
    # PowerShell con palabras reservadas en ingles que son correctas ahi. Comprobar
    # ingles dentro de ellos produce falsos positivos que acaban ignorando el informe.
    if ($linea -match '^\s*(```|~~~)') {
      $enBloqueCodigo = -not $enBloqueCodigo
      continue
    }
    if ($enBloqueCodigo) { continue }

    foreach ($nombre in $patrones.Keys) {
      if ($linea -match $patrones[$nombre]) {
        Write-Host ("  [{0}] {1}:{2}" -f $nombre, $relativo, ($i + 1))
        Write-Host ("      {0}" -f $linea.Trim())
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
  Write-Host "Si alguna incidencia es un ejemplo documentado en aprendido.md, anadela a excepciones."
  exit 1
}
