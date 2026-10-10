# Prompt engineering

Del día 1 del curso. La técnica base, antes de que existan comandos, skills ni agentes.

## Los cinco pasos

**1. Rol — ¿quién soy?** Define el nivel de experiencia y la especialidad que asume la IA.
No es cosmético: cambia el vocabulario, el nivel de detalle y lo que da por supuesto.

> Actúa como desarrollador frontend senior que escribe código simple, claro y fácil de
> entender para alguien que está empezando a programar.

**2. Contexto — ¿dónde estamos?** De qué trata el proyecto, qué tecnologías hay y cuál es el
problema general. Es el paso que más se omite y el que más cuesta omitir: sin él, el modelo
rellena los huecos con el caso más común, que casi nunca es el tuyo.

**3. Tarea exacta — ¿qué necesitas?** Sé específico. En lugar de pedir «un sistema», pide algo
concreto, preferiblemente enumerado. Un prompt con tres puntos numerados se puede cumplir; uno
con tres párrafos se interpreta.

**4. Restricciones — ¿qué límites hay?** Convenciones, estándares, lo que no se permite. Este
paso es el que convierte un prompt en un contrato: sin él, el modelo decide los límites por ti.

> No añadas nada que no aparezca en este mensaje.

**5. Formato de salida — ¿cómo lo quiero?** Cómo quieres recibir la respuesta. Si no lo dices,
recibes lo que al modelo le parece natural, que rara vez coincide con lo que necesitas.

> Al terminar, responde con un resumen de 3-4 líneas, los pasos para probarlo y cualquier
> decisión que hayas tomado por tu cuenta y que yo deba revisar.

## Por qué funcionan en este orden

El orden no es arbitrario. Da al modelo primero **quién es**, luego **dónde está**, después
**qué hacer**, y por último **cómo entregarlo**. Cada paso reduce la ambigüedad del siguiente.

Los dos que más se saltan son el contexto y las restricciones. Y son los dos que determinan si
el resultado sirve: sin restricciones, el modelo añade lo que no le has pedido; sin contexto,
añade lo que sí le has pedido pero para otro proyecto.

## El prompt de 2026

El curso marca una diferencia entre el prompt engineering clásico y el actual. La clave es que
**el prompt ya no vive solo**: ahora hay instrucciones persistentes (`AGENTS.md`), memoria
entre sesiones (`MEMORY.md`), especificaciones (`specs/`) y catálogos de capacidades.

Un prompt largo que explica el contexto cada vez se sustituye por instrucciones que se cargan
solas. El prompt pasa a ser la tarea concreta, no el manual del proyecto.

Regla práctica: **si te repites en cada prompt, eso no es un prompt: es una instrucción**, y
debe subir a `AGENTS.md`. Si se repite con una estructura fija, es un comando.

## El modo Plan

Un matiz que el curso da y que merece sitio propio: antes de escribir código, pide un plan.

> Antes de escribir código, prepárame un plan con: cómo lo vas a implementar respetando las
> reglas de AGENTS.md; qué archivos vas a modificar y qué cambia en cada uno; los casos
> límite y las dudas que debo decidir yo antes de empezar; qué actualizarías en AGENTS.md y
> MEMORY.md.

Los cuatro puntos no son una formalidad. El tercero —los casos límite y las dudas— es el que
descubre los requisitos que no habías pensado, cuando todavía son gratis de cambiar.

## Markdown

El curso lo menciona y es relevante: los prompts se escriben en Markdown. No por estética,
sino porque la estructura —títulos, listas, bloques de código— la lee el modelo como
organización. Un prompt en prosa corrida se interpreta peor que el mismo prompt con listas.
