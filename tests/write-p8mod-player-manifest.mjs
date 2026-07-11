import { createHash } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';
import { resolve, relative } from 'node:path';

const [monorepoRoot, destination, ...sources] = process.argv.slice(2);
const files = {};
for (const name of ['p8mod.js', 'p8mod_bg.wasm']) {
  const bytes = await readFile(resolve(destination, name));
  files[name] = {
    source: 'projects/xwsdk/p8mod (wasm-pack release build)',
    sha256: createHash('sha256').update(bytes).digest('hex'),
  };
}
for (const source of sources) {
  const sourceRoot = resolve(monorepoRoot, 'projects/manxiangsu.web/packages/webdata/public/pico8/tools');
  const name = relative(sourceRoot, source).replace('p8mod/', '').replace('p8edu/', '');
  const bytes = await readFile(resolve(destination, name));
  files[name] = {
    source: relative(monorepoRoot, source),
    sha256: createHash('sha256').update(bytes).digest('hex'),
  };
}
await writeFile(resolve(destination, 'manifest.json'), JSON.stringify({ schemaVersion: 1, files }, null, 2) + '\n');
