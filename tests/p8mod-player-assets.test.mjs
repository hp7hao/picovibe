import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import test from 'node:test';

const root = resolve(import.meta.dirname, '..');

test('runtime manifest covers required assets with matching hashes', async () => {
  const manifest = JSON.parse(await readFile(resolve(root, 'tools/p8mod-player/runtime/manifest.json'), 'utf8'));
  const required = ['p8mod.js', 'p8mod_bg.wasm', 'p8edu.html', 'pico8_edu_0206c_dev8.js', 'src/browsersetup.css'];
  assert.deepEqual(Object.keys(manifest.files).sort(), required.sort());
  for (const [name, metadata] of Object.entries(manifest.files)) {
    assert.ok(metadata.source.startsWith('projects/manxiangsu.web/') || metadata.source.startsWith('projects/xwsdk/p8mod'));
    const bytes = await readFile(resolve(root, 'tools/p8mod-player/runtime', name));
    assert.equal(createHash('sha256').update(bytes).digest('hex'), metadata.sha256, name);
  }
});
