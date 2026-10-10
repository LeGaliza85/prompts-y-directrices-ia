# Fundamentos de los LLM

Lo que hay que entender para trabajar con un modelo, no para entrenarlo. Del día 1 del curso.

## Cómo funciona

Un LLM es un modelo entrenado con grandes cantidades de texto para aprender patrones del
lenguaje y generar respuestas por probabilidad. El proceso:

1. Recibe el mensaje.
2. Lo procesa en fragmentos llamados **tokens**.
3. Calcula qué token podría venir a continuación, elige uno, y repite hasta completar la
   respuesta.

**Predice el siguiente token. No piensa; calcula probabilidades.** De aquí sale todo lo
demás.

## Los conceptos que importan trabajar con esto

**Parámetros.** Las «conexiones neuronales» que almacenan lo aprendido. Más parámetros, más
capacidad de representar patrones complejos.

**Tokens.** La unidad en que se procesa la información, y la que se usa para cobrar. El
modelo no lee palabras: lee y calcula tokens.

**Ventana de contexto.** La memoria a corto plazo del modelo en una conversación. Define
cuánto texto puede leer, procesar y recordar a la vez. **Si un proyecto excede ese límite, el
modelo empieza a olvidar requisitos previos o a alucinar.** Es la razón por la que la
gestión del contexto no es una optimización, sino una necesidad.

**Temperatura.** Ajuste al seleccionar tokens. Controla la aleatoriedad. Valores altos,
respuestas más variadas y menos predecibles.

**Alucinaciones.** El mayor defecto de un LLM: cuando no sabe la respuesta, se la inventa. La
contramedida no es pedirle que no invente, es **no darle ocasión**: contexto suficiente y
requisitos escritos.

**Razonamiento frente a rapidez.** Los modelos de razonamiento pausan, planifican y verifican
internamente sus pasos antes de responder. Son más lentos y más fiables. No hay uno mejor:
hay uno por tarea.

**Latencia.** El tiempo desde que se envía hasta el primer token. Se mide, y para tareas
interactivas importa más que la calidad marginal.

**Multimodalidad.** Capacidad de procesar imágenes, audio y vídeo, no solo texto.

## Tipos de modelos

**Pesos abiertos o cerrados.** Si se puede acceder a los parámetros del modelo, depende de la
licencia. Ojo: **pesos abiertos no significa código abierto** — puede faltar el código de
entrenamiento, los datos o los permisos de uso.

**Ejecución en nube o local.** Si el modelo corre en tu equipo o en servidores remotos. Un
modelo de pesos abiertos puede ejecutarse de las dos formas; los de pesos cerrados suelen
ofrecerse solo como servicio en la nube.

## Potencia, velocidad y coste

La elección es por tarea, no por modelo favorito:

| Tarea | Modelo |
|---|---|
| Pensar y decidir arquitectura | Potente |
| Trabajo del día a día | Medio |
| Tareas mecánicas y repetitivas | Rápido y barato |

Usar el modelo potente para todo es caro y a veces más lento. Usar solo el rápido produce
arquitectura mal razonada.

## Herramientas

El curso lista: Claude Code, OpenCode, Warp, Codex, ChatGPT, GitHub Copilot, Cursor,
Antigravity. Lo relevante no es cuál, sino que **el salto es de chat a agente**: dejar de
copiar y pegar para pasar a un sistema que lee, ejecuta y verifica.

## La idea que organiza todo

- Crear software no es programar.
- Los fundamentos importan más que nunca.
- Tú diriges, la IA ejecuta.
- Usar IA no es opcional.

Lo que cambia no es que el programador desaparezca: es que **el mercado deja de pagar por
teclear y empieza a pagar por orquestar**. La habilidad que gana valor son los fundamentos,
los requisitos, el diseño y la supervisión. La que lo pierde es la sintaxis pura.

Y la regla que cierra el curso: **la IA ejecuta, pero el responsable del proyecto eres tú.**
Potencia sin control no sirve de nada.
