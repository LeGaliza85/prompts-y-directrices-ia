# IMPROVE.md — Lo que funciona pero molesta

Para cosas que **no están rotas**: van lentas, obligan a repetir pasos, o existen sin motivo.
Va en `aprendido.md` lo que falla. Esto es lo que funciona y aun así se podría hacer mejor.

**Por qué este archivo existe.** Un sistema que solo aprende de los errores nunca mejora de lo
que ya va bien. Y el caso más frecuente no es una rotura: es un documento que funciona pero
cuesta tres pasos donde bastaría uno.

## El filtro

Una entrada entra aquí si cumple **las dos** condiciones:

1. **Funciona.** No hay nada roto. Si hay un fallo, va a `aprendido.md`.
2. **Muele.** Alguien perdió tiempo con ello. No es "podría ser más elegante".

La segunda condición es la difícil. «Se podría mejorar» no es motivo suficiente: casi todo se
podría mejorar, y una lista así crece sin priorizar y se lee menos que nada.

**La prueba de la molestia:** ¿hubo un momento concreto en que pensé «esto es un coñazo»? Si no
puedes señalar el momento, no hay entrada.

## Formato

```markdown
## AAAA-MM-DD — <qué molesta, en una frase>

**Dónde.** <archivo, comando o paso>
**Cuesta.** <tiempo, pasos oipanidad concreta>
**Propuesta.** <qué cambiar>
**Probado.** <si se probó en serio, o "no, es una idea suelta">
```

La línea **Probado** es la importante. Distingue lo que se mejoró porque se comprobó que
funcionaba de lo que se cambió porque a alguien se le ocurrió. Sin ella, esta lista se llena de
ideas de alguien que nunca va a mirar.

## Entradas

*Vacío todavía. La primera sale cuando alguien eche un coñazo.*

## Qué no va aquí

- **Errores.** Aunque ya estén corregidos. Van a `aprendido.md`, que es donde se busca cuando
  algo falla.
- **Funcionalidad que falta.** Eso es una spec nueva, o una entrada en laSpec 000.
- **Estilo.** Si son dos opinions sobre cómo escribir algo, es una conversación, no un archivo.
- **Propuestas sin motivo.** Si no puedes decir qué tiempo perdiste, espera a que lo pierdas.

## Cómo se aplica

Al leer este archivo antes de empezar una tarea:

1. ¿Alguna entrada toca lo que voy a tocar? entonces propón el cambio **en la misma tarea**, con
   su comprobación.
2. ¿Alguna entrada toca algo que ya estás cambiando? Aprovéchalo y aplícala: el coste es cero.
3. ¿Ninguna? sigue con la tarea y no pienses en esto.

**Regla:** un cambio de este archivo **no abre una tarea nueva**. Se aplica opportunisticamente,
cuando ya se está tocando esa zona. Abrir una tarea para "mejorar algo" es cómo se accumulate
deuda de refactor que nunca se paga.

Igual que con `REFACTOR.md`: sin comprobación que respalde, no se toca.

## Revisión

Cada pocas semanas, revisa la lista. Para cada entrada, una de estas tres:

- **Ya se aplicó.** Se borra: ya está en el código.
- **Resultó no ser molestia.** Se borra, y ese no-respuesta es información: la idea queda
  archivada.
- **Lleva mucho tiempo sin biting y nadie la ha tocado.** Se queda: no es urgente, pero
  tampoco se descarta.

Una lista que se recorta es una lista que se lee. Pero **se recorta lo que sobra, no lo que
simplemente lleva tiempo esperando**: esa espera es el dato.