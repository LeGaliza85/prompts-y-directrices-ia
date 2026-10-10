# ENTREGA

Esto es una biblioteca para trabajar con agentes de IA en cualquier proyecto. No es una
aplicación: son directrices, una plantilla y cinco herramientas que se comprueban a sí
mismas.

## Qué hace falta instalado

| Para | Necesitas |
|---|---|
| `verificar.ps1`, `watchdog.ps1`, `nuevo-proyecto.ps1`, `modelos.ps1` | **PowerShell 5.1 o superior** (Windows de serie) |
| `verificar-interfaz.js` | **Node 22 o superior** y **Chrome** instalado |
| Usar la plantilla con OpenCode | opencode, la versión que diga `directrices/PIN.md` |
| Usar la plantilla con otro agente | Ver `directrices/PORTABILIDAD.md` |

Los scripts se ejecutan con `powershell -File`, no haciendo doble clic. Llevan BOM porque
PowerShell 5.1 lee los `.ps1` como ANSI si no lo tienen, y los acentos se rompen en
silencio. Está en `aprendido.md`, lección 9.

## Empieza por aquí, en este orden

1. **`directrices/CONSTITUTION.md`** — 11 principios, se leen enteros en diez minutos. El
   que más te va a ahorrar disgustos es el **10**: ninguna cifra se da sin origen.
2. **`directrices/aprendido.md`** — 13 fallos reales con su causa y su directiva. Tiene un
   índice arriba. Si solo lees tres: la **9**, la **10** y la **12**.
3. **`AGENTS.md`** (este repositorio) y **`plantilla/LEEME.md`** — cómo se usa la plantilla.
4. **`directrices/BLOQUEOS.md`** — qué hacer cuando algo se atasca.

## Las cinco herramientas

| Herramienta | Sirve para |
|---|---|
| `verificar.ps1` | Pásalo antes de dar nada por bueno. Revisa corrupción, comillas sin cerrar, rutas que no existen, párrafos repetidos y cifras desincronizadas. |
| `nuevo-proyecto.ps1` | Crea un proyecto desde la plantilla. Ocho tipos. Te lista lo que queda por rellenar. |
| `modelos.ps1` | Comprueba si un modelo responde **ahora**. Úsalo antes de delegar. |
| `watchdog.ps1` | Vigila subagentes y detecta atascos. Informa; solo cancela con `-Cancelar`. |
| `verificar-interfaz.js` | Prueba una interfaz en Chrome real y guarda una captura. |

## Para una aplicación de prueba

```powershell
.\nuevo-proyecto.ps1 -Nombre "prueba" -Tipo web -Stack "Node" -Git
```

Después, el script te dice exactamente qué queda por rellenar: los marcadores que solo
sabe quien pide el proyecto. Los que están dentro de bloques de permisos hay que
sustituirlos sí o sí: si no, el agente no puede ejecutar el comando de comprobación y
**no hay ningún error que te avise**.

## Aviso importante sobre las cifras

Las mediciones de `directrices/MODELOS.md` y de `directrices/BLOQUEOS.md` salieron del log
de la cuenta con la que se construyó este material. **No son hechos de tu sistema:** son
el historial de otro. Heredarlas sin comprobarlo es justo lo que prohíbe el principio 10.

Vuelve a medirlas con tus propios datos antes de tomar una decisión basada en ellas. Lo
que sí es portable es el **método** para medirlas, que está descrito en esos dos documentos.

## Qué es portable y qué no

Corto: **el 80% es portable**, y el 20% atado está en cuatro sitios.
Largo: `directrices/PORTABILIDAD.md`, con tablas de equivalencia para Cursor, Claude Code,
Windsurf, Aider, Cline y Roo.

Dos destinos que **no** están cubiertos por esa tabla, y por qué:

- **ZED**: no se ha verificado. No se afirma que funcione.
- **ChatGPT**: no tiene acceso al sistema de ficheros, así que no lee este repositorio ni
  carga los agentes. Viaja el método como texto; no viaja ninguna herramienta.

## Si algo va mal

`powershell -File verificar.ps1`. Si sale rojo, te dice qué fichero y qué línea. Si crees
que es la versión de la herramienta, mira `directrices/PIN.md` antes de tocar nada.
