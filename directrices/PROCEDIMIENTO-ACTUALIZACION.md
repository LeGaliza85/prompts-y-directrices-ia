# PROCEDIMIENTO-ACTUALIZACION.md — Actualizar OpenCode

Qué hacer cuando cambia la versión de OpenCode. El material de este repo está verificado
contra la versión de `PIN.md`.

El modo de fallo peligroso es el silencioso: un archivo se carga sin error, pero no aplica
lo que dice. No busques errores; busca efectos.

## Pasos

1. **Antes de actualizar.** Anota la versión actual y comprueba que `PIN.md` la refleja.
   Ejecuta `opencode --version`. Ese número es el que manda: los metadatos del binario
   pueden quedar desfasados (confirmado: el binario instalado marcaba 1.3.11 mientras el
   CLI imprimía 1.4.0).
2. **Lee el registro de cambios oficial.** Busca cambios en agents, commands, skills,
   permissions, mcp y rules. Apunta las claves nuevas y las que desaparecen.
3. **Actualiza OpenCode.** Anota la versión nueva que quede instalada.
4. **Chequeo real.** Recorre cada fila de `APIS-VERIFICADAS.md` contra la versión nueva y
   comprueba que surte efecto de verdad: no que el archivo se carga, sino que hace lo que
   dice. Si una fila no se puede comprobar en la práctica, prueba el archivo equivalente
   de `plantilla/`.
5. **Corrige `plantilla/`.** Lo que haya dejado de funcionar: comandos, agentes, skill y
   `opencode.jsonc`.
6. **Actualiza `PIN.md`** con la versión y la fecha nuevas.
7. **Registra en `BITACORA.md`:** qué se completó y qué se rompió. Incluye lo que quedó
   sin comprobar.
8. **Si algo se rompe y no hay arreglo claro,** restaura la versión anterior y deja
   constancia en `BITACORA.md`.

## Síntomas de fallo silencioso

| Síntoma | Revisar |
|---|---|
| Un comando no aparece al escribir `/` | Nombre del archivo en `.opencode/commands/` y frontmatter con `description` |
| `$ARGUMENTS`, `$1` o `$2` salen literales en el prompt | Que la versión siga soportando esos marcadores |
| Un agente no aparece en `/agents` | El `description` del frontmatter y el campo `mode` |
| Un permiso de agente no surte efecto | Sintaxis antigua `permissions:` con `action`, `resource`, `effect` |
| Una skill no se activa nunca | Que `name` cumpla `^[a-z0-9]+(-[a-z0-9]+)*$` y coincida con la carpeta |
| Un glob o una URL de `instructions` no se carga | Que el patrón encaje y que la URL responda en menos de 5 s |
| Un MCP figura en `/mcps` pero no conecta | Tipo `local` con `command` o tipo `remoto` con `url` |
| `AGENTS.md` no se tiene en cuenta | Que el archivo esté en la raíz del proyecto y conserve ese nombre |

## Si solo quieres comprobar rápido

```powershell
opencode --version   # versión instalada
```

`/agents` — lista los agentes cargados. Comprueba que están los de `plantilla/`.
`/mcps` — estado de los MCPs. Comprueba que conectan los configurados.

Si estos tres controles salen bien, la instalación parsea la configuración. No sustituyen
al chequeo paso a paso.
