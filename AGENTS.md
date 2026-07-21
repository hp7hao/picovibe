# AGENTS.md

Guidance for AI coding agents when working in `projects/picovibe`.

## Project Overview

`picovibe` is a curated catalog of PICO-8 cartridges that run on the PICO8GO handheld, including community game mods that exercise device features (haptics, achievements). Cart sources and release exports here are treated as **IDE-generated output from `pico8ide`**. Picovibe also owns an authoring-only standalone browser preview runner; it is not a release conversion pipeline or cart-image build tool.

## Authoritative Spec

`docs/specs/picovibe_spec.md` is the project spec. It defines:

- The cart catalog layout and per-cart artifact contract.
- The IDE-generated source shape required for cart Lua (the expanded `-- [lib:p8go] --` block).
- The legacy → `p8go.*` migration rules.
- Validation requirements (REQ-PICOVIBE-001..007).

Upstream IPC contract: `projects/xwsdk/docs/specs/p8mod_spec.md §5.4`.
Upstream runtime source: `projects/xwsdk/p8mod/src/p8go_runtime.lua`. `libs/pico8/pico8go.lua` mirrors it byte-for-byte (REQ-PICOVIBE-004).

## Discipline

- Carts MUST NOT define legacy globals `function vibrate(...)`, `function sfxplay(...)`, `function sfxstop(...)`, `function sfxpause(...)`, `function sfxresume(...)`. The `printh "vibrator"` / `"pico8goapi"` log channels are dead-letter and have no host consumer.
- Carts that need device features MUST use `p8go.vibe`, `p8go.vibe_stop`, `p8go.ach_unlock`, `p8go.ach_progress`, `p8go.ipc_send`, exposed via the bundled p8go runtime block at the top of `__lua__`.
- Do not hand-edit the embedded `p8go` runtime block in any cart. Re-run pico8ide's include resolver, or re-mirror from `projects/xwsdk/p8mod/src/p8go_runtime.lua`.
- Use `scripts/export-p8mod.sh --lang <locale> <cart.p8mod>` for `.p8mod` release exports. The wrapper must invoke Pico8 IDE through the relative sibling path `../pico8ide/out/extension/p8modtool.js`, explicitly select its named `default` template for `.p8.png`, and write both `.p8` and `.p8.png` outputs. Do not reintroduce retired local wrappers or converter stacks such as `build_pico8cart.{sh,bat}`, `setup.*`, `requirements.txt`, `tools/pico8i18n`, `tools/customcart`, `tools/img2p8`, `deps/picotool`, or `deps/shrinko8`.
- Use `npm run build` for the FCDB catalog batch. It reads the sibling FCDB `pico8pixelbomb.json` source manifest, exports every declared BCP-47 locale, stages tracked successful runtime carts under `release/fcdb/<game>.<locale>.p8.png`, and skips individual locale variants that Pico8 IDE cannot export while reporting them in the final summary.
- Use `scripts/run-p8mod.sh <cart.p8mod>` for rapid authoring preview. It opens a dedicated Electron window, converts in renderer memory through shared `xwsdk/p8mod` WASM, and must not be described as release export.
- After changing copied player assets, run `scripts/sync-p8mod-player-assets.sh`; verification uses `--check`.

## Mod Cart Inventory (uses `p8go`)

| Cart | Path |
|------|------|
| pet-the-cat | `carts/pico8pixelbomb/pet-the-cat-pico8gomod/` |
| justoneboss | `carts/pico8pixelbomb/justoneboss-pico8gomod/` |
| celeste | `carts/pico8pixelbomb/celeste-pico8gomod/` |
| bas | `carts/pico8pixelbomb/bas-pico8gomod/` |
| pico8go-about | `carts/pico8go/pico8go-about/` |

## Verification Commands

```bash
# REQ-PICOVIBE-001: no legacy printh log channels
grep -rn 'printh.*"vibrator"\|printh.*"pico8goapi"' carts/

# REQ-PICOVIBE-002: no legacy global defs
grep -rEn '^function (vibrate|sfxplay|sfxstop|sfxpause|sfxresume)\b' carts/

# REQ-PICOVIBE-004: pico8go.lua mirrors xwsdk source (skip the 4-line picovibe header)
diff <(tail -n +5 libs/pico8/pico8go.lua) \
     <(tail -n +2 ../xwsdk/p8mod/src/p8go_runtime.lua)

# REQ-PICOVIBE-005: p8go text carts stay under compressed-code limit
# Use Pico8 IDE token/export validation for carts actively being edited.

# export wrapper uses sibling pico8ide CLI and no retired converters
bash scripts/check-export-p8mod-wrapper.sh
node --test tests/export-fcdb-carts.test.mjs

# standalone preview runner and copied runtime integrity
node --test tests/p8mod-player-server.test.mjs tests/p8mod-player-assets.test.mjs tests/p8mod-player-browser.test.mjs
bash scripts/sync-p8mod-player-assets.sh --check
```
