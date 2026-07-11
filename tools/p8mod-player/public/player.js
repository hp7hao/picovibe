import init, { WasmCart } from '/runtime/p8mod.js';

const statusElement = document.querySelector('#status');
const engineFrame = document.querySelector('#engine');
let wasmReady;
let engineReady;
let requestedGeneration = 0;
let processing = false;
let activeGeneration = 0;
let inFlightGeneration = 0;

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
        runtime.p8_run_cart('/runtime/pico8_edu_0206c_dev8.js', '0', '');
        const poll = setInterval(() => {
          if (runtime.Module && typeof runtime.Module._main !== 'undefined') {
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
  const png = cart.to_playable_p8_png();
  let binary = '';
  const chunkSize = 0x8000;
  for (let i = 0; i < png.length; i += chunkSize) {
    binary += String.fromCharCode.apply(null, png.subarray(i, i + chunkSize));
  }
  const nextUrl = 'data:image/png;base64,' + btoa(binary);
  const runtime = await waitForEngine();
  runtime.p8_dropped_cart_name = 'preview.p8.png';
  runtime.p8_dropped_cart = nextUrl;
  runtime.codo_command = 9;
  let attempts = 0;
  while (runtime.codo_command !== 0 && attempts < 120) {
    await new Promise(resolve => requestAnimationFrame(resolve));
    attempts += 1;
  }
  if (runtime.codo_command !== 0) throw new Error('PICO-8 cart load was not consumed');
  await new Promise(resolve => setTimeout(resolve, 750));
  if (Array.isArray(runtime.codo_key_buffer)) {
    for (const code of [114, 117, 110, 13]) runtime.codo_key_buffer.push(code);
  }
  await new Promise(resolve => setTimeout(resolve, 100));
  await report('running', generation);
}

async function drain() {
  if (processing) return;
  processing = true;
  while (requestedGeneration) {
    const generation = requestedGeneration;
    requestedGeneration = 0;
    if (generation <= activeGeneration) continue;
    inFlightGeneration = generation;
    try {
      await convertAndRun(generation);
      activeGeneration = generation;
    } catch (error) {
      await report(error.message.includes('engine') ? 'engine_error' : 'conversion_error', generation, error);
    } finally {
      inFlightGeneration = 0;
    }
  }
  processing = false;
}

function requestGeneration(generation) {
  if (generation > activeGeneration && generation !== inFlightGeneration && generation > requestedGeneration) requestedGeneration = generation;
  drain();
}

const initial = await (await fetch('/status')).json();
requestGeneration(initial.generation);
const events = new EventSource('/events');
events.addEventListener('generation', event => requestGeneration(JSON.parse(event.data).generation));
