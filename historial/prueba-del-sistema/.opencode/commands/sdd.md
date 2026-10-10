---
description: SDD · Menú del flujo completo y qué comando usar en cada momento
agent: plan
---

Muestra el flujo SDD y en qué fase estoy. Usa la skill `sdd`.

```
Constitución → Spec → Clarificación → Plan → Tareas → Implementación → Validación → Cambio
```

| Fase | Comando | Para qué |
|---|---|---|
| Constitución | `/sdd-constitution` | Principios innegociables del proyecto. Una vez. |
| Especificación | `/sdd-spec 002-nombre idea` | Entrevista y redacción de la spec. |
| Clarificación | `/sdd-clarify 002-nombre` | Revisión como QA. Solo detecta. |
| Planificación | `/sdd-plan 002-nombre` | Plan técnico de una spec aprobada. |
| Tareas | `/sdd-tasks 002-nombre` | Dividir el plan en tareas verificables. |
| Implementación | `/sdd-implement 002-nombre T3` | Una tarea, comprobación primero. |
| Validación | `/sdd-validate 002-nombre` | Recorrer la spec requisito por requisito. |
| Cambio | `/sdd-change 002-nombre requisito` | Requisito nuevo: primero la spec. |
| Estado | `/sdd-status 002-nombre` | En qué fase estoy y qué toca ahora. |

Después, dime en qué fase está el proyecto y cuál es el siguiente paso concreto.
**No modifiques ningún archivo.**
