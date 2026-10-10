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
  'kanji' = '[\u4E00-\u9FFF]'
  'hiragana/katakana' = '[\u3040-\u30FF]'
  'palabra inglesa' = '\b(the|and|with|this|that|from|have|about|should|would|there|their|when|then|only|more|what|which|will|been)\b'
  # Basura pegada DENTRO de una palabra: "ideasPJ", "alguienKJ".
  # CaseSensitive es obligatorio: PowerShell hace las comparaciones sin distinguir mayusculas,
  # asi que [a-z] y [A-Z] son lo mismo y el patron marca cualquier palabra.
  'palabra mezclada' = '\b[a-z]{3,}[A-Z]{2,}([a-z]{2,})?\b'
}

$fallos = 0
# node_modules no es nuestro: son README de terceros en inglés. Recorrerlos solo produce
# falsos positivos que hacen ignorable el informe.
$archivos = Get-ChildItem -Path $raiz -Recurse -Include *.md -File |
  Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\node_modules\\' }

$regex = @{}
foreach ($nombre in $patrones.Keys) {
  # CaseSensitive es obligatorio para el patron de palabra mezclada: sin el, [a-z] y
  # [A-Z] son la misma clase en PowerShell y el patron marca cualquier palabra.
  # Se compila con [regex] en vez de usar -match porque -match no admite opciones por
  # parametro, y aqui hacen falta.
  $cs = if ($nombre -eq 'palabra mezclada') {
    [System.Text.RegularExpressions.RegexOptions]::None
  } else {
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
  }
  $regex[$nombre] = New-Object System.Text.RegularExpressions.Regex($patrones[$nombre], $cs)
}

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

    # El codigo en linea (`modelID=...`) no es texto: camelCase ahi es correcto.
    # Comprobarlo daba falsos positivos. Se quita antes de mirar.
    $sinCodigo = [regex]::Replace($linea, '`[^`\r\n]*`', ' ')
    foreach ($nombre in $patrones.Keys) {
      if ($regex[$nombre].IsMatch($sinCodigo)) {
        Write-Host ("  [{0}] {1}:{2}" -f $nombre, $relativo, ($i + 1))
        Write-Host ("      {0}" -f $linea.Trim())
        $fallos++
      }
    }
  }
}

# --- Comprobaciones estructurales --------------------------------------------
# Las cuatro de aqui nacieron de errores reales encontrados a mano. Automatizar lo
# que ya se busca con la vista evita depender de que alguien se acuerde.

$apertura = [char]0x00AB
$cierre = [char]0x00BB

# Nombres de fichero que existen en el repo, para resolver referencias sueltas.
$todosLosNombres = @(Get-ChildItem $raiz -Recurse -File -ErrorAction SilentlyContinue |
  Where-Object { $_.FullName -notmatch '\\\.git\\' } | ForEach-Object { $_.Name } | Sort-Object -Unique)

# Nombres que NO estan en el repo y no deben marcarse: son ficheros de OTROS
# proyectos. PORTABILIDAD.md habla de traducir esto a Claude Code, y ahi existen
# CLAUDE.md y CONVENTIONS.md. Tambien lo que el script genera fuera del repo.
$nombresAjenos = @(
  'CLAUDE.md', 'CLAUDE.local.md', 'CONVENTIONS.md', 'COMMIT.md', 'AGENTS.local.md',
  'package.json', 'package-lock.json', 'tsconfig.json', 'go.mod', 'Cargo.toml',
  'algo.md', 'FICHA.md', 'watchdog-registro.md', 'opencode.log'
)

foreach ($f in $archivos) {
  $lineas = [System.IO.File]::ReadAllLines($f.FullName, [System.Text.Encoding]::UTF8)
  $relativo = $f.FullName.Replace($raiz + [System.IO.Path]::DirectorySeparatorChar, '')

  # 1. Comillas angulares desbalanceadas.
  # Se cuenta por ARCHIVO y no por linea a proposito: una cita abierta al final de una
  # linea y cerrada en la siguiente es correcta, y contarla por linea la marca como
  # suelta. Eight casos reales de este repo tenian la cita partida entre lineas.
  $enBloque = $false
  $abiertas = 0; $cerradas = 0
  $parrafos = New-Object System.Collections.Generic.List[string]
  $actual = ''
  for ($i = 0; $i -lt $lineas.Count; $i++) {
    $linea = $lineas[$i]
    if ($linea -match '^\s*(```|~~~)') { $enBloque = -not $enBloque; continue }
    if ($enBloque) { continue }

    $abiertas += ([regex]::Matches($linea, [regex]::Escape([string]$apertura))).Count
    $cerradas += ([regex]::Matches($linea, [regex]::Escape([string]$cierre))).Count

    # 3. Parrafos duplicados. Se juntan las lineas antes de comparar porque el mismo
    # parrafo puede estar partido en puntos distintos en dos sitios, y comparando
    # lineas sueltas no se ve que son el mismo texto.
    if ($linea.Trim() -eq '') {
      if ($actual.Length -ge 120) { $parrafos.Add($actual) }
      $actual = ''
    } else {
      $actual += ' ' + $linea.Trim()
    }
  }
  if ($actual.Length -ge 120) { $parrafos.Add($actual) }

  if ($abiertas -ne $cerradas) {
    Write-Host ("  [comillas sin cerrar] {0}: {1} apertura y {2} cierre" -f $relativo, $abiertas, $cerradas) -ForegroundColor Yellow
    $fallos++
  }

  $vistos = @{}
  foreach ($p in $parrafos) {
    $norm = [regex]::Replace($p, '\s+', ' ')
    if ($norm -match '^\s*[#|]' -or $norm -match '^\s*[-*]\s') { continue }
    if ($vistos.ContainsKey($norm)) {
      Write-Host ("  [parrafo duplicado] {0}" -f $relativo) -ForegroundColor Yellow
      Write-Host ("      {0}" -f $norm.Substring(0, [Math]::Min(90, $norm.Length)))
      $fallos++
      break
    }
    $vistos[$norm] = $true
  }

  # 2. Rutas entre acentos graves que no existen.
  #
  # La primera version daba 40 falsos positivos y hay que entender por que. Un nombre
  # suelto como `tasks.md` en prosa casi nunca significa "un fichero aqui": significa
  # "el tasks.md de tu proyecto". Comprobarlo contra esta carpeta da error siempre.
  #
  # Por eso hay dos reglas, no una:
  #   - Con barra: es una ruta de ESTE repo. Se resuelve y tiene que existir.
  #   - Sin barra: se busca ese nombre en todo el repo. Si aparece en cualquier sitio,
  #     la referencia es valida. Solo se avisa si no existe en ninguna parte.
  # Se omiten plantilla/, historial/ y curso/: describen la estructura de otro proyecto.
  if ($relativo -notmatch '^(plantilla|historial|curso)\\' -and $relativo -notmatch '\\.agents\\') {
    $texto = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    foreach ($m in [regex]::Matches($texto, '`([A-Za-z0-9_\.\\/\-]+\.(?:md|ps1|js|json|jsonc))`')) {
      $p = $m.Groups[1].Value
      if ($p -match '<' -or $p -match '^(docs/|src/|node_modules)') { continue }

      if ($p -match '\\' -or $p -match '/') {
        $rel = $p -replace '/', '\'
        # Se prueba en la raiz, en la carpeta del propio fichero y en plantilla/:
        # la skill vive en plantilla/ y PORTABILIDAD.md la cita por su ruta final.
        $ok = (Test-Path (Join-Path $raiz $rel)) -or
              (Test-Path (Join-Path $f.DirectoryName $rel)) -or
              (Test-Path (Join-Path (Join-Path $raiz 'plantilla') $rel))
      } else {
        $base = [System.IO.Path]::GetFileName($p)
        $ok = ($todosLosNombres -contains $base) -or ($nombresAjenos -contains $base)
      }

      if (-not $ok) {
        Write-Host ("  [ruta inexistente] {0}: {1}" -f $relativo, $p) -ForegroundColor Yellow
        $fallos++
      }
    }
  }
}

# 4. Cifras desincronizadas. Tres documentos dar tres numeros distintos para el mismo
# hecho (17, 20 y 21) es lo que paso. Se comprueba contra el recuento real.
$nDirectrices = (Get-ChildItem (Join-Path $raiz 'directrices') -Filter *.md -File -ErrorAction SilentlyContinue).Count
$nMarkdown = $archivos.Count
foreach ($doc in @('AGENTS.md', 'INDICE.md', 'PROXIMA-SESION.md')) {
  $rutaDoc = Join-Path $raiz $doc
  if (-not (Test-Path $rutaDoc)) { continue }
  $dl = [System.IO.File]::ReadAllLines($rutaDoc, [System.Text.Encoding]::UTF8)
  for ($i = 0; $i -lt $dl.Count; $i++) {
    if ($dl[$i] -match 'curso|origen|plantilla') { continue }
    foreach ($m in [regex]::Matches($dl[$i], '(\d+)\s+documentos')) {
      if ([int]$m.Groups[1].Value -ne $nDirectrices) {
        Write-Host ("  [cifra] {0}:{1} dice {2} documentos; hay {3}" -f $doc, ($i + 1), $m.Groups[1].Value, $nDirectrices) -ForegroundColor Yellow
        $fallos++
      }
    }
    foreach ($m in [regex]::Matches($dl[$i], '(\d+)\s+archivos')) {
      if ([int]$m.Groups[1].Value -ne $nMarkdown) {
        Write-Host ("  [cifra] {0}:{1} dice {2} archivos; hay {3}" -f $doc, ($i + 1), $m.Groups[1].Value, $nMarkdown) -ForegroundColor Yellow
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
  Write-Host ''
  Write-Host "Si una incidencia es legitima, el problema no es el script: es el texto." -ForegroundColor DarkGray
  Write-Host "Si es un falso positivo, mira el patron que la produjo, en las lineas 14-24." -ForegroundColor DarkGray
  exit 1
}
