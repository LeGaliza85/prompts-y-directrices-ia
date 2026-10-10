# RECOMENDACIONES.md — Qué añadiría y qué no

La tercera pregunta que había que responder: qué añadiría el agente y qué recomendaría. Con
datos del propio repositorio, no de opinión.

**Fecha del análisis:** 2026-10-11, con 21 documentos, 33 archivos de plantilla, 13 agentes,
10 comandos y un proyecto de prueba real.

---

## Lo que añadiría

### 1. Un `IMPROVE.md` — el hueco más grande

**Qué falta.** No hay ningún sitio donde ir cuando algo no funciona. Cada vez que sale un
problema se resuelven dos cosas: el fallo, y su entrada en `aprendido.md`. Lo que no existe es
la mejora de lo que **funciona pero molesta**: un documento que funciona pero tarda tres pasos
donde bastaría uno, una tarea que se repite, un agente que nunca se usa.

**Por qué importa.** `aprendido.md` solo crece cuando algo falla. Un sistema que solo aprende
de los errores no mejora nunca de lo que ya va bien. Y el caso más frecuente es ese: no está
roto, es incómodo.

**Formato:** fecha · qué molesta · cuánto cuesta · propuesta · qué se probó en vez de
aplicar. La última columna es la importante: distingue lo que se
probó porque funcionó de lo que se cambió porque se le ocurrió a alguien.

### 2. El último 20% del script, no el primero

**Qué falta.** `nuevo-proyecto.ps1` copia, elige agentes y resuelve marcadores. Se detiene
justo antes de la parte que más valor tiene: **escribir la constitución**.

Es el paso que más cuesta y el que más ahorraía. Lo escribí a mano en el proyecto de prueba en
diez minutos, y esos diez minutos se repiten en cada proyecto.

**Qué haría.** Un comando `/sdd-constitution` ya existe, pero requiere que el agente pregunte.
Un script no puede preguntar bien. La salida razonable es **generar un borrador a partir de
`-Stack` y `-Tipo`**, con seis principios de relleno, y que la persona corrija. Mejor un borrador
que hay que ajustar que una plantilla vacía que hay que entender.

**El riesgo, dicho claro.** Un principio generado automáticamente es un principio que no has
pensado. Eso va contra el principio 4 y contra el 8. Por eso el borrador tiene que ir marcado
como tal y por qué, y no presentarse como una constitución.

### 3. Dos comprobaciones que faltan

`verificar.ps1` mira caracteres. Faltan dos de bajo coste que atrapan fallos reales:

- **Enlaces y archivos referenciados.** Un `` `algo.md` `` que no existe. Ya lo busqué a mano
  esta sesión y salieron cuatro referencias rotas. Automatizable.
- **Cifras sin fuente.** El caso de «un MCP con cincuenta herramientas» que tuve que quitar.
  Una cifra concreta sin origen verificable es exactamente lo que el principio 4 prohíbe. Se
  puede marcar automáticamente cualquier número seguido de una unidad.

Ninguna de las dos requiere entender el contenido, solo recorrerlo. Y las dos atrapan fallos que
el revisor tarda minutos en ver.

### 4. Un segundo proyecto en `historial/`

**Qué falta.** Hay un proyecto archivado. El formato solo se ha probado una vez, y un formato
probado una vez no es un formato.

**Qué escribiría.** Un proyecto **pequeño y de otro tipo**: un script o una API en lugar de una
web. En la segunda copia se ve qué de la plantilla sobró, porque un CLI no necesita CSS y
`styles.css` es ruido. El formato del archivo está pensado para proyectos parecidos; falta ver
si sirve para distintos.

---

## Lo que NO añadiría

### El cuarto tipo de agente del catálogo

**Por qué no.** `frontend-reviewer` existe para un proyecto web con interfaz. Los dos proyectos
que han pasado por aquí ya lo traían sin necesitarlo. **La plantilla trae trece candidatos y
cada proyecto borra la mayoría.** Añadir un cuarto agente especializado sería más de lo mismo.

La restricción de permisos que justifica a cada agente es real, pero el criterio es que la
necesidad sea del proyecto, no que el catálogo sea amplio.

### Un `COMMIT.md` o guía de commits

**Por qué no.** Ya hay una convención clara en los mensajes del repo, y `AGENTS.md` no la
reproduce porque no hace falta: se copia del historial. Añadir una guía sería documentar algo
que ya se ve.

### Más verificación automática

Tentador y equivocado. El sistema ya tiene: verificador de caracteres, script de arranque,
herramienta de interfaz en navegador real, revisor y asesor. **El cuello de botella ya no es
falta de comprobación automática: es que las comprobaciones no miran lo que importa.**

`verificar.ps1` comprueba 98 archivos y no ha encontrado nunca un error de lógica. Ninguna
comprobación automática de texto lo haría. Lo que sirve aquí es el criterio humano de leer y
preguntarse si algo significa lo que dice.

---

## Las tres recomendaciones, ordenadas

| # | Qué | Por qué | Coste |
|---|---|---|---|
| 1 | `IMPROVE.md` | Es el único hueco de estructura: el sistema solo aprende de errores | Bajo |
| 2 | Los dos verificadores que faltan | Atrapan fallos reales, de bajo coste | Bajo |
| 3 | Segundo proyecto en `historial/` | El formato está probado una vez | Medio |

**Lo que más vida ha dado hasta ahora** no ha sido ninguna de estas: ha sido `BITACORA.md`.
Registrar cada decisión con su alternativa descartada es lo que ha permitido deshacer tres
decisiones equivocadas y entender por qué se tomaron. Cualquier otro documento nuevo tendría
que ganarse el sitio por algo parecido.

---

## Sobre el coste de todo esto

El repositorio tiene 21 documentos, 13 agentes, 10 comandos y 2 scripts para lo que empezó como
«aprender de un curso». Funciona, y la prueba real lo demuestra.

**El riesgo real ya no es que falte nada: es que una biblioteca de directrices crezca más que
la necesidad que la justifica.** Cada documento que se añade es contexto que un agente lee y
que nadie comprueba. La salida de hoy, con T13 como única tarea abierta, es un buen momento
para eso: el sistema está casi completo y casi todo está probado.

Por eso la primera recomendación es `IMPROVE.md` y no una capacidad nueva. **El sistema tiene
que aprender de lo que va mal antes de aprender a hacer más cosas.**
