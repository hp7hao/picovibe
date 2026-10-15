#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PICOVIBE_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
XWS_P8MOD=$(cd "$PICOVIBE_ROOT/../xwsdk/p8mod" && pwd)
SOURCE_ROOT=$(cd "$PICOVIBE_ROOT/../manxiangsu.web/packages/webdata/public/pico8/tools" && pwd)
DEST="$PICOVIBE_ROOT/tools/p8mod-player/runtime"
MODE=sync
[[ "${1:-}" == "--check" ]] && MODE=check

names=(p8edu.html pico8_edu_0207.js src/browsersetup.css)
sources=(
  "$SOURCE_ROOT/p8edu/p8edu.html"
  "$SOURCE_ROOT/p8edu/pico8_edu_0207.js"
  "$SOURCE_ROOT/p8edu/src/browsersetup.css"
)

mkdir -p "$DEST"
if [[ "$MODE" == sync ]]; then
  TMP_OUT=$(mktemp -d)
  trap 'rm -rf "$TMP_OUT"' EXIT
  wasm-pack build "$XWS_P8MOD" --target web --release --out-dir "$TMP_OUT" --out-name p8mod
  cp "$TMP_OUT/p8mod.js" "$DEST/p8mod.js"
  cp "$TMP_OUT/p8mod_bg.wasm" "$DEST/p8mod_bg.wasm"
  for i in "${!names[@]}"; do
    mkdir -p "$(dirname "$DEST/${names[$i]}")"
    cp "${sources[$i]}" "$DEST/${names[$i]}"
  done
  node "$PICOVIBE_ROOT/tests/write-p8mod-player-manifest.mjs" "$SOURCE_ROOT" "$DEST" "${sources[@]}"
fi

node "$PICOVIBE_ROOT/tests/verify-p8mod-player-assets.mjs"
