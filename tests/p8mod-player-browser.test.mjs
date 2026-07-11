import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { resolve } from 'node:path';
import test from 'node:test';
import { chromium } from '../../manxiangsu.web/node_modules/playwright/index.mjs';

const root = resolve(import.meta.dirname, '..');
const runner = resolve(root, 'tools/p8mod-player/server.mjs');
const cart = resolve(root, 'carts/pico8go/firework-simulators/firework-simulators.p8mod');

test('a real p8mod converts and reaches running', async (t) => {
  const child = spawn(process.execPath, [runner, '--no-open', cart], { stdio: ['ignore', 'pipe', 'pipe'] });
  t.after(() => child.kill('SIGTERM'));
  let output = '';
  child.stdout.on('data', c => { output += c; });
  child.stderr.on('data', c => { output += c; });
  for (let i = 0; i < 100 && !output.includes('http://'); i += 1) await new Promise(r => setTimeout(r, 25));
  const url = output.split(/\s+/).find(part => part.startsWith('http://'));
  assert.ok(url, output);
  const browser = await chromium.launch({ headless: true });
  t.after(() => browser.close());
  const page = await browser.newPage();
  await page.goto(url);
  let status;
  for (let i = 0; i < 200; i += 1) {
    status = await (await fetch(url + 'status')).json();
    if (status.state === 'running') break;
    if (status.state.endsWith('_error')) assert.fail(JSON.stringify(status));
    await new Promise(r => setTimeout(r, 100));
  }
  assert.equal(status.state, 'running');
  assert.equal(status.lastSuccessfulGeneration, 1);
  const frameSignature = () => page.locator('#engine').evaluate((frame) => {
    const canvas = frame.contentDocument.querySelector('#canvas');
    const context = canvas.getContext('2d');
    const pixels = context.getImageData(0, 0, canvas.width, canvas.height).data;
    let hash = 2166136261;
    for (let i = 0; i < pixels.length; i += 16) {
      hash ^= pixels[i] | (pixels[i + 1] << 8) | (pixels[i + 2] << 16);
      hash = Math.imul(hash, 16777619);
    }
    return hash >>> 0;
  });
  await page.waitForTimeout(300);
  const firstFrame = await frameSignature();
  await page.waitForTimeout(500);
  const secondFrame = await frameSignature();
  assert.notEqual(firstFrame, secondFrame, 'expected animated Firework frames, got static template cart');
});

test('failed watched reload preserves the last success and later recovers', async (t) => {
  const dir = await mkdtemp(join(tmpdir(), 'picovibe-browser-'));
  const watched = join(dir, 'watched.p8mod');
  const valid = await readFile(cart, 'utf8');
  await writeFile(watched, valid);
  const child = spawn(process.execPath, [runner, '--no-open', watched], { stdio: ['ignore', 'pipe', 'pipe'] });
  t.after(() => child.kill('SIGTERM'));
  let output = '';
  child.stdout.on('data', c => { output += c; });
  child.stderr.on('data', c => { output += c; });
  for (let i = 0; i < 100 && !output.includes('http://'); i += 1) await new Promise(r => setTimeout(r, 25));
  const url = output.split(/\s+/).find(part => part.startsWith('http://'));
  const browser = await chromium.launch({ headless: true });
  t.after(() => browser.close());
  const page = await browser.newPage();
  await page.goto(url);
  const waitState = async (state, generation) => {
    let current;
    for (let i = 0; i < 200; i += 1) {
      current = await (await fetch(url + 'status')).json();
      if (current.state === state && current.generation === generation) return current;
      await new Promise(r => setTimeout(r, 50));
    }
    assert.fail('state timeout: ' + state + ' generation ' + generation + ' last=' + JSON.stringify(current));
  };
  await waitState('running', 1);
  await writeFile(watched, 'pico-8 cartridge // http://www.pico-8.com\nversion 42\n__meta__\n{broken json');
  const failed = await waitState('conversion_error', 2);
  assert.equal(failed.lastSuccessfulGeneration, 1);
  await writeFile(watched, valid);
  const recovered = await waitState('running', 3);
  assert.equal(recovered.lastSuccessfulGeneration, 3);
});
