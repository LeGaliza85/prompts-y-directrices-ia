# AGENTES.md — Catálogo de subagentes

> Catálogo de subagentes del sistema. **No es la instrucción maestra de un proyecto**: esa
> es `directrices/AGENTS.md`, sin E. Los dos documentos se llaman casi igual y hacen cosas
> distintas, así que se citan siempre por ruta completa.

## Aviso de nombre

| Archivo | Qué es | Dónde vive |
|---|---|---|
| `directrices/AGENTS.md` | Instrucción maestra del proyecto. Qué haces, cómo cargas el contexto. | En este repositorio y copiado a cada proyecto |
| `directrices/AGENTES.md` | Este catálogo. Qué subagentes hay, cómo se crean y cuándo se usan. | Solo aquí |

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

Un subagente es un archivo Markdown con frontmatter YAML. Sintaxis verificada para
opencode 1.3.11:

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

## El catálogo base

Cuatro agentes de partida para un proyecto con SDD.

| Agente | Qué hace | Permisos clave | No debe |
|---|---|---|---|
| `coordinator` | Primario. Dirige el flujo SDD, habla contigo y reparte el trabajo entre subagentes. | `permission.task` con globs sobre los subagentes del proyecto. | Escribir código ni editar archivos. |
| `planner` | Subagente. Redacta spec, plan y tareas. | `edit` limitado a `specs/`. | Escribir código. |
| `implementer` | Subagente. Implementa una tarea de un plan aprobado, con la comprobación primero. | `edit` y `bash` acotados al alcance de la tarea. | Rediseñar, cambiar el plan o encadenar tareas. |
| `reviewer` | Subagente. Revisa como QA y valida requisito por requisito. | `edit: deny`; `bash` en lectura para tests. | Modificar archivos. |

`coordinator` solo delega en los subagentes que el proyecto tenga:

```yaml
permission:
  edit: deny
  task:
    "*": deny
    "planner": allow
    "implementer": allow
    "reviewer": allow
```

El orden importa: las entradas más específicas ganan, así que el glob de denegación va
antes que los nombres concretos.

## Bajo demanda

Siete agentes que se copian al proyecto solo cuando una spec lo justifica.

| Agente | Aporta | Restricción que le da sentido |
|---|---|---|
| `tester` | Escribe y ejecuta pruebas sobre lo que ya existe. | `edit` solo en el directorio de tests. |
| `debugger` | Traza un fallo hasta su causa y la documenta. | `edit` negado: diagnostica, no parchea. |
| `docs-writer` | Redacta y actualiza documentación a partir del código. | `edit` solo en `docs/` y archivos `*.md`. |
| `security-auditor` | Revisa secretos, entradas sin validar y permisos. | `edit: deny` y sin `webfetch`. |
| `refactorer` | Cambia estructura sin cambiar comportamiento. | `edit` sobre el módulo acordado, con tests obligatorios. |
| `perf-auditor` | Mide y señala cuellos de botella con datos. | Solo lectura; puede ejecutar perfiles. |
| `migrator` | Ejecuta una migración de datos o de formato. | `edit` sobre las rutas de la migración, `bash` con glob. |

Un agente de esta lista que llega sin su restricción de permisos es un prompt suelto con
nombre bonito.

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

## Primeros pasos en un proyecto nuevo

1. Copia los cuatro agentes base a `.opencode/agents/`.
2. Revisa que la sintaxis de `permission` coincide con la versión de opencode instalada.
3. Ajusta los globs de `task` de `coordinator` a los agentes que existan de verdad.
4. Añade agentes de «Bajo demanda» solo cuando una spec lo pida.
5. Anota en `MEMORY.md` qué subagentes hay y por qué, para no volver a crearlos.
