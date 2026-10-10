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
$plantilla = Join-Path $raiz 'plantilla'
$objetivo = Join-Path $Destino $Nombre

# --- Agentes por tipo de proyecto -------------------------------------------
# La tabla esta en directrices/AGENTES.md. Se mantiene aqui igual para poder elegir
# sin leer el documento. Si cambias alli, cambiala aqui tambien.
$agentes = @{
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
if (-not (Test-Path -LiteralPath $plantilla)) {
  throw "No encuentro la plantilla en: $plantilla"
}
if (Test-Path -LiteralPath $objetivo) {
  $vacio = -not (Get-ChildItem -LiteralPath $objetivo -Force | Select-Object -First 1)
  if (-not $vacio -and -not $Forzar) {
    throw "La carpeta ya existe y no esta vacia: $objetivo. Usa -Forzar si de verdad quieres."
  }
} else {
  New-Item -ItemType Directory -Path $objetivo -Force | Out-Null
}

# --- 1. Copiar -------------------------------------------------------------
Write-Host "Copiando plantilla en $objetivo ..." -ForegroundColor Cyan
Copy-Item -Path (Join-Path $plantilla '*') -Destination $objetivo -Recurse -Force

# El .git de esta biblioteca no debe viajar al proyecto nuevo
$gitCopiado = Join-Path $objetivo '.git'
if (Test-Path -LiteralPath $gitCopiado) { Remove-Item -LiteralPath $gitCopiado -Recurse -Force }

# --- 2. Elegir agentes -----------------------------------------------------
$dirAgentes = Join-Path $objetivo '.opencode\agents'
$quedan = @()
if ($Tipo -eq 'todos') {
  $quedan = (Get-ChildItem -LiteralPath $dirAgentes -Filter *.md).BaseName
  Write-Host "  agentes: todos ($($quedan.Count))" -ForegroundColor DarkGray
} else {
  $quedan = $agentes[$Tipo]
  Get-ChildItem -LiteralPath $dirAgentes -Filter *.md | ForEach-Object {
    if ($_.BaseName -notin $quedan) {
      Remove-Item -LiteralPath $_.FullName -Force
    }
  }
  Write-Host "  agentes de tipo '$Tipo': $($quedan -join ', ')" -ForegroundColor DarkGray
}

# --- 3. Sustituir marcadores ----------------------------------------------
Write-Host "Resolviendo marcadores ..." -ForegroundColor Cyan

# Titulo legible a partir del nombre. Las palabras cortas van en minuscula, salvo la primera.
$palabras = $Nombre -split '[-_]'
$cortas = 'de', 'del', 'la', 'las', 'el', 'los', 'y', 'en', 'para', 'con'
$titulo = ''
$primera = $true
foreach ($p in $palabras) {
  if ($primera) {
    $titulo += $p.Substring(0, 1).ToUpper() + $p.Substring(1) + ' '
    $primera = $false
  } elseif ($cortas -contains $p.ToLower()) {
    $titulo += $p.ToLower() + ' '
  } else {
    $titulo += $p.Substring(0, 1).ToUpper() + $p.Substring(1) + ' '
  }
}
$titulo = $titulo.TrimEnd()

# Ojo con los acentos en las claves: <TECNOLOGIAS> lleva tilde en la plantilla.
# Un patron ASCII no la encuentra y la sustitucion falla en silencio.
$sustituciones = [ordered]@{
  '<NOMBRE DEL PROYECTO>'           = $titulo
  '<IDIOMA>'                        = $Idioma
  '<TECNOLOGÍAS Y VERSIONES CLAVE>' = $(if ($Stack) { $Stack } else { '<TECNOLOGÍAS Y VERSIONES CLAVE>' })
  '<STACK>'                         = $(if ($Stack) { $Stack } else { '<STACK>' })
}

$archivosMd = Get-ChildItem -LiteralPath $objetivo -Recurse -Include *.md, *.jsonc, *.json -File
$pendientes = New-Object System.Collections.Generic.List[string]

foreach ($f in $archivosMd) {
  $texto = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
  foreach ($k in $sustituciones.Keys) {
    $texto = $texto -replace [regex]::Escape($k), $sustituciones[$k]
  }
  [System.IO.File]::WriteAllText($f.FullName, $texto, (New-Object System.Text.UTF8Encoding $false))

  # Releer DESPUES de sustituir. Leer antes listaria como pendiente lo que ya se ha
  # resuelto, que es peor que listar de mas: hace dudar de la sustitucion.
  $lineas = $texto -split "`r?`n"

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
  $enCodigo = $false
  for ($i = 0; $i -lt $lineas.Count; $i++) {
    $linea = $lineas[$i]
    if ($linea -match '^\s*(```|~~~)') { $enCodigo = -not $enCodigo; continue }
    if ($enCodigo) { continue }
    if ($linea -match '^\s*\|') { continue }

    foreach ($m in [regex]::Matches($linea, '<[A-ZÁÉÍÓÚÑ][^<>]{0,200}>')) {
      $pendientes.Add("$($f.FullName.Replace("$objetivo\", '')) :L$($i + 1) $($m.Value)")
    }
  }
}

# --- 4. Limpiar la spec de ejemplo ---------------------------------------
$specEjemplo = Join-Path $objetivo 'specs\000-plantilla'
if (Test-Path -LiteralPath $specEjemplo) {
  Remove-Item -LiteralPath $specEjemplo -Recurse -Force
  New-Item -ItemType Directory -Path (Join-Path $objetivo 'specs\000-plantilla') -Force | Out-Null
}

# --- 5. git ---------------------------------------------------------------
if ($Git) {
  Write-Host "Inicializando git ..." -ForegroundColor Cyan
  & git -C $objetivo init 2>&1 | Out-Null
}

# --- Informe --------------------------------------------------------------
Write-Host ''
Write-Host "Proyecto creado: $objetivo" -ForegroundColor Green
Write-Host "Tipo: $Tipo   Agentes: $($quedan.Count)" -ForegroundColor Green
if ($Git) { Write-Host "git inicializado" -ForegroundColor Green }

# Lista blanca: solo se listan los ficheros que la persona tiene que editar. Los
# marcadores de la skill y de la spec de ejemplo son de formato, y los del bloque de
# recomendacion de tooling-advisor los rellena el agente cuando recomienda. Listarlos
# como pendientes es ruido que hace ignorar la lista entera.
$editables = 'AGENTS\.md', 'MEMORY\.md', 'EXPECT\.md', 'LEEME\.md', 'constitution\.md', 'opencode\.jsonc?', 'planner\.md', 'implementer\.md', 'reviewer\.md', 'tester\.md', 'debugger\.md', 'security-auditor\.md', 'refactorer\.md', 'migrator\.md', 'perf-auditor\.md', 'frontend-reviewer\.md', 'docs-writer\.md'

$faltan = $pendientes | Select-Object -Unique | Where-Object {
  $rel = ($_ -split ' : ')[0]
  $nombre = Split-Path -Leaf $rel
  if ($rel -match '\\specs\\' -or $rel -match '\\skills\\') { return $false }
  if ($nombre -eq 'tooling-advisor.md') { return $false }
  return ($editables | Where-Object { $nombre -match $_ }) -ne $null
}
if ($faltan) {
  Write-Host ''
  Write-Host "Queda por rellenar ($($faltan.Count)):" -ForegroundColor Yellow
  $faltan | Sort-Object | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
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
$MarcEnPermisos = Get-ChildItem (Join-Path $objetivo '.opencode\agents') -Filter *.md -File -ErrorAction SilentlyContinue |
  ForEach-Object {
    $tx = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
    if ($tx -notmatch '(?s)permission:.*?---') { return }
    foreach ($m in [regex]::Matches($tx, '<[A-ZÀ-ÿ][^<>]{0,80}>')) {
      "$($_.Name): $($m.Value)"
    }
  } | Sort-Object -Unique

if ($MarcEnPermisos) {
  Write-Host "  5. Marcadores SIN SUSTITUIR dentro de permisos (no funcionan hasta rellenarlos):" -ForegroundColor Yellow
  $MarcEnPermisos | ForEach-Object { Write-Host "       $_" -ForegroundColor Yellow }
  Write-Host "     Si un permiso se queda sin sustituir, ese agente no puede ejecutar ese comando." -ForegroundColor DarkGray
}
