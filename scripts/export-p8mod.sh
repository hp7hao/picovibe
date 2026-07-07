#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: scripts/export-p8mod.sh [--out-dir <dir>] [--dry-run] <cart.p8mod>

Exports a Picovibe .p8mod source cart to both .p8 and .p8.png by invoking the
Pico8 IDE p8modtool CLI through the sibling ../pico8ide checkout.
USAGE
}

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PICOVIBE_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
PICO8IDE_REL="../pico8ide"
PICO8IDE_ROOT=$(cd "$PICOVIBE_ROOT/$PICO8IDE_REL" && pwd)
P8MODTOOL_REL="$PICO8IDE_REL/out/extension/p8modtool.js"
P8MODTOOL_PATH="$PICOVIBE_ROOT/$P8MODTOOL_REL"
PICO8IDE_REQUIRED_MODULE="$PICO8IDE_ROOT/node_modules/opentype.js"

OUT_DIR=""
DRY_RUN=0
INPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --out-dir)
      [[ $# -ge 2 ]] || { echo "--out-dir requires a value" >&2; exit 2; }
      OUT_DIR=$2
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      [[ -z "$INPUT" ]] || { echo "Only one input cart is supported" >&2; exit 2; }
      INPUT=$1
      shift
      ;;
  esac
done

[[ -n "$INPUT" ]] || { usage >&2; exit 2; }

if [[ "$INPUT" != /* ]]; then
  INPUT="$PWD/$INPUT"
fi
INPUT=$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")

[[ -f "$INPUT" ]] || { echo "Input cart not found: $INPUT" >&2; exit 1; }
[[ "$INPUT" == *.p8mod ]] || { echo "Input must end with .p8mod: $INPUT" >&2; exit 2; }

if [[ -z "$OUT_DIR" ]]; then
  OUT_DIR="$(dirname "$INPUT")/release"
elif [[ "$OUT_DIR" != /* ]]; then
  OUT_DIR="$PWD/$OUT_DIR"
fi
OUT_DIR=$(mkdir -p "$OUT_DIR" && cd "$OUT_DIR" && pwd)

base=$(basename "$INPUT" .p8mod)
out_p8="$OUT_DIR/$base.p8"
out_png="$OUT_DIR/$base.p8.png"

print_cmd() {
  printf '%q ' "$@"
  printf '\n'
}

run_from_picovibe() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    print_cmd "$@"
  else
    (cd "$PICOVIBE_ROOT" && "$@")
  fi
}

if [[ ! -d "$PICO8IDE_REQUIRED_MODULE" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    print_cmd bash -lc "cd $PICO8IDE_REL && npm install"
  else
    (cd "$PICO8IDE_ROOT" && npm install)
  fi
fi

if [[ ! -f "$P8MODTOOL_PATH" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    print_cmd bash -lc "cd $PICO8IDE_REL && npm run compile"
  else
    (cd "$PICO8IDE_ROOT" && npm run compile)
  fi
fi

run_from_picovibe node "$P8MODTOOL_REL" "$INPUT" \
  --format p8 \
  --out "$out_p8" \
  --workspace-root "$PICOVIBE_ROOT"

run_from_picovibe node "$P8MODTOOL_REL" "$INPUT" \
  --format p8.png \
  --out "$out_png" \
  --workspace-root "$PICOVIBE_ROOT" \
  --write-provenance
