#!/usr/bin/env bash
# PNG stills for each kit: parts, assembly, exploded, front side view (ortho,
# with a 100 mm post) and a same-scale old vs new 2-way comparison.
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

IMG=(--imgsize=1280,720 --autocenter --viewall --colorscheme=Tomorrow --projection=perspective)
# front elevation, orthographic, looking along +y
SIDE=(--imgsize=1280,720 --colorscheme=Tomorrow --projection=ortho --viewall --autocenter --camera=0,0,0,90,0,0,500)

render_views() {
  local label="$1" scad="$2" out="$3"
  shift 3
  mkdir -p "$out"
  echo "=== renders ${label} -> ${out} ==="
  for part in "$@"; do
    echo "  ${part}.png ..."
    "$OPENSCAD" "${IMG[@]}" -o "${out}/${part}.png" -D "PART=\"${part}\"" "$scad"
  done
  echo "  side_view.png (ortho) ..."
  "$OPENSCAD" "${SIDE[@]}" -o "${out}/side_view.png" -D 'PART="side_view"' "$scad"
}

render_views "2-way" "$ROOT/scad/splitter_2way.scad" "$ROOT/render/2way" \
  cup catch_tray frame riffle funnel assembly exploded

render_views "4-way" "$ROOT/scad/splitter_4way.scad" "$ROOT/render/4way" \
  cup catch_tray frame riffle funnel assembly exploded

render_views "cascade" "$ROOT/scad/splitter_cascade.scad" "$ROOT/render/cascade" \
  cup catch_tray frame riffle_upper riffle_lower funnel assembly exploded

echo "=== old vs new 2-way comparison ==="
"$OPENSCAD" "${SIDE[@]}" -o "$ROOT/render/compare_2way_old_vs_new.png" "$ROOT/scad/compare_2way_old_vs_new.scad"

# Legacy flat render/ names point at the 2-way kit
LEGACY="$ROOT/render"
cp -f "$ROOT/render/2way/assembly.png"   "$LEGACY/assembly.png"
cp -f "$ROOT/render/2way/side_view.png"  "$LEGACY/assembly_side.png"
cp -f "$ROOT/render/2way/exploded.png"   "$LEGACY/exploded.png"
for p in cup catch_tray frame riffle funnel; do cp -f "$ROOT/render/2way/${p}.png" "$LEGACY/${p}.png"; done

echo "Done. Renders in render/{2way,4way,cascade}/ and render/compare_2way_old_vs_new.png"
