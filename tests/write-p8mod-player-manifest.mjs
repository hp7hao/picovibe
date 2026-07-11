import { createHash } from 'node:crypto';
import { readFile, writeFile } from 'node:fs/promises';
import { basename, resolve, relative } from 'node:path';

const [monorepoRoot, destination, ...sources] = process.argv.slice(2);
const files = {};
for (const source of sources) {
  const name = basename(source);
  const bytes = await readFile(resolve(destination, name));
  files[name] = {
    source: relative(monorepoRoot, source),
    sha256: createHash('sha256').update(bytes).digest('hex'),
  };
}
await writeFile(resolve(destination, 'manifest.json'), JSON.stringify({ schemaVersion: 1, files }, null, 2) + '\n');
