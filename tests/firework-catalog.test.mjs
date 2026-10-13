import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const cartUrl = new URL(
  '../carts/pico8go/firework-simulators/firework-simulators.p8mod',
  import.meta.url,
);

async function readCatalog() {
  const cart = await readFile(cartUrl, 'utf8');
  const i18n = JSON.parse(cart.split('__i18n__\n')[1]);
  const translations = new Map(i18n.entries.map((entry) => [entry.key, entry.translations]));
  return { translations };
}

test('every firework card localizes its name, physical shape, and effect in English and Chinese', async () => {
  const { translations } = await readCatalog();

  for (let index = 1; index <= 50; index += 1) {
    for (const prefix of ['n', 's', 'e']) {
      const key = `${prefix}${String(index).padStart(2, '0')}`;
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
