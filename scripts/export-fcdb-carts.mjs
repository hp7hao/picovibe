#!/usr/bin/env node

import { spawnSync } from 'node:child_process';
import { constants as fsConstants } from 'node:fs';
import {
  access,
  copyFile,
  mkdir,
  mkdtemp,
  readFile,
  rm,
} from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { basename, dirname, isAbsolute, join, relative, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const projectRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');

function usage() {
  console.log(`Usage: scripts/export-fcdb-carts.mjs [options]

Options:
  --manifest <file>     FCDB source manifest
  --source-root <dir>   Root used to resolve manifest cart_path values
  --out-dir <dir>       Directory for generated .p8.png files
  --exporter <file>     Single-cart exporter command
  -h, --help            Show this help`);
}

function parseArgs(argv) {
  const options = {
    manifest: resolve(projectRoot, '../fcdb/platforms/pico8/metadata/sources/pico8pixelbomb.json'),
    sourceRoot: projectRoot,
    outDir: resolve(projectRoot, 'release/fcdb'),
    exporter: resolve(projectRoot, 'scripts/export-p8mod.sh'),
  };

  for (let index = 0; index < argv.length; index += 1) {
    const option = argv[index];
    if (option === '-h' || option === '--help') {
      usage();
      process.exit(0);
    }

    const value = argv[index + 1];
    if (!value || !['--manifest', '--source-root', '--out-dir', '--exporter'].includes(option)) {
      throw new Error(`unknown or incomplete option: ${option}`);
    }
    index += 1;

    if (option === '--manifest') options.manifest = resolve(value);
    if (option === '--source-root') options.sourceRoot = resolve(value);
    if (option === '--out-dir') options.outDir = resolve(value);
    if (option === '--exporter') options.exporter = resolve(value);
  }

  return options;
}

function resolveInside(root, candidate) {
  if (typeof candidate !== 'string' || candidate.length === 0 || isAbsolute(candidate)) {
    return null;
  }

  const resolved = resolve(root, candidate);
  const pathFromRoot = relative(root, resolved);
  if (pathFromRoot === '..' || pathFromRoot.startsWith(`..${sep}`) || isAbsolute(pathFromRoot)) {
    return null;
  }
  return resolved;
}

function isCanonicalLocale(locale) {
  if (typeof locale !== 'string' || !/^[a-z]{2,3}(?:-[A-Z][a-z]{3})?(?:-[A-Z]{2}|-[0-9]{3})?$/.test(locale)) {
    return false;
  }
  try {
    return Intl.getCanonicalLocales(locale)[0] === locale;
  } catch {
    return false;
  }
}

async function declaredLocales(input) {
  const text = await readFile(input, 'utf8');
  const header = text.match(/^__i18n__[ \t]*\r?$/m);
  if (!header || header.index === undefined) return [];
  const bodyStart = header.index + header[0].length;
  const remainder = text.slice(bodyStart).replace(/^\r?\n/, '');
  const nextHeader = remainder.search(/^__[a-z0-9_]+__[ \t]*\r?$/im);
  const section = nextHeader >= 0 ? remainder.slice(0, nextHeader) : remainder;

  try {
    const i18n = JSON.parse(section);
    if (!Array.isArray(i18n.locales) || i18n.locales.length === 0) return [];
    return i18n.locales.every(isCanonicalLocale) ? [...i18n.locales] : [];
  } catch {
    return [];
  }
}

function exporterCommand(exporter, input, outDir, lang) {
  const args = ['--out-dir', outDir, '--lang', lang, input];
  return exporter.endsWith('.mjs')
    ? { command: process.execPath, args: [exporter, ...args] }
    : { command: exporter, args };
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const sourceFromOutput = relative(options.outDir, options.sourceRoot);
  if (sourceFromOutput === '' || (!sourceFromOutput.startsWith(`..${sep}`) && sourceFromOutput !== '..')) {
    throw new Error('output directory must not contain the source root');
  }

  await access(
    options.exporter,
    options.exporter.endsWith('.mjs') ? fsConstants.R_OK : fsConstants.X_OK,
  );

  let manifest;
  try {
    manifest = JSON.parse(await readFile(options.manifest, 'utf8'));
  } catch (error) {
    throw new Error(`cannot load manifest ${options.manifest}: ${error.message}`);
  }
  if (!Array.isArray(manifest)) {
    throw new Error('manifest must contain a JSON array');
  }

  await rm(options.outDir, { recursive: true, force: true });
  await mkdir(options.outDir, { recursive: true });
  const built = [];
  const skipped = [];

  for (const entry of manifest) {
    const id = typeof entry?.id === 'string' && entry.id ? entry.id : '<unknown>';
    const source = resolveInside(options.sourceRoot, entry?.extension?.source_path);
    const extension = entry?.extension;
    const primaryLocale = extension?.cart_locale;
    const variants = extension?.cart_variants;

    if (!source || !isCanonicalLocale(primaryLocale)
      || typeof extension?.cart_file !== 'string' || typeof extension?.cart_path !== 'string'
      || (variants !== undefined && (typeof variants !== 'object' || Array.isArray(variants)))) {
      console.error(`SKIP ${id}: invalid source_path, primary cart, or cart_variants`);
      skipped.push(id);
      continue;
    }

    const targets = {
      [primaryLocale]: { file: extension.cart_file, path: extension.cart_path },
      ...(variants || {}),
    };

    try {
      await access(source);
    } catch {
      console.error(`SKIP ${id}: source cart not found: ${source}`);
      skipped.push(id);
      continue;
    }

    const locales = await declaredLocales(source);
    if (locales.length === 0) {
      console.error(`SKIP ${id}: source has no canonical BCP-47 __i18n__.locales`);
      skipped.push(id);
      continue;
    }

    for (const lang of locales) {
      const variant = `${id}[${lang}]`;
      const outputName = targets[lang]?.file;
      const declaredOutputPath = targets[lang]?.path;
      if (typeof outputName !== 'string' || basename(outputName) !== outputName
        || typeof declaredOutputPath !== 'string'
        || resolveInside(options.sourceRoot, declaredOutputPath) !== join(options.outDir, outputName)) {
        console.error(`SKIP ${variant}: manifest locale paths do not match the staging output`);
        skipped.push(variant);
        continue;
      }

      const workDir = await mkdtemp(join(tmpdir(), 'picovibe-export-'));
      try {
        const invocation = exporterCommand(options.exporter, source, workDir, lang);
        const result = spawnSync(invocation.command, invocation.args, {
          encoding: 'utf8',
          stdio: ['ignore', 'pipe', 'pipe'],
        });
        const sourcePng = join(workDir, `${basename(source, '.p8mod')}.p8.png`);

        if (result.status !== 0) {
          const detail = result.stderr.trim() || result.stdout.trim() || `exit ${result.status}`;
          console.error(`SKIP ${variant}: ${detail}`);
          skipped.push(variant);
          continue;
        }

        await access(sourcePng);
        await copyFile(sourcePng, join(options.outDir, outputName));
        console.log(`BUILT ${variant}: ${outputName}`);
        built.push(variant);
      } catch (error) {
        console.error(`SKIP ${variant}: ${error.message}`);
        skipped.push(variant);
      } finally {
        await rm(workDir, { recursive: true, force: true });
      }
    }
  }

  console.log(`Built (${built.length}): ${built.join(', ') || 'none'}`);
  console.log(`Skipped (${skipped.length}): ${skipped.join(', ') || 'none'}`);
}

main().catch((error) => {
  console.error(`FCDB cart export failed: ${error.message}`);
  process.exitCode = 1;
});
