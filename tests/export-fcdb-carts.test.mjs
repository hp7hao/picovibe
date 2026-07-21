import assert from 'node:assert/strict';
import { access, chmod, mkdtemp, mkdir, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';
import test from 'node:test';
import { fileURLToPath } from 'node:url';

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const batchScript = join(projectRoot, 'scripts', 'export-fcdb-carts.mjs');

async function writeFixture(root) {
  const goodSource = join(root, 'carts', 'good', 'source.p8mod');
  const tooLargeSource = join(root, 'carts', 'large', 'large.p8mod');
  await mkdir(dirname(goodSource), { recursive: true });
  await mkdir(dirname(tooLargeSource), { recursive: true });
  const localizedCart = '__i18n__\n{"locales":["zh-CN","en-US"],"entries":[],"outputLocale":"zh-CN"}\n';
  await writeFile(goodSource, localizedCart);
  await writeFile(tooLargeSource, localizedCart);

  const manifest = join(root, 'pico8pixelbomb.json');
  await writeFile(manifest, JSON.stringify([
    {
      id: 'good',
      extension: {
        cart_file: 'picovibe_good.zh-CN.p8.png',
        cart_path: 'release/picovibe_good.zh-CN.p8.png',
        cart_locale: 'zh-CN',
        cart_variants: {
          'en-US': {
            file: 'picovibe_good.en-US.p8.png',
            path: 'release/picovibe_good.en-US.p8.png',
          },
        },
        source_file: 'picovibe_good.p8mod',
        source_path: 'carts/good/source.p8mod',
      },
    },
    {
      id: 'too-large',
      extension: {
        cart_file: 'picovibe_too_large.zh-CN.p8.png',
        cart_path: 'release/picovibe_too_large.zh-CN.p8.png',
        cart_locale: 'zh-CN',
        cart_variants: {
          'en-US': {
            file: 'picovibe_too_large.en-US.p8.png',
            path: 'release/picovibe_too_large.en-US.p8.png',
          },
        },
        source_file: 'picovibe_too_large.p8mod',
        source_path: 'carts/large/large.p8mod',
      },
    },
    {
      id: 'missing',
      extension: {
        cart_file: 'picovibe_missing.zh-CN.p8.png',
        cart_path: 'release/picovibe_missing.zh-CN.p8.png',
        cart_locale: 'zh-CN',
        source_file: 'picovibe_missing.p8mod',
        source_path: 'carts/missing/missing.p8mod',
      },
    },
  ]));

  const exporter = join(root, 'fake-exporter.mjs');
  await writeFile(exporter, `
import { mkdir, writeFile } from 'node:fs/promises';
import { basename, join } from 'node:path';
const args = process.argv.slice(2);
const input = args.at(-1);
const outDir = args[args.indexOf('--out-dir') + 1];
const lang = args[args.indexOf('--lang') + 1];
if (!['zh-CN', 'en-US'].includes(lang)) {
  console.error('unexpected locale: ' + lang);
  process.exit(2);
}
if (basename(input) === 'large.p8mod' && lang === 'zh-CN') {
  console.error('compressed cart exceeds limit');
  process.exit(1);
}
await mkdir(outDir, { recursive: true });
const base = basename(input, '.p8mod');
await writeFile(join(outDir, base + '.p8.png'), 'png:' + base + ':' + lang);
`);

  return { manifest, exporter };
}

test('exports manifest carts to FCDB png names and skips per-cart failures', async () => {
  const root = await mkdtemp(join(tmpdir(), 'picovibe-fcdb-export-'));
  const outDir = join(root, 'release');
  const { manifest, exporter } = await writeFixture(root);
  await mkdir(outDir, { recursive: true });
  await writeFile(join(outDir, 'picovibe_too_large.zh-CN.p8.png'), 'stale png');

  const result = spawnSync(process.execPath, [
    batchScript,
    '--manifest', manifest,
    '--source-root', root,
    '--out-dir', outDir,
    '--exporter', exporter,
  ], { encoding: 'utf8' });

  assert.equal(result.status, 0, result.stderr);
  assert.equal(
    await readFile(join(outDir, 'picovibe_good.zh-CN.p8.png'), 'utf8'),
    'png:source:zh-CN',
  );
  assert.equal(
    await readFile(join(outDir, 'picovibe_good.en-US.p8.png'), 'utf8'),
    'png:source:en-US',
  );
  assert.equal(
    await readFile(join(outDir, 'picovibe_too_large.en-US.p8.png'), 'utf8'),
    'png:large:en-US',
  );
  await assert.rejects(readFile(join(outDir, 'picovibe_too_large.zh-CN.p8.png')));
  assert.match(result.stdout, /Built \(3\): good\[zh-CN\], good\[en-US\], too-large\[en-US\]/);
  assert.match(result.stdout, /Skipped \(2\): too-large\[zh-CN\], missing/);
});

test('rejects an invalid manifest as a build-level failure', async () => {
  const root = await mkdtemp(join(tmpdir(), 'picovibe-fcdb-manifest-'));
  const manifest = join(root, 'invalid.json');
  await writeFile(manifest, JSON.stringify({ games: [] }));

  const result = spawnSync(process.execPath, [
    batchScript,
    '--manifest', manifest,
    '--source-root', root,
    '--out-dir', join(root, 'release'),
  ], { encoding: 'utf8' });

  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /manifest must contain a JSON array/);
});

test('rejects an output directory that would delete the source root', async () => {
  const root = await mkdtemp(join(tmpdir(), 'picovibe-fcdb-safe-output-'));
  const { manifest, exporter } = await writeFixture(root);

  const result = spawnSync(process.execPath, [
    batchScript,
    '--manifest', manifest,
    '--source-root', root,
    '--out-dir', root,
    '--exporter', exporter,
  ], { encoding: 'utf8' });

  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /output directory must not contain the source root/);
  await access(manifest);
});

test('rejects a non-executable exporter as a build-level failure', async () => {
  const root = await mkdtemp(join(tmpdir(), 'picovibe-fcdb-exporter-'));
  const { manifest } = await writeFixture(root);
  const exporter = join(root, 'exporter.sh');
  await writeFile(exporter, '#!/usr/bin/env bash\nexit 0\n');
  await chmod(exporter, 0o644);

  const result = spawnSync(process.execPath, [
    batchScript,
    '--manifest', manifest,
    '--source-root', root,
    '--out-dir', join(root, 'release'),
    '--exporter', exporter,
  ], { encoding: 'utf8' });

  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /FCDB cart export failed/);
});
