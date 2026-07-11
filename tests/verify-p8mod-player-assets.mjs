import { createHash } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';

const root = resolve(import.meta.dirname, '..');
const runtime = resolve(root, 'tools/p8mod-player/runtime');
const manifest = JSON.parse(await readFile(resolve(runtime, 'manifest.json'), 'utf8'));
for (const [name, metadata] of Object.entries(manifest.files)) {
  const bytes = await readFile(resolve(runtime, name));
  const actual = createHash('sha256').update(bytes).digest('hex');
  if (actual !== metadata.sha256) throw new Error('runtime asset hash mismatch: ' + name);
}
console.log('P8mod player runtime assets verified.');
