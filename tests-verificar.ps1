$p = "C:\Users\Pablo\AppData\Local\Temp\opencode\proj-en"
$script = "C:\Proyectos\Prompts-y-directrices-ia\verificar.ps1"
$ab = [char]0x00AB
$bb = [char]0x00BB

function Probar($nombre, $texto, $debeFallar) {
  Remove-Item "$p\*" -Force -ErrorAction SilentlyContinue
  [System.IO.File]::WriteAllText("$p\a.md", $texto, (New-Object System.Text.UTF8Encoding $true))
  $out = powershell -File $script -Ruta $p 2>&1 | Out-String
  $tieneFallo = $out -match 'incidencias' -and $out -notmatch 'OK -'
  $bien = if ($debeFallar) { $tieneFallo } else { -not $tieneFallo }
  $marca = if ($bien) { 'CORRECTO   ' } else { '*** MAL ***' }
  '  {0}  {1}' -f $marca, $nombre
  if (-not $bien) { '      -> ' + ($out -replace '\s+', ' ') }
  $script:aciertos = $script:aciertos + $(if ($bien) { 1 } else { 0 })
}

$nl = "`r`n"
$script:aciertos = 0

'=== DEBEN PASAR ==='
Probar 'ingles limpio' ("This is a paragraph about the system and how it works with the tools." + $nl + "There is nothing wrong here at all, and that is the point of this test." + $nl + '"Quoted text that opens and closes properly," she said.' + $nl + "Another paragraph where all the words are in English here.") $false

Probar 'ingles con codigo en linea entrecomillado' ("The value of the flag is ``on`` in this paragraph about the system." + $nl + "This paragraph has enough english words to be classified properly." + $nl + "There is more text here so the detector can decide the language.") $false

Probar 'ingles con comillas rectas emparejadas' ("This paragraph has a quote in it that is fine and complete here." + $nl + 'He said "this part is fine" and then he left the room without waiting.' + $nl + "More english text to keep the classifier happy about the language here.") $false

Probar 'español limpio' ("Esta es una frase normal del documento que no tiene ningun problema." + $nl + "La segunda frase tambien esta bien escrita y no contiene nada que este mal." + $nl + "Tercera frase normal para que el detector tenga contexto suficiente.") $false

Probar 'bloque de codigo con palabras inglesas' ("Para ejecutar esto hay que escribir un comando con palabras en ingles." + $nl + $nl + '```bash' + $nl + 'cd somewhere && the thing --with-more --should work' + $nl + '```' + $nl + $nl + "Una frase final en espanol normal para que el idioma quede claro.") $false

''
'=== DEBEN FALLAR ==='
Probar 'ingles con " recta sin cerrar (impar)' ("This paragraph opens a quotation and never closes it here." + $nl + '"She said that the system was broken and that nobody could fix it.' + $nl + "More english text that should not be a problem by itself in this document.") $true

Probar 'español con the/and/with' ("Esta es una frase normal del documento que no tiene ningun problema." + $nl + "Esta otra tiene the and with pegados dentro del texto en espanol." + $nl + "Tercera frase normal para que el detector tenga contexto suficiente.") $true

Probar ('español con ' + $ab + ' sin cerrar') ("Esta es una frase normal del documento que no tiene ningun problema." + $nl + "Esta otra abre una cita angular" + $ab + "y nunca la cierra en todo el texto." + $nl + "Tercera frase normal para que el detector tenga contexto.") $true

Probar 'cirilico colado' ("Esta es una frase normal del documento que no tiene ningun problema." + $nl + "En esta linea hay texto en cirilico " + [string][char]0x0434 + [string][char]0x0435 + [string][char]0x043B + " que se colaron aqui al escribir." + $nl + "Tercera frase normal para que el detector tenga contexto suficiente.") $true

Probar 'palabra mezclada (ideasPJ)' ("Esta es una frase normal del documento que no tiene ningun problema." + $nl + "Aqui aparece una basura pegada dentro de una palabra como ideasPJ en el texto." + $nl + "Tercera frase normal para que el detector tenga contexto suficiente.") $true

''
# --- Casos de cifras ---------------------------------------------------------
# Necesitan un proyecto de verdad con carpetas, porque el recuento se compara con
# el disco. Por eso no van en la carpeta temporal de a.mes arriba: se monta un
# proyecto pequeno con el numero de ficheros que se quiere que sea correcto.

function ProbarProyecto($nombre, $archivos, $lineaExtra, $debeFallar) {
  $proj = "C:\Users\Pablo\AppData\Local\Temp\opencode\proj-cifras"
  Remove-Item $proj -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Path $proj -Force | Out-Null
  New-Item -ItemType Directory -Path (Join-Path $proj 'directrices') -Force | Out-Null
  # a.md se cuenta a si mismo: los ficheros de texto del proyecto son $archivos + 1
  for ($k = 1; $k -le $archivos; $k++) {
    [System.IO.File]::WriteAllText((Join-Path $proj ("d$k.md")), "contenido $k", (New-Object System.Text.UTF8Encoding $true))
  }
  [System.IO.File]::WriteAllText((Join-Path $proj 'directrices\e1.md'), "contenido", (New-Object System.Text.UTF8Encoding $true))
  [System.IO.File]::WriteAllText((Join-Path $proj 'a.md'), $lineaExtra, (New-Object System.Text.UTF8Encoding $true))

  $out = powershell -File $script -Ruta $proj 2>&1 | Out-String
  $tieneFallo = $out -match 'incidencias' -and $out -notmatch 'OK -'
  $bien = if ($debeFallar) { $tieneFallo } else { -not $tieneFallo }
  '  {0}  {1}' -f $(if ($bien) { 'CORRECTO   ' } else { '*** MAL ***' }), $nombre
  if (-not $bien) { '      -> ' + ($out -replace '\s+', ' ') }
  $script:aciertos = $script:aciertos + $(if ($bien) { 1 } else { 0 })
}

'=== CIFRAS: deben pasar ==='
ProbarProyecto 'recuento de archivos correcto' 3 ("El repositorio tiene 5 archivos en total ahora." + $nl) $false
ProbarProyecto 'recuento de documentos correcto' 3 ("Hay 1 documentos en la capa de directrices." + $nl) $false
# El acento grave se construye con su codigo: dentro de una cadena con comillas dobles
# de PowerShell es el caracter de ESCAPE y se traga la letra siguiente. Escribiendolo
# asi el test mide lo que de verdad hay en el fichero.
$bt = [string][char]0x60
ProbarProyecto 'carpeta citada: el numero es de esa carpeta' 3 ("La tabla dice que " + $bt + "directrices/" + $bt + " (1 archivos) es la capa." + $nl) $false

'=== CIFRAS: deben fallar ==='
ProbarProyecto 'recuento de archivos equivocado' 3 ("El repositorio tiene 99 archivos en total ahora." + $nl) $true
ProbarProyecto 'recuento de documentos equivocado' 3 ("Hay 7 documentos en la capa de directrices." + $nl) $true

''
'=== RESUMEN: {0} de 15 casos correctos ===' -f $script:aciertos
