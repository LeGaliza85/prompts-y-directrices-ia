# RECURSOS

Índice de lo que hay, para no buscarlo.Todo lo de aquí está verificado contra el
sistema o contra el log; donde no lo está, se dice.

## Índice

1. [Scripts de este repo](#scripts-de-este-repo)
2. [Comandos de OpenCode verificados](#comandos-de-opencode-verificados)
3. [Rutas que vas a necesitar](#rutas-que-vas-a-necesitar)
4. [Modelos: qué está medido](#modelos-qué-está-medido)
5. [Automatizaciones](#automatizaciones)
6. [Consejos para ganar tiempo](#consejos-para-ganar-tiempo)
7. [Lo que no está comprobado](#lo-que-no-está-comprobado)

---

## Scripts de este repo

### `verificar.ps1` — el que se pasa antes de dar nada por bueno

```powershell
powershell -File verificar.ps1
```

Comprueba dos bloques, sobre los ficheros `.md`:

- **Patrones de texto**: cirílico, CJK, kanji, palabras inglesas en texto español,
  palabras mezcladas. Ignora bloques de código y, desde el 2026-10-10, también el
  código en línea.
- **Cuatro comprobaciones estructurales**:
  1. Comillas angulares desbalanceadas (por archivo, no por línea, porque una cita
     puede partirse entre dos).
  2. Rutas entre acentos graves que no existen.
  3. Párrafos duplicados.
  4. Cifras desincronizadas: documentos, archivos.

Parámetro: `-Ruta` para revisar otra carpeta.

Salida roja y `exit 1` si hay algo. Va por 102 archivos sin incidencias.

### `watchdog.ps1` — vigilancia de subagentes

```powershell
powershell -File watchdog.ps1 -UnaVez      # informe y salir
powershell -File watchdog.ps1              # vigilar en bucle
powershell -File watchdog.ps1 -Cancelar    # cancela solo sesiones con error de causa leída
```

**No cancela nada por defecto.** Informa el silencio medido de cada sesión y lo
clasifica por hechos (`activa`, `sin-trabajo-registrado`, `cancelada`, `error`).
No hay umbral de tiempo: el log no distingue un agente callado de un usuario ausente.

Parámetros: `-Umbral`, `-CancelarSegundos` (ambos sin efecto, a 0 a propósito),
`-Intervalo` (segundos entre lecturas, 15), `-UnaVez`, `-Cancelar`, `-Log`, `-Registro`.

Registro persistente en
`C:\Users\Pablo\.local\share\opencode\log\watchdog-registro.md`.

### `nuevo-proyecto.ps1` — scaffold

```powershell
.\nuevo-proyecto.ps1 -Nombre "mi-proyecto" -Tipo web -Stack "React, TypeScript" -Git
```

Tipos: `web`, `api`, `datos`, `cli`, `movil`, `infra`, `docs`, `todos`.

Resuelve los marcadores que se pueden saber, elige agentes según el tipo y **lista lo
que queda por rellenar**. Los marcadores de permisos (`<COMANDO_DE_COMPROBACIÓN>`)
se quedan a propósito: solo sabe quién pide el proyecto qué comando se usa.

Parámetros: `-Nombre`, `-Tipo`, `-Stack`, `-Idioma`, `-Destino`, `-Git`, `-Forzar`.

**Ojo:** si lo ejecutas en la raíz de este repo, crea el proyecto **dentro** del repo.
Pásale `-Destino` a otra ruta.

### `verificar-interfaz.js` — prueba de interfaz en Chrome real

```powershell
node verificar-interfaz.js <url> <archivo-de-comprobaciones.js> [captura.png]
```

Abre Chrome real por CDP (puerto 9222), comprueba errores de consola, desborde a
375 px y **guarda la captura** en disco. Probado el 2026-10-10: PNG válido de
18.886 bytes.

El archivo de comprobaciones exporta `pasos`, un array de `{ nombre, expresion }`.

---

## Comandos de OpenCode verificados

Verificados con `opencode --help` y las ayudas de cada subcomando, binario
1.4.0. No probados: solo listados en la ayuda.

| Comando | Para qué |
|---|---|
| `opencode` | abrir el TUI |
| `opencode web` | servidor + interfaz web |
| `opencode serve` | servidor sin interfaz |
| `opencode run "<msg>"` | ejecutar una petición |
| `opencode attach <url>` | conectarse a un servidor ya abierto |
| `opencode models [prov]` | listar modelos |
| `opencode models --verbose` | con costes y metadatos |
| `opencode stats` | consumo y tokens |
| `opencode auth list` | proveedores configurados |
| `opencode session` | gestionar sesiones |
| `opencode export [id]` / `import` | exportar e importar |
| `opencode providers` | alias de `auth` |
| `opencode agent` | gestionar agentes |

Opciones comunes a `web` y `serve`: `--hostname` (por defecto `127.0.0.1`),
`--port` (por defecto `0`), `--mdns`, `--cors`, `--model`, `--agent`, `--session`,
`--continue`.

**Verificado:** existen `OPENCODE_SERVER_PASSWORD` y `OPENCODE_SERVER_USERNAME` en
el binario (19 y 10 apariciones). Sirven para proteger el servidor web. Lo demás de
autenticación está en `APIS-VERIFICADAS.md`.

El binario no está en el PATH del shell. Ruta:
`C:\Users\Pablo\AppData\Local\opencode\opencode-cli.exe`

---

## Rutas que vas a necesitar

| Qué | Dónde |
|---|---|
| Log de opencode | `C:\Users\Pablo\.local\share\opencode\log\opencode.log` |
| Registro del watchdog | …mismo directorio `watchdog-registro.md` |
| Caché de modelos | `C:\Users\Pablo\.cache\opencode\models.json` |
| Credenciales | `…\opencode\auth.json` — **un solo proveedor: `zai-coding-plan`** |
| Config de opencode | `C:\Users\Pablo\.config\opencode\opencode.jsonc` |
| Binario | `C:\Users\Pablo\AppData\Local\opencode\opencode-cli.exe` |
| Base de datos | `…\opencode\opencode.db` — 293 MB, la sesión gratuita cuelga de aquí |

El log hay que abrirlo con compartido de lectura, porque opencode lo tiene abierto:

```powershell
$fs=[System.IO.File]::Open($log,'Open','Read','ReadWrite')
$sr=New-Object System.IO.StreamReader($fs,[System.Text.Encoding]::UTF8)
$txt=$sr.ReadToEnd(); $sr.Close(); $fs.Close()
```

---

## Modelos: qué está medido

Un proveedor, 18 modelos. Detalle y cifras en `directrices/MODELOS.md`.

Lo único que sostiene el historial:

| Modelo | Usos | Errores de disponibilidad |
|---|---|---|
| `space-bunny-free` | 1494 | 0 |
| `big-pickle` | 1058 | 0 |
| `step-5-preview-free` | 408 | 3, el último hoy 16:26 |
| `ling-3.0-flash-fin-free` | 12 | 6, el último el 9 de octubre |

Los otros 14 tienen 0, 1 o 2 usos: **no se puede decir que funcionen**. Cero usos no
es un fallo, es que nadie los ha pedido.

**No existe columna de disponibilidad en `MODELOS.md` a propósito.** Un modelo con 0
errores puede estar caído desde hace diez minutos. Eso se comprueba llamándolo.

---

## Automatizaciones

**El verificador se pasa solo si lo invocas.** No hay hook. El orden natural es:
`verificar.ps1` antes de commitear.

**El watchdog no arranca solo.** Si quieres que te avise mientras delegas, hay que
lanzarlo en otra terminal antes.

**Lo que falta montar y no está**: arranque automático de `opencode web` tras
reiniciar, y un comprobador de disponibilidad por lotes. Los dos están propuestos en
`BLOQUEOS.md` y `MODELOS.md`, ninguno escrito.

---

## Consejos para ganar tiempo

- **Antes de delegar, comprueba que el modelo responde.** Lanzar a ciegas gasta la
  tarea entera si el modelo está caído: `space-bunny-free` es el que más historial
  tiene sin fallos.
- **Dos subagentes como máximo con modelos gratuitos.** Tres simultáneos dieron
  `Rate limit exceeded` en 0,6 s, y eso sí está medido en el log.
- **El log no distingue silencio de atasco.** No esperes a que un subagente dé señales:
  medidos 426 silencios de trabajo por encima de 30 s, el mayor de 1873 s. Un corte
  por tiempo mata trabajo real.
- **Si un script de PowerShell analiza algo, revisa sus nombres de variables antes
  de leer la salida.** `$S` y `$s` son la misma variable; un análisis de esta sesión
  se destruyó a sí mismo así.
- **Los scripts se pasan con `powershell -File`, no ejecutándolos.** Llevan BOM y
  PowerShell 5.1 los lee como ANSI si se abren de otra forma.
- **El log hay que leerlo con compartido de lectura.** `ReadAllLines` falla.

---

## Lo que no está comprobado

- **La latencia de cada modelo.** Exige llamarlos. No se ha hecho.
- **La disponibilidad ahora mismo de los 14 modelos sin uso.** Exige lo mismo.
- **La cuota restante del plan de Z.AI.** `opencode stats` marca `$0.00`, pero eso
  es la contabilidad de OpenCode, no tu plan. No hay comando que la exponga.
- **El tiempo de arranque de los subagentes.** El análisis se encargó a un subagente
  y se canceló antes de completarse. Sigue pendiente.
