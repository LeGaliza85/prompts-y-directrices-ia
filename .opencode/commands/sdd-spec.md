---
description: SDD · Entrevista y genera la spec. Uso: /sdd-spec 002-nombre idea inicial
agent: plan
---

NO escribas código en ningún momento. Lee `docs/constitution.md`, `MEMORY.md` y usa la skill
`sdd`.

Carpeta de la spec: `specs/$1/`
Idea inicial: $ARGUMENTS

Tu trabajo:

1. **Hazme preguntas de UNA en UNA** para eliminar ambigüedades: casos límite, comportamiento
   con errores, y qué queda fuera de esta versión. Máximo 5 preguntas. No supongas: si falta
   una decisión, pregunta.
2. Con mis respuestas, genera `specs/$1/spec.md` con la plantilla de la skill `sdd`: contexto
   y objetivo, usuarios, historias de usuario, requisitos funcionales en EARS, requisitos no
   funcionales, casos límite, fuera de alcance, criterios de finalización y dudas abiertas
   marcadas como `[NECESITA ACLARACIÓN]`. Marca `Estado: borrador`.
3. **Solo el QUÉ y el POR QUÉ.** Nada de stack, arquitectura ni nombres de archivo: eso va en
   el plan.
