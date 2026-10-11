param([string]$Ruta = ".")

# Verificador de documentos: detecta lo que la relectura visual no caza.
#   1. Caracteres cirilicos / CJK / reemplazo - tipografia colada en text espanol.
#   2. Puntuacion CJK (comas, comillas de ancho completo) - casi siempre corruptas.
#   3. Palabras inglesas - failures de generacion que no son de codificacion.
#
# Uso:  powershell -File verificar.ps1
#       powershell -File verificar.ps1 -Ruta plantilla
#
# Comprueba TODO el repositorio por defecto, no solo directrices/.

$ErrorActionPreference = 'Stop'
$raiz = (Resolve-Path $Ruta).Path
$patterns = [ordered]@{
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

$failures = 0
# node_modules no es nuestro: son README de terceros en inglés. Recorrerlos solo produce
# falsos positivos que hacen ignorable el informe.
$files = Get-ChildItem -Path $raiz -Recurse -Include *.md -File |
  Where-Object { $_.FullName -notmatch '\\\.git\\' -and $_.FullName -notmatch '\\node_modules\\' }

$regexes = @{}
foreach ($checkName in $patterns.Keys) {
  # CaseSensitive es obligatorio para el patron de palabra mezclada: sin el, [a-z] y
  # [A-Z] son la misma clase en PowerShell y el patron marca cualquier palabra.
  # Se compila con [regex] en vez de usar -match porque -match no admite opciones por
  # parametro, y aqui hacen falta.
  $caseSensitive = if ($checkName -eq 'palabra mezclada') {
    [System.Text.RegularExpressions.RegexOptions]::None
  } else {
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
  }
  $regexes[$checkName] = New-Object System.Text.RegularExpressions.Regex($patterns[$checkName], $caseSensitive)
}

foreach ($f in $files) {
  $lines = [System.IO.File]::ReadAllLines($f.FullName, [System.Text.Encoding]::UTF8)
  $relative = $f.FullName.Replace($raiz + [System.IO.Path]::DirectorySeparatorChar, '')
  $inCodeBlock = $false
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]

    # Los bloques de codigo son ejemplos: su contenido puede ser JavaScript, YAML o
    # PowerShell con palabras reservadas en ingles que son correctas ahi. Comprobar
    # ingles dentro de ellos produce falsos positivos que acaban ignorando el informe.
    if ($line -match '^\s*(```|~~~)') {
      $inCodeBlock = -not $inCodeBlock
      continue
    }
    if ($inCodeBlock) { continue }

    # El codigo en line (`modelID=...`) no es text: camelCase ahi es correcto.
    # Comprobarlo daba falsos positivos. Se quita antes de mirar.
    $withoutInlineCode = [regex]::Replace($line, '`[^`\r\n]*`', ' ')
    foreach ($checkName in $patterns.Keys) {
      if ($regexes[$checkName].IsMatch($withoutInlineCode)) {
        Write-Host ("  [{0}] {1}:{2}" -f $checkName, $relative, ($i + 1))
        Write-Host ("      {0}" -f $line.Trim())
        $failures++
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

foreach ($f in $files) {
  $lines = [System.IO.File]::ReadAllLines($f.FullName, [System.Text.Encoding]::UTF8)
  $relative = $f.FullName.Replace($raiz + [System.IO.Path]::DirectorySeparatorChar, '')

  # 1. Comillas angulares desbalanceadas.
  # Se cuenta por ARCHIVO y no por line a proposito: una cita abierta al final de una
  # line y cerrada en la siguiente es correcta, y contarla por line la marca como
  # suelta. Eight casos reales de este repo tenian la cita partida entre lines.
  $enBloque = $false
  $openQuotes = 0; $closeQuotes = 0
  $paragraphs = New-Object System.Collections.Generic.List[string]
  $current = ''
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match '^\s*(```|~~~)') { $enBloque = -not $enBloque; continue }
    if ($enBloque) { continue }

      $openQuotes += ([regex]::Matches($line, [regex]::Escape([string]$apertura))).Count
      $closeQuotes += ([regex]::Matches($line, [regex]::Escape([string]$cierre))).Count

    # 3. Parrafos duplicados. Se juntan las lines antes de comparar porque el mismo
    # parrafo puede estar partido en puntos distintos en dos sitios, y comparando
    # lines sueltas no se ve que son el mismo text.
    if ($line.Trim() -eq '') {
      if ($current.Length -ge 120) { $paragraphs.Add($current) }
      $current = ''
    } else {
      $current += ' ' + $line.Trim()
    }
  }
  if ($current.Length -ge 120) { $paragraphs.Add($current) }

  if ($openQuotes -ne $closeQuotes) {
    Write-Host ("  [comillas sin cerrar] {0}: {1} apertura y {2} cierre" -f $relative, $openQuotes, $closeQuotes) -ForegroundColor Yellow
    $failures++
  }

  $seenParas = @{}
  foreach ($p in $paragraphs) {
      $normalized = [regex]::Replace($p, '\s+', ' ')
    if ($normalized -match '^\s*[#|]' -or $normalized -match '^\s*[-*]\s') { continue }
    if ($seenParas.ContainsKey($normalized)) {
      Write-Host ("  [parrafo duplicado] {0}" -f $relative) -ForegroundColor Yellow
      Write-Host ("      {0}" -f $normalized.Substring(0, [Math]::Min(90, $normalized.Length)))
      $failures++
      break
    }
    $seenParas[$normalized] = $true
  }

  # 2. Rutas entre acentos graves que no existen.
  #
  # La primera version daba 40 falsos positivos y hay que entender por que. Un checkName
  # suelto como `tasks.md` en prosa casi nunca significa "un fichero aqui": significa
  # "el tasks.md de tu proyecto". Comprobarlo contra esta carpeta da error siempre.
  #
  # Por eso hay dos reglas, no una:
  #   - Con barra: es una ruta de ESTE repo. Se resuelve y tiene que existir.
  #   - Sin barra: se busca ese checkName en todo el repo. Si aparece en cualquier sitio,
  #     la referencia es valida. Solo se avisa si no existe en ninguna parte.
  # Se omiten plantilla/, historial/ y curso/: describen la estructura de otro proyecto.
  if ($relative -notmatch '^(plantilla|historial|curso)\\' -and $relative -notmatch '\\.agents\\') {
    $text = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    foreach ($m in [regex]::Matches($text, '`([A-Za-z0-9_\.\\/\-]+\.(?:md|ps1|js|json|jsonc))`')) {
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
        Write-Host ("  [ruta inexistente] {0}: {1}" -f $relative, $p) -ForegroundColor Yellow
        $failures++
      }
    }
  }
}

# 4. Cifras desincronizadas. Tres documentos dar tres numeros distintos para el mismo
# hecho (17, 20 y 21) es lo que paso. Se comprueba contra el recuento real.
$directiveCount = (Get-ChildItem (Join-Path $raiz 'directrices') -Filter *.md -File -ErrorAction SilentlyContinue).Count
$markdownCount = $files.Count
foreach ($doc in @('AGENTS.md', 'INDICE.md', 'PROXIMA-SESION.md')) {
  $docPath = Join-Path $raiz $doc
  if (-not (Test-Path $docPath)) { continue }
  $docLines = [System.IO.File]::ReadAllLines($docPath, [System.Text.Encoding]::UTF8)
  for ($i = 0; $i -lt $docLines.Count; $i++) {
    if ($docLines[$i] -match 'curso|origen|plantilla') { continue }
    foreach ($m in [regex]::Matches($docLines[$i], '(\d+)\s+documentos')) {
      if ([int]$m.Groups[1].Value -ne $directiveCount) {
        Write-Host ("  [cifra] {0}:{1} dice {2} documentos; hay {3}" -f $doc, ($i + 1), $m.Groups[1].Value, $directiveCount) -ForegroundColor Yellow
        $failures++
      }
    }
    foreach ($m in [regex]::Matches($docLines[$i], '(\d+)\s+archivos')) {
      if ([int]$m.Groups[1].Value -ne $markdownCount) {
        Write-Host ("  [cifra] {0}:{1} dice {2} archivos; hay {3}" -f $doc, ($i + 1), $m.Groups[1].Value, $markdownCount) -ForegroundColor Yellow
        $failures++
      }
    }
  }
}

Write-Host ''
if ($failures -eq 0) {
  Write-Host ("OK - {0} archivos, sin incidencias" -f $files.Count)
} else {
  Write-Host ("{0} incidencias en {1} archivos" -f $failures, $files.Count)
  Write-Host ''
  Write-Host "Si una incidencia es legitima, el problema no es el script: es el texto." -ForegroundColor DarkGray
  Write-Host "Si es un falso positivo, mira el patron que la produjo, en las lineas 14-24." -ForegroundColor DarkGray
  exit 1
}
