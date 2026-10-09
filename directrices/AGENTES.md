# AGENTES.md — Catálogo de subagentes

> Catálogo de subagentes del sistema. **No es la instrucción maestra de un proyecto**: esa
> es `directrices/AGENTS.md`, sin E. Los dos documentos se llaman casi igual y hacen cosas
> distintas, así que se citan siempre por ruta completa.

## Aviso de nombre

| Archivo | Qué es | Dónde vive |
|---|---|---|
| `directrices/AGENTS.md` (sin E) | Instruccion maestra del proyecto: que haces y como cargas el contexto | En este repositorio y copiado a cada proyecto |
| `directrices/AGENTES.md` (con E, este archivo) | Catalogo de subagentes: cuales hay, como se crean y cuando se usan | Solo en este repositorio |

Dos archivos distintos que se diferencian en una letra. Confirma la E antes de editar: si
sobrescribes el `AGENTS.md` sin E, pierdes la instrucción del proyecto.

## Los dos conceptos

**Agente primario.** El principal, el que habla contigo: `build` y `plan`. Recibe la
petición, conduce el flujo y responde. Es el que conserva el hilo y la memoria de la sesión.

**Subagente.** Un agente especializado al que el primario delega un trozo de trabajo.
Trabaja en su propia sesión, con su propio contexto y sus propios permisos, y devuelve un
resultado. No sigue la conversación: recibe lo que le pasen y nada más.

La diferencia práctica: el primario piensa el conjunto; el subagente ejecuta un encargo
acotado. Se invoca con `@nombre` o de forma automática cuando su `description` encaja con
lo que se está haciendo.

## Cómo se crea

Un subagente es un archivo Markdown con frontmatter YAML. Sintaxis verificada para la
versión instalada (1.4.0, ver `PIN.md`):

```yaml
---
description: <qué hace y cuándo usarlo; obligatoria>
mode: subagent
permission:
  edit: deny
  bash:
    "*": ask
    "git diff": allow
---
<cuerpo con las instrucciones>
```

**`description` es obligatoria** y es lo que usa el agente para decidir si lo invoca. Tiene
que decir cuándo usarlo, no solo qué hace: «revisa código» no basta, «revisa código como
QA y valida la spec requisito por requisito» sí.

**`permission`** acepta `"allow" | "ask" | "deny"`. Las claves útiles son `edit`, `bash`,
`webfetch`, `task`, `skill`, `read`, `glob`, `grep` y `todowrite`. En `bash` se admiten
globs: `"git *": allow`. Sin una entrada `permission`, el subagente hereda los permisos
globales, así que restringir es una decisión que se toma, no un estado por defecto.

Otras opciones del frontmatter: `model`, `temperature`, `top_p`, `steps` (límite de
iteraciones; `maxSteps` está obsoleto) y `hidden: true`, que lo oculta del autocompletado
de `@`.

> **AVISO:** la sintaxis antigua `permissions:` con lista de objetos
> `action` / `resource` / `effect` **no funciona en esta versión**. El material de cursos
> anteriores la usa. Copiada tal cual, el archivo se carga sin error, pero no aplica
> ninguna restricción: el fallo es silencioso. Verifica la sintaxis contra tu versión
> instalada. Detalle en `APIS-VERIFICADAS.md`.

## Quién necesita cada proyecto

No hay un equipo fijo. Un proyecto web no necesita lo mismo que uno de datos, igual que un
edificio no necesita el mismo equipo que una campaña de publicidad. El conjunto de agentes
lo determina **el trabajo que el proyecto hace**, no una lista de partida.

| Tipo de proyecto | Lo que suele necesitar |
|---|---|
| Web con interfaz | `planner`, `implementer`, `reviewer`, `frontend-reviewer`, `tooling-advisor` |
| API o backend | `planner`, `implementer`, `reviewer`, `security-auditor`, `tester`, `tooling-advisor` |
| Datos o estadísticas | `planner`, `implementer`, `reviewer`, `debugger` |
| CLI o herramienta | `planner`, `implementer`, `reviewer` |
| Móvil | `planner`, `implementer`, `reviewer`, `perf-auditor` |
| Infraestructura o despliegue | `planner`, `security-auditor`, `migrator`, `reviewer` |
| Solo documentación | `planner`, `docs-writer`, `reviewer` |

Todos comparten dos piezas: alguien que **planifique** y alguien que **revise**. Sin
planificación no hay spec; sin revisión, el principio 5 no se cumple.

La tabla es un punto de partida, no una plantilla. Si el proyecto es un backend con una
parte visual que importa, se anade `frontend-reviewer` y ya está.

## El catálogo completo

Doce agentes de trabajo, mas `coordinator`, que es opcional. Cada uno con el trabajo que
hace y la **restricción de permisos** que lo justifica, que es lo que de verdad lo convierte
en agente y no en un prompt con nombre.

### Del flujo SDD

| Agente | Trabajo | Restricción que le da sentido |
|---|---|---|
| `planner` | Redacta spec, plan y tareas. | `edit` limitado a `specs/`. Nunca escribe código. |
| `implementer` | Implementa una tarea de un plan aprobado, comprobación primero. | `edit` y `bash` acotados a la tarea. No redisena. |
| `reviewer` | Revisa como QA y valida requisito por requisito. | `edit: deny`. No modifica nunca nada. |

### De especialidad

| Agente | Trabajo | Restricción que le da sentido |
|---|---|---|
| `tester` | Escribe y ejecuta pruebas sobre lo que ya existe. | `edit` solo en el directorio de tests. |
| `debugger` | Traza un fallo hasta su causa y lo documenta. | `edit` negado: diagnostica, no parchea. |
| `docs-writer` | Redacta y actualiza documentación desde el código. | `edit` solo en `docs/` y archivos `*.md`. |
| `security-auditor` | Revisa secretos, entradas sin validar y permisos. | `edit: deny` y sin `webfetch`. |
| `refactorer` | Cambia estructura sin cambiar comportamiento. | `edit` sobre el módulo acordado, con tests obligatorios. |
| `perf-auditor` | Mide cuellos de botella con datos. | Solo lectura; puede ejecutar perfiles. |
| `migrator` | Ejecuta una migración de datos o de formato. | `edit` sobre las rutas de la migración, `bash` con glob. |
| `frontend-reviewer` | Revisa accesibilidad, diseño y vista móvil. | `edit: deny`; puede abrir navegador controlado. |
| `tooling-advisor` | Examina el proyecto y propone comandos, skills, MCP o agentes que ayuden, con su coste. | Todo denegado: `edit`, `bash`, `webfetch`. No instala ni activa nada. |

`tooling-advisor` merece una nota. Es el único agente del catálogo cuya salida no es
trabajo hecho, sino decisiones para que tú tomes. Existe porque aconsejar bien exige
demostrar el hueco antes de proponer, y eso es más fácil de hacer sin permiso para tocar
nada: quien no puede arreglarlo, no tiene la tentación de ofrecer el arreglo.

Su regla contra recomendar de más es una prueba que se aplica a cada propuesta:

> ¿Sin esto, el trabajo se para, se repite a mano, o se comprueba peor?

Si la respuesta a las tres es no, es una preferencia y no se envía. Un asesor que recomienda
mucho acaba siendo ignorado, y entonces no asesora nada.

### Coordinación

`coordinator` —primario— dirige el flujo SDD repartiendo entre subagentes y hablando
contigo. Es **opcional**: solo se justifica en proyectos con specs largas, de varias fases.
En el resto, el primario coordina directamente, porque delegar no requiere autorización
previa (principio 7).

## El criterio para crear uno nuevo

Un subagente nuevo solo si aporta una **restricción de permisos** o una **especialidad**
que los existentes no cubren.

- Si la diferencia es solo el texto del prompt, es un **comando**, no un agente.
- Si la diferencia es solo el modelo, configura el campo `model` en el agente existente.
- Si la diferencia es solo el momento, ya lo resuelve la descripción del primario.

La razón es el coste: cada subagente nuevo es contexto que se transpasa, un archivo que
mantener y un nombre más en el catálogo. Veinte agentes que hacen lo mismo multiplican ese
coste sin dividir el trabajo.

## Reglas de coordinación

Los subagentes no ven la conversación del principal. Al delegar hay que pasarles:

1. La fase del flujo SDD en la que estás.
2. La petición original con tus palabras.
3. Las rutas de los archivos que debe leer.
4. El resultado de la fase anterior, si lo hay.

- **No se delega la coordinación.** Repartir el trabajo entre subagentes es del primario.
- **No se delega una cadena** en la que cada fase alimenta a la siguiente: encadenar
  sesiones cuesta más que hacerlo en una.
- Delegar con beneficio **no requiere tu autorización previa** (principio 7). Sí se
  consulta si el paralelismo rompe una regla del flujo SDD.
- Si explicar el encargo ocupa más que hacerlo, hazlo tú.

## Cómo se elige

Dados los agentes existentes y la tarea, se decide así:

1. **¿Es trabajo de planificar, de implementar o de revisar?** Son los tres que todo
   proyecto con specs necesita. Si el proyecto no tiene ninguno de los tres, le falta algo.
2. **¿La tarea tiene una restricción de permisos propia?** Un auditor de seguridad que
   pudiera editar no es un auditor. Si el trabajo necesita un permiso distinto al del que
   existe, es un agente nuevo.
3. **¿La tarea se aparta de lo que el proyecto hace?** Revisar accesibilidad en un
   proyecto que nunca la ha revisado justifica `frontend-reviewer`, aunque el proyecto ya
   tenga `reviewer`.
4. **¿Se puede hacer con lo que hay?** Entonces no se crea nada.

El limite lo marca la necesidad. Un proyecto con tres agentes que trabajan bien esta mejor servido que uno con trece que se pisan.

## Primeros pasos en un proyecto nuevo

1. Mira la fila de «Quién necesita cada proyecto» que corresponda al tipo de proyecto.
2. Copia a `.opencode/agents/` los agentes de esa fila, más los que la situación pida.
3. Sustituye `<COMANDO_DE_COMPROBACIÓN>` en los permisos de `implementer` y `reviewer`.
4. Revisa que la sintaxis de `permission` coincide con la versión instalada (ver
   `PIN.md` y `APIS-VERIFICADAS.md`).
5. Con el tiempo, anade o quita según lo que el proyecto vaya necesitando.
5. Anota en `MEMORY.md` qué subagentes hay y por qué, para no volver a crearlos.
