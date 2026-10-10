# DEPURACION.md — Cómo encontrar la causa de un fallo

Método para cuando algo no funciona y no se sabe por qué. Está pensado para que lo aplique
un agente, que es quien más veces cae en la tentación de parchear el síntoma.

## La regla que gobierna todo

**No se corrige lo que no se ha reproducido.** Sin reproducción no hay depuración: hay
adivinanza. Un arreglo aplicado sobre una suposición puede funcionar, y entonces no se sabe
por qué, y se vuelve a romper.

## El método

### 1. Reproduce

Documenta los pasos exactos que llevan al fallo, **incluidas las condiciones que parecen
irrelevantes**. Lo que parece no tener relación es a menudo lo que lo causa.

Si no se puede reproducir a voluntad, no se pasa a la fase siguiente: se buscan las
condiciones que lo disparan.

### 2. Aísla

Reduce el fallo al caso más pequeño que lo muestra. Si hacen falta tres cosas para que falle y
basta con una, ya sabes dónde mirar.

Preguntas que ayudan:

- ¿Falla con datos distintos?
- ¿Falla en el primer intento o solo después de varios?
- ¿Depende del orden de las acciones?

### 3. Formula una hipótesis

Una hipótesis útil tiene una **predicción**: qué se observaría si fuera cierta y qué se
observaría si fuera falsa.

*Mal:* «algo va mal con las fechas». No se puede comprobar.
*Bien:* «la fecha se desplaza un día porque se construye en UTC; si es eso, una sesión
registrada a las 00:30 en zona horaria positiva aparece con fecha del día anterior».

Sin predicción no hay forma de descartarla, así que no es una hipótesis: es una sospecha.

### 4. Verifica

Comprueba la predicción. Si se cumple, avanza. Si no se cumple, **descarta la hipótesis** y
formula otra.

No acumules hipótesis. Contrastar una cada vez es más lento y es lo que funciona: con tres
hipótesis abiertas, cualquier resultado parece confirmar alguna.

### 5. Documenta la causa

La causa raíz, con la evidencia que la sostiene. No el síntoma.

## Los fallos que se cometen

**Parchear el síntoma.** Silenciar el error, inicializar el valor que debería llegar o
envolver en un `try`. El fallo sigue ahí, solo ha cambiado de sitio. Suele aparecer después,
más caro.

**Cambiar dos cosas a la vez.** Si se tocan dos sitios y el fallo desaparece, no se sabe cuál
lo causaba. Un cambio, una comprobación.

**Fiarse de la intuición sobre dónde está.** El rendimiento y los fallos no están donde la
gente cree. La medición manda.

**Confundir explicación con excusa.** «Pasa a veces» no es una explicación. «Pasa cuando la
petición tarda más de X» sí lo es, y apunta a algo concreto.

**No verificar el arreglo con el caso que lo descubrió.** Se arregla, el test unitario pasa y
el caso original sigue roto. El test que se escribió no cubría el fallo real.

## Cuándo parar

Si tras tres hipótesis descartadas sigue sin aparecer la causa, **para y dilo**. Seguir
insistiendo gasta tiempo y produce arreglos aleatorios que esconden la causa.

Vale más entregar «no he encontrado la causa, esto es lo que he descartado y esto es lo que
sospecho» que un arreglo que parece funcionar.

## Cómo se comprueba que está arreglado

**El caso que lo descubrió deja de fallar.** No un test nuevo escrito para el arreglo: el caso
original, ejecutado.

Si no se puede reproducir el original, el arreglo no está verificado.
