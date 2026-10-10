# PORTABILIDAD.md — Usar este sistema con otro agente

Qué se puede llevar tal cual a Cursor, Claude Code, Windsurf, Aider, Cline o cualquier otro, y
qué hay que adaptar. La capa genérica se escribió probada contra un solo agente; este
documento separa lo que es independiente de la herramienta de lo que no lo es.

## La respuesta corta

**El 80% es portable.** Los nueve principios, el flujo SDD, la sintaxis de requisitos, los
criterios de terminado y el protocolo de memoria no mencionan ninguna herramienta concreta.

**El 20% restante está en cuatro sitios**, y son cuatro, no veinte. Concentrarlos aquí es lo que
permite hacer la adaptación en vez de reescribir el sistema.

## Lo que ya es estándar

`AGENTS.md` es un formato estándar, no una invención de OpenCode. Lo leen varios agentes, y
OpenCode además acepta `CLAUDE.md` si no encuentra `AGENTS.md`. **Es el mayor punto de
portabilidad del sistema**: la instrucción que gobierna todo es un archivo de texto con
secciones, y cualquiera lo puede leer.

La convención `specs/NNN-nombre/` con `spec.md`, `plan.md` y `tasks.md` también es neutra: son
carpetas y Markdown. Ningún agente los necesita para nada más que leerlos.

## Los cuatro puntos atados

### 1. `opencode.jsonc` y el campo `instructions`

Carga documentos al empezar cada sesión. **Es lo más fácil de adaptar**, porque solo hace falta
una lista de archivos a cargar.

| Agente | Cómo se carga lo que hay que leer |
|---|---|
| OpenCode | `"instructions": ["AGENTS.md", "MEMORY.md", ...]` en `opencode.jsonc` |
| Claude Code | `CLAUDE.md` o `CLAUDE.local.md` en la raíz. `@ruta/archivo.md` los incluye |
| Cursor | `.cursor/rules/*.mdc`, uno por archivo, con frontmatter propio |
| Windsurf | `.windsurf/rules/*.md` |
| Cline / Roo | `.clinerules/` o `.roorules/` en la raíz |
| Aider | `--read` en la invocación, o `CONVENTIONS.md` |

**La alternativa universal**: si el agente no tiene forma de cargar archivos por configuración,
basta con que `AGENTS.md` lo diga con claridad. Un agente tiene sus herramientas para leer
archivos; lo único que hay que ensure es que entienda que **debe** leerlos. No hace falta
configuración, solo instrucción.

### 2. La carpeta `.opencode/`

```text
.opencode/
├── agents/      subagentes con frontmatter YAML
└── commands/    comandos personalizados
```

| Agente | Dónde van |
|---|---|
| OpenCode | `.opencode/agents/`, `.opencode/commands/` |
| Claude Code | `.claude/agents/`, `.claude/commands/` — formato casi idéntico |
| Cursor | `.cursor/rules/` para reglas; no tiene subagentes |
| Windsurf | `.windsurf/workflows/` para comandos |

**Los subagentes son lo más atado.** Cursor y Windsurf no tienen el concepto equivalente: ahí el
reparto de trabajo lo hace el agente principal en una sola sesión. La capa genérica sobrevive
—el principio 7 habla de "cuando aporta"—, pero **el catálogo de 13 agentes no aplica**.

### 3. El frontmatter de los agentes

```yaml
---
description: <obligatoria>
mode: subagent
permission:
  edit: deny
  bash: deny
---
```

Es específico de OpenCode. Claude Code usa un formato parecido pero con otras claves. El
**cuerpo** del agente es texto plano y se reutiliza tal cual; lo que cambia es la cabecera.

Lo que define el comportamiento de un subagente es su cuerpo, no su frontmatter. Los
permisos son la parte que se traduce.

### 4. La skill `sdd`

`.agents/skills/sdd/SKILL.md` es la ubicación más portable que hay: la usa OpenCode, Claude
Code y varios más, porque es un estándar emergente (`agentskills.io`). El frontmatter es de dos
campos y ambos se pueden portar sin cambios.

## Qué hacer para adaptarlo

1. **Empieza por `AGENTS.md`.** Es lo estándar y lo más importante. Copia la sección de la
   tabla anterior al principio de tu `AGENTS.md` con lo que aplica a tu agente.
2. **Las skills probablemente ya funcionan.** Si tu agente lee `.agents/skills/`, no hay nada
   que hacer.
3. **Los subagentes son opcionales.** Si tu agente no los tiene, el principio 7 se cumple
   haciendo el reparto en el mismo agente principal. El catálogo se consulta como criterio, no
   como instalación.
4. **Lo que no depende de nada son los documentos de método.** `CONSTITUTION.md`, `SDD.md`,
   `EARS.md`, `EXPECT.md`, `MEMORY.md`, `DEPURACION.md`, `REFACTOR.md` se copian tal cual.

## Lo que no cambia con ningún agente

Esto es lo que de verdad justifica el sistema:

| Documento | Por qué es independiente |
|---|---|
| Los 9 principios | Reglas de trabajo, no de herramienta |
| `SDD.md` | Un flujo de trabajo sobre carpetas y Markdown |
| `EARS.md` | Sintaxis de requisitos, no de agentes |
| `EXPECT.md` | Criterios de terminado, no de agentes |
| `MEMORY.md` | Protocolo de un archivo de texto |
| `DEPURACION.md` | Método de depuración, anterior a los agentes |
| `REFACTOR.md` | Método de refactor, anterior a los agentes |
| `verificar.ps1` | PowerShell puro, sin dependencias |

**Siete documentos de veinte no mencionan ninguna herramienta.** Es la medida de
portabilidad del sistema, y está aquí para que quede escrita.

## Con otros modelos de lenguaje

No hay diferencia: los documentos son texto y el modelo los lee. Lo que cambia con el modelo es
cuánta documentación conviene tener cargada a la vez.

| Modelo | Contexto amplio | Recomendación |
|---|---|---|
| Cualquiera | cargado al inicio | Tres documentos: `AGENTS.md`, `MEMORY.md`, constitución |
| Con ventana grande | cabe más | Añadir `EXPECT.md` y la spec activa |
| Con ventana pequeña | hay que recortar | Cargar por tarea, con `instructions` si el agente lo permite |

**La lección no depende del modelo.** Cuando la ventana de contexto se llena, el modelo deja de
recordar el principio de los primeros documentos y empieza a inventar. Dividir la instrucción
para cargarla bajo demanda funciona con todos.

Lo que sí cambia entre modelos es la **fidelidad a un formato estricto**. Un modelo puede
aceptar una spec ambigua y otro no. Por eso el principio 4 —verificable o no existe— es más
importante cuanto mejor es el modelo: **un modelo mejor no compensa una spec peor.**