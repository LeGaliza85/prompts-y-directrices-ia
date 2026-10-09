# curso/ — Material de origen

Material del curso de desarrollo con IA del que salen estas directrices.

## Estructura

| Carpeta | Qué hay |
|---|---|
| `originales/` | Los tres PDF del curso, **sin modificar**. Con su hash SHA256 para poder comprobar que siguen intactos. |
| `apuntes/` | Lo extraído, organizado por tema y no por día del curso. |

## Por qué hay dos copias

El PDF es la fuente original: se conserva tal cual para poder contrastar cualquier cosa. Los
apuntes son la versión **trabajada**: lo que de ese material es reutilizable, separado de lo
que era específico de la aplicación de ejemplo.

Mira siempre primero los apuntes. El PDF se abre cuando hay que comprobar algo concreto.

## Qué se sacó y a dónde fue

| Del curso | Directriz que salió |
|---|---|
| Fundamentos de LLM: tokens, contexto, alucinaciones | `apuntes/fundamentos.md` |
| Prompt engineering de 5 pasos | `apuntes/prompt-engineering.md` |
| AGENTS.md, estructura y límites | `plantilla/AGENTS.md` |
| MEMORY.md y su protocolo | `directrices/MEMORY.md` |
| Context engineering, harness y guardarraíles | `apuntes/context-engineering.md` |
| Spec-Driven Development, 7 pasos | `directrices/SDD.md` |
| EARS | `directrices/EARS.md` |
| Comandos personalizados | `plantilla/.opencode/commands/` |
| Skills | `plantilla/.agents/skills/sdd/SKILL.md` |
| Multiagentes, los cuatro roles | `directrices/AGENTES.md` |
| MCP | `directrices/CAPACIDADES.md` |
| Herramientas y atajos de OpenCode | `directrices/OPENCODE.md` |

## Lo que no se aprovechó

- **La sintaxis de permisos del curso**, que es antigua. Está registrada en
  `directrices/aprendido.md`.
- **Los límites de longitud** (30-40 líneas para `AGENTS.md`, ~50 para `MEMORY.md`), que
  eran de aquel proyecto y no de ninguno en general.
- **Los datos concretos de la app de ejemplo.** La app fue el vehículo; lo reutilizable es el
  método.
- **La recomendación de herramientas específicas** del curso sin verificar. Están en
  `CAPACIDADES.md`, marcadas con su fecha de comprobación.

## Aviso

El material es de un curso con derechos de autor. Estas notas son un resumen estructurado de
lo reutilizable, no una transcripción. Los PDF originales están aquí para consulta personal.
