import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const cartUrl = new URL(
  '../carts/pico8go/firework-simulators/firework-simulators.p8mod',
  import.meta.url,
);

async function readCatalog() {
  const cart = await readFile(cartUrl, 'utf8');
  const records = [...cart.matchAll(
    /\{"(n\d{2})","(s\d{2})","(e\d{2})",(\d+),(\d+),(\d+)\}/g,
  )].map((match) => ({
    nameKey: match[1],
    shapeKey: match[2],
    effectKey: match[3],
    color: Number(match[4]),
    carrier: Number(match[5]),
    profile: Number(match[6]),
  }));
  const i18n = JSON.parse(cart.split('__i18n__\n')[1]);
  const translations = new Map(i18n.entries.map((entry) => [entry.key, entry.translations]));
  return { cart, records, translations };
}

test('firework catalog contains 50 ordered cards with reusable carriers and unique effects', async () => {
  const { cart, records } = await readCatalog();
  const sequence = Array.from({ length: 50 }, (_, index) => index + 1);

  assert.equal(records.length, 50);
  assert.deepEqual(records.map((record) => record.nameKey), sequence.map((n) => `n${String(n).padStart(2, '0')}`));
  assert.deepEqual(records.map((record) => record.shapeKey), sequence.map((n) => `s${String(n).padStart(2, '0')}`));
  assert.deepEqual(records.map((record) => record.effectKey), sequence.map((n) => `e${String(n).padStart(2, '0')}`));
  assert.deepEqual(records.map((record) => record.profile), sequence);
  assert.deepEqual([...new Set(records.map((record) => record.carrier))].sort((a, b) => a - b), sequence.slice(0, 14));
  assert.ok(new Set(records.map((record) => record.carrier)).size < records.length);

  assert.match(cart, /launch\(fw\[sel\]\[6\]\)/);
  assert.match(cart, /draw_mesh\(fw\[sel\]\[5\]\)/);
  assert.match(cart, /mode="preview"/);
  assert.match(cart, /mode="launched"/);
});

test('every firework card localizes its name, physical shape, and effect in English and Chinese', async () => {
  const { records, translations } = await readCatalog();

  for (const record of records) {
    for (const key of [record.nameKey, record.shapeKey, record.effectKey]) {
      assert.ok(translations.has(key), `missing i18n entry ${key}`);
      assert.ok(translations.get(key).en, `missing English translation ${key}`);
      assert.ok(translations.get(key).zh, `missing Chinese translation ${key}`);
    }
  }

  assert.equal(translations.get('n01').en, 'sand popper');
  assert.equal(translations.get('n16').en, 'fountain battery');
  assert.equal(translations.get('n17').en, 'color paper display');
  assert.equal(translations.get('n25').en, 'peony');
  assert.equal(translations.get('n45').en, 'brocade tail strobe');
  assert.equal(translations.get('n46').en, 'shell combination');
  assert.equal(translations.get('n50').en, 'synchronized finale');
});
