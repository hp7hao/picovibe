#!/usr/bin/env python3
"""Check p8go text carts against Picovibe's compressed-code size limit."""

from __future__ import annotations

import sys
from pathlib import Path


PNG_COMPRESSED_BODY_LIMIT = 0x8000 - 0x4300 - 8
SOURCE_ONLY_OVERSIZE_CARTS = {
    "carts/pico8pixelbomb/justoneboss-pico8gomod/justonebossmod.p8",
    "carts/pico8pixelbomb/justoneboss-pico8gomod/justonebossmod.p8mod",
}
PROJECT_ROOT = Path(__file__).resolve().parents[1]
PICOTOOL = PROJECT_ROOT / "deps" / "picotool"

sys.path.insert(0, str(PICOTOOL))

from pico8.game.compress import compress_code  # noqa: E402


def lua_section(path: Path) -> bytes:
    text = path.read_text(encoding="utf-8")
    marker = "__lua__"
    start = text.find(marker)
    if start == -1:
        raise ValueError("missing __lua__ section")
    body = text[start + len(marker) :]

    next_section = body.find("\n__")
    if next_section != -1:
        body = body[:next_section]

    return body.lstrip("\r\n").encode("utf-8")


def iter_p8go_text_carts() -> list[Path]:
    candidates = [
        *PROJECT_ROOT.glob("carts/**/*.p8"),
        *PROJECT_ROOT.glob("carts/**/*.p8mod"),
    ]
    return sorted(
        path
        for path in candidates
        if "p8go." in path.read_text(encoding="utf-8", errors="ignore")
    )


def main() -> int:
    failed = False
    for path in iter_p8go_text_carts():
        rel = path.relative_to(PROJECT_ROOT)
        rel_posix = rel.as_posix()
        try:
            size = len(compress_code(lua_section(path)))
        except Exception as error:  # noqa: BLE001 - report every bad cart.
            print(f"{rel}: ERROR {error}", file=sys.stderr)
            failed = True
            continue

        if size <= PNG_COMPRESSED_BODY_LIMIT:
            status = "OK"
        elif rel_posix in SOURCE_ONLY_OVERSIZE_CARTS:
            status = "SOURCE-ONLY"
        else:
            status = "FAIL"
            failed = True

        print(f"{rel}: {size}/{PNG_COMPRESSED_BODY_LIMIT} compressed bytes {status}")

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
