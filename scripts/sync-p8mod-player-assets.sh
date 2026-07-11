#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PICOVIBE_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
MONOREPO_ROOT=$(cd "$PICOVIBE_ROOT/../.." && pwd)
SOURCE_ROOT="$MONOREPO_ROOT/projects/manxiangsu.web/packages/webdata/public/pico8/tools"
DEST="$PICOVIBE_ROOT/tools/p8mod-player/runtime"
MODE=sync
[[ "${1:-}" == "--check" ]] && MODE=check

names=(p8mod.js p8mod_bg.wasm template.html template.js)
sources=(
  "$SOURCE_ROOT/p8mod/p8mod.js"
  "$SOURCE_ROOT/p8mod/p8mod_bg.wasm"
  "$SOURCE_ROOT/template/template.html"
  "$SOURCE_ROOT/template/template.js"
)

mkdir -p "$DEST"
if [[ "$MODE" == sync ]]; then
  for i in "${!names[@]}"; do cp "${sources[$i]}" "$DEST/${names[$i]}"; done
  node "$PICOVIBE_ROOT/tests/write-p8mod-player-manifest.mjs" "$MONOREPO_ROOT" "$DEST" "${sources[@]}"
fi

node "$PICOVIBE_ROOT/tests/verify-p8mod-player-assets.mjs"
