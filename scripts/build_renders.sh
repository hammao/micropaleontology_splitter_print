#!/usr/bin/env bash
# PNG stills for each kit (parts + assembly / exploded / side).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if command -v openscad >/dev/null 2>&1; then
  OPENSCAD=openscad
elif [[ -x /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD ]]; then
  OPENSCAD=/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
else
  echo "Error: OpenSCAD CLI not found." >&2
  exit 1
fi

IMG=(--imgsize=1280,720 --autocenter --viewall --colorscheme=Tomorrow)
# Soft orthographic-ish preview lighting
CAM_EXTRA=(--projection=perspective)

render_views() {
  local label="$1"
  local scad="$2"
  local out="$3"
  shift 3
  local parts=("$@")
  mkdir -p "$out"
  echo "=== renders ${label} → ${out} ==="
  for part in "${parts[@]}"; do
    echo "  ${part}.png ..."
    "$OPENSCAD" "${IMG[@]}" "${CAM_EXTRA[@]}" \
      -o "${out}/${part}.png" \
      -D "PART=\"${part}\"" \
      "$scad"
  done
}

# Also refresh legacy flat render/ from 2-way for backward compatibility
LEGACY="$ROOT/render"
mkdir -p "$LEGACY"

render_views "2-way" "$ROOT/scad/splitter_2way.scad" "$ROOT/render/2way" \
  cup catch_tray frame riffle funnel assembly exploded side_view

render_views "4-way" "$ROOT/scad/splitter_4way.scad" "$ROOT/render/4way" \
  cup catch_tray frame riffle funnel assembly exploded side_view

render_views "cascade" "$ROOT/scad/splitter_cascade.scad" "$ROOT/render/cascade" \
  cup catch_tray frame riffle_upper riffle_lower funnel assembly exploded side_view

# Legacy filenames (2-way)
cp -f "$ROOT/render/2way/assembly.png" "$LEGACY/assembly.png"
cp -f "$ROOT/render/2way/side_view.png" "$LEGACY/assembly_side.png"
cp -f "$ROOT/render/2way/exploded.png" "$LEGACY/exploded.png"
cp -f "$ROOT/render/2way/cup.png" "$LEGACY/cup.png"
cp -f "$ROOT/render/2way/catch_tray.png" "$LEGACY/catch_tray.png"
cp -f "$ROOT/render/2way/frame.png" "$LEGACY/frame.png"
cp -f "$ROOT/render/2way/riffle.png" "$LEGACY/riffle.png"
cp -f "$ROOT/render/2way/funnel.png" "$LEGACY/funnel.png"

echo "Done. Renders in render/{2way,4way,cascade}/ (+ legacy render/*.png)."
