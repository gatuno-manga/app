#!/usr/bin/env python3
"""Check the Impeccable context files (issue #40) for internal consistency.

Validates .impeccable/design.json structure, that every token carries a Figma
name, that DESIGN.md mentions every token, and that surface files only
reference tokens that exist. Standard library only. Exit code 1 on any error.

Usage: python3 tool/check_design_tokens.py
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DESIGN_JSON = ROOT / ".impeccable" / "design.json"
DESIGN_MD = ROOT / "DESIGN.md"
PRODUCT_MD = ROOT / "PRODUCT.md"
SURFACES = ROOT / ".impeccable" / "surfaces"
REQUIRED_SURFACES = [
    "home", "latest-reads", "books-list", "book-detail",
    "reader", "library", "profile", "settings", "auth",
]
HEX = re.compile(r"^#[0-9a-f]{6}([0-9a-f]{2})?$")
STATUSES = {"match", "differs", "missing"}

errors = []


def err(msg):
    errors.append(msg)


def check_flutter(key, tok):
    fl = tok.get("flutter")
    if not isinstance(fl, dict) or fl.get("status") not in STATUSES:
        err(f"{key}: flutter.status must be one of {sorted(STATUSES)}")
        return
    if fl["status"] != "missing" and not fl.get("target"):
        err(f"{key}: status {fl['status']} requires flutter.target")


def main():
    for path in (DESIGN_JSON, DESIGN_MD, PRODUCT_MD):
        if not path.is_file():
            err(f"missing file: {path.relative_to(ROOT)}")
    if errors:
        return
    data = json.loads(DESIGN_JSON.read_text(encoding="utf-8"))
    themes = data.get("themes", [])
    if len(themes) != 5:
        err(f"expected 5 themes, found {len(themes)}")
    keys = []

    for key, tok in data.get("colors", {}).items():
        keys.append(key)
        if tok.get("figma", {}).get("name") != key:
            err(f"{key}: figma.name must equal the key")
        for theme in themes:
            val = tok.get("values", {}).get(theme)
            if not isinstance(val, str) or not HEX.match(val):
                err(f"{key}: bad hex for theme {theme}: {val!r}")
        check_flutter(key, tok)
        code = tok["flutter"].get("code", {})
        for theme, val in code.items():
            if val is not None and not HEX.match(val):
                err(f"{key}: bad code hex for {theme}: {val!r}")

    modes = data.get("readerThemes", {}).get("modes", [])
    for key, tok in data.get("readerThemes", {}).get("tokens", {}).items():
        keys.append(key)
        if tok.get("figma", {}).get("name") != key:
            err(f"{key}: figma.name must equal the key")
        for mode in modes:
            val = tok.get("values", {}).get(mode)
            if not isinstance(val, str) or not HEX.match(val):
                err(f"{key}: bad hex for mode {mode}: {val!r}")
        check_flutter(key, tok)

    for group in ("typography", "radius", "spacing", "effects"):
        for key, tok in data.get(group, {}).items():
            keys.append(key)
            if tok.get("figma", {}).get("name") != key:
                err(f"{key}: figma.name must equal the key")
            check_flutter(key, tok)
    for key, tok in data.get("typography", {}).items():
        for field in ("family", "weight", "size", "lineHeightPercent"):
            if field not in tok:
                err(f"{key}: missing {field}")

    if not data.get("gaps"):
        err("gaps must not be empty")
    gap_ids = {g.get("id") for g in data.get("gaps", [])}

    # DESIGN.md must mention every token and every gap id.
    design = DESIGN_MD.read_text(encoding="utf-8")
    for key in keys:
        if f"`{key}`" not in design and key not in design:
            err(f"DESIGN.md does not mention token {key}")
    for gid in gap_ids:
        if f"**{gid}**" not in design:
            err(f"DESIGN.md gaps section missing gap id {gid}")
    for key, tok in data.get("colors", {}).items():
        if re.search(r"-\d+$", key):
            continue  # ramps are documented as a group
        for theme in themes:
            if tok["values"][theme] not in design:
                err(f"DESIGN.md table lacks {key} value {tok['values'][theme]} ({theme})")

    # Surfaces.
    known = set(keys)
    for name in REQUIRED_SURFACES:
        path = SURFACES / f"{name}.md"
        if not path.is_file():
            err(f"missing surface file: {path.relative_to(ROOT)}")
            continue
        text = path.read_text(encoding="utf-8")
        for section in ("## Route", "## Figma frames", "## Tokens used", "## Gaps"):
            if section not in text:
                err(f"{path.name}: missing section {section}")
        block = text.split("## Tokens used", 1)[-1].split("\n## ", 1)[0]
        for tok in re.findall(r"^- `([^`]+)`$", block, re.M):
            if tok not in known:
                err(f"{path.name}: unknown token `{tok}`")
    extra = {p.stem for p in SURFACES.glob("*.md")} - set(REQUIRED_SURFACES)
    if extra:
        err(f"unexpected surface files: {sorted(extra)}")


if __name__ == "__main__":
    main()
    if errors:
        print("\n".join(f"ERROR: {e}" for e in errors))
        sys.exit(1)
    print("design context OK")
