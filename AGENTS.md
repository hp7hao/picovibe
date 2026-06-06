# AGENTS.md

Guidance for AI coding agents when working in `projects/picovibe`.

## Project Overview

`picovibe` is a curated catalog of PICO-8 cartridges that run on the PICO8GO handheld, including community game mods that exercise device features (haptics, achievements). Cart sources here are treated as **IDE-generated output from `pico8ide`** — picovibe does not maintain a parallel runtime, shim libraries, or build helpers for the device API.

## Authoritative Spec

`docs/specs/picovibe_spec.md` is the project spec. It defines:

- The cart catalog layout and per-cart artifact contract.
- The IDE-generated source shape required for cart Lua (the expanded `-- [lib:p8go] --` block).
- The legacy → `p8go.*` migration rules.
- Validation requirements (REQ-PICOVIBE-001..005).

Upstream IPC contract: `projects/xwsdk/docs/specs/p8mod_spec.md §5.4`.
Upstream runtime source: `projects/xwsdk/p8mod/src/p8go_runtime.lua`. `libs/pico8/pico8go.lua` mirrors it byte-for-byte (REQ-PICOVIBE-004).

## Discipline

- Carts MUST NOT define legacy globals `function vibrate(...)`, `function sfxplay(...)`, `function sfxstop(...)`, `function sfxpause(...)`, `function sfxresume(...)`. The `printh "vibrator"` / `"pico8goapi"` log channels are dead-letter and have no host consumer.
- Carts that need device features MUST use `p8go.vibe`, `p8go.vibe_stop`, `p8go.ach_unlock`, `p8go.ach_progress`, `p8go.ipc_send`, exposed via the bundled p8go runtime block at the top of `__lua__`.
- Do not hand-edit the embedded `p8go` runtime block in any cart. Re-run pico8ide's include resolver, or re-mirror from `projects/xwsdk/p8mod/src/p8go_runtime.lua`.
- The picovibe build script (`build_pico8cart.sh`) does not expand bundled `--#include` libraries — those land here pre-expanded. It does still resolve per-cart `--#include ./<name>.texts.<locale>.lua` for i18n.

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
```

## Build

```bash
./build_pico8cart.sh --cart carts/pico8pixelbomb/bas-pico8gomod/basmod.p8
```
