# MCP.md — Servidores MCP

Cómo se conecta el agente a herramientas y datos externos, cómo se comprueba que funciona, y
cómo se apaga. El catálogo con el coste de cada uno está en `CAPACIDADES.md`; aquí está la
parte técnica.

## Qué es

Un **servidor MCP** da al agente capacidades que no tiene por sí mismo: abrir un navegador,
leer documentación actualizada, hablar con GitHub o con una base de datos.

El protocolo es abierto, así que el mismo servidor funciona en distintos entornos. Eso es su
ventaja frente a una integración propia.

## Los dos tipos

| Tipo | Cómo se configura | Coste |
|---|---|---|
| **Local** | `command` con el proceso que arranca | Un proceso vivo durante toda la sesión, aunque no se use |
| **Remoto** | `url` a la que conectar | Una llamada por uso; depende de que el servicio responda |

La elección no es de preferencia: un local consume recursos tuyos siempre, un remoto consume
red cada vez. Para tareas puntuales, remoto. Para trabajo continuo con muchos datos, local.

## Configuración

En `opencode.jsonc`, en la clave `mcp`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": ["AGENTS.md", "MEMORY.md", "docs/constitution.md"]
}
```

**Nada se precarga.** Por el principio 1, activar un MCP requiere aprobación. Cuando se
apruebe uno, se anade su bloque, se comprueba que funciona, y se registra en
`MEMORY.md` con la fecha y el motivo.

Un bloque de ejemplo, comentado, para que se vea la forma sin activar nada:

```jsonc
  // "mcp": {
  //   "chrome-devtools": {
  //     "type": "local",
  //     "command": ["npx", "-y", "chrome-devtools-mcp@latest", "--no-usage-statistics"]
  //   }
  // }
```

## Comprobar que funciona

Un MCP que aparece en la lista pero no conecta es el modo de fallo más común, y no da error
visible: la herramienta simplemente no está cuando se la necesita.

Después de configurar uno:

```powershell
opencode --version    # la version, para la clave de mcp
```

Y en la sesión:

- `/mcps` — estado de los MCPs. Comprueba que el tuyo aparece y en qué estado.
- Pide una tarea real que lo use. Si no responde, no está conectado, aunque figure en la lista.

Si no responde, revisa en este orden:

1. El tipo: `local` necesita `command`, `remoto` necesita `url`.
2. La API key: va en variables de entorno o en la configuración local. **Nunca en el
   repositorio.**
3. Que el proceso arranque solo: un `npx` sin caché descarga paquetes la primera vez y tarda.
4. La sintaxis de la clave `mcp` en `APIS-VERIFICADAS.md`, por si cambió con la versión.

## Las claves

Las de los MCPs remotos van en variables de entorno o en configuración local. Reglas:

- **Nunca en el repositorio**, ni en `opencode.jsonc`, ni en `MEMORY.md`, ni en un documento
  de ejemplo.
- Si una clave se ha escrito por error, **se rota**. Borrarla del commit no la borra del
  historial.
- Si un ejemplo necesita una clave, se escribe `<TU_API_KEY>`, no una clave real.

## Cuándo NO merece la pena

- Para una consulta puntual que puedes hacer tú en el navegador.
- Si el proyecto no va a usar esa capacidad más que una vez.
- Si activarlo carga más herramientas en el contexto de las que la tarea necesita. Los
  servidores con muchas herramientas acaban describiendo cada una en el prompt, aunque solo
  uses una. No he medido el coste exacto: se nota con servidores muy grandes, y conviene
  activarlos cuando la tarea los necesita y apagarlos cuando no.

## Cómo se apaga

`/mcps` permite activar y desactivar sin tocar la configuración. Para quitarlo del todo, se
borra su bloque de `opencode.jsonc` y se anota en `MEMORY.md` por qué, para que no se vuelva a
proponer por el mismo motivo.
