---
description: SDD · Divide el plan en tareas pequeñas y verificables
agent: plan
---

A partir de `specs/$1/spec.md` y `specs/$1/plan.md`, genera `specs/$1/tasks.md` siguiendo el
formato de la skill `sdd`:

```markdown
- [ ] **Tn. <Descripción>.** RF-x, RF-y
  - Hecho cuando: <comprobación verificable>.
```

Reglas:

- **Máximo 20-30 minutos por tarea.** Si una tarea no se puede acabar en ese tiempo, se divide.
- **En orden de dependencia.** Una tarea que necesita otra va después.
- Cada una con **los requisitos que cubre** y una línea «Hecho cuando:» que se pueda comprobar
  ejecutándola.
- **Máximo 10 tareas.** Si salen más, propón dividir la spec en dos y dímelo.
- La última tarea es de **cierre**: recorrer los requisitos, comprobar los criterios de
  finalización y actualizar `MEMORY.md`.
