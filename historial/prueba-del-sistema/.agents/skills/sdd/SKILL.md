---
name: sdd
description: Usar siempre que se trabaje con Spec-Driven Development en este proyecto — redactar, revisar o cambiar specs, planes y tareas, o implementar y validar tareas de una spec. Se activa con docs/constitution.md o con cualquier archivo dentro de specs/.
---

# Spec-Driven Development

El flujo que gobierna este proyecto. Lo que no está en la spec activa no se implementa.

## Flujo

`Constitución → Spec → Clarificación → Plan → Tareas → Implementación → Validación → Cambio`

- Nunca se pasa de fase sin la aprobación explícita del usuario.
- La spec manda. Si algo no está en la spec, no se implementa; si falta una decisión, se
  para y se pregunta.
- Un cambio de requisito va primero a la spec, después al plan y las tareas, y por último
  al código.
- Cada spec vive en su carpeta `specs/NNN-nombre/` con `spec.md`, `plan.md` y `tasks.md`.
- Al terminar cada fase se actualiza `MEMORY.md`.
- La clarificación puede repetirse tras el plan o las tareas si algo sigue sin estar claro.

## Plantilla de spec

```markdown
# Spec NNN — <Nombre>

Estado: borrador | aprobada | implementada

## Contexto y objetivo
<Qué problema resuelve y por qué merece la pena. Un párrafo.>

## Usuarios
<Quién lo usa.>

## Historias de usuario
- HU-1. Como <rol>, quiero <acción> para <beneficio>.

## Definiciones
<Solo si hay términos que puedan interpretarse de varias formas.>

## Requisitos funcionales
<En EARS. Ver abajo.>

## Requisitos no funcionales
<Solo los que apliquen: rendimiento, seguridad, accesibilidad, plataformas, idioma.>

## Casos límite
<Vacíos, duplicados, datos corruptos, límites, concurrencia.>

## Fuera de alcance
<Lo que explícitamente NO se hace en esta iteración.>

## Criterios de finalización
<Qué tiene que estar comprobado para darla por cerrada.>

## Dudas abiertas
- [NECESITA ACLARACIÓN] <duda>
```

La spec describe el **qué** y el **por qué**. Nada de stack, arquitectura ni nombres de
archivo: eso va en el plan.

## Requisitos en EARS

Una frase, un comportamiento. Cada uno verificable.

- `RF-x:` CUANDO `<evento>`, EL SISTEMA `<respuesta>`.
- `RF-x:` SI `<condición no deseada>`, ENTONCES EL SISTEMA `<respuesta>`.
- `RF-x:` MIENTRAS `<estado>`, EL SISTEMA `<respuesta>`.
- `RF-x:` EL SISTEMA `<comportamiento permanente>`.

Sin adjetivos que no se puedan medir: «rápido», «bonito», «intenso», «robusto» se
descartan o se convierten en un número. El patrón `SI… ENTONCES` es el que obliga a pensar
en el error, que es lo que más se olvida.

## Plan

Archivos y su responsabilidad. Funciones puras —con la fecha actual como parámetro donde
aplique—. Algoritmo en pseudocódigo. Cómo se pinta en la interfaz. Decisiones técnicas
justificadas **con su alternativa descartada**. Estrategia de comprobaciones. Marca qué
requisito cubre cada parte.

## Tareas

```markdown
- [ ] **Tn. <Descripción>.** RF-x, RF-y
  - Hecho cuando: <comprobación verificable>.
```

Máximo 20-30 minutos por tarea, en orden de dependencia. No más de diez: si salen más, se
propone dividir la spec.

## Implementación

Una sola tarea cada vez:

1. Escribir primero la comprobación y ver que falla.
2. Escribir el código hasta que pase.
3. Ejecutar la comprobación y mostrar el resultado.
4. Marcar la tarea y **parar**. No empezar la siguiente.

Nunca dar una tarea por terminada con la comprobación en rojo.

## Validación

Recorrer la spec requisito por requisito. Para cada uno, qué comprobación lo cubre y su
resultado. Los requisitos de interfaz que no se puedan comprobar automáticamente se
verifican a mano, documentado. Comprobar también los criterios de finalización. Terminar
con un veredicto claro: cumplida o no.

## Mantenimiento

Un requisito nuevo sobre una spec existente: primero la spec, después el plan y las
tareas, y por último el código. Mostrar el diff de la spec y esperar aprobación antes de
tocar nada más.
