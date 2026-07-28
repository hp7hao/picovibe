# PICOVIBE Cart Catalog Specification

**Version**: 0.4.0
**Status**: Active
**Level**: product
**Owner**: picovibe
**Parent**: docs/specs/GLOBAL_SPEC.md
**Last Reviewed**: 2026-07-20

## 1. Purpose

`picovibe` curates a catalog of PICO-8 cartridges — original works and community-modded games — that target the PICO8GO handheld. Mods exercise the PICO8GO device APIs (haptics, achievements, media control, launcher integration) on top of stock PICO-8 carts.

This spec defines:

- The catalog layout and per-cart artifact contract.
- The integration contract between cart Lua source and the PICO8GO IPC runtime.
- The migration rule from the legacy `printh "vibrator"` / `printh "pico8goapi"` pattern to the canonical `p8go.*` API.
- Authoring and release expectations: cart sources and release exports are
  produced by `pico8ide`. Picovibe does not maintain a parallel release runtime,
  `.p8mod` release-conversion pipeline, or cart-image build toolchain. It may
  provide a standalone browser preview runner for rapid authoring feedback; that
  runner is not a release exporter.

## 2. Scope

**In scope:**

- Cart files (`.p8`, `.p8.png`, `.p8mod`) under `carts/`.
- Per-cart i18n text tables (`*.texts.<locale>.lua`) and metadata (`*.meta.<locale>.json`).
- The shape of `--#include p8go` expansion that must appear in all picovibe-shipped carts that use the device API.
- The release-build contract for Pico8 IDE exporter assets, including simple
  source include ids, optional `.p8mod` compatibility constraints, and exact
  release locks/provenance for generated artifacts.
- Static support assets copied by downstream consumers, such as
  `tools/resources/fonts/3x7-font.ttf`.
- A standalone local `.p8mod` browser preview workflow for humans and agents.
- First-party cart-specific presentation behavior, including the Firework
  Simulators selection preview defined in §8.

**Out of scope:**

- The PICO8GO IPC packet format, manifest, and Lua runtime source — owned by `projects/xwsdk/docs/specs/p8mod_spec.md §5.4`.
- Host-side haptic dispatch, achievement persistence, FCDB metadata mapping — owned by `projects/pico8go/docs/specs/p8go_ipc_bridge_spec.md`.
- pico8ide editor behavior, library bundling, `--#include` resolution, and
  exporter asset-pack semantics — owned by pico8ide.
- The bundled PICO-8 manual translation under `docs/pico8manual/`. That tree is
  a copied upstream/reference documentation payload for the manual cart and is
  not Picovibe behavior authority. Availability limits described there, such as
  host bytestream channels not being available in BBS or exported carts, must
  not be read as Picovibe implementation TODOs; Picovibe's active device API
  authority remains the `p8go.*` cart-source contract in this spec plus the
  upstream xwsdk/pico8go specs named above.

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
├── scripts/export-p8mod.sh       # Thin wrapper around ../pico8ide p8modtool
├── scripts/check-export-p8mod-wrapper.sh
├── tools/resources/              # Static support assets consumed downstream
├── docs/specs/                   # This spec
└── README.md
```

Each cart directory contains:

| File | Required | Description |
|------|----------|-------------|
| `<name>.p8` | one of | Plain `.p8` source (preferred for authoring) |
| `<name>.p8mod` | one of | Extended format with `__meta__` / `__i18n__` (preferred for haptic/i18n carts) |
| `<name>.p8.png` | optional | Steganographic export |
| `<name>.texts.<locale>.lua` | per-locale | i18n string tables consumed by Pico8 IDE export |
| `<name>.meta.<locale>.json` | per-locale | Per-locale title/author metadata |
| `<name>.p8mod.lock.json` | release-only | Optional generated Pico8 IDE export provenance for reproducible `.p8mod` release builds |
| `release/` | optional | Generated artifacts from Pico8 IDE export |

## 4. Cart Source Contract: IDE-Generated Shape

Cart Lua source in this repo MUST be treated as the output of `pico8ide`'s include resolver (see `pico8ide/src/extension/libManager.ts::resolveIncludes`). In practice this means:

- Cart authoring happens in `pico8ide`, not here. Carts land in picovibe already expanded.
- `--#include` directives for **bundled** libraries (e.g. `p8go`, `vec2`) MUST be expanded inline. Picovibe build tooling does not re-resolve them.
- `--#include` for **per-cart i18n text tables** (e.g. `--#include ./pico8go-about.texts.zhcn.lua`) MAY remain unexpanded — those are resolved by the picovibe build script per locale.
- Carts MUST NOT define legacy device-bridge globals such as `function vibrate(...)`, `function sfxplay(...)`, `function sfxstop(...)`, `function sfxpause(...)`, `function sfxresume(...)`. These were `printh` stubs targeting the legacy `vibrator` / `pico8goapi` log channels and are dead-letter — no host bridge consumes them.
- Carts MUST NOT emit `printh(..., "vibrator")` or `printh(..., "pico8goapi")`.
- Carts that need device features MUST use the `p8go.*` API exclusively.

For editable `.p8mod` source carts, authoring may use simple Pico8 IDE include
ids such as `--#include p8go`. Include directives are source-level requests and
must not contain versions. If a source cart needs asset compatibility
constraints, it records them in `__meta__.export` using semver-style constraints:

```json
{
  "title": "My Game",
  "author": "Author Name",
  "template": "default",
  "export": {
    "assetPack": "pico8ide-default@^2026.07.0",
    "libs": { "p8go": "^0.1.0" },
    "templates": { "default": "^1.0.0" }
  }
}
```

Picovibe release builds use the Pico8 IDE CLI/headless exporter. The exporter
package must be pinned through the package manager and should write a sidecar
`<name>.p8mod.lock.json` provenance file for generated release artifacts. The
lock records exact exporter version, asset-pack version, per-asset versions,
and content hashes. Frozen release rebuilds must fail if a locked asset is
missing or hash-different. The `.p8mod` source remains portable; the lock is the
release reproducibility artifact.

Asset resolution for Picovibe `.p8mod` release builds follows the Pico8 IDE
contract: frozen lock first, then `__meta__.export` constraints, then bundled
exporter defaults, then explicit project asset directories only when the build
command opts into them. Conflicting asset ids with incompatible versions or
different hashes are build errors unless the command explicitly allows the
override.

Picovibe MUST NOT reintroduce local `.p8mod`/`.p8` to `.p8.png` conversion
wrappers, vendored converter submodules, or Python/C cart-image toolchains such
as `pico8i18n`, `customcart`, `img2p8`, `picotool`, or `shrinko8`. Those were
retired in favor of the Pico8 IDE exporter path.

This release rule does not prohibit the authoring-only preview runner defined in
§7.1. The preview runner converts in browser memory through the shared
`xwsdk/p8mod` WASM implementation, does not write release artifacts or
provenance, and must not be presented as equivalent to Pico8 IDE export.

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

## 5. `libs/pico8/` Directory And Export Assets

`libs/pico8/` mirrors selected pico8ide bundled libraries so picovibe-side tooling, samples, and offline reference can resolve them without a pico8ide install. The files are reference copies — they are not loaded into shipped carts (carts ship pre-expanded per §4).

| File | Mirrors | Purpose |
|------|---------|---------|
| `pico8go.lua` | `pico8ide/resources/libs/p8go.json` `code` field, kept aligned with `xwsdk/p8mod/src/p8go_runtime.lua` | Reference of the canonical p8go runtime source |
| `i18n.lua`, `qrcode.lua`, `speako8.lua` | n/a (picovibe-original helpers) | Authoring helpers |

Drift between `libs/pico8/pico8go.lua` and the xwsdk source is a bug.

`.p8mod` release builds treat Pico8 IDE's exporter package and its asset
manifest as the default source of shared libs, templates, and generated cart
images. Picovibe may keep static assets only when they are consumed directly by
downstream projects or selected explicitly by the Pico8 IDE exporter and
recorded in release lock/provenance.

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

## 7. Release Export Pipeline

Picovibe release exports are produced through the Pico8 IDE CLI/headless export
path. For `.p8mod` inputs, Pico8 IDE resolves simple include ids through the
exporter asset contract, generates localized `.p8` or `.p8.png` artifacts, and
writes exact asset provenance for release builds. Existing generated carts remain
valid consumers of the Pico8 IDE-expanded shape described above.

The Picovibe entrypoint is
`scripts/export-p8mod.sh --lang <locale> <cart.p8mod>`. The wrapper
resolves the sibling Pico8 IDE checkout as `../pico8ide` relative to
`projects/picovibe`, ensures Pico8 IDE package dependencies are installed when
its required runtime modules are absent, compiles Pico8 IDE only when
`../pico8ide/out/extension/p8modtool.js` is missing, then invokes:

```bash
node ../pico8ide/out/extension/p8modtool.js <cart.p8mod> --format p8 --lang <locale> --out <release>/<name>.p8 --workspace-root <picovibe-root>
node ../pico8ide/out/extension/p8modtool.js <cart.p8mod> --format p8.png --lang <locale> --template default --out <release>/<name>.p8.png --workspace-root <picovibe-root> --write-provenance
```

By default `<release>` is the input cart's sibling `release/` directory. The
wrapper may accept an explicit `--out-dir`, but it must not synthesize cart data
itself or call any retired local converter.
PicoVibe exports MUST pass Pico8 IDE's named `default` cart template explicitly
for `.p8.png`; Pico8 IDE remains the template asset owner. Successful localized
artifacts under `release/fcdb/` are tracked release outputs, not ignored scratch
files, so FCDB can consume the reviewed PicoVibe snapshot without requiring a
fresh export. The batch still recreates that directory to prune stale variants.

For catalog builds, `scripts/export-fcdb-carts.mjs` reads the FCDB
`sources/pico8/pico8pixelbomb.json` manifest from the sibling `projects/fcdb`
checkout. Each entry's `extension.source_path` identifies an editable Picovibe
`.p8mod` source. Picovibe source locales MUST use correctly cased BCP-47 tags
matching FCDB (`zh-CN`, `en-US`, and similar), not short or underscore aliases.
For a localized source, the primary target is declared by FCDB's scalar
`cart_file`, `cart_path`, and `cart_locale`; `cart_variants` declares only
additional targets. A normal scalar game without a `.p8mod` source or locale
fields remains outside this optional batch compilation path. The batch exporter invokes `scripts/export-p8mod.sh` independently for every
locale declared by `__i18n__.locales` and stages each successful artifact under
`release/fcdb/<base>.<locale>.p8.png`. A locale failure skips only that locale;
other locales and later games continue. This keeps FCDB's game metadata and
distributed names authoritative without teaching FCDB how to compile the
extended source format.

The batch exporter recreates `release/fcdb/` on each run so failed carts cannot
leave stale runtime artifacts in the staged snapshot. It treats manifest
loading, manifest shape, output-directory setup, and exporter availability as
build-level failures. A missing source cart
or a failed cart export, including Pico8 cartridge size-limit failures, is a
per-locale skip: the batch continues with later locales and games and prints a
final list of successful and skipped `<game-id>[<locale>]` variants. Per-locale
skips do not make the batch command fail; FCDB packaging can subsequently
collect the successful `.p8.png` files
and retain `.p8mod` as an additional editor-capable source artifact.

Retired local wrappers and dependencies (`build_pico8cart.{sh,bat}`, `setup.*`,
`requirements.txt`, `tools/pico8i18n`, `tools/customcart`, `tools/img2p8`,
`deps/picotool`, and `deps/shrinko8`) are not part of the active Picovibe build
surface. Do not add compatibility wrappers for those paths; update the Pico8 IDE
exporter contract instead.

### 7.1 Standalone Authoring Preview

Picovibe provides `scripts/run-p8mod.sh <cart.p8mod>` as the stable rapid-preview
entrypoint. The command starts a loopback HTTP server and standalone player owned
by `tools/p8mod-player`, opens a dedicated Electron window by default, and watches
the source by default. The preview must not use the system web browser or boot the
Manxiangsu application. `--no-open` supports agents and CI; `--no-watch` selects deterministic
one-shot behavior; `--host` and `--port` override the loopback/dynamic-port
defaults.

The player converts the fetched `.p8mod` in browser memory through the shared
`projects/xwsdk/p8mod` playable-export WASM API, which prepends the generated
i18n Lua runtime when `outputLocale` is selected, then loads the generated `.p8.png` into the
PICO-8 web runtime. It must not invoke Pico8 IDE, import or boot Manxiangsu, write
release artifacts, or depend on Manxiangsu paths at runtime. Copied runtime
assets require an explicit synchronization/integrity guard.

The server exposes `/health`, `/status`, `/events`, and `/cart.p8mod`. Player
status distinguishes `starting`, `converting`, `reloading`, `running`,
`source_error`, `conversion_error`, `engine_error`, and `load_error`. `running`
means conversion, engine initialization, and cart load/run handoff succeeded; it
does not certify gameplay correctness.

Every observed source change increments a generation. The browser converts the
newest generation before replacing the active cart and coalesces rapid changes.
If conversion fails, the last successful generation remains playable and the
error is reported in the browser, terminal, and `/status`; a later save retries.
Watch-mode cart errors remain recoverable. One-shot conversion/runtime failures
exit nonzero after the browser reports the terminal state.

After submitting the engine's cart-load command, the player must wait until the
engine consumes that command, allow the console prompt to become ready, and only
then submit `RUN`. It reports `running` after that ordered handoff, not after
a fixed delay from cart submission. Browser verification must distinguish the
loaded cart from the bundled template cart by an observable cart-specific frame.

## 8. Firework Simulators Catalog And Physical Preview

`carts/pico8go/firework-simulators/firework-simulators.p8mod` provides a large
physical-product preview while the player selects one of 50 curated fireworks.
The catalog is ordered from small, local, and mechanically simple products to
large, layered, and choreographed displays. This order is a game-content
progression, not a safety ranking or an official Chinese classification count.
The non-authoritative research evidence for the names and ordering is recorded
in `projects/picovibe/docs/notes/2026-07-15-chinese-firework-taxonomy-and-effects.md`.

Every selection separates the physical carrier from its visible and audible
effect profile. Carrier models may be reused when several effects use the same
external shell, tube, cake, or frame. Every selection must still have an
authored launch profile that distinguishes it through at least one of geometry,
motion, colour sequence, trail, strobe, crackle, break count, timing, sound, or
choreography. The UI provides localized English and Chinese names and concise
effect descriptions for all 50 entries. Product-class terminology must not
present curated combinations or show vocabulary as official GB categories.

The carrier preview is a procedural low-poly model representing the external
casing or launcher rather than an unsupported guess about internal construction.
It rotates continuously around its vertical axis and uses projected,
depth-sorted polygon faces with palette shading, an outline, and a ground shadow
to communicate volume within PICO-8 constraints.

The preview replaces the sky area while selection is idle. Left and right change
the selected model without launching it. Firing immediately hides the preview
and restores the unobstructed sky for the particle simulation. The preview
returns when the launched effect and its scheduled jobs have completed. Changing
selection during an active effect clears it and returns directly to the newly
selected model. The existing name, power, description, and control panel remain
visible in both modes.

## 9. Validation Contract

The cart tree and FCDB metadata own the current catalog inventory. Static guards
reject legacy `printh` device shims and local copies of vibration/audio helpers;
every `p8go.*` consumer and the authoring library must match the canonical XWSDK
runtime. Pico8 IDE validation enforces the 15,608-byte compressed-body boundary
for release PNGs. Headless release export preserves simple include ids, enforces
declared asset constraints, records exporter/asset hashes, and selects the named
`default` template.

The preview runner uses shared XWSDK WASM, publishes phase-specific state, and
keeps the last successful generation across failed watched reloads without
invoking Pico8 IDE or Manxiangsu. The FCDB exporter resolves sources from
`extension.source_path`, exports declared BCP-47 locales to deterministic names,
continues across per-locale omissions, and fails only for build-level errors.
Firework Simulators must retain its 50 localized, ordered selections and the
carrier/effect behavior defined above. Executable cases and cart names stay in
tests and catalog data rather than this contract.

## 10. References

- `projects/xwsdk/docs/specs/p8mod_spec.md` — IPC packet format, manifest, runtime source (authoritative)
- `projects/xwsdk/p8mod/src/p8go_runtime.lua` — runtime source mirrored here
- `projects/pico8go/docs/specs/p8go_ipc_bridge_spec.md` — host-side haptic dispatch and achievement persistence
- `projects/pico8ide/src/extension/libManager.ts` — `--#include` expansion that produces the cart shape required by §4.1
- `projects/pico8ide/resources/libs/p8go.json` — bundled lib manifest
- `projects/pico8ide/docs/SPEC.md` — reference documentation for the headless
  export asset contract; root `docs/specs/spec_index.md` classifies it as
  reference-only for monorepo SDD purposes.

## Agent Contract

| Field | Contract |
|---|---|
| Governed files | `projects/picovibe/carts/**`, `libs/pico8/**`, `scripts/export-p8mod.sh`, `scripts/export-fcdb-carts.mjs`, `scripts/check-export-p8mod-wrapper.sh`, `scripts/run-p8mod.sh`, `tools/p8mod-player/**`, `tools/resources/**`, and Picovibe catalog metadata. |
| Invariants | Treat generated release cart outputs as pico8ide-generated; keep editable `.p8mod` includes simple; call Pico8 IDE through the relative `../pico8ide/out/extension/p8modtool.js` path; use release locks/provenance for exact exporter asset provenance; keep preview conversion authoring-only and backed by shared `xwsdk/p8mod` WASM; use canonical `p8go.*` runtime shape; do not reintroduce release conversion wrappers, vendored converter submodules, or legacy `printh` device API shims. |
| Validation | Picovibe REQ checks, `bash scripts/check-export-p8mod-wrapper.sh`, FCDB catalog batch-export tests, standalone runner HTTP/state/reload tests and runtime-asset integrity guard, Pico8 IDE compressed-size/export checks for release carts, p8go runtime byte-match checks, and Pico8 IDE exporter lock/provenance checks for `.p8mod` release builds. |
| Parent specs | `docs/specs/GLOBAL_SPEC.md`, `projects/xwsdk/docs/specs/p8mod_spec.md`, `projects/pico8go/docs/specs/p8go_ipc_bridge_spec.md`. |
