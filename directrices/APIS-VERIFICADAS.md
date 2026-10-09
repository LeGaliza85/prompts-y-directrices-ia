# APIS-VERIFICADAS.md — Inventario de superficies de configuración

Qué se ha comprobado de la sintaxis de OpenCode, contra qué versión y cuándo. La versión
está en `PIN.md`; el proceso para revalidar, en `PROCEDIMIENTO-ACTUALIZACION.md`.

Solo lo que aparece aquí como VERIFICADO puede usarse como referencia. El resto son
suposiciones.

## Estado de cada superficie

| Superficie | Sintaxis | Estado | Ultima comprobación |
|---|---|---|---|
| Reglas: `AGENTS.md` | Archivo de instrucciones del proyecto. OpenCode lo carga automáticamente. | VERIFICADO | 2026-10-09 |
| `instructions` en `opencode.json` | Carga archivos externos. Admite globs y URLs remotas, con timeout de 5 s. | VERIFICADO | 2026-10-09 |
| Comandos: `.opencode/commands/*.md` | Frontmatter con `description`, `agent`, `model`, `subtask`. Argumentos con `$ARGUMENTS`, `$1`, `$2`. | VERIFICADO | 2026-10-09 |
| Agentes: `.opencode/agents/*.md` | Frontmatter con `description`, `mode`, `permission`, `model`, `temperature`, `steps`, `hidden`, `top_p`. La sintaxis antigua `permissions:` con `action` / `resource` / `effect` NO FUNCIONA: el archivo se carga pero no aplica ninguna restricción, sin error. | VERIFICADO | 2026-10-09 |
| Skills: `.agents/skills/<nombre>/SKILL.md` | Frontmatter con `name` (obligatorio) y `description` (obligatoria), más `license`, `compatibility`, `metadata`. El nombre cumple `^[a-z0-9]+(-[a-z0-9]+)*$` y coincide con la carpeta. | VERIFICADO | 2026-10-09 |
| MCP: clave `mcp` en `opencode.json` | Dos tipos: `local` (con `command`) y `remoto` (con `url`). | VERIFICADO | 2026-10-09 |

Ejemplos mínimos de la sintaxis verificada:

```jsonc
{
  "instructions": ["AGENTS.md", "MEMORY.md", "docs/constitution.md"],
  "mcp": {
    "local": { "type": "local", "command": ["npx", "-y", "@upstash/context7-mcp"] },
    "remoto": { "type": "remote", "url": "https://mcp.context7.com/mcp" }
  }
}
```

```markdown
---
name: nombre-de-la-skill
description: Cuándo usar esta skill.
---

Instrucciones de la skill.
```

Convención de esta tabla:

- Cambios detectados al revalidar se marcan con `CAMBIADO:` y una nota al final de la fila.
- Lo que no está en la tabla es supuesto, hasta que se compruebe y se añada.

## Cómo revalidar

1. Abre la documentación oficial de OpenCode para la versión instalada, que figura en
   `PIN.md`.
2. Recorre cada fila de la tabla y comprueba que la sintaxis sigue siendo la misma: claves
   del frontmatter, comodines, expresión regular del nombre de la skill y tipos de MCP.
3. Anota lo que haya cambiado antes de tocar los archivos.
4. Corrige los archivos de `plantilla/` afectados: comandos, agentes, skill y
   `opencode.jsonc`.
5. Actualiza este archivo con la fecha nueva y marca con `CAMBIADO:` lo que se movió.
6. Actualiza `PIN.md` con la versión y la fecha nuevas.
7. Registra el resultado en `BITACORA.md`.

## Lo que NO está verificado

- Cualquier superficie que no tenga fila en la tabla. Se trata como supuesto hasta
   comprobarse.
- El curso de origen: su sintaxis es antigua y contradice esta tabla allí donde difieren.
   Manda esta tabla.
- Cualquier campo de frontmatter que no aparezca listado arriba.
- La ejecución real de cada caso: la verificación es contra la documentación oficial al
   2026-10-08, no contra el comportamiento observado de OpenCode en cada escenario.
- La sintaxis antigua de permisos (`action`, `resource`, `effect`) solo está confirmada
   como rota; no se ha comprobado si alguna versión la aceptó alguna vez.
