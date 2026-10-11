# Prompts y directrices para trabajar con agentes de IA

Un sistema para trabajar con agentes de IA en cualquier proyecto: unas directrices que
dicen cómo se trabaja, una plantilla que se copia al empezar, y ocho herramientas que se
comprueban a sí mismas.

No es una aplicación. Es el método y las herramientas para aplicarlo.

## Empezar

```powershell
.\nuevo-proyecto.ps1 -Nombre "mi-proyecto" -Tipo web -Stack "React, TypeScript" -Git
```

Copia la plantilla, elige los agentes según el tipo de proyecto, resuelve lo que se puede
saber de antemano y **te lista exactamente lo que queda por rellenar**. Hay ocho tipos:
`web`, `api`, `datos`, `cli`, `móvil`, `infra`, `docs` y `todos`.

**Guía completa de uso: [`ENTREGA.md`](ENTREGA.md).** Lee esa antes de tocar nada.

## Qué hay aquí

| Carpeta | Qué contiene |
|---|---|
| `directrices/` | 23 documentos: el método, los principios, el flujo de trabajo y los casos donde algo falla |
| `plantilla/` | 33 ficheros que se copian a cada proyecto: agentes, comandos y la skill de specs |
| `specs/` | La spec de este propio sistema, con su plan y sus tareas |
| `historial/` | Copias literales de proyectos ya terminados |

## Las herramientas

| Herramienta | Para qué |
|---|---|
| `verificar.ps1` | Se pasa antes de dar nada por bueno. Detecta corrupción, comillas sin cerrar, rutas inexistentes, párrafos repetidos y cifras desincronizadas |
| `tests-verificar.ps1` | 15 casos que comprueban que el anterior **no** marca lo que no debe |
| `nuevo-proyecto.ps1` | Crea un proyecto desde la plantilla |
| `modelos.ps1` | Comprueba si un modelo de IA responde **ahora**, antes de delegar en él |
| `watchdog.ps1` | Lee el log y vigila los subagentes |
| `vigilancia.ps1` | Pregunta a la API: quién está ocupado y quién **espera permiso** |
| `medir-api.ps1` | Mide cuánto dura cada herramienta, para no escribir umbrales de memoria |
| `verificar-interfaz.js` | Prueba una interfaz en un Chrome real y guarda una captura |

`watchdog.ps1` y `vigilancia.ps1` miran cosas distintas y no se sustituyen: el log es el
único que registra `stream error`, y la API es la única que sabe si un subagente está
esperando permiso.

## Los principios

`directrices/CONSTITUTION.md` tiene once. Se leen enteros en diez minutos. El que más
disgustos ahorra es el **10**:

> Ninguna cifra se da sin origen. Si no se sabe el número, no se inventa: se avisa.

Y el **6** va de que cada error de proceso se registra con su causa, en
`directrices/aprendido.md`. Va por trece entradas, con un índice arriba.

## Si algo falla

```powershell
powershell -File verificar.ps1
```

Si sale rojo, dice qué fichero y qué línea. Si crees que es la versión de la herramienta y
no del contenido, mira `directrices/PIN.md` antes de tocar nada.

## Aviso sobre las cifras

Las mediciones de `directrices/MODELOS.md` y `directrices/BLOQUEOS.md` salieron del log de
la cuenta con la que se construyó este material. **No son hechos de tu sistema**: son el
historial de otro. Vuelve a medirlas con tus propios datos antes de decidir nada. Lo que sí
es portable es el método para medirlas, que está descrito ahí.

## Requisitos

| Para | Necesitas |
|---|---|
| Los cuatro scripts `.ps1` | PowerShell 5.1 o superior |
| `verificar-interfaz.js` | Node 22 o superior, y Chrome |
| La plantilla con OpenCode | La versión que indique `directrices/PIN.md` |
| La plantilla con otro agente | `directrices/PORTABILIDAD.md` |

## Estado

Verificador en verde: 106 archivos, 0 incidencias. El número de commits no se escribe
aquí: se consulta con `git rev-list --count HEAD`.

## Dónde está

<https://github.com/LeGaliza85/prompts-y-directrices-ia>

Es un repositorio **público**: se clona sin cuenta y sin invitación.

```bash
git clone https://github.com/LeGaliza85/prompts-y-directrices-ia.git
```

Estaba en privado. Se hizo público el 2026-10-11 para poder compartirlo por enlace, que
era más rápido que gestionar invitaciones una a una. Antes de hacerlo se pasó el escaneo
de secretos sobre todo lo versionado: no hay claves, ni tokens, ni ficheros de
autenticación en el historial.

Lo que sí queda visible y conviene saber: el email del autor en los metadatos de los
commits (`jpoliveiramoreiras@gmail.com`). No es un secreto, pero es un dato personal, y
un repositorio público lo indexa. Si algún día molesta, se cambia con un filtro de git y
reeescribiendo el historial.

**No hay `LICENSE`.** Sin ella, el repositorio es de «todos los derechos reservados» por
defecto: se puede leer y clonar, pero no se permite reutilizar ni modificar. Si la intención es
que otros lo aprovechen, hace falta elegir una licencia.