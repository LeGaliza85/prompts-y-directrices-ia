# Spec 001 — Contador con nombre guardado

Estado: borrador

## Contexto y objetivo

El proyecto necesita una funcionalidad mínima que sirva para comprobar el sistema entero: que
la spec se pueda implementar, que la lógica se pueda comprobar sin navegador, que la interfaz
se pueda verificar en uno, y que el flujo SDD completo se sostenga de principio a fin.

Un contador con nombre guardado cumple eso: tiene lógica pura, estado persistente, interfaz
visible y casos límite claros.

## Usuarios

- Una persona que abre la página y quiere que el contador recuerde su nombre.

## Historias de usuario

- HU-1. Como usuario, quiero poner mi nombre una vez, para no tener que escribirlo cada vez.
- HU-2. Como usuario, quiero ver cuántas veces he pulsado, para saber si el dato se guarda.

## Requisitos funcionales

**RF-1.** CUANDO la persona escriba un nombre en el campo y pulse guardar, EL SISTEMA lo
guarda y lo muestra en pantalla en lugar del campo.

**RF-2.** CUANDO la persona pulse el botón de contar, EL SISTEMA incrementa el contador en uno
y lo muestra.

**RF-3.** MIENTRAS el nombre esté guardado, EL SISTEMA mantiene el nombre visible al recargar
la página.

**RF-4.** SI el campo de nombre está vacío, ENTONCES EL SISTEMA no guarda nada y muestra un
mensaje pidiendo un nombre.

**RF-5.** SI el nombre solo contiene espacios en blanco, ENTONCES EL SISTEMA lo trata como
vacío.

**RF-6.** MIENTRAS no haya nombre guardado, EL SISTEMA muestra el campo para escribirlo.

**RF-7.** CUANDO la persona pulse reiniciar, EL SISTEMA pone el contador a cero y borra el
nombre guardado.

**RF-8.** SI la persona recarga con el contador a cero y sin nombre, ENTONCES EL SISTEMA
muestra el estado inicial sin errores en consola.

## Requisitos no funcionales

- La lógica del contador y del nombre son funciones puras, comprobables con `node --test`.
- El contador responde al pulsar, sin retardo perceptible.
- Los textos de la interfaz en español.

## Casos límite

- Nombre con espacios al principio y al final: se recorta antes de guardar.
- Nombre muy largo: se guarda tal cual, la interfaz no debe romperse.
- Contador con valor no numérico en `localStorage` por corrupción: se trata como cero.
- Recargar justo después de pulsar contar: el valor tiene que estar ya guardado.

## Fuera de alcance

- Varios contadores o varios nombres.
- Sincronización entre pestañas o dispositivos.
- Historial de pulsaciones.
- Anadir, restar o editar el contador a mano.

## Criterios de finalización

- Los ocho requisitos funcionales cubiertos: lógica con test, interfaz verificada en
  navegador.
- Los cuatro casos límite comprobados.
- Consola sin errores en el flujo completo.
- `MEMORY.md` actualizado.

## Dudas abiertas

- [NECESITA ACLARACIÓN] ¿El nombre se recorta solo por los extremos o también se colapsan los
  espacios internos? La spec actual dice solo extremos. Confirmar antes de implementar.
- [NECESITA ACLARACIÓN] ¿Reiniciar pide confirmación o es inmediato? La spec actual dice
  inmediato. Confirmar.
