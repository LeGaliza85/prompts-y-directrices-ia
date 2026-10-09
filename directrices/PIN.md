# PIN.md — Ancla de versión

Todo el material de `directrices/` y de `plantilla/` está verificado contra **una versión
concreta de OpenCode**. Si la versión instalada cambia, los ejemplos dejan de ser fiables
hasta revalidarlos.

**Regla:** si la versión instalada cambia, este archivo se actualiza **antes** de fiarse de
cualquier ejemplo del repo, y el cambio se registra en `BITACORA.md`.

## Versión verificada

| Componente | Versión | Fuente | Verificado el |
|---|---|---|---|
| OpenCode real (`--version`) | **1.4.0** | `opencode-cli.exe --version` | 2026-10-09 |
| Metadatos del binario | 1.3.11 | `opencode-cli.exe` | 2026-10-09 |
| Desinstalador | 1.4.0 | `uninstall.exe` | 2026-10-09 |
| Plugin `@opencode-ai/plugin` | 1.4.0 | `C:\Users\Pablo\.config\opencode\package.json` | 2026-10-09 |
| Documentación oficial | actualizada el 2026-10-08 | https://opencode.ai/docs | 2026-10-09 |

**Discrepancia que importa.** El binario tiene tres números distintos. `--version` y el
desinstalador dicen 1.4.0; los metadatos del archivo dicen 1.3.11. La versión que manda es
la de `--version`: **1.4.0**. Los metadatos no se actualizaron en una compilación posterior.

Esto no es un detalle. Consultar la versión por los metadatos del archivo —que es lo más
cómodo desde un script— da el número equivocado, y con él se concluye que la documentación
consultada no corresponde. **Comprueba siempre con `--version`.**

## Dónde se comprobó

- Versión real: ejecutando `opencode-cli.exe --version` desde un shell donde `opencode` no
  está en el PATH. Si lo está, `opencode --version` da el mismo resultado.
- Plugin: `package.json` de `C:\Users\Pablo\.config\opencode`.
- Config del usuario: `C:\Users\Pablo\.config\opencode\opencode.jsonc`. Solo contiene
  `{"$schema": "https://opencode.ai/config.json"}`, así que no aporta configuración que
  verificar ni que pueda quedar desfasada.
- Sintaxis de agentes, comandos, skills, MCP y rules: documentación oficial al 2026-10-08.
  El inventario completo está en `APIS-VERIFICADAS.md`.

## Límite

La verificación es contra la documentación oficial, no contra la ejecución real de cada
caso. Lo no verificado se trata como supuesto.

El procedimiento para actualizar está en `PROCEDIMIENTO-ACTUALIZACION.md`.
