# Context engineering, harness y guardarraíles

Del día 1 y el día 2 del curso. Es la parte que convierte un chat en un sistema de trabajo.

## Los tres conceptos

**Arnés (harness).** El sistema que rodea al modelo y le permite actuar como agente. Gestiona
contexto, herramientas y ejecución de tareas. Sin arnés, el modelo solo responde.

**Guardarraíles.** Reglas y controles que limitan sus acciones y validan sus resultados:
permisos, aprobaciones y comprobaciones de seguridad. Son la diferencia entre un agente que
hace lo que le pides y uno que hace lo que le pides **y nada más**.

**Contexto.** La información que tiene disponible para una tarea: instrucciones,
conversación, archivos, documentación y resultados de herramientas.

## La ingeniería de contexto

Consiste en **seleccionar, organizar y actualizar** esa información para que el agente reciba
lo relevante en cada momento. No se trata de meter más, sino de meter lo que toca.

Esto no es una preferencia de estilo. La ventana de contexto es finita, y cuando se llena el
modelo **empieza a olvidar el principio de los documentos y a alucinar**. La consecuencia
práctica es que cargar todo siempre es peor que cargar lo necesario: el exceso degrada la
calidad de lo que queda.

## Chat frente a agente

| Chat | Agente |
|---|---|
| Pregunta → respuesta | Bucle autónomo |
| Sin acceso al sistema | Lee y escribe archivos |
| Un solo turno | Ejecuta y verifica |
| Requiere copiar y pegar | Itera |

El salto cualitativo: pasar de **corregir líneas de código aisladas** a **validar
intenciones**. Esa es la razón por la que un chat convencional es una ineficiencia
estratégica para el trabajo de ingeniería.

## Los tres mecanismos de contexto

**Instrucciones (`AGENTS.md`).** El archivo que el agente lee para saber cómo trabajar en el
proyecto. Es lo primero de todo el sistema, y la razón de que exista este repositorio.

**Memoria (`MEMORY.md`).** Un agente arranca sin recordar nada. Lo que no está escrito en el
repo, no existe para él. La memoria es el puente entre sesiones, y su función es cubrir el
hueco entre lo que el código demuestra y lo que solo se decidió.

**Documentación (`docs/`, `specs/`).** La especificación: qué debe hacer el sistema y por qué.
La spec es la fuente de verdad del proyecto; el código es su consecuencia.

## Vibe coding frente a ingeniería de software

**Vibe coding.** Programar guiándose por la intuición y la IA para generar código rápido.
Describir y aceptar sin revisar. Rápido, divertido y peligroso.

**Ingeniería de software.** Diseñar y construir software de forma sistemática, con
arquitectura, control, pruebas y mantenimiento a largo plazo.

La diferencia no es la velocidad: es **quién responde de lo que se entrega**. El vibe coding
transfiere la responsabilidad al siguiente que abra el código.

## El modo Plan

El modo plan permite al agente analizar una tarea, consultar el proyecto y proponer los pasos
antes de ejecutarlos. Sirve para clarificar requisitos, detectar riesgos y revisar el enfoque
antes de escribir código.

| Usarlo | No usarlo |
|---|---|
| Tareas grandes | Tareas pequeñas |
| Refactors | Correcciones obvias |
| Supervisión de estrategia | Prototipado rápido |

La frontera práctica: **un cambio grande en modo de ejecución directa es un error de
proceso, no un atajo.**
