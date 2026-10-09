# Plantilla de proyecto nuevo

Copia esta carpeta entera a la carpeta del proyecto nuevo. Después sustituye cada marcador
`<...>`, elige los agentes que el proyecto necesite y borra el resto.

## Qué hay aquí

| Archivo | Qué es |
|---|---|
| `opencode.jsonc` | Configuración. Carga `AGENTS.md`, `MEMORY.md` y `docs/constitution.md` en cada sesión. Los MCP van comentados a propósito. |
| `AGENTS.md` | Instrucción maestra del proyecto. Lo primero que hay que rellenar. |
| `MEMORY.md` | Memoria entre sesiones. Empieza vacía. |
| `EXPECT.md` | Cuándo se da algo por terminado. |
| `docs/constitution.md` | Principios innegociables, con marcadores para el stack. |
| `specs/000-plantilla/` | Spec, plan y tareas de ejemplo. Sustituir por la primera spec real. |
| `.agents/skills/sdd/SKILL.md` | La skill con el flujo completo Spec-Driven Development. |
| `.opencode/agents/` | **Trece agentes candidatos.** El proyecto se queda con los que necesite. |

## Orden para ponerlo en marcha

1. **Elige los agentes.** Lee la tabla de abajo y quédate solo con los que apliquen. Borra
   el resto: un agente que no se usa es ruido en el catálogo y contexto que se transpasa.
2. **`docs/constitution.md`.** Rellena los marcadores. Stack, idioma, dónde se guardan los
   datos, cómo se comprueba. Es el documento que decide los demás.
3. **`AGENTS.md`.** Sustituye los marcadores. Las secciones que más cuesta rellenar después
   son *Reglas de dominio y trampas conocidas* y *Datos*. **No olvides `<RUTA_A_LAS_DIRECTRICES>`**: sin ella, las cuatro filas de la tabla de carga de contexto apuntan a archivos que no existen en el proyecto.
4. **Sustituye `<COMANDO_DE_COMPROBACIÓN>`** en los permisos de todos los agentes que
   hayas conservado, y `<RUTAS...>` o `<MÓDULO...>` donde aparezca.
5. **`specs/000-plantilla/`.** Usa la spec de ejemplo como referencia y bórrala, o
   reemplázala por la primera spec real.

## Qué agentes suele necesitar cada proyecto

| Tipo de proyecto | Agentes |
|---|---|
| Web con interfaz | `planner`, `implementer`, `reviewer`, `frontend-reviewer`, `tooling-advisor` |
| API o backend | `planner`, `implementer`, `reviewer`, `security-auditor`, `tester`, `tooling-advisor` |
| Datos o estadísticas | `planner`, `implementer`, `reviewer`, `debugger` |
| CLI o herramienta | `planner`, `implementer`, `reviewer` |
| Móvil | `planner`, `implementer`, `reviewer`, `perf-auditor` |
| Infraestructura o despliegue | `planner`, `security-auditor`, `migrator`, `reviewer` |
| Solo documentación | `planner`, `docs-writer`, `reviewer` |

Es un punto de partida, no una plantilla. Un backend con una parte visual que importa anade
`frontend-reviewer`. Un proyecto con datos que migrar de formato anade `migrator`.

Dos piezas son comunes a todos: alguien que **planifique** y alguien que **revise**. Sin
planificación no hay spec; sin revisión, el principio 5 no se cumple.

## Los trece candidatos

**Del flujo SDD**

| Agente | Trabajo | Por qué existe |
|---|---|---|
| `planner` | Redacta spec, plan y tareas. | Solo puede editar `specs/`. Nunca escribe código. |
| `implementer` | Implementa una tarea de un plan aprobado. | `edit` y `bash` acotados a la tarea. No redisena. |
| `reviewer` | Revisa como QA y valida requisito por requisito. | `edit: deny`. No modifica nunca nada. |

**De especialidad**

| Agente | Trabajo | Por qué existe |
|---|---|---|
| `tester` | Escribe y ejecuta pruebas. | `edit` solo en el directorio de tests. |
| `debugger` | Traza un fallo hasta su causa. | `edit` negado: diagnostica, no parchea. |
| `docs-writer` | Documenta desde el código. | `edit` solo en `docs/` y `*.md`. |
| `security-auditor` | Secretos, entradas y permisos. | `edit: deny` y sin `webfetch`. |
| `refactorer` | Cambia estructura sin cambiar comportamiento. | `edit` sobre el módulo acordado, con tests. |
| `perf-auditor` | Mide cuellos de botella. | Solo lectura. |
| `migrator` | Migra datos o formatos sin perder nada. | `edit` sobre las rutas de la migración. |
| `frontend-reviewer` | Accesibilidad, diseño y vista móvil. | `edit: deny`; puede abrir navegador. |
| `tooling-advisor` | Propone comandos, skills, MCP o agentes que ayuden, con su coste. | Todo denegado: no instala ni activa nada. |

**Coordinación**

| Agente | Trabajo | Por qué existe |
|---|---|---|
| `coordinator` | Dirige el flujo SDD repartiendo entre subagentes. | **Opcional.** Solo en specs largas. En el resto, el primario coordina directamente. |

El límite lo marca la necesidad. Un proyecto con tres agentes que trabajan bien está mejor
servido que uno con trece que se pisan.

Si hace falta uno que no está aquí, créalo solo si aporta una **restricción de permisos** o
una **especialidad** que estos no cubren. Si la diferencia es solo el texto del prompt, es
un comando; si es solo el modelo, es el campo `model` de un agente existente.

## Cómo copiarla

```powershell
Copy-Item -Recurse -Force "plantilla\*" "C:\ruta\del\proyecto\"
```

Después, en la carpeta del proyecto:

```powershell
Remove-Item -Recurse -Force ".git"   # si la copia arrastró el repositorio
git init
```

## Aviso de sintaxis

Los agentes usan `permission:` con mapa de claves, verificada en la versión instalada. Si
los copias de material más antiguo que use `permissions:` con `action` / `resource` /
`effect`, no funcionarán: el archivo se cargará sin error pero no aplicará ninguna
restricción. El fallo es silencioso.
