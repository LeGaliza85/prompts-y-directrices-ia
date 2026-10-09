# Spec 000 — Sistema de trabajo con IA

Estado: borrador

## Contexto y objetivo

Un curso de desarrollo con IA explica un método: prompt engineering, AGENTS.md, memoria,
Spec-Driven Development, comandos, skills, multiagentes y MCP. Pero ese método está explicado
para **una aplicación concreta**, y la sintaxis de la herramienta que usa el curso ya ha
cambiado.

El objetivo es convertir ese material en un sistema reutilizable: una capa genérica que
gobierne cómo se trabaja en cualquier proyecto, una plantilla que se copie al empezar uno
nuevo, y un registro que permita recuperar y aprender de lo usado en cada uno.

No es documentación. Es la parte del trabajo que decide si el siguiente proyecto se construye
sobre lo aprendido o desde cero otra vez.

## Usuarios

- Una persona que crea proyectos con agentes de IA y quiere que cada uno herede lo aprendido
  en los anteriores.
- Un agente que trabaja en un proyecto y necesita saber cómo, sin que se lo expliquen cada
  vez.

## Historias de usuario

- HU-1. Como persona que empieza un proyecto, quiero copiar una plantilla y tener el
  andamio listo, para no empezar desde cero.
- HU-2. Como persona que ya tuvo un problema, quiero que quede registrado con su causa, para
  no repetirlo.
- HU-3. Como persona que actualiza su herramienta, quiero saber qué se rompe, para no
  descubrirlo cuando un proyecto falla en silencio.
- HU-4. Como agente, quiero un catálogo con el coste de cada herramienta, para aconsejar sin
  adivinar.

## Requisitos funcionales

**RF-1.** CUANDO se cree un proyecto nuevo, EL SISTEMA proporciona una plantilla con
instrucción maestra, memoria, criterios de terminado, constitución y una spec de ejemplo.

**RF-2.** CUANDO una directiva se proponga, EL SISTEMA la muestra antes de escribirla y
espera aprobación.

**RF-3.** CUANDO una directiva se apruebe, EL SISTEMA la escribe en disco y la registra en la
bitácora con su razonamiento.

**RF-4.** CUANDO se produzca un error de proceso, EL SISTEMA lo registra con su causa y la
directiva que lo previene.

**RF-5.** CUANDO un proyecto requiera un subagente, EL SISTEMA ofrece un catálogo del que
elegir según el tipo de trabajo, con la restricción de permisos que justifica cada uno.

**RF-6.** CUANDO una tarea se pueda cubrir con una herramienta externa, EL SISTEMA la propone
con su coste desglosado y espera aprobación.

**RF-7.** CUANDO la versión de la herramienta cambie, EL SISTEMA indica qué superficies hay
que revalidar y cómo.

**RF-8.** CUANDO un documento se escriba en español, EL SISTEMA lo comprueba antes de darlo
por bueno, detectando caracteres corruptos y palabras en otro idioma.

**RF-9.** SI una recomendación de herramienta se rechaza, ENTONCES EL SISTEMA guarda el
motivo y no la vuelve a proponer por el mismo motivo.

**RF-10.** MIENTRAS un proyecto esté activo, EL SISTEMA conserva su spec activa como la de
mayor número sin marcar como implementada.

**RF-11.** CUANDO un proyecto termine, EL SISTEMA archiva una copia literal de sus directivas
con una ficha.

**RF-12.** SI el trabajo se puede repartir en tareas independientes, ENTONCES EL SISTEMA lo
delega sin requerir autorización previa, y lo informa.

## Requisitos no funcionales

- Los documentos se cargan bajo demanda, no todos a la vez. Razón: la ventana de contexto es
  finita y cargar de más degrada lo que el modelo recuerda.
- La capa genérica se verifica contra una versión concreta de la herramienta, con fecha.
- El revisor y el asesor tienen todos los permisos de escritura denegados.
- Todo en español, tratando de tú al lector. Código en inglés, textos y documentación en
  español.

## Casos límite

- La herramienta se actualiza y una sintaxis deja de funcionar. Debe haber forma de saberlo
  sin que un proyecto falle en silencio.
- Un documento con acentos se corrompe al escribirlo. Ha pasado tres veces.
- Un subagente escribe un documento con un error de coherencia interna. Ha pasado.
- La misma herramienta se propone dos veces para el mismo proyecto.
- Un archivo se referencia pero no existe.
- La versión que marca el binario no coincide con la que ejecuta el CLI. Ha pasado.

## Fuera de alcance

- Automatizar la copia de la plantilla con un script. Se copia a mano hasta que haya
  evidencia de que merece la pena automaticarlo.
- Integración con repositorios remotos, CI o publicación.
- Cubrir herramientas que no sean OpenCode.
- Traducir la capa genérica a otros idiomas.
- Una interfaz gráfica.

## Criterios de finalización

- Los doce requisitos funcionales cubiertos por algo que exista en el repositorio, no por
  intención.
- La plantilla copiable y comprobada abriendo un proyecto nuevo con ella.
- El registro de errores de proceso con al menos tres entradas reales.
- La bitácora con las decisiones tomadas, su razonamiento y su alternativa descartada.
- `verificar.ps1` funcionando sobre todos los documentos.

## Dudas abiertas

- [NECESITA ACLARACIÓN] Si en el futuro hay un proyecto con plazo, ¿se recupera el orden de
  sacrificio "velocidad primero" que se descartó?
- [NECESITA ACLARACIÓN] ¿El archivo de la plantilla debe llamarse `opencode.jsonc` o
  `opencode.json`? La documentación usa ambos y el comportamiento puede diferir entre
  extensiones.
