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
// Requisitos: Node 18 o superior (WebSocket nativo) y Chrome instalado.

const PUERTO_CDP = 9222;
const ANCHO_MOVIL = 375;

/** Función para abrir el Chrome y devolver el cliente CDP ya conectado. */
async function abrirChrome(rutaChrome = null) {
  const rutas = [
    rutaChrome,
    process.env.CHROME_PATH,
    'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
    process.env.LOCALAPPDATA + '\\Google\\Chrome\\Application\\chrome.exe',
    '/usr/bin/google-chrome',
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
  ].filter(Boolean);

  return rutas[0];
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

const esperar = (ms) => new Promise((r) => setTimeout(r, ms));

/**
 * Comprueba una pagina en Chrome real.
 *
 * @param {string} urlPagina - URL a abrir
 * @param {string[]} pasos - Expresiones JavaScript a ejecutar, en orden
 * @returns {Promise<{ok: boolean, resultados: object[], errores: string[], captura: string|null}>}
 */
async function comprobar(urlPagina, pasos = []) {
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
  await s('Page.navigate', { url: urlPagina });
  await esperar(1200);

  const erroresConsola = cliente.eventos
    .filter((e) => e.method === 'Log.entryAdded' && e.params.entry.level === 'error')
    .map((e) => e.params.entry.text);

  const evalua = (expr) =>
    s('Runtime.evaluate', { expression: expr, returnByValue: true }).then((r) => r.result.value);

  const resultados = [];
  for (const paso of pasos) {
    try {
      const valor = await evalua(paso.expresion);
      resultados.push({ nombre: paso.nombre, ok: Boolean(valor), valor });
    } catch (e) {
      resultados.push({ nombre: paso.nombre, ok: false, valor: `error: ${e.message}` });
    }
  }

  let captura = null;
  try {
    const { data } = await s('Page.captureScreenshot', { format: 'png' });
    captura = Buffer.from(data, 'base64').toString('base64');
  } catch { /* la captura es opcional */ }

  await cliente.enviar('Target.closeTarget', { targetId });
  cliente.cerrar();

  const errores = resultados.filter((r) => !r.ok).map((r) => r.nombre);
  return { ok: errores.length === 0 && erroresConsola.length === 0, resultados, errores, erroresConsola, captura };
}

// --- Uso directo -----------------------------------------------------------
if (require.main === module) {
  const url = process.argv[2] || 'about:blank';
  comprobar(url).then((r) => {
    console.log(r.ok ? 'OK' : `FALLOS: ${r.errores.join(', ')}`);
    process.exit(r.ok ? 0 : 1);
  }).catch((e) => {
    console.error('No se pudo comprobar. ¿Está Chrome arrancado con --remote-debugging-port?');
    console.error(' ', e.message);
    process.exit(1);
  });
}

module.exports = { comprobar, conectar, esperar, PUERTO_CDP, ANCHO_MOVIL };
