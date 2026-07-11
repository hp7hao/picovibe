# P8mod Preview Runner Design

**Date**: 2026-07-11
**Status**: Approved design evidence
**Authority**: `projects/picovibe/docs/specs/picovibe_spec.md`

## Goal

Provide a fast standalone feedback loop for human- or agent-authored `.p8mod`
files without requiring Pico8 IDE or launching the Manxiangsu application. The
runner converts the source in the browser with the shared `xwsdk/p8mod` WASM
implementation, loads the result into the PICO-8 web runtime, and reloads after
valid file changes. Pico8 IDE remains the release-export authority.

## Selected Architecture

`projects/picovibe/scripts/run-p8mod.sh` is the stable command. It starts a
loopback-only server owned by `projects/picovibe/tools/p8mod-player`, prints the
player URL, opens a browser unless `--no-open` is supplied, and watches the
input unless `--no-watch` is supplied.

The standalone page fetches the current `.p8mod`, converts it to `.p8.png` in
memory through `WasmCart.from_p8mod(...).to_p8_png(...)`, initializes the PICO-8
web engine once, and feeds the generated cart through the engine's dropped-cart
load path before issuing `RUN`. It does not import the Manxiangsu application or
invoke Pico8 IDE. Runtime artifacts are copied into PicoVibe and checked through
an explicit synchronization/verification command; the runner does not depend on
Manxiangsu's checkout layout at runtime.

## Server Contract

- `GET /` serves the player.
- `GET /cart.p8mod` serves the current source with caching disabled.
- `GET /health` reports server readiness.
- `GET /status` reports the current generation, source, state, and error.
- `GET /events` streams generation changes through server-sent events.
- `POST /status` accepts player conversion/runtime state.

Player states are `starting`, `converting`, `reloading`, `running`,
`source_error`, `conversion_error`, `engine_error`, and `load_error`. `running`
means conversion succeeded, the engine initialized, and the load/run handoff was
accepted; it does not assert gameplay correctness.

## Reload And Failure Semantics

Each observed source change increments a generation. The browser converts the
newest generation before replacing the active cart, coalescing rapid changes. A
failed conversion leaves the previous successful generation playable and
reports the error in both the page and terminal. A later save retries normally.

Watch-mode cart errors are recoverable and do not stop the server. In
`--no-watch` mode, conversion or runtime failure becomes a nonzero process exit
after the browser reports a terminal failure state. Invalid invocation or server
startup failure is always nonzero.

## Initial Scope

The initial CLI accepts `--no-open`, `--no-watch`, `--host`, and `--port`. The
default host is `127.0.0.1`; the default port is selected dynamically. Cover
selection, screenshots, scripted gameplay, advanced telemetry, and release
export are not part of the first version. Preview conversion may use a
transparent cover.

## Verification

Automated checks cover a real cart reaching `running`, invalid conversion,
recovery after a later valid save, preservation of the last successful
generation, rapid-write coalescing, `--no-open`, HTTP/SSE contracts, runtime
artifact integrity, and absence of Pico8 IDE or Manxiangsu runtime invocation.
