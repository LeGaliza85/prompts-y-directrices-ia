---
description: SDD · Revisa la especificación como un QA. Solo detecta, no resuelve
agent: plan
---

Revisa `specs/$1/spec.md` como si fueras un QA muy profesional. Usa la skill `sdd`.

Lista, en formato numerado:

1. **Ambigüedades restantes.** Requisitos que no se pueden verificar: «rápido», «bonito»,
   «intuitivo», o cualquier cosa que no se pueda comprobar ejecutándola.
2. **Contradicciones entre requisitos.** Dos requisitos que no pueden cumplirse a la vez, o
   un requisito que contradice lo dicho en el contexto.
3. **Casos límite no cubiertos.** Vacío, duplicados, datos corruptos, valores en el borde,
   concurrencia, error de entrada.
4. **Conflictos con `docs/constitution.md`.**

**No propongas soluciones todavía: solo detecta.** Quien escribe la spec soy yo después; tú
encuentras lo que está mal.
