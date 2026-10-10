# PRÓXIMA SESIÓN

**Fecha:** 2026-10-10
**Estado:** verificador en verde. 101 archivos, 0 incidencias.
**Último commit:** `18ef8d9` — el trabajo de esta sesión está sin commitear.

## Lee esto primero

El `AGENTS.md` de la raíz manda empezar por este fichero. Si algo aquí no cuadra con lo
que veas, gana lo que veas: este texto envejece, el repo no.

## Qué se ha hecho en esta sesión

### Código

Cuatro cosas muertas eliminadas y una rota:

- `verificar-interfaz.js`: fuera `chromeYaAbierto()`, que se definía y no se llamaba.
- La captura convertía el base64 a texto y de vuelta al
  base64: una ida y vuelta identidad. No convertía nada y el PNG no se podía abrir. Ahora
  entrega un bloque de bytes real y **se escribe en disco**. Comprobado: PNG de 18.886 bytes
  con la firma correcta. Antes la devolvía y nadie la consumía.
- `verificar.ps1`: fuera `$excepciones`, variable muerta, y el mensaje final que remitía
  a un mecanismo de excepciones inexistente.
- `watchdog.ps1`: fuera `$previos`, variable muerta.

### `verificar.ps1` (%d4 controles nuevos)

Cada uno nace de un defecto encontrado a mano. Automatizan lo que se buscaba con la vista:

1. **Comillas angulares desbalanceadas.** Se cuenta por archivo, no por línea, porque una
   cita abierta al final de una línea y cerrada en la siguiente es correcta. Eran 8 casos
   reales de este repo.
2. **Rutas inexistentes.** Dos reglas: con barra se resuelve contra el repo; sin barra se
   busca ese nombre en todo el repo, porque `tasks.md` en prosa significa «el de tu
   proyecto», no «uno de esta carpeta». La primera versión daba más de treinta falsos positivos.
3. **Párrafos duplicados.** Se juntan las líneas antes de comparar, porque el mismo texto
   partido en puntos distintos no se ve comparando líneas sueltas. Pilla el duplicado de
   `plantilla/LEEME.md` que se había escapado.
4. **Cifras desincronizadas.** Tres documentos dar tres números distintos (17, 20 y 21) es
   lo que pasaba. Se comprueba contra el recuento real.

### Texto

- 83 líneas de comillas rectas normalizadas a angulares, en cuarenta ficheros.
- 14 correcciones de sintaxis y 45 de erratas y tildes.
- `plantilla/LEEME.md`: párrafo duplicado eliminado, `QA` traducido, `anade`/`mas`
  corregidos.
- Cifras sincronizadas a 21 documentos y 101 archivos, en `AGENTS.md`, `INDICE.md` y
  `PROXIMA-SESION.md`.
- Corregida la referencia al fichero de configuracion, que no existe con ese nombre.
- «cinco casos límite» → cuatro, en los tres ficheros que lo decían.

### `nuevo-proyecto.ps1`

El último paso imprimía `<COMANDO_DE_COMPROBACION>` sin tilde, mientras el fichero tiene
`<COMANDO_DE_COMPROBACIÓN>` con tilde: copiar y pegar no encontraba nada. Ahora **lee los
marcadores del proyecto generado** y avisa de los que quedan dentro de bloques
`permission:`, que son los que no funcionan.

## Lo que se-rise mal y quedó documentado

Se afirmó que los 13 agentes estaban rotos por faltarles `tools:`. **Estaban bien**: la
lista real es `description`, `mode` y `permission`. Después se afirmó que el scaffolder no
sustituía sus marcadores y que era un fallo silencioso. Al extraer el regex del propio
script y probarlo contra el fichero real, salía **una coincidencia**: el marcador se
detecta y se avisa. El script cumplía su diseño, que es no inventar lo que solo sabe quien
pide el proyecto.

Está en `aprendido.md`, con la causa. La lección: **antes de decir que algo está roto,
ejecutar la comprobación y enseñar la salida.** Y extraer los patrones de los ficheros,
no escribirlos de memoria.

## Estado de las tareas

`specs/000-sistema-de-trabajo/tasks.md`: T1 a T12 hechas, **T13 pendiente**.

## Qué queda

1. **T13.** Terminar `C:\Proyectos\divisor` con subagentes. Rellenar sus marcadores y
   comprobar que los agentes cargan y funcionan. Los marcadores sin rellenar **son lo
   correcto**: la prueba es llenarlos y ver que el permiso pasa a funcionar.
2. **Segunda pasada de `tasks.md`.** T1 a T12 están hechas y siguen como ruido. Quitar las
   completadas y dejar solo lo que queda.
3. **Medir liveness con datos.** `watchdog.ps1` está probado contra un log sintético,
   nunca contra un subagente real atascado. T13 es la oportunidad.

## Antes de dar algo por bueno

```powershell
powershell -File verificar.ps1
```

Ha dado 0 incidencias en 101 archivos. Si aparece algo, mira primero si el texto tiene un
carácter corrupto antes de tocar el patrón.

## Acceso remoto

Se-mm tenancyó, sin ejecutar: Tailscale + `opencode web`, y RustDesk como alternativa.
**No se instaló nada.** Hechos verificados y guardados:

- `opencode web` y `opencode serve` existen. `--hostname` por defecto `127.0.0.1`.
- No hay flag `--auth`, pero el binario contiene `OPENCODE_SERVER_PASSWORD` y
  `OPENCODE_SERVER_USERNAME`, que sí sirven para protegerlo.
- ZED 1.23.2 está instalado. **No tiene cliente móvil**: su modelo es cliente → servidor
  por `ssh://`, y el cliente es el propio ZED. Para usar ZED desde el móvil hay que
  controlar el escritorio, no conectar ZED.

Nada de esto se ha aplicado. Queda como decisión, no como tarea hecha.