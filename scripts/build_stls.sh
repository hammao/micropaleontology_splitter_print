#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Prefer Homebrew OpenSCAD binary when `openscad` is not on PATH
if command -v openscad >/dev/null 2>&1; then
  OPENSCAD=openscad
elif [[ -x /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD ]]; then
  OPENSCAD=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
elif [[ -x /opt/homebrew/bin/openscad ]]; then
  OPENSCAD=/opt/homebrew/bin/openscad
else
  echo "Error: OpenSCAD CLI not found. Install OpenSCAD or add it to PATH." >&2
  exit 1
fi

render_kit() {
  local label="$1"
  local scad="$2"
  local out="$3"
  shift 3
  local parts=("$@")
  mkdir -p "$out"
  echo "=== ${label} → ${out} ==="
  for part in "${parts[@]}"; do
    echo "  Rendering ${part} ..."
    "$OPENSCAD" -o "${out}/${part}.stl" -D "PART=\"${part}\"" "$scad"
  done
}

render_kit "2-way" "$ROOT/scad/splitter_2way.scad" "$ROOT/stl/2way" \
  cup catch_tray frame riffle funnel

render_kit "4-way" "$ROOT/scad/splitter_4way.scad" "$ROOT/stl/4way" \
  cup catch_tray frame riffle funnel

render_kit "cascade" "$ROOT/scad/splitter_cascade.scad" "$ROOT/stl/cascade" \
  cup catch_tray frame riffle_upper riffle_lower funnel

echo
echo "Done."
echo "  2-way:    print stl/2way/cup.stl ×4 + one each of catch_tray, frame, riffle, funnel"
echo "  4-way:    print stl/4way/cup.stl ×4 (all active) + one each of catch_tray, frame, riffle, funnel"
echo "  cascade:  print stl/cascade/cup.stl ×4, riffle_lower.stl ×2,"
echo "            + one each of catch_tray, frame, riffle_upper, funnel"
