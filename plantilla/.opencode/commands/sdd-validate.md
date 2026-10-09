---
description: SDD · Valida la especificación requisito por requisito
agent: build
---

Recorre `specs/$1/spec.md` **requisito por requisito**. Usa la skill `sdd`.

Para cada requisito indica:

- Qué comprobación lo cubre.
- El resultado de ejecutarla.

Los requisitos de interfaz que no se puedan comprobar automáticamente, verifícalos a mano y
**dime exactamente qué has hecho**: qué has abierto, qué has pulsado y qué has visto.

Después comprueba los **criterios de finalización** de la spec.

Si algún requisito no está cubierto o falla, **dilo claramente**. NO arregles nada todavía.

Termina con un veredicto: **¿la spec está cumplida?**
