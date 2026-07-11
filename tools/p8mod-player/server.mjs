#!/usr/bin/env node
import { createReadStream, existsSync, statSync, watch } from 'node:fs';
import { createServer } from 'node:http';
import { extname, resolve, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawn } from 'node:child_process';

const here = dirname(fileURLToPath(import.meta.url));
const publicDir = join(here, 'public');
const runtimeDir = join(here, 'runtime');
const electronMain = join(here, 'electron-main.cjs');
const electronBin = join(here, '..', '..', 'node_modules', '.bin', process.platform === 'win32' ? 'electron.cmd' : 'electron');
const terminalStates = new Set(['conversion_error', 'engine_error', 'load_error', 'running']);
const playerStates = new Set(['starting', 'converting', 'reloading', 'running', 'source_error', 'conversion_error', 'engine_error', 'load_error']);

function usage(message) {
  if (message) console.error(message);
  console.error('Usage: scripts/run-p8mod.sh [--no-open] [--no-watch] [--host HOST] [--port PORT] <cart.p8mod>');
  process.exit(2);
}

const args = process.argv.slice(2);
let host = '127.0.0.1';
let port = 0;
let shouldOpen = true;
let shouldWatch = true;
let input;
for (let i = 0; i < args.length; i += 1) {
  const arg = args[i];
  if (arg === '--no-open') shouldOpen = false;
  else if (arg === '--no-watch') shouldWatch = false;
  else if (arg === '--host') host = args[++i] || usage('--host requires a value');
  else if (arg === '--port') {
    port = Number(args[++i]);
    if (!Number.isInteger(port) || port < 0 || port > 65535) usage('--port requires 0..65535');
  } else if (arg.startsWith('-')) usage('Unknown option: ' + arg);
  else if (input) usage('Only one input cart is supported');
  else input = resolve(arg);
}
if (!input || extname(input) !== '.p8mod') usage('Input must end with .p8mod');
if (!existsSync(input) || !statSync(input).isFile()) usage('Input cart not found: ' + input);

let status = { state: 'starting', generation: 1, source: input, error: null, lastSuccessfulGeneration: null };
const clients = new Set();
let changeTimer;
function emitGeneration() {
  const payload = 'event: generation\ndata: ' + JSON.stringify({ generation: status.generation }) + '\n\n';
  for (const client of clients) client.write(payload);
}
function sourceChanged() {
  clearTimeout(changeTimer);
  changeTimer = setTimeout(() => {
    status = { ...status, generation: status.generation + 1 };
    emitGeneration();
  }, 60);
}
function json(res, code, body) {
  res.writeHead(code, { 'content-type': 'application/json', 'cache-control': 'no-store' });
  res.end(JSON.stringify(body));
}
function staticFile(res, path) {
  if (!existsSync(path) || !statSync(path).isFile()) return false;
  const types = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8', '.wasm': 'application/wasm', '.css': 'text/css; charset=utf-8' };
  res.writeHead(200, { 'content-type': types[extname(path)] || 'application/octet-stream', 'cache-control': 'no-store' });
  createReadStream(path).pipe(res);
  return true;
}
function childPath(root, requestPath) {
  const path = resolve(root, requestPath);
  return path === root || path.startsWith(root + '/') ? path : null;
}

const server = createServer(async (req, res) => {
  const url = new URL(req.url, 'http://localhost');
  if (req.method === 'GET' && url.pathname === '/health') return json(res, 200, { ok: true });
  if (req.method === 'GET' && url.pathname === '/status') return json(res, 200, status);
  if (req.method === 'GET' && url.pathname === '/cart.p8mod') {
    res.writeHead(200, { 'content-type': 'text/plain; charset=utf-8', 'cache-control': 'no-store' });
    return createReadStream(input).on('error', err => res.destroy(err)).pipe(res);
  }
  if (req.method === 'GET' && url.pathname === '/events') {
    res.writeHead(200, { 'content-type': 'text/event-stream', 'cache-control': 'no-store', connection: 'keep-alive' });
    clients.add(res);
    res.write('event: generation\ndata: ' + JSON.stringify({ generation: status.generation }) + '\n\n');
    req.on('close', () => clients.delete(res));
    return;
  }
  if (req.method === 'POST' && url.pathname === '/status') {
    try {
      let body = '';
      for await (const chunk of req) { body += chunk; if (body.length > 65536) throw new Error('status body too large'); }
      const next = JSON.parse(body);
      if (next.generation !== status.generation || !playerStates.has(next.state)) return json(res, 409, status);
      status = { ...status, ...next, source: input };
      if (next.state === 'running') status.lastSuccessfulGeneration = next.generation;
      console.log('[' + next.state + '] generation ' + next.generation + (next.message ? ': ' + next.message : ''));
      json(res, 200, status);
      if (!shouldWatch && terminalStates.has(next.state)) setTimeout(() => process.exit(next.state === 'running' ? 0 : 1), 10);
    } catch (error) { json(res, 400, { error: error.message }); }
    return;
  }
  if (req.method === 'GET' && url.pathname === '/') return staticFile(res, join(publicDir, 'index.html')) || json(res, 404, { error: 'player assets not installed' });
  if (req.method === 'GET' && url.pathname.startsWith('/public/')) {
    const path = childPath(publicDir, decodeURIComponent(url.pathname.slice(8)));
    return (path && staticFile(res, path)) || json(res, 404, { error: 'not found' });
  }
  if (req.method === 'GET' && url.pathname.startsWith('/runtime/')) {
    const path = childPath(runtimeDir, decodeURIComponent(url.pathname.slice(9)));
    return (path && staticFile(res, path)) || json(res, 404, { error: 'not found' });
  }
  json(res, 404, { error: 'not found' });
});

server.listen(port, host, () => {
  const address = server.address();
  const displayHost = host.includes(':') ? '[' + host + ']' : host;
  const url = 'http://' + displayHost + ':' + address.port + '/';
  console.log('PicoVibe player: ' + url);
  console.log('Source: ' + input);
  if (shouldOpen) {
    if (!existsSync(electronBin)) usage('Electron is not installed; run npm install in projects/picovibe or use --no-open');
    const linuxFlags = process.platform === 'linux'
      ? ['--no-sandbox', ...(process.env.WAYLAND_DISPLAY ? ['--ozone-platform=wayland'] : [])]
      : [];
    const electronArgs = [...linuxFlags, electronMain, url];
    const electron = spawn(electronBin, electronArgs, { stdio: 'ignore' });
    electron.on('exit', () => shutdown());
  }
});
const watcher = shouldWatch ? watch(input, sourceChanged) : null;
function shutdown() { watcher?.close(); for (const client of clients) client.end(); server.close(() => process.exit(0)); }
process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
