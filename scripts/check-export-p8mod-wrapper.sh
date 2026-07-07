#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="$ROOT/scripts/export-p8mod.sh"
INPUT="$ROOT/carts/pico8pixelbomb/i18ndemo/i18ndemo.p8mod"

if [[ ! -x "$SCRIPT" ]]; then
  echo "missing executable wrapper: $SCRIPT" >&2
  exit 1
fi

output=$("$SCRIPT" --dry-run "$INPUT")

[[ "$output" == *"../pico8ide/out/extension/p8modtool.js"* ]] || {
  echo "wrapper must invoke p8modtool through ../pico8ide" >&2
  exit 1
}

[[ "$output" == *"--format p8"* ]] || {
  echo "wrapper must export a .p8 artifact" >&2
  exit 1
}

[[ "$output" == *"--format p8.png"* ]] || {
  echo "wrapper must export a .p8.png artifact" >&2
  exit 1
}

[[ "$output" == *"--workspace-root $ROOT"* ]] || {
  echo "wrapper must pass picovibe as the p8modtool workspace root" >&2
  exit 1
}

if rg -n 'pico8i18n|customcart|img2p8|picotool|shrinko8' "$SCRIPT"; then
  echo "wrapper must not call retired local converter tools" >&2
  exit 1
fi
