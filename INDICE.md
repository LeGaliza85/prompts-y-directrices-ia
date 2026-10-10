# INDICE — Prompts y directrices IA

Biblioteca de directrices para trabajar con agentes de IA en cualquier proyecto. Lo que hay
aquí se propone, se aprueba y se registra antes de escribirse en disco.

**Estado:** capa genérica completa · plantilla completa · falta el registro y la Spec 000.

## Para empezar en 30 segundos

**Si vuelves de una sesión anterior: lee `PROXIMA-SESION.md` primero.** Tiene lo que quedó
pendiente. Este repositorio tiene `AGENTS.md` en la raíz que te manda leerlo, así que deberías
haber llegado por ahí.

**Si quieres crear un proyecto nuevo:**

```powershell
.\nuevo-proyecto.ps1 -Nombre "mi-proyecto" -Tipo web -Stack "React, TypeScript" -Git
```

Copia la plantilla, elige los agentes de ese tipo, sustituye los marcadores e inicializa git.
Después te lista exactamente qué queda por rellenar. Detalle en `plantilla/LEEME.md`.

**Si vienes a trabajar en un proyecto ya creado:** lee `directrices/AGENTS.md`.

**Si quieres entender cómo se trabaja aquí:** `directrices/CONSTITUTION.md` (los 9 principios)
y `directrices/SDD.md` (el flujo).

**Si quieres ver qué se decidió y por qué:** `directrices/BITACORA.md`.

**Si algo no funciona y crees que es la versión:** `directrices/PIN.md`.

**Antes de dar cualquier documento por bueno:** `powershell -File verificar.ps1`.

## Qué hay

### `directrices/` — la capa genérica

Lo que se aplica a cualquier proyecto, con independencia del stack.

| Documento | Qué es |
|---|---|
| `CONSTITUTION.md` | Los 9 principios innegociables, en tres bloques, con su origen. |
| `AGENTS.md` | Instrucción maestra: qué hago al empezar, mientras trabajo y al terminar. |
| `MEMORY.md` | Protocolo de memoria entre sesiones y cuándo recortarla. |
| `EXPECT.md` | Cuándo se da algo por terminado, y la decisión de calidad frente a velocidad. |
| `SDD.md` | El flujo de 8 fases, las tres formas de SDD y cuándo no usarlo. |
| `EARS.md` | Cómo se escribe un requisito para que sea verificable, con ejemplos. |
| `DEPURACION.md` | Método para encontrar la causa de un fallo. Reproducir, aislar, hipótesis, verificar. |
| `REFACTOR.md` | Cambiar la estructura sin cambiar el comportamiento, sin romper lo que funciona. |
| `APIS-VERIFICADAS.md` | Inventario de la sintaxis de OpenCode comprobada, con su fecha. |
| `PIN.md` | La versión exacta contra la que está verificado todo esto. |
| `PROCEDIMIENTO-ACTUALIZACION.md` | Qué hacer al actualizar OpenCode, con los modos de fallo silencioso. |
| `CAPACIDADES.md` | Catálogo de MCP, skills y herramientas, con el formato para proponerlas. |
| `MCP.md` | Cómo se conectan y se comprueban los servidores MCP, y cómo se apagan. |
| `AGENTES.md` | Catálogo de subagentes: quién necesita cada proyecto y cómo se eligen. |
| `OPENCODE.md` | Referencia práctica de la herramienta: agentes, comandos, modo Plan. |
| `aprendido.md` | Errores de proceso, con su causa y la directiva que los previene. |
| `BITACORA.md` | Registro de decisiones con su razonamiento. |

**Aviso de nombres.** `AGENTS.md` y `AGENTES.md` son dos archivos distintos que solo se
diferencian en una letra: la instrucción maestra y el catálogo de subagentes. Sitúate siempre
por la ruta completa.

### `plantilla/` — el esqueleto de un proyecto nuevo

Lo que se copia a cada proyecto. Detalle de uso en `plantilla/LEEME.md`.

Contiene `AGENTS.md`, `MEMORY.md`, `EXPECT.md`, `docs/constitution.md`, una spec de ejemplo
completa con su plan y sus tareas, la skill `sdd`, `opencode.jsonc` y trece agentes
candidatos de los que el proyecto se queda con los que necesite.

### `.opencode/` — agentes de este repositorio

`reviewer.md` (revisa sin modificar nada) y `tooling-advisor.md` (propone herramientas con su
coste). Los mismos que están en la plantilla, para poder usarlos aquí.

## Herramientas

| Script | Para qué |
|---|---|
| `nuevo-proyecto.ps1` | Crea un proyecto desde la plantilla, con agentes según el tipo y marcadores resueltos. |
| `verificar.ps1` | Recorre todos los `.md` buscando caracteres corruptos, puntuación CJK y palabras en inglés. |

`nuevo-proyecto.ps1` acepta `-Nombre`, `-Destino`, `-Tipo` (web, api, datos, cli, movil,
infra, docs), `-Stack`, `-Idioma`, `-Git` y `-Forzar`. No inventa nada del proyecto: lo que
solo sabes tú queda marcado y se lista al final.

**Aviso:** el script lleva BOM UTF-8 a propósito. PowerShell 5.1 lee los `.ps1` como ANSI si
no lo llevan, y los acentos rompen el parser.

### Comandos disponibles aquí

Los diez comandos `/sdd-*` están en `.opencode/commands/`, uno por fase del flujo. Escribe
`/sdd` para ver el menú y en qué fase está el proyecto.

## Estado del trabajo

| Bloque | Estado |
|---|---|
| 0 · Andamiaje: git, carpetas y verificador | hecho |
| 1 · Capa genérica | **hecho** (17 documentos) |
| 2 · Blindaje contra la desactualización | hecho |
| 3 · Plantilla | **hecho** (33 archivos, 10 comandos) |
| 4 · Registro: historial, curso, apuntes | hecho |
| 5 · Spec 000 | hecho |
| 6 · Demostración con un proyecto real | **hecho** — `prueba-del-sistema` |

### Estado de los requisitos de la Spec 000

Los doce están cubiertos. **Los dos que dependían de un proyecto real ya no son hipótesis:**

- **RF-1** — la plantilla se copió con `nuevo-proyecto.ps1`, se rellenó y se construyó una
  funcionalidad completa con ella.
- **RF-11** — el proyecto está archivado en `historial/prueba-del-sistema/` con su ficha.

### Qué reveló la prueba

Cuatro cosas que solo se ven construyendo, todas registradas en `aprendido.md`:

1. **`module.exports` no funciona en el navegador.** La lógica compartida entre `node --test` y
   la página necesita exportación doble. Los tests pasaban y la página se rompía.
2. **Un test puede sobreespecificar.** Fallaba un test, y tenía razón el código.
3. **El MCP de `chrome-devtools` no se puede activar desde una sesión abierta.** Exige reinicio.
   La alternativa que funcionó: Chrome headless por CDP, sin dependencias.
4. **El script de arranque lista marcadores que no aplican** después de usar el proyecto.

### Lo que queda

- Corregir lo que la prueba reveló: el falso pendiente del script, y anadir el patrón de
  exportación doble a la plantilla como trampa conocida.
- Probar el flujo con agentes, no a mano. En la prueba el primario hizo todo.

## Las decisiones que gobiernan cómo se trabaja aquí

Resumidas para no tener que abrir la constitución:

1. **Nada se activa sin permiso.** MCP, skill, agente o dependencia se propone con motivo,
   coste y alternativa.
2. **Lo acordado manda.** Un cambio de requisito pasa por la spec antes que por el código.
3. **Lo simple sobrevive.** Toda decisión técnica registra su alternativa descartada.
4. **Verificable o no existe.** Sin criterio medible, no es un requisito.
5. **Nada se da por bueno sin verificar.** Comprobación ejecutada y resultado visto.
6. **Aprender de los errores es parte del trabajo.**
7. **Se delega cuando aporta o cuando lo pidas.** Sin autorización previa si hay beneficio.
8. **Tú decides, yo propongo.** La iniciativa es mía en el cómo, no en el qué.
9. **Nada se ejecuta sin estar escrito.** Primero el acuerdo, después el artefacto.

El texto completo, con su ámbito y su procedencia, está en `directrices/CONSTITUTION.md`.

## Comprobación

Antes de dar cualquier documento por bueno:

```powershell
powershell -File verificar.ps1
```

Detecta caracteres cirílicos o CJK colados en texto español, puntuación china y palabras en
inglés que deberían ser españolas. No detecta errores de lógica ni incoherencias: para eso
está el agente `reviewer`.
