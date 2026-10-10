# REFACTOR.md — Cambiar la estructura sin cambiar el comportamiento

Refactorizar es mejorar cómo está escrito el código sin alterar qué hace. Es la tarea con más
trampas, porque el error no se ve en el momento: se ve semanas después, en un sitio que
parece no tener relación.

## La condición para poder refactorizar

**Si no hay una comprobación que verifique el comportamiento actual, no se refactoriza.**

Sin esa red, un refactor es una reescritura con buenas intenciones. Antes de tocar nada:

1. Ejecuta la comprobación.
2. Comprueba que está en verde.
3. Si no hay pruebas, propón escribirlas primero.

Un refactor sin pruebas no es refactorizar: es cambiar el código y esperar.

## Las reglas

**Un cambio de estructura cada vez.** Renombrar, extraer una función y mover un archivo son
tres tareas. Hacerlas juntas convierte un fallo en algo imposible de localizar: si algo se
rompe, no se sabe cuál de los tres fue.

**El comportamiento no cambia.** Si hay que arreglar un fallo, es otra tarea, en otra spec.
Refactorizar y corregir a la vez es cómo se cuela un comportamiento nuevo sin que nadie lo
apruebe.

**Se comprueba después de cada paso**, no al final. Un refactor de diez pasos con una sola
comprobación al final oculta en qué paso se rompió.

**Si algo se rompe, se vuelve atrás.** No se apilan arreglos sobre una estructura que ya no se
sostiene. Deshacer y tomar otro camino es más rápido que reparar.

## Lo que no es refactorizar

- **«Aprovechar» para arreglar algo.** No te lo han pedido. Va en otra tarea.
- **Añadir una abstracción para un caso que aún no existe.** Cuando llegue el segundo caso, se
  abstrae. Antes, es especulación.
- **Cambiar el formato de los datos.** Eso rompe a quien los lee, y requiere migración.
- **Reescribir porque el código no te gusta.** El criterio no es el gusto, es que el cambio
  haga algo más fácil de mantener o de comprobar. Si no lo hace, no es refactorizar.

## La secuencia segura

1. Escribe la comprobación del comportamiento actual, si no existe.
2. Ejecútala. Comprueba que está en verde. **Si no, para.**
3. Aplica **un** cambio de estructura.
4. Ejecuta la comprobación otra vez.
5. Si está en verde, repite desde 3. Si está en rojo, deshaz el cambio y toma otro camino.

La comprobación al final de cada paso es lo que distingue un refactor de una apuesta.

## Cuándo refactorizar

**Sí.**

- Antes de añadir una funcionalidad a código que la va a dificultar.
- Cuando el mismo código aparece por tercera vez.
- Cuando un cambio pequeño obliga a tocar muchos sitios.

**No.**

- Sin comprobación que lo respalde.
- En código que nadie va a tocar.
- Como tarea suelta, sin una funcionalidad que la justifique.

El mejor momento es **justo antes** de necesitar el cambio, no en una tarea aparte.

## Lo que se entrega

Al terminar, di:

1. Los cambios de estructura aplicados, uno por uno.
2. El resultado de la comprobación antes y después.
3. **Cualquier comportamiento que haya cambiado**, aunque parezca una mejora. Si el
   comportamiento se movió, no era un refactor.
