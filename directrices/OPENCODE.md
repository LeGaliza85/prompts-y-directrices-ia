# OpenCode — Referencia práctica del sistema

> Verificado contra **OpenCode 1.3.11** —binario `opencode-cli.exe` 1.3.11, plugin `@opencode-ai/plugin` 1.4.0,
> documentación oficial al 8 de octubre de 2026. Este documento describe la herramienta. El procedimiento
> está en `AGENTS.md`.

## Agentes disponibles

| Agente | Tipo | Para qué sirve | Herramientas |
|---|---|---|---|
| `build` | primario | Construcción y edición. Es el agente por defecto. | Todas |
| `plan` | primario | Análisis y planificación sin tocar ficheros. | Todas, pero por defecto pide aprobación para editar y para `bash` |
| `general` | subagente | Investigación y tareas multi-paso. | Todas salvo `todo` |
| `explore` | subagente | Explorar el código del proyecto. | Solo lectura |
| `scout` | subagente | Documentación externa y dependencias. | Solo lectura |

El sistema tiene además tres agentes ocultos —`compaction`, `title` y `summary`— que no se pueden
seleccionar.

**Cambiar de primario:** tecla `Tab`, o el keybind `switch_agent`.

**Invocar un subagente:** escribe `@` seguido del nombre (por ejemplo `@explore`), o deja que el agente
principal lo llame por su cuenta según la descripción de cada subagente.

## Comandos y atajos

| Comando | Qué hace |
|---|---|
| `/help` | Muestra la ayuda de OpenCode |
| `/init` | Genera o mejora el `AGENTS.md` del proyecto |
| `/agents` | Lista los agentes principales disponibles |
| `/mcps` | Activa o desactiva los MCP configurados |
| `/new` | Abre una sesión nueva |
| `/session` | Gestiona las sesiones guardadas |
| `/compact` | Compacta el contexto de la sesión actual |
| `/undo` | Deshace el último cambio aplicado |
| `/redo` | Rehace el último cambio deshecho |
| `/diff` | Muestra el diff acumulado de la sesión |
| `/status` | Estado del modelo, del contexto y de los MCP |
| `/exit` | Sale de OpenCode |

| Atajo | Qué hace |
|---|---|
| `Shift+TAB` | Alterna entre Build y Plan |
| `CTRL+T` | Cambia el nivel de esfuerzo del modelo |
| `CTRL+P` | Muestra todos los comandos disponibles |
| `@` | Referencia ficheros dentro del prompt |
| `!` | Ejecuta un comando de shell sin salir de la sesión |

## Modo Plan

El modo Plan analiza y propone sin escribir código. Úsalo para **clarificar requisitos**, **detectar
riesgos** y **revisar el enfoque** antes de tocar nada.

No lo uses en tareas pequeñas, correcciones obvias ni prototipado rápido: el coste de cambiar de modo
supera al beneficio.

Un buen prompt de plan pide cuatro cosas:

1. Cómo se implementa el cambio respetando las reglas de `AGENTS.md`.
2. Qué archivos se modifican y qué cambia en cada uno.
3. Casos límite y dudas que debo decidir yo.
4. Qué se actualizaría en `AGENTS.md` y `MEMORY.md`.

Cierra siempre con: «No modifiques ningún archivo hasta que apruebe el plan.»

## El campo `instructions`

OpenCode carga `AGENTS.md` automáticamente, pero **no interpreta referencias `@archivo.md` por sí solo**.
Para cargar ficheros externos hay que declararlos en `opencode.json`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["AGENTS.md", "MEMORY.md", "docs/constitution.md"]
}
```

Admite rutas locales, globs y URLs remotas. Las URLs tienen un tiempo de espera de 5 s: si no responden,
se ignoran y la sesión sigue.

Orden de precedencia, de mayor a menor peso:

1. Archivos locales subiendo desde el directorio actual hasta la raíz del worktree.
2. El global `~/.config/opencode/AGENTS.md`.
3. `~/.claude/CLAUDE.md`, solo si no hay ningún `AGENTS.md`.

Un `AGENTS.md` local siempre gana al global. Si un documento debe cargarse en todos los proyectos, se
declara en el fichero global, no en el de cada proyecto.

Cargar un documento no basta para que el agente lo lea cuando toca: la instrucción de lectura tiene que
estar escrita en `AGENTS.md`.

## Compatibilidad con Claude Code

`CLAUDE.md` se usa solo si no existe `AGENTS.md` en la misma carpeta. Hay compatibilidad con las skills
de `.claude/skills/`. Para desactivar toda esta compatibilidad, define la variable de entorno
`OPENCODE_DISABLE_CLAUDE_CODE=1`.

## Dónde se configuran las cosas

| Qué | Global (usuario) | Proyecto |
|---|---|---|
| Agentes | `~/.config/opencode/agents/` | `.opencode/agents/` |
| Comandos | `~/.config/opencode/commands/` | `.opencode/commands/` |
| Skills | `~/.config/opencode/skills/<nombre>/SKILL.md` | `.opencode/skills/<nombre>/SKILL.md`, `.agents/skills/<nombre>/SKILL.md` |
| MCP | — | `opencode.json` del proyecto, clave `mcp` |

Añadir un agente, comando, skill o MCP es activar una capacidad: consulta antes, siguiendo el principio 1
de `CONSTITUTION.md` y el formato de propuesta de `CAPACIDADES.md`.

## Aviso de versiones

Las APIs de OpenCode cambian entre versiones. Este documento se verificó el 8-oct-2026 contra la versión
1.3.11. Si algo no funciona, la causa más probable es un cambio de versión: consulta
`APIS-VERIFICADAS.md` y `PROCEDIMIENTO-ACTUALIZACION.md` en esta misma carpeta.
