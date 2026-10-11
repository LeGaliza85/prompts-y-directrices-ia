<#
.SYNOPSIS
  Crea un proyecto nuevo desde la plantilla, con los marcadores resueltos y solo los
  agentes que ese tipo de proyecto necesita.

.DESCRIPTION
  Automatiza lo mecanico: copiar, elegir agentes, inicializar git. No inventa nada del
  proyecto: lo que solo sabes tu queda marcado con <...> y se lista al final para que
  lo rellenes.

.PARAMETER Nombre
  Nombre del proyecto. Se usa para la carpeta y para los titulos.

.PARAMETER Destino
  Carpeta donde crear el proyecto. Por defecto, la actual.

.PARAMETER Tipo
  web | api | datos | cli | movil | infra | docs
  Define que agentes se quedan. Por defecto, todos.

.PARAMETER Stack
  Tecnologias y versiones. Rellena la seccion de stack de AGENTS.md.

.PARAMETER Idioma
  Idioma de los textos y la documentacion. Por defecto, espanol.

.PARAMETER Git
  Inicializa git en el proyecto nuevo.

.PARAMETER Forzar
  Permite escribir en una carpeta que ya existe y no esta vacia.

.EXAMPLE
  .\nuevo-proyecto.ps1 -Nombre "diario-estudio" -Tipo web -Stack "HTML, CSS y JS" -Git
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)][string]$Nombre,
  [string]$Destino = (Get-Location).Path,
  [ValidateSet('web', 'api', 'datos', 'cli', 'movil', 'infra', 'docs', 'todos')]
  [string]$Tipo = 'todos',
  [string]$Stack = '',
  [string]$Idioma = 'espanol',
  [switch]$Git,
  [switch]$Forzar
)

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $MyInvocation.MyCommand.Path
$template = Join-Path $raiz 'plantilla'
$target = Join-Path $Destino $Nombre

# --- Agentes por tipo de proyecto -------------------------------------------
# La tabla esta en directrices/AGENTES.md. Se mantiene aqui igual para poder elegir
# sin leer el documento. Si cambias alli, cambiala aqui tambien.
$agents = @{
  'web'    = 'planner', 'implementer', 'reviewer', 'frontend-reviewer', 'tooling-advisor'
  'api'    = 'planner', 'implementer', 'reviewer', 'security-auditor', 'tester', 'tooling-advisor'
  'datos'  = 'planner', 'implementer', 'reviewer', 'debugger'
  'cli'    = 'planner', 'implementer', 'reviewer'
  'movil'  = 'planner', 'implementer', 'reviewer', 'perf-auditor'
  'infra'  = 'planner', 'security-auditor', 'migrator', 'reviewer'
  'docs'   = 'planner', 'docs-writer', 'reviewer'
}
# coordinator solo en especificaciones largas. Se queda si se pide -Tipo todos.

# --- Comprobaciones previas ------------------------------------------------
if (-not (Test-Path -LiteralPath $template)) {
  throw "No encuentro la plantilla en: $template"
}
if (Test-Path -LiteralPath $target) {
  $vacio = -not (Get-ChildItem -LiteralPath $target -Force | Select-Object -First 1)
  if (-not $vacio -and -not $Forzar) {
    throw "La carpeta ya existe y no esta vacia: $target. Usa -Forzar si de verdad quieres."
  }
} else {
  New-Item -ItemType Directory -Path $target -Force | Out-Null
}

# --- 1. Copiar -------------------------------------------------------------
Write-Host "Copiando plantilla en $target ..." -ForegroundColor Cyan
Copy-Item -Path (Join-Path $template '*') -Destination $target -Recurse -Force

# El .git de esta biblioteca no debe viajar al proyecto nuevo
$gitInited = Join-Path $target '.git'
if (Test-Path -LiteralPath $gitInited) { Remove-Item -LiteralPath $gitInited -Recurse -Force }

# --- 2. Elegir agentes -----------------------------------------------------
$agentsDir = Join-Path $target '.opencode\agents'
$kept = @()
if ($Tipo -eq 'todos') {
  $kept = (Get-ChildItem -LiteralPath $agentsDir -Filter *.md).BaseName
  Write-Host "  agentes: todos ($($kept.Count))" -ForegroundColor DarkGray
} else {
  $kept = $agents[$Tipo]
  Get-ChildItem -LiteralPath $agentsDir -Filter *.md | ForEach-Object {
    if ($_.BaseName -notin $kept) {
      Remove-Item -LiteralPath $_.FullName -Force
    }
  }
  Write-Host "  agentes de tipo '$Tipo': $($kept -join ', ')" -ForegroundColor DarkGray
}

# --- 3. Sustituir marcadores ----------------------------------------------
Write-Host "Resolviendo marcadores ..." -ForegroundColor Cyan

# Titulo legible a partir del nombre. Las palabras cortas van en minuscula, salvo la primera.
$words = $Nombre -split '[-_]'
$shortWords = 'de', 'del', 'la', 'las', 'el', 'los', 'y', 'en', 'para', 'con'
$title = ''
$primera = $true
foreach ($p in $words) {
  if ($primera) {
    $title += $p.Substring(0, 1).ToUpper() + $p.Substring(1) + ' '
    $primera = $false
  } elseif ($shortWords -contains $p.ToLower()) {
    $title += $p.ToLower() + ' '
  } else {
    $title += $p.Substring(0, 1).ToUpper() + $p.Substring(1) + ' '
  }
}
$title = $title.TrimEnd()

# Ojo con los acentos en las claves: <TECNOLOGIAS> lleva tilde en la plantilla.
# Un patron ASCII no la encuentra y la sustitucion falla en silencio.
$substitutions = [ordered]@{
  '<NOMBRE DEL PROYECTO>'           = $title
  '<IDIOMA>'                        = $Idioma
  '<TECNOLOGÍAS Y VERSIONES CLAVE>' = $(if ($Stack) { $Stack } else { '<TECNOLOGÍAS Y VERSIONES CLAVE>' })
  '<STACK>'                         = $(if ($Stack) { $Stack } else { '<STACK>' })
}

$mdFiles = Get-ChildItem -LiteralPath $target -Recurse -Include *.md, *.jsonc, *.json -File
$pending = New-Object System.Collections.Generic.List[string]

foreach ($f in $mdFiles) {
  $texto = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
  foreach ($k in $substitutions.Keys) {
    $texto = $texto -replace [regex]::Escape($k), $substitutions[$k]
  }
  [System.IO.File]::WriteAllText($f.FullName, $texto, (New-Object System.Text.UTF8Encoding $false))

  # Releer DESPUES de sustituir. Leer antes listaria como pendiente lo que ya se ha
  # resuelto, que es peor que listar de mas: hace dudar de la sustitucion.
  $lines = $texto -split "`r?`n"

  # Recoger lo que sigue sin resolver.
  #
  # El criterio NO puede ser "donde esta el marcador" sino "si es un marcador", y eso se
  # decide por el ARCHIVO, no por la posicion en la linea. Un filtro por posicion
  # descartaba 40 de 43 marcadores reales: backticks, comas y texto alrededor los hacian
  # parecer que estaban en medio de una frase.
  #
  #   1. Solo mayusculas: `<COMANDO>` si, `<idea>` no. Un marcador de proyecto va en
  #      mayusculas; en minusculas suele ser el uso de ejemplo de un comando.
  #   2. Ni dentro de una tabla ni de un bloque de codigo, donde lo que hay entre < y >
  #      es un argumento ilustrativo, no un hueco.
  #   3. Sin limite de longitud: un marcador de 70 caracteres sigue siendo un marcador.
  $inCode = $false
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ($line -match '^\s*(```|~~~)') { $inCode = -not $inCode; continue }
    if ($inCode) { continue }
    if ($line -match '^\s*\|') { continue }

    foreach ($m in [regex]::Matches($line, '<[A-ZÁÉÍÓÚÑ][^<>]{0,200}>')) {
      $pending.Add("$($f.FullName.Replace("$target\", '')) :L$($i + 1) $($m.Value)")
    }
  }
}

# --- 4. Limpiar la spec de ejemplo ---------------------------------------
$exampleSpec = Join-Path $target 'specs\000-plantilla'
if (Test-Path -LiteralPath $exampleSpec) {
  Remove-Item -LiteralPath $exampleSpec -Recurse -Force
  New-Item -ItemType Directory -Path (Join-Path $target 'specs\000-plantilla') -Force | Out-Null
}

# --- 5. git ---------------------------------------------------------------
if ($Git) {
  Write-Host "Inicializando git ..." -ForegroundColor Cyan
  & git -C $target init 2>&1 | Out-Null
}

# --- Informe --------------------------------------------------------------
Write-Host ''
Write-Host "Proyecto creado: $target" -ForegroundColor Green
Write-Host "Tipo: $Tipo   Agentes: $($kept.Count)" -ForegroundColor Green
if ($Git) { Write-Host "git inicializado" -ForegroundColor Green }

# Lista blanca: solo se listan los ficheros que la persona tiene que editar. Los
# marcadores de la skill y de la spec de ejemplo son de formato, y los del bloque de
# recomendacion de tooling-advisor los rellena el agente cuando recomienda. Listarlos
# como pendientes es ruido que hace ignorar la lista entera.
$editableFiles = 'AGENTS\.md', 'MEMORY\.md', 'EXPECT\.md', 'LEEME\.md', 'constitution\.md', 'opencode\.jsonc?', 'planner\.md', 'implementer\.md', 'reviewer\.md', 'tester\.md', 'debugger\.md', 'security-auditor\.md', 'refactorer\.md', 'migrator\.md', 'perf-auditor\.md', 'frontend-reviewer\.md', 'docs-writer\.md'

$missing = $pending | Select-Object -Unique | Where-Object {
  $rel = ($_ -split ' : ')[0]
  $name = Split-Path -Leaf $rel
  if ($rel -match '\\specs\\' -or $rel -match '\\skills\\') { return $false }
  if ($name -eq 'tooling-advisor.md') { return $false }
  return ($editableFiles | Where-Object { $name -match $_ }) -ne $null
}
if ($missing) {
  Write-Host ''
  Write-Host "Queda por rellenar ($($missing.Count)):" -ForegroundColor Yellow
  $missing | Sort-Object | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
} else {
  Write-Host ''
  Write-Host "Sin marcadores pendientes." -ForegroundColor Green
}

Write-Host ''
Write-Host "Siguiente paso:" -ForegroundColor Cyan
Write-Host "  1. docs/constitution.md: decide el stack, el idioma y como se comprueba"
Write-Host "  2. AGENTS.md: comandos, trampas conocidas y formato de datos"
Write-Host "  3. <RUTA_A_LAS_DIRECTRICES> en AGENTS.md y LEEME.md"
Write-Host "  4. Primera spec en specs/001-nombre/ (ver .agents/skills/sdd/SKILL.md)"

# Los marcadores que quedan en los permisos se imprimen LEIDOS del fichero generado,
# no escritos a mano. La version anterior escribia <COMANDO_DE_COMPROBACION> sin tilde
# mientras el fichero tiene <COMANDO_DE_COMBACIÓN> con tilde: copiar y pegar no
# encontraba nada y el nombre que aparecia no existia en el proyecto.
$permissionMarks = Get-ChildItem (Join-Path $target '.opencode\agents') -Filter *.md -File -ErrorAction SilentlyContinue |
  ForEach-Object {
    $tx = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    if ($tx -notmatch '(?s)permission:.*?---') { return }
    foreach ($m in [regex]::Matches($tx, '<[A-ZÀ-ÿ][^<>]{0,80}>')) {
      "$($_.Name): $($m.Value)"
    }
  } | Sort-Object -Unique

if ($permissionMarks) {
  Write-Host "  5. Marcadores SIN SUSTITUIR dentro de permisos (no funcionan hasta rellenarlos):" -ForegroundColor Yellow
  $permissionMarks | ForEach-Object { Write-Host "       $_" -ForegroundColor Yellow }
  Write-Host "     Si un permiso se queda sin sustituir, ese agente no puede ejecutar ese comando." -ForegroundColor DarkGray
}
