# PICOVIBE Cart Catalog Specification

**Version**: 0.1.0
**Status**: Active
**Level**: product
**Owner**: picovibe
**Parent**: docs/specs/GLOBAL_SPEC.md
**Last Reviewed**: 2026-05-12

## 1. Purpose

`picovibe` curates a catalog of PICO-8 cartridges — original works and community-modded games — that target the PICO8GO handheld. Mods exercise the PICO8GO device APIs (haptics, achievements, media control, launcher integration) on top of stock PICO-8 carts.

This spec defines:

- The catalog layout and per-cart artifact contract.
- The integration contract between cart Lua source and the PICO8GO IPC runtime.
- The migration rule from the legacy `printh "vibrator"` / `printh "pico8goapi"` pattern to the canonical `p8go.*` API.
- Authoring expectations: cart sources are treated as **IDE-generated output** from `pico8ide`. Picovibe does not maintain a parallel runtime, build helpers, or shim libraries.

## 2. Scope

**In scope:**

- Cart files (`.p8`, `.p8.png`, `.p8mod`) under `carts/`.
- Per-cart i18n text tables (`*.texts.<locale>.lua`) and metadata (`*.meta.<locale>.json`).
- The shape of `--#include p8go` expansion that must appear in all picovibe-shipped carts that use the device API.
- Build wrappers (`build_pico8cart.sh`, `build_pico8cart.bat`) and tooling under `tools/` for packaging carts into releases.

**Out of scope:**

- The PICO8GO IPC packet format, manifest, and Lua runtime source — owned by `projects/xwsdk/docs/specs/p8mod_spec.md §5.4`.
- Host-side haptic dispatch, achievement persistence, FCDB metadata mapping — owned by `projects/pico8go/docs/specs/p8go_ipc_bridge_spec.md`.
- pico8ide editor behavior, library bundling, `--#include` resolution — owned by pico8ide.
- The bundled PICO-8 manual translation under `docs/pico8manual/`.

## 3. Catalog Layout

```
projects/picovibe/
├── carts/
│   ├── pico8go/                  # First-party carts shipped on the PICO8GO handheld
│   │   ├── pico8go-about/
│   │   ├── pico8go-thanks/
│   │   ├── pico8go-wizard/
│   │   ├── pico8go-manual/
│   │   └── pico8go-bilibilideck/
│   ├── pico8pixelbomb/           # Community mods (haptic + i18n + audio)
│   │   ├── bas-pico8gomod/
│   │   ├── celeste-pico8gomod/
│   │   ├── justoneboss-pico8gomod/
│   │   ├── pet-the-cat-pico8gomod/
│   │   ├── i18ndemo/
│   │   ├── nezhapoems/
│   │   ├── splooshdemo/
│   │   ├── yxkl/
│   │   └── pico8mural/
│   └── manxiangsu/               # Misc community carts
├── libs/pico8/                   # Mirror copies of pico8ide bundled libs (see §5)
├── tools/                        # Build helpers (pico8i18n, img2p8, customcart)
├── deps/picotool/                # Vendored picotool
├── docs/specs/                   # This spec
└── build_pico8cart.{sh,bat}      # Per-cart build entrypoints
```

Each cart directory contains:

| File | Required | Description |
|------|----------|-------------|
| `<name>.p8` | one of | Plain `.p8` source (preferred for authoring) |
| `<name>.p8mod` | one of | Extended format with `__meta__` / `__i18n__` (preferred for haptic/i18n carts) |
| `<name>.p8.png` | optional | Steganographic export |
| `<name>.texts.<locale>.lua` | per-locale | i18n string tables (consumed by `pico8i18n`) |
| `<name>.meta.<locale>.json` | per-locale | Per-locale title/author metadata |
| `release/` | optional | Generated artifacts from `build_pico8cart.sh` |

## 4. Cart Source Contract: IDE-Generated Shape

Cart Lua source in this repo MUST be treated as the output of `pico8ide`'s include resolver (see `pico8ide/src/extension/libManager.ts::resolveIncludes`). In practice this means:

- Cart authoring happens in `pico8ide`, not here. Carts land in picovibe already expanded.
- `--#include` directives for **bundled** libraries (e.g. `p8go`, `vec2`) MUST be expanded inline. Picovibe build tooling does not re-resolve them.
- `--#include` for **per-cart i18n text tables** (e.g. `--#include ./pico8go-about.texts.zhcn.lua`) MAY remain unexpanded — those are resolved by the picovibe build script per locale.
- Carts MUST NOT define legacy device-bridge globals such as `function vibrate(...)`, `function sfxplay(...)`, `function sfxstop(...)`, `function sfxpause(...)`, `function sfxresume(...)`. These were `printh` stubs targeting the legacy `vibrator` / `pico8goapi` log channels and are dead-letter — no host bridge consumes them.
- Carts MUST NOT emit `printh(..., "vibrator")` or `printh(..., "pico8goapi")`.
- Carts that need device features MUST use the `p8go.*` API exclusively.

### 4.1 Expanded `p8go` Block Format

When a cart uses the device API, the bundled `p8go` runtime MUST appear at the top of the `__lua__` section, framed by the markers pico8ide emits:

```lua
__lua__
-- [lib:p8go] --
-- p8go runtime v0
p8go={}
local _b=0x5f80
local _s=0
local function _w(cmd,ch,msg)
 _s=(_s+1)%256
 ch=ch or ""
 msg=msg or ""
 poke(_b,0)
 poke(_b+1,_s)
 poke(_b+2,112) poke(_b+3,56) poke(_b+4,103) poke(_b+5,111) poke(_b+6,33)
 poke(_b+7,cmd)
 poke(_b+8,#ch)
 poke(_b+9,#msg)
 for i=1,min(#ch,8) do poke(_b+9+i,ord(ch,i)) end
 for i=1,min(#msg,13) do poke(_b+17+i,ord(msg,i)) end
 local c=0
 for i=0,30 do c=(c+peek(_b+i))%256 end
 poke(_b+31,c)
end
function p8go.has(_) return peek(_b+2)==112 and peek(_b+3)==56 end
function p8go.ipc_send(ch,msg) _w(1,ch,msg) end
function p8go.vibe(ms,strength) p8go.ipc_send("haptic",chr(1)..chr(ms%256)..chr(flr((strength or 1)*255))) end
function p8go.vibe_stop() p8go.ipc_send("haptic",chr(2)) end
function p8go.ach_unlock(id) p8go.ipc_send("ach",chr(1)..id) end
function p8go.ach_progress(id,v,t) p8go.ipc_send("ach",chr(2)..id..":"..v..":"..t) end
-- [/lib:p8go] --
```

The block content is the verbatim `code` field of `pico8ide/resources/libs/p8go.json`, which itself mirrors `xwsdk/p8mod/src/p8go_runtime.lua`. When that source updates, picovibe carts are regenerated by re-running pico8ide. Do not hand-edit the block in picovibe.

## 5. `libs/pico8/` Directory

`libs/pico8/` mirrors selected pico8ide bundled libraries so picovibe-side tooling, samples, and offline reference can resolve them without a pico8ide install. The files are reference copies — they are not loaded into shipped carts (carts ship pre-expanded per §4).

| File | Mirrors | Purpose |
|------|---------|---------|
| `pico8go.lua` | `pico8ide/resources/libs/p8go.json` `code` field, kept aligned with `xwsdk/p8mod/src/p8go_runtime.lua` | Reference of the canonical p8go runtime source |
| `i18n.lua`, `qrcode.lua`, `speako8.lua` | n/a (picovibe-original helpers) | Authoring helpers |

Drift between `libs/pico8/pico8go.lua` and the xwsdk source is a bug.

## 6. Legacy → p8go Migration Rules

The legacy haptic surface in pre-2026 picovibe carts was:

```lua
function vibrate(s, d)            -- s = "strength bucket" 1..3, d = "duration ms"
    printh("vibrate "..s.." "..d, "vibrator")
end

function vibrate(s, d, delay)     -- justoneboss variant; delay was never honored
    printh("vibrate "..s.." "..d.." "..delay, "vibrator")
end
```

No host process ever consumed the `vibrator` log channel (verified 2026-05-12: zero matches across pico8go, xwsdk, gamingshell). Migration replaces every legacy site with `p8go.vibe`:

| Legacy call | Migrated call |
|-------------|---------------|
| `vibrate(1, d)` | `p8go.vibe(min(d,255), 0.33)` |
| `vibrate(2, d)` | `p8go.vibe(min(d,255), 0.66)` |
| `vibrate(3, d)` | `p8go.vibe(min(d,255), 1.0)` |
| `vibrate(s, d, delay)` | Drop `delay`. Map `s` and `d` as above. |

Notes:

- `d` is clamped to 255 because the V0 packet payload encodes ms in a single byte (`p8go_runtime.lua` line 23 uses `ms%256`). Longer haptics chain multiple `p8go.vibe` calls; this is rare in the catalog (`max d = 1200` in pet-the-cat, `max d = 900` in justoneboss).
- The legacy `delay` argument in `vibrate(s, d, delay)` is dropped. Reason: it was never wired through any consumer, so removing it preserves observable behavior. If a future cart genuinely needs deferred haptics, schedule `p8go.vibe` from the cart's own tick counter.
- Inline `function vibrate(...)` definitions are removed entirely; `p8go.vibe` is the only callable.
- Legacy `sfxplay` / `sfxstop` / `sfxpause` / `sfxresume` (printh on the `pico8goapi` channel) are not in active use in any cart. They are removed from `libs/pico8/pico8go.lua` and not re-exposed under `p8go`. If host-controlled music is wanted later, route it through `p8go.ipc_send("media", ...)` per the package conventions in `xwsdk/p8mod_spec §5.4`.

## 7. Build Pipeline

`build_pico8cart.sh --cart <path>`:

1. Detects locales from `*.texts.<locale>.lua` siblings.
2. Generates per-locale Lua via `tools/pico8i18n`.
3. Invokes PICO-8 to export `.p8.png` per locale.
4. Optionally applies a cart template image (`tools/customcart`).
5. Writes outputs to `<cart>/release/`.

The build script does not expand bundled `--#include` libraries (those are pre-expanded per §4) and does not synthesize device-bridge stubs.

## 8. Catalog Inventory (Mod Carts using `p8go`)

| Cart | Path | Migrated to p8go |
|------|------|------------------|
| pet-the-cat | `carts/pico8pixelbomb/pet-the-cat-pico8gomod/` | required |
| justoneboss | `carts/pico8pixelbomb/justoneboss-pico8gomod/` | required (drop `delay` arg) |
| celeste | `carts/pico8pixelbomb/celeste-pico8gomod/` | required |
| bas | `carts/pico8pixelbomb/bas-pico8gomod/` | required |
| pico8go-about | `carts/pico8go/pico8go-about/` | required |

Carts not on this list either do not use device APIs or are non-haptic demos (`i18ndemo`, `nezhapoems`, `splooshdemo`, `yxkl`, `pico8mural`).

## 9. Testing Criteria

- REQ-PICOVIBE-001: No file under `carts/` contains `printh(..., "vibrator")` or `printh(..., "pico8goapi")`.
- REQ-PICOVIBE-002: No file under `carts/` defines a top-level `function vibrate(`, `function sfxplay(`, `function sfxstop(`, `function sfxpause(`, `function sfxresume(`.
- REQ-PICOVIBE-003: Every cart that calls `p8go.*` contains a `-- [lib:p8go] --` … `-- [/lib:p8go] --` block whose content matches `xwsdk/p8mod/src/p8go_runtime.lua` byte-for-byte (after stripping the markers).
- REQ-PICOVIBE-004: `libs/pico8/pico8go.lua` matches `xwsdk/p8mod/src/p8go_runtime.lua` byte-for-byte.
- REQ-PICOVIBE-005: Each migrated cart's compressed code size stays within PICO-8's 12544-byte limit (verified via `cargo run -p p8mod -- count`, or pico8ide token panel).

## 10. References

- `projects/xwsdk/docs/specs/p8mod_spec.md` — IPC packet format, manifest, runtime source (authoritative)
- `projects/xwsdk/p8mod/src/p8go_runtime.lua` — runtime source mirrored here
- `projects/pico8go/docs/specs/p8go_ipc_bridge_spec.md` — host-side haptic dispatch and achievement persistence
- `projects/pico8ide/src/extension/libManager.ts` — `--#include` expansion that produces the cart shape required by §4.1
- `projects/pico8ide/resources/libs/p8go.json` — bundled lib manifest
