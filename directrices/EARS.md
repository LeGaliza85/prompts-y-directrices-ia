# EARS.md — Cómo se escribe un requisito

> Sintaxis para que un requisito no sea ambiguo. Si un requisito no se puede comprobar, no
> es un requisito.

## Por qué una sintaxis y no solo buena intención

«El sistema debe ser rápido» no se puede verificar: nadie puede decir qué rápido es
suficiente y qué lento es un fallo. «El sistema responde en menos de 200 ms en el percentil
95» sí.

La diferencia parece de redacción pero no lo es. Un requisito no verificable **pasa el
control de calidad**: parece específico, se lee bien y llega a la implementación. El error
solo aparece cuando ya es caro corregirlo — o nunca aparece.

Un requisito con criterio medible se convierte casi directamente en un test. Esa es la
razón práctica: obligarse a escribirlo verificable ahora evita tener que adivinarlo después.

## Los cuatro patrones

**CUANDO** `<evento>`, **EL SISTEMA** `<respuesta>`.

El caso normal. Un disparador y un resultado.

> CUANDO el usuario registre una sesión de estudio, EL SISTEMA la guarda y actualiza la
> racha del día.

**SI** `<condición no deseada>`, **ENTONCES** **EL SISTEMA** `<respuesta>`.

El error. Es el patrón que más se olvida y el que más casos límite cubre.

> SI la fecha indicada no tiene ninguna sesión, ENTONCES EL SISTEMA la cuenta como día
> sin estudiar y no rompe la racha.

**MIENTRAS** `<estado>`, **EL SISTEMA** `<respuesta>`.

Un comportamiento que se mantiene mientras algo es cierto.

> MIENTRAS la sesión esté sin guardar, EL SISTEMA desactiva el botón de confirmar.

**EL SISTEMA** `<comportamiento permanente>`.

Una regla que siempre se cumple. Sin disparador.

> EL SISTEMA guarda los datos en el navegador, nunca en un servidor.

## La estructura SI-ENTONCES

Lo que hace útil al patrón de error es la palabra **ENTONCES**: obliga a decidir qué hace
el sistema cuando algo va mal.

Sin ella, un requisito dice qué debe pasar en el camino feliz y deja el resto a la
interpretación de quien implemente. Y quien implemente no es quien va a descubrir el
problema: lo descubre el usuario, en producción, con datos reales.

Un requisito de error escrito de verdad tiene esta forma:

> **SI** `<condición>` **ENTONCES** **EL SISTEMA** `<respuesta observable>`

Las cuatro piezas: la condición es concreta y esperable; la respuesta es algo que se puede
observar, no una intención.

## Las cinco reglas para que un requisito sea bueno

**1. Una frase, un comportamiento.** Nada de párrafos donde el agente tenga que interpretar
qué de lo que dice es un requisito y qué es contexto.

**2. Comportamiento observable.** El resultado se ve desde fuera: una pantalla, una
respuesta, un archivo, un valor devuelto. «El usuario siente que la app responde» no es
observable.

**3. Sin adjetivos sin número.** «Rápido», «bonito», «intenso», «robusto», «intuitivo» se
descartan o se convierten en algo medible. Si no puedes medirlo, no es un requisito: es una
intención.

**4. Verificable por un mecanismo concreto.** Antes de escribirlo, piensa en cómo se
comprobará: un test, una comprobación manual, una captura. Si no hay forma de comprobarlo,
el requisito no está listo.

**5. El error es parte del requisito.** Un comportamiento sin su caso de fallo no está
completo. Es la mitad que se olvida y la que más aparece en producción.

## Un ejemplo completo, con lo que no debe ponerse

**Mal.** «La aplicación debe ser fácil de usar y mostrar la información de forma clara y
rápida, incluyendo las sesiones del usuario.»

Tres comportamientos distintos en una frase, ninguno verificable. «Fácil de usar», «clara» y
«rápida» no se pueden comprobar. Y no dice qué pasa si las sesiones no existen.

**Bien.**

> **RF-1.** CUANDO el usuario registre una sesión, EL SISTEMA la guarda y la muestra en la
> lista de más reciente a más antigua.
>
> **RF-2.** CUANDO el usuario abra la aplicación, EL SISTEMA muestra la racha actual en
> formato numérico grande.
>
> **RF-3.** SI no hay ninguna sesión guardada, ENTONCES EL SISTEMA muestra un mensaje
> indicando que todavía no hay sesiones, en lugar de una lista vacía.
>
> **RF-4.** MIENTRAS el formulario tenga el campo de minutos vacío, EL SISTEMA desactiva el
> botón de guardar.
>
> **RF-5.** EL SISTEMA guarda los datos en el navegador del usuario y no los envía a ningún
> servidor.

Cinco requisitos. Cada uno comprobable por separado, con dos casos de error explícitos.

## Lo que **no** va en un requisito

- **Stack, arquitectura o nombres de archivo.** Son del plan (ver `SDD.md`).
- **Justificaciones.** El porqué va en el contexto de la spec, no dentro del requisito.
- **Adjetivos sin criterio medible.**
- **Varios comportamientos en una frase.**
- **Suposiciones sobre el código.** Un requisito describe el mundo, no la solución.

## Nomenclatura

**RF-x** — requisito funcional: qué hace el sistema.
**RNF-x** — requisito no funcional: cómo lo hace. Rendimiento, seguridad, accesibilidad,
compatibilidad. Se escriben con la misma exigencia de verificabilidad: «arranca en menos
de 2 segundos» o no es un requisito.

Los identificadores no son decorativos: una tarea dice qué RF cubre, y la validación los
recorre uno a uno. Sin identificador, no hay forma de comprobar que todo está cubierto.