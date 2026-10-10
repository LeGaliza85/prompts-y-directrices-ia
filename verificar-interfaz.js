// verificar-interfaz.js — Comprobar una web en un navegador real
//
// Para qué sirve:
//   Los tests unitarios no ven la interfaz. Un JSON corrupto en localStorage, una vista que
//   desborda en móvil o un error en consola solo se detectan abriendo la página. Este script
//   lo hace en un Chrome real, sin instalar nada en el proyecto.
//
// Por qué no el MCP de Chrome DevTools:
//   El MCP es la vía cómoda, pero activarlo exige conectarlo a la sesión y reiniciar. Desde
//   dentro de una sesión ya abierta no se puede. Este script habla el protocolo CDP
//   directamente con el WebSocket que Node trae de serie, y funciona siempre.
//
// Uso:
//   node verificar-interfaz.js <url> <script-de-comprobaciones.mjs>
//
//   O, para el uso más común, edita las constantes de abajo y ejecuta:
//   node verificar-interfaz.js
//
// Requisitos: Node 22 o superior (WebSocket global) y Chrome instalado.

const PUERTO_CDP = 9222;
const ANCHO_MOVIL = 375;

/** Rutas donde suele estar Chrome, en orden de probabilidad. */
const RUTAS_CHROME = [
  process.env.CHROME_PATH,
  'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
  'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
  process.env.LOCALAPPDATA + '\\Google\\Chrome\\Application\\chrome.exe',
  '/usr/bin/google-chrome',
  '/usr/bin/chromium',
  '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  '/Applications/Chromium.app/Contents/MacOS/Chromium',
].filter(Boolean);

const esperar = (ms) => new Promise((r) => setTimeout(r, ms));

/**
 * Arranca Chrome en headless con el puerto de depuracion abierto, y devuelve un manejador
 * para pararlo.
 *
 * Existe porque el MCP de Chrome DevTools no se puede activar desde una sesion ya abierta:
 * exige conectarlo y reiniciar. Este metodo funciona siempre y no depende de la sesion.
 *
 * El perfil es temporal y se borra al parar: no toca el Chrome del usuario.
 */
async function abrirChrome(rutaChrome = null) {
  const { spawn } = require('node:child_process');
  const fs = require('node:fs');
  const os = require('node:os');
  const path = require('node:path');

  const candidatas = rutaChrome ? [rutaChrome, ...RUTAS_CHROME] : RUTAS_CHROME;
  const ejecutable = candidatas.find((r) => fs.existsSync(r));
  if (!ejecutable) {
    throw new Error(
      'No encuentro Chrome. Indica la ruta con CHROME_PATH o como primer argumento.'
    );
  }

  const perfil = path.join(os.tmpdir(), `verif-chrome-${process.pid}`);
  const proc = spawn(ejecutable, [
    '--headless=new',
    `--remote-debugging-port=${PUERTO_CDP}`,
    '--no-first-run',
    '--no-default-browser-check',
    '--disable-extensions',
    `--user-data-dir=${perfil}`,
  ], { stdio: 'ignore', detached: false });

  // El puerto tarda un poco en abrir. Se espera a que responda, no un tiempo fijo.
  const endpoint = `http://127.0.0.1:${PUERTO_CDP}`;
  for (let intento = 0; intento < 40; intento++) {
    await esperar(250);
    try {
      const r = await fetch(`${endpoint}/json/version`);
      if (r.ok) {
        return {
          endpoint,
          proceso: proc,
          parar: () => {
            try { proc.kill(); } catch { /* ya estaba parado */ }
            try { fs.rmSync(perfil, { recursive: true, force: true }); } catch { /* ya no existe */ }
          },
        };
      }
    } catch { /* todavia no responde */ }
  }

  try { proc.kill(); } catch { /* nada que hacer */ }
  throw new Error(`Chrome arranco pero el puerto ${PUERTO_CDP} no responde.`);
}

/**
 * Cliente minimo del protocolo CDP.
 *
 * Trampa: el sessionId va en el mensaje, NO dentro de params. Si se manda como
 * parametro, el servidor responde "Runtime.enable wasn't found", que parece un error de
 * nombre de metodo y no lo es.
 */
function conectar(wsUrl) {
  const ws = new WebSocket(wsUrl);
  const pendientes = new Map();
  const eventos = [];
  let id = 0;

  ws.addEventListener('message', (ev) => {
    const msg = JSON.parse(ev.data);
    if (msg.id && pendientes.has(msg.id)) {
      const { resolve, reject } = pendientes.get(msg.id);
      pendientes.delete(msg.id);
      msg.error ? reject(new Error(msg.error.message)) : resolve(msg.result);
    } else if (msg.method) {
      eventos.push(msg);
    }
  });

  return {
    listo: new Promise((r) => ws.addEventListener('open', r)),
    enviar(method, params = {}, sessionId) {
      const miId = ++id;
      const p = new Promise((resolve, reject) => pendientes.set(miId, { resolve, reject }));
      const msg = { id: miId, method, params };
      if (sessionId) msg.sessionId = sessionId;
      ws.send(JSON.stringify(msg));
      return p;
    },
    eventos,
    cerrar: () => ws.close(),
  };
}

/**
 * Comprueba una pagina en Chrome real.
 *
 * @param {string} urlPagina - URL a abrir
 * @param {Array<{nombre: string, expresion: string}>} pasos - Comprobaciones a ejecutar
 * @param {object} opciones - {movil: boolean} añade la comprobacion de desborde a 375 px
 * @returns {Promise<{ok, resultados, errores, erroresConsola, captura}>}
 * @throws Si pasos esta vacio: sin comprobaciones, decir "OK" no significaria nada.
 */
async function comprobar(urlPagina, pasos = [], opciones = {}) {
  if (!Array.isArray(pasos) || pasos.length === 0) {
    throw new Error(
      'Hay que pasar al menos una comprobacion. Sin pasos, "OK" no significa nada: ' +
      'no se ha comprobado nada.'
    );
  }

  const endpoint = `http://127.0.0.1:${PUERTO_CDP}`;
  const version = await fetch(`${endpoint}/json/version`).then((r) => r.json());

  const cliente = await conectar(version.webSocketDebuggerUrl);
  await cliente.listo;

  const { targetId } = await cliente.enviar('Target.createTarget', { url: 'about:blank' });
  const { sessionId } = await cliente.enviar('Target.attachToTarget', { targetId, flatten: true });
  const s = (method, params = {}) => cliente.enviar(method, params, sessionId);

  await s('Runtime.enable');
  await s('Log.enable');
  await s('Page.enable');

  const todos = [...pasos];
  if (opciones.movil) {
    await s('Emulation.setDeviceMetricsOverride', {
      width: ANCHO_MOVIL, height: 667, deviceScaleFactor: 2, mobile: true,
    });
    todos.push({
      nombre: `nada desborda a ${ANCHO_MOVIL} px`,
      expresion: 'document.documentElement.scrollWidth - document.documentElement.clientWidth <= 0',
    });
  }

  await s('Page.navigate', { url: urlPagina });
  await esperar(1200);

  const erroresConsola = cliente.eventos
    .filter((e) => e.method === 'Log.entryAdded' && e.params.entry.level === 'error')
    .map((e) => e.params.entry.text);

  const evalua = (expr) =>
    s('Runtime.evaluate', { expression: expr, returnByValue: true }).then((r) => r.result.value);

  const resultados = [];
  for (const paso of todos) {
    try {
      const valor = await evalua(paso.expresion);
      resultados.push({ nombre: paso.nombre, ok: Boolean(valor), valor });
    } catch (e) {
      resultados.push({ nombre: paso.nombre, ok: false, valor: `error: ${e.message}` });
    }
  }

  // La captura se guarda a disco tal cual. Antes se fazia
  // Buffer.from(base64).toString('base64'), que es una ida y vuelta identidad: no
  // convertia nada y el PNG nunca se podia abrir.
  let captura = null;
  try {
    const { data } = await s('Page.captureScreenshot', { format: 'png' });
    captura = Buffer.from(data, 'base64');
  } catch { /* la captura es opcional */ }

  await cliente.enviar('Target.closeTarget', { targetId });
  cliente.cerrar();

  const errores = resultados.filter((r) => !r.ok).map((r) => r.nombre);
  if (erroresConsola.length > 0) {
    errores.push(`${erroresConsola.length} error(es) en la consola del navegador`);
  }
  return {
    ok: errores.length === 0,
    resultados,
    errores,
    erroresConsola,
    captura,
  };
}


// --- Uso directo -----------------------------------------------------------
// Sin comprobaciones, decir "OK" no significaria nada: se comprueba que no se ha
// comprobado. Por eso el uso directo exige un archivo con los pasos.
async function principal() {
  const [url, rutaPasos, rutaCaptura] = process.argv.slice(2);

  if (!url || !rutaPasos) {
    console.error('Uso: node verificar-interfaz.js <url> <archivo-de-comprobaciones.js> [captura.png]');
    console.error('');
    console.error('El archivo debe exportar `pasos`: un array de { nombre, expresion }.');
    console.error('El tercer argumento, si se da, es donde se guarda la captura. Por');
    console.error('defecto, verificacion.png en la carpeta actual.');
    console.error('Ejemplo:');
    console.error('  module.exports = { pasos: [');
    console.error('    { nombre: "abre", expresion: "document.title.length > 0" },');
    console.error('  ] };');
    process.exit(1);
  }

  // await es obligatorio: abrirChrome es async y sin el se guarda una promesa, que
  // no tiene .parar(). Fallaria al borrar, no al arrancar, que es mas dificil de ver.
  const chrome = await abrirChrome();

  let pasos;
  try {
    ({ pasos } = require(require('node:path').resolve(rutaPasos)));
  } catch (e) {
    console.error(`No se pudo leer el archivo de comprobaciones: ${e.message}`);
    chrome.parar();
    process.exit(1);
  }

try {
    const r = await comprobar(url, pasos, { movil: true });
    r.resultados.forEach((x) => console.log(`  ${x.ok ? 'OK   ' : 'FALLA'} ${x.nombre}`));
    if (r.erroresConsola.length) {
      console.log(`  consola: ${r.erroresConsola.join(' | ')}`);
    }

    // La captura se escribe a disco. Sin ella, el script comprueba numeros y no dice
    // nada de si la pagina se VE bien: un OK no distingue una interfaz correcta de una
    // que desborda, ilegible o con el contraste justo.
    if (r.captura) {
      const ruta = rutaCaptura || 'verificacion.png';
      require('node:fs').writeFileSync(ruta, r.captura);
      console.log(`  captura: ${ruta}`);
    }

    console.log(r.ok ? 'VEREDICTO: APROBADO' : 'VEREDICTO: CAMBIOS NECESARIOS');
    chrome.parar();
    process.exit(r.ok ? 0 : 1);
  } catch (e) {
    console.error('No se pudo comprobar:', e.message);
    chrome.parar();
    process.exit(1);
  }
}

if (require.main === module) {
  principal();
}

module.exports = {
  comprobar,
  conectar,
  esperar,
  abrirChrome,
  PUERTO_CDP,
  ANCHO_MOVIL,
};