import assert from 'node:assert/strict';
import { mkdtemp, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { spawn } from 'node:child_process';
import test from 'node:test';
import { readFile } from 'node:fs/promises';

const root = resolve(import.meta.dirname, '..');
const runner = join(root, 'tools/p8mod-player/server.mjs');

async function start(extra = []) {
  const dir = await mkdtemp(join(tmpdir(), 'picovibe-player-'));
  const cart = join(dir, 'game.p8mod');
  await writeFile(cart, 'pico-8 cartridge // http://www.pico-8.com\nversion 42\n__lua__\nfunction _draw() cls() end\n');
  const child = spawn(process.execPath, [runner, '--no-open', ...extra, cart], { stdio: ['ignore', 'pipe', 'pipe'] });
  let output = '';
  child.stdout.on('data', (chunk) => { output += chunk; });
  child.stderr.on('data', (chunk) => { output += chunk; });
  for (let i = 0; i < 100 && !output.includes('http://'); i += 1) await new Promise(r => setTimeout(r, 25));
  const url = output.split(/\s+/).find(part => part.startsWith('http://'));
  assert.ok(url, output);
  return { child, cart, url };
}

test('serves health, status, and uncached cart source', async (t) => {
  const app = await start();
  t.after(() => app.child.kill('SIGTERM'));
  assert.deepEqual(await (await fetch(`${app.url}health`)).json(), { ok: true });
  const status = await (await fetch(`${app.url}status`)).json();
  assert.equal(status.state, 'starting');
  assert.equal(status.generation, 1);
  const cart = await fetch(`${app.url}cart.p8mod`);
  assert.match(cart.headers.get('cache-control'), /no-store/);
  assert.match(await cart.text(), /function _draw/);
  assert.equal((await fetch(app.url + 'runtime/%2e%2e/%2e%2e/server.mjs')).status, 404);
  const rejected = await fetch(app.url + 'status', {
    method: 'POST', headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ generation: 1, state: 'anything' }),
  });
  assert.equal(rejected.status, 409);
});

test('watching increments the generation after a source change', async (t) => {
  const app = await start();
  t.after(() => app.child.kill('SIGTERM'));
  await writeFile(app.cart, 'changed');
  let generation = 1;
  for (let i = 0; i < 50 && generation === 1; i += 1) {
    await new Promise(r => setTimeout(r, 30));
    generation = (await (await fetch(`${app.url}status`)).json()).generation;
  }
  assert.equal(generation, 2);
});

test('rejects non-p8mod input', async () => {
  const child = spawn(process.execPath, [runner, '--no-open', 'bad.p8'], { stdio: ['ignore', 'pipe', 'pipe'] });
  let output = '';
  child.stderr.on('data', c => { output += c; });
  const [code] = await new Promise(resolveExit => child.on('exit', (...args) => resolveExit(args)));
  assert.notEqual(code, 0);
  assert.match(output, /.p8mod/);
});
test('default launcher uses the owned Electron window instead of xdg-open', async () => {
  const server = await readFile(new URL('../tools/p8mod-player/server.mjs', import.meta.url), 'utf8');
  assert.match(server, /electron-main\.cjs/);
  assert.doesNotMatch(server, /xdg-open/);
});
