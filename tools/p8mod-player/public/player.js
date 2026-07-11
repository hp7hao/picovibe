import init, { WasmCart } from '/runtime/p8mod.js';

const statusElement = document.querySelector('#status');
const engineFrame = document.querySelector('#engine');
let wasmReady;
let engineReady;
let requestedGeneration = 0;
let processing = false;
let activeObjectUrl = null;

async function report(state, generation, error = null) {
  const message = error ? (error.message || String(error)) : null;
  statusElement.textContent = message ? state + ': ' + message : state + ' · generation ' + generation;
  statusElement.classList.toggle('error', Boolean(error));
  await fetch('/status', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ state, generation, error: message, message }),
  });
}

function waitForEngine() {
  if (!engineReady) engineReady = new Promise((resolve, reject) => {
    const timeout = setTimeout(() => reject(new Error('PICO-8 engine initialization timed out')), 15000);
    const start = () => {
      try {
        const runtime = engineFrame.contentWindow;
        runtime.p8_run_cart();
        const poll = setInterval(() => {
          if (runtime.Module && runtime.p8_is_running) {
            clearInterval(poll);
            clearTimeout(timeout);
            resolve(runtime);
          }
        }, 50);
      } catch (error) {
        clearTimeout(timeout);
        reject(error);
      }
    };
    if (engineFrame.contentDocument?.readyState === 'complete') start();
    else engineFrame.addEventListener('load', start, { once: true });
  });
  return engineReady;
}

async function convertAndRun(generation) {
  await report(generation === 1 ? 'converting' : 'reloading', generation);
  if (!wasmReady) wasmReady = init('/runtime/p8mod_bg.wasm');
  await wasmReady;
  const response = await fetch('/cart.p8mod?generation=' + generation, { cache: 'no-store' });
  if (!response.ok) throw new Error('source fetch failed: ' + response.status);
  const cart = WasmCart.from_p8mod(await response.text());
  const png = cart.to_p8_png();
  const nextUrl = URL.createObjectURL(new Blob([png], { type: 'image/png' }));
  const runtime = await waitForEngine();
  runtime.p8_dropped_cart_name = 'preview.p8.png';
  runtime.p8_dropped_cart = nextUrl;
  runtime.codo_command = 9;
  await new Promise(resolve => setTimeout(resolve, 100));
  if (Array.isArray(runtime.codo_key_buffer)) {
    for (const code of [114, 117, 110, 13]) runtime.codo_key_buffer.push(code);
  }
  if (activeObjectUrl) URL.revokeObjectURL(activeObjectUrl);
  activeObjectUrl = nextUrl;
  await report('running', generation);
}

async function drain() {
  if (processing) return;
  processing = true;
  while (requestedGeneration) {
    const generation = requestedGeneration;
    requestedGeneration = 0;
    try {
      await convertAndRun(generation);
    } catch (error) {
      await report(error.message.includes('engine') ? 'engine_error' : 'conversion_error', generation, error);
    }
  }
  processing = false;
}

function requestGeneration(generation) {
  if (generation > requestedGeneration) requestedGeneration = generation;
  drain();
}

const initial = await (await fetch('/status')).json();
requestGeneration(initial.generation);
const events = new EventSource('/events');
events.addEventListener('generation', event => requestGeneration(JSON.parse(event.data).generation));
