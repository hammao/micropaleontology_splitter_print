#!/usr/bin/env bash
# Orbit + walkthrough MP4s for each kit (OpenSCAD frames → ffmpeg).
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
command -v ffmpeg >/dev/null 2>&1 || { echo "Error: ffmpeg not found." >&2; exit 1; }

IMG=(--imgsize=1280,720 --autocenter --viewall --colorscheme=Tomorrow --projection=perspective)
STEP_DEG="${STEP_DEG:-15}"   # 24 frames / revolution at 15°
FPS="${FPS:-8}"
HOLD_FRAMES="${HOLD_FRAMES:-12}"  # ~1.5s holds in walkthrough

make_orbit() {
  local label="$1"
  local scad="$2"
  local out_mp4="$3"
  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/orbit_${label}.XXXXXX")"
  echo "=== orbit ${label} → ${out_mp4} ==="
  local i=0
  local deg
  for deg in $(seq 0 "$STEP_DEG" 359); do
    local frame
    frame=$(printf "%03d" "$i")
    echo "  frame ${frame} (ORBIT_DEG=${deg})"
    "$OPENSCAD" "${IMG[@]}" \
      -o "${tmp}/frame_${frame}.png" \
      -D "PART=\"assembly\"" \
      -D "ORBIT_DEG=${deg}" \
      "$scad"
    i=$((i + 1))
  done
  ffmpeg -y -loglevel error -framerate "$FPS" \
    -i "${tmp}/frame_%03d.png" \
    -c:v libx264 -pix_fmt yuv420p -crf 23 \
    "$out_mp4"
  rm -rf "$tmp"
}

# Walkthrough: title stills (exploded → assembly → side) + short orbit clip
make_walkthrough() {
  local label="$1"
  local scad="$2"
  local title="$3"
  local out_mp4="$4"
  local orbit_mp4="$5"
  local tmp
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/walk_${label}.XXXXXX")"
  echo "=== walkthrough ${label} → ${out_mp4} ==="

  local views=(exploded assembly side_view)
  local captions=("Exploded parts" "Assembled kit" "Side profile")
  local i=0
  for view in "${views[@]}"; do
    local frame
    frame=$(printf "%03d" "$i")
    echo "  still ${view}"
    "$OPENSCAD" "${IMG[@]}" \
      -o "${tmp}/still_${frame}.png" \
      -D "PART=\"${view}\"" \
      "$scad"
    # Caption overlay
    ffmpeg -y -loglevel error -loop 1 -i "${tmp}/still_${frame}.png" \
      -f lavfi -i "color=c=black:s=1280x720:d=1" \
      -filter_complex \
      "[0:v]drawtext=text='${title}':fontcolor=white:fontsize=36:x=40:y=40:box=1:boxcolor=black@0.45:boxborderw=12,drawtext=text='${captions[$i]}':fontcolor=white:fontsize=28:x=40:y=100:box=1:boxcolor=black@0.45:boxborderw=10[v]" \
      -map "[v]" -frames:v "$HOLD_FRAMES" -r "$FPS" \
      -c:v libx264 -pix_fmt yuv420p \
      "${tmp}/hold_${frame}.mp4"
    i=$((i + 1))
  done

  # Title card
  ffmpeg -y -loglevel error -f lavfi -i "color=c=0x1a1a1a:s=1280x720:d=2" \
    -vf "drawtext=text='${title}':fontcolor=white:fontsize=48:x=(w-text_w)/2:y=(h-text_h)/2-20,drawtext=text='Jones micropaleontology splitter':fontcolor=0xcccccc:fontsize=28:x=(w-text_w)/2:y=(h-text_h)/2+40" \
    -c:v libx264 -pix_fmt yuv420p "${tmp}/title.mp4"

  # Concat list: title + holds + orbit
  {
    echo "file '${tmp}/title.mp4'"
    for j in 0 1 2; do
      echo "file '${tmp}/hold_$(printf "%03d" "$j").mp4'"
    done
    echo "file '${orbit_mp4}'"
  } > "${tmp}/list.txt"

  ffmpeg -y -loglevel error -f concat -safe 0 -i "${tmp}/list.txt" \
    -c copy "$out_mp4"

  # Stills for README / thumbs
  local vdir
  vdir="$(dirname "$out_mp4")"
  cp -f "${tmp}/still_001.png" "${vdir}/${label}_assembly_still.png"
  cp -f "${tmp}/still_000.png" "${vdir}/${label}_exploded_still.png"

  rm -rf "$tmp"
}

mkdir -p "$ROOT/video"

make_orbit "2way" "$ROOT/scad/splitter_2way.scad" "$ROOT/video/2way_orbit.mp4"
make_orbit "4way" "$ROOT/scad/splitter_4way.scad" "$ROOT/video/4way_orbit.mp4"
make_orbit "cascade" "$ROOT/scad/splitter_cascade.scad" "$ROOT/video/cascade_orbit.mp4"

make_walkthrough "2way" "$ROOT/scad/splitter_2way.scad" \
  "2-way Jones splitter" \
  "$ROOT/video/2way_walkthrough.mp4" \
  "$ROOT/video/2way_orbit.mp4"

make_walkthrough "4way" "$ROOT/scad/splitter_4way.scad" \
  "4-way Jones splitter" \
  "$ROOT/video/4way_walkthrough.mp4" \
  "$ROOT/video/4way_orbit.mp4"

make_walkthrough "cascade" "$ROOT/scad/splitter_cascade.scad" \
  "Cascade 4-way splitter" \
  "$ROOT/video/cascade_walkthrough.mp4" \
  "$ROOT/video/cascade_orbit.mp4"

# Legacy aliases (2-way)
cp -f "$ROOT/video/2way_orbit.mp4" "$ROOT/video/splitter_3d_orbit.mp4"
cp -f "$ROOT/video/2way_walkthrough.mp4" "$ROOT/video/two_way_splitter_walkthrough.mp4"
cp -f "$ROOT/video/2way_assembly_still.png" "$ROOT/video/walkthrough_still.png"
cp -f "$ROOT/video/2way_exploded_still.png" "$ROOT/video/how_it_works_still.png"

echo "Done. Videos in video/."
