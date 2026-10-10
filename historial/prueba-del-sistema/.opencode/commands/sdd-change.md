---
description: SDD · Requisito nuevo sobre una spec existente. Primero la spec, luego el código
agent: plan
---

Nuevo requisito para la spec `specs/$1/`: $ARGUMENTS

**NO toques código.** Usa la skill `sdd`.

1. Actualiza `specs/$1/spec.md`: nuevo requisito en EARS, sus casos límite, y lo que entra o
   sale del alcance. Si cambia un requisito existente, márcalo como cambiado.
2. Indica qué partes de `plan.md` y `tasks.md` habría que cambiar después. **No las cambies
   todavía.**
3. Muéstrame el diff de la spec y **espera mi aprobación**.

El orden es el que evita que el código y la spec se separen: primero la spec, después el plan
y las tareas, y por último el código.
