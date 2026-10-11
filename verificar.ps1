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

# --- Idioma del documento ---------------------------------------------------
# Por que esto existe: este script se usaba en cualquier proyecto y solo entendia
# espanol. En un documento en ingles marcaba cada frase ("the", "and", "with") y
# nunca comprobaba las comillas, que en espanol son << >> y en ingles son dobles.
#
# La deteccion NO usa un porcentaje ni un umbral: usa dos listas de palabras
# funcionales que no existen en el otro idioma y gana la que tenga mas tipos
# distintos. Empate, includedo cero contra cero, es "no lo se" y se avisa. Un
# archivo del que no se puede inferir el idioma NO se da por bueno en silencio:
# se cuenta aparte y se dice en el resumen. Esa es la parte importante.
$stopEs = @('del','los','las','una','unos','unas','para','por','con','que','como','pero',
  'esto','esta','estos','estas','aquí','ahí','donde','cuando','porque','desde','hasta',
  'sobre','entre','sus','nuestro','ser','está','están','hay','muy','todo','todos','otra',
  'otro','mismo','cada','sin','bajo','tras','según','mediante','mientras','después','antes')
# Las dos listas son DISJUNTAS a proposito: se descartan las palabras que existen en
# los dos idiomas (a, no, so, as, to, in, on, at, or, is, be, it, of, if, an, by, up, out).
# Usar palabras compartidas daria certidumbre falsa en documentos mixtos.
$stopEn = @('the','and','with','this','that','from','have','about','should','would','there',
  'their','when','then','only','more','what','which','will','been','these','those','where',
  'while','other','another','because','must','could','into','over','after','before',
  'through','being','does','done','than','them','they','your','yours','their','itself')

function Get-DocLanguage([string[]]$Lines) {
  $text = ($Lines -join ' ')
  $text = [regex]::Replace($text, '`[^`]*`', ' ')          # codigo en linea
  $text = [regex]::Replace($text, 'https?://\S+', ' ')      # URLs
  $words = [regex]::Matches($text.ToLower(), "[a-záéíóúñü']+") | ForEach-Object { $_.Value }
  $distinct = @{}
  foreach ($w in $words) { $distinct[$w] = $true }
  $nEs = @($stopEs | Where-Object { $distinct.ContainsKey($_) }).Count
  $nEn = @($stopEn | Where-Object { $distinct.ContainsKey($_) }).Count
  if ($nEs -gt $nEn) { return 'es' }
  if ($nEn -gt $nEs) { return 'en' }
  return '?'
}

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

# Comprobaciones que solo tienen sentido en un idioma. La clave es el idioma exigido.
# Si el documento esta en otro idioma, la comprobacion se OMITE y no se cuenta como fallo:
# marcar un documento ingles por sus palabras inglesas era el falso positivo que motivo esto.
$soloEnIdioma = @{
  'palabra inglesa' = 'es'
}

$failures = 0
# Cobertura por idioma. Se informa al final porque un archivo que no se pudo clasificar
# es un archivo al que NO se le comprobo la regla de palabras inglesas ni las comillas
# de su idioma. Callarselo seria repetir el fallo que motivo este cambio.
$conteoEs = 0; $conteoEn = 0; $conteoDesconocido = 0
$dirLangEs = @(); $dirLangEn = @(); $dirLangDesconocido = @()
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
  $lang = Get-DocLanguage $lines
  switch ($lang) {
    'es' { $conteoEs++; $dirLangEs += $relative }
    'en' { $conteoEn++; $dirLangEn += $relative }
    default { $conteoDesconocido++; $dirLangDesconocido += $relative }
  }
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
      # Comprobaciones ligadas a un idioma: solo si el documento esta en ese idioma.
      if ($soloEnIdioma.ContainsKey($checkName)) {
        if ($lang -ne $soloEnIdioma[$checkName]) { continue }
      }
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

# Pares de comillas por idioma. Solo se comprueba el par del idioma del documento:
# buscar << >> en un texto ingles da siempre cero y cero, que parece "correcto" sin
# haber comprobado nada. Eso era exactamente lo que pasaba antes.
#
# El ingles admite DOS pares y se comprueban los dos: las tipograficas son las correctas
# en un documento bien compuesto, pero las rectas son las que se escriben a machine y
# en Markdown corriente. Comprobar solo las tipograficas deja pasar un texto entero
# mal entrecerrado: es lo que paso en la primera version de esto.
$quotePairs = @{
  'es' = @(
    @{ Open = [char]0x00AB; Close = [char]0x00BB; Name = 'angulares' }
  )
  'en' = @(
    @{ Open = [char]0x201C; Close = [char]0x201D; Name = 'tipograficas' },
    @{ Open = [char]0x22;    Close = [char]0x22;    Name = 'rectas' }
  )
}

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
  if ($quotePairs.ContainsKey($lang)) { $pairs = $quotePairs[$lang] } else { $pairs = @() }
  $openQuotes = @{}; $closeQuotes = @{}

  # 1. Comillas desbalanceadas.
  # Se cuenta por ARCHIVO y no por line a proposito: una cita abierta al final de una
  # line y cerrada en la siguiente es correcta, y contarla por line la marca como
  # suelta. Eight casos reales de este repo tenian la cita partida entre lines.
  $enBloque = $false
  $paragraphs = New-Object System.Collections.Generic.List[string]
  $current = ''
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match '^\s*(```|~~~)') { $enBloque = -not $enBloque; continue }
    if ($enBloque) { continue }

    # El codigo en linea tambien brings comillas rectas que no son citas: se quitan
    # antes de contar o `el valor es "x"` marcaria un texto perfectamente correcto.
    $sinCodigo = [regex]::Replace($line, '`[^`\r\n]*`', ' ')
    foreach ($pair in $pairs) {
      $n = [regex]::Escape([string]$pair.Open)
      $c = [regex]::Escape([string]$pair.Close)
      if (-not $openQuotes.ContainsKey($pair.Name)) { $openQuotes[$pair.Name] = 0; $closeQuotes[$pair.Name] = 0 }
      $openQuotes[$pair.Name] += ([regex]::Matches($sinCodigo, $n)).Count
      $closeQuotes[$pair.Name] += ([regex]::Matches($sinCodigo, $c)).Count
    }

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

  foreach ($pair in $pairs) {
    $nOpen = $openQuotes[$pair.Name]
    $nClose = $closeQuotes[$pair.Name]
    # Dos formas de comprobar, segun el par. No es arbitrario: es lo que significa el signo.
    #
    # Par ASIMETRICO (< >, " "): se cuenta de cada lado y se comparan. Un " de mas
    # significa que falta su cierre.
    #
    # Par SIMETRICO (" "): apertura y cierre son el MISMO caracter, asi que comparar
    # los dos contadores siempre da igual y un texto con un solo " sucio pasaria como
    # correcto. Eso no lo detecto la primera version: se probo con un fichero con un
    # unico " y el script dijo que estaba bien. Para estos la unica comprobacion
    # posible es la paridad: un numero impar de comillas no puede estar emparejado.
    if ($pair.Open -eq $pair.Close) {
      $mal = ($nOpen % 2) -ne 0
      $detalle = "{0} comillas, numero impar" -f $nOpen
    } else {
      $mal = $nOpen -ne $nClose
      $detalle = "{0} apertura y {1} cierre" -f $nOpen, $nClose
    }
    if ($mal) {
      Write-Host ("  [comillas sin cerrar] {0}: comillas {1}, {2}" -f $relative, $pair.Name, $detalle) -ForegroundColor Yellow
      $failures++
    }
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
#
# Antes miraba solo tres ficheros de ESTE repo y solo las palabras castellanas, asi que
# en cualquier otro proyecto la comprobacion no se hacia: Verde por no mirar, no por
# estar bien. Ahora son tres tablas y ninguna tiene numeros de este repo metidos.
#
# Que palabra significa que cosa se deduce del nombre de la carpeta y del sentido de la
# frase, no de un numero inventado:
#
#   "23 documentos", "23 directrices" -> los .md de la carpeta directrices/ de este repo.
#   "106 archivos", "106 files"       -> todos los .md del repo.
#
# Son dos preguntas distintas y confundirlas produce falsos positivos en cadena: al
# tratar "documentos" como total, los cuatro sitios que dicen 23 documentos saltaban
# como error cuando eran correctos. Se separaron los dos grupos.
#
# Si la carpeta directrices/ no existe (un proyecto que no usa esta plantilla), el dato
# no se puede comprobar y NO se da por bueno: se cuenta y se dice en el resumen.
# Los dos patrones se construyen aqui y se usan mas abajo, uno por grupo.
$patDir = '(\d+)\s+(documentos|directivas|directrices|documents|directives)'
$patTot = '(\d+)\s+(archivos|files)'
$markdownCount = $files.Count

$countDirs = (Get-ChildItem (Join-Path $raiz 'directrices') -Filter *.md -File -ErrorAction SilentlyContinue).Count
$hayDirDirectrices = (Test-Path (Join-Path $raiz 'directrices'))

foreach ($f in $files) {
  $relative = $f.FullName.Replace($raiz + [System.IO.Path]::DirectorySeparatorChar, '')
  # Estas carpetas describen la estructura de otro proyecto: sus recuentos no son de este.
  if ($relative -match '^(plantilla|historial|curso)\\' -or $relative -match '\\.agents\\') { continue }

  $docLines = [System.IO.File]::ReadAllLines($f.FullName, [System.Text.Encoding]::UTF8)
  for ($i = 0; $i -lt $docLines.Count; $i++) {
    $linea = $docLines[$i]
    if ($linea -match 'curso|origen|plantilla') { continue }

    # Los dos grupos se comprueban con UN SOLO regex cada uno, no con un bucle por
    # palabra. Con un bucle, "archivos" y "files"-producian el mismo hallazgo dos veces
    # cuando coincidian, y el recuento de incidencias mentia. Una alternancia por grupo
    # recorre cada linea una vez por grupo.
    if ($hayDirDirectrices) {
      $patDir = '(\d+)\s+(documentos|directivas|directrices|documents|directives)'
      foreach ($m in [regex]::Matches($linea, $patDir)) {
        if ([int]$m.Groups[1].Value -ne $countDirs) {
          Write-Host ("  [cifra] {0}:{1} dice {2} {3}; hay {4}" -f $relative, ($i + 1), $m.Groups[1].Value, $m.Groups[2].Value, $countDirs) -ForegroundColor Yellow
          $failures++
        }
      }
    }
    $patTot = '(\d+)\s+(archivos|files)'
    foreach ($m in [regex]::Matches($linea, $patTot)) {
      # Si la MISMA linea nombra una carpeta concreta, el numero cuenta ESA carpeta y
      # no el repo entero. Sin esta excepcion, una tabla como
      #   | `directrices/` (23 archivos) | ... |
      # se marcaba como error (23 != 106) cuando las dos cifras eran correctas.
      # Se descarta solo si la carpeta existe de verdad: si no existe, no es una
      # referencia y el numero sigue siendo del total.
      $esDeCarpeta = $false
      foreach ($mm in [regex]::Matches($linea, '`([^`]+?)/?`')) {
        $carpeta = $mm.Groups[1].Value.TrimEnd('/')
        if ($carpeta -and (Test-Path (Join-Path $raiz $carpeta)) -and (Get-Item (Join-Path $raiz $carpeta)).PSIsContainer) {
          $esDeCarpeta = $true; break
        }
      }
      if ($esDeCarpeta) { continue }
      if ([int]$m.Groups[1].Value -ne $markdownCount) {
        Write-Host ("  [cifra] {0}:{1} dice {2} {3}; hay {4}" -f $relative, ($i + 1), $m.Groups[1].Value, $m.Groups[2].Value, $markdownCount) -ForegroundColor Yellow
        $failures++
      }
    }
    # Recuento total de ficheros de texto del repo.
    foreach ($palabra in $palabrasDeTotales) {
      foreach ($m in [regex]::Matches($linea, '(\d+)\s+' + $palabra)) {
        if ([int]$m.Groups[1].Value -ne $markdownCount) {
          Write-Host ("  [cifra] {0}:{1} dice {2} {3}; hay {4}" -f $relative, ($i + 1), $m.Groups[1].Value, $palabra, $markdownCount) -ForegroundColor Yellow
          $failures++
        }
      }
    }
  }
}

if (-not $hayDirDirectrices) {
  Write-Host ("  Nota: no existe la carpeta directrices/, asi que los recuentos de")
  Write-Host ("  directrices y documentos NO se han comprobado. No es lo mismo que estar bien.") -ForegroundColor DarkGray
}

Write-Host ''
Write-Host ("Idioma detectado: {0} en espanol, {1} en ingles, {2} sin clasificar." -f $conteoEs, $conteoEn, $conteoDesconocido) -ForegroundColor DarkGray
if ($conteoDesconocido -gt 0) {
  Write-Host ("  Sin clasificar significa que NO se les comprobo la regla de palabras inglesas")
  Write-Host ("  ni las comillas de su idioma. No es lo mismo que estar correctos:")
  foreach ($d in $dirLangDesconocido) { Write-Host ("    {0}" -f $d) -ForegroundColor DarkGray }
  Write-Host ''
}
if ($failures -eq 0) {
  Write-Host ("OK - {0} archivos, sin incidencias" -f $files.Count)
} else {
  Write-Host ("{0} incidencias en {1} archivos" -f $failures, $files.Count)
  Write-Host ''
  Write-Host "Si una incidencia es legitima, el problema no es el script: es el texto." -ForegroundColor DarkGray
  Write-Host "Si es un falso positivo, mira el patron que la produjo, en las lineas 14-24." -ForegroundColor DarkGray
  exit 1
}
