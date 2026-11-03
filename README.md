# Micropaleontology dry-sediment splitter (Jones-type)

Classic **Jones micro-riffle** kits for dried sediment — rebuilt as **separate hollow printable parts**.

This repo ships **three complete kits**, each with its own print-ready STLs:

| Kit | Split | STLs | OpenSCAD |
|-----|-------|------|----------|
| **2-way** | 1:1 left / right | [`stl/2way/`](stl/2way/) | [`scad/splitter_2way.scad`](scad/splitter_2way.scad) |
| **4-way** | 1:1:1:1 single-stage quartering | [`stl/4way/`](stl/4way/) | [`scad/splitter_4way.scad`](scad/splitter_4way.scad) |
| **Cascade** | 1:1:1:1 via two sequential 2-way stages | [`stl/cascade/`](stl/cascade/) | [`scad/splitter_cascade.scad`](scad/splitter_cascade.scad) |

Submit the files from **one** folder to your printer — no re-render needed.

---

## 2-way (left / right)

```
        ┌─────────────────────┐
        │   LARGE FUNNEL      │  ← anti-spill hopper
        └─────────┬───────────┘
                  │
           ╱│╱│╱│╱│╱│╱│╲│╲     ← alternating vanes (1:1 split)
        ───╱  L   │   R  ╲───  ← A-frame side discharges
              ↓       ↓
            [A1]    [B1]       ← active pans
            [A2]    [B2]       ← spare pans (storage bay)
        └─────────────────────┘  ← spill tray + stand
```

Only **A1** (left) and **B1** (right) sit under the discharges. **A2/B2** are spares parked behind a divider — not fed by chutes.

### Print list (2-way)

| Part | Qty | STL |
|------|-----|-----|
| Hi-back pan / cup | **4** | `stl/2way/cup.stl` |
| Spill catch tray | 1 | `stl/2way/catch_tray.stl` |
| Open stand / frame | 1 | `stl/2way/frame.stl` |
| Riffle bank (12 chutes) | 1 | `stl/2way/riffle.stl` |
| Funnel | 1 | `stl/2way/funnel.stl` |

### Assemble (2-way)

1. Place the catch tray on the bench; drop the frame into it.
2. Seat pans: **A1/B1** under the discharges, **A2/B2** at the back as spares.
3. Set the riffle onto the frame rails (A-frame hoods point into A1 and B1).
4. Seat the funnel sleeve into the riffle socket.
5. Pour dried sediment into the funnel; collect halves in A1 and B1. Swap spare pans to re-split.

Footprint ~260×210 mm, height ~250 mm. Chute width 7 mm (`chute_w` / `n_chutes`).

---

## 4-way (true quartering, single-stage)

```
        ┌─────────────────────┐
        │   LARGE FUNNEL      │
        └─────────┬───────────┘
                  │
           ╱│╱│╱│╱│╱│╱│╱│╱│     ← 16 vanes, i%4 → four corners
      FL ↙    FR ↘   RL ↙  RR ↘
       [A1]  [B1]
       [A2]  [B2]              ← all four pans ACTIVE
        └─────────────────────┘
```

One pour splits into **four equal streams**. All four pans sit under corner discharges (no spare bay).

### Print list (4-way)

| Part | Qty | STL |
|------|-----|-----|
| Hi-back pan / cup | **4** | `stl/4way/cup.stl` |
| Spill catch tray | 1 | `stl/4way/catch_tray.stl` |
| Open stand / frame | 1 | `stl/4way/frame.stl` |
| Riffle bank (16 chutes) | 1 | `stl/4way/riffle.stl` |
| Funnel | 1 | `stl/4way/funnel.stl` |

### Assemble (4-way)

1. Place the catch tray on the bench; drop the frame into it.
2. Seat pans in the four labeled wells: **A1 FL**, **B1 FR**, **A2 RL**, **B2 RR**.
3. Set the riffle onto the frame rails (corner hoods over the four pans).
4. Seat the funnel sleeve into the riffle socket.
5. Pour dried sediment; collect quarters in A1–B2. Empty / swap pans to re-split as needed.

Footprint ~300×300 mm. Same 7 mm chute width; **16** chutes (4 per quarter).

### How it works (4-way video)

- [`video/4way_how_it_works.mp4`](video/4way_how_it_works.mp4) — animated four-compartment flow + assembly / explode + 3D orbit
- [`video/4way_orbit.mp4`](video/4way_orbit.mp4) — rotating 3D assembly only
- Stills: [`render/4way/assembly.png`](render/4way/assembly.png), [`render/4way/exploded.png`](render/4way/exploded.png)

Rebuild the how-it-works clip:

```bash
python3 scripts/make_4way_how_it_works.py
```

---

## Cascade (two-stage quartering)

Lab-style accuracy: **halve, then halve again**.

```
                 [FUNNEL]
                    │
             [STAGE-1 L/R]
               ╱         ╲
        [STAGE-2 F/B] [STAGE-2 F/B]   ← print riffle_lower ×2
           ╱   ╲         ╱   ╲
         A1    A2      B1    B2
```

### Print list (cascade)

| Part | Qty | STL |
|------|-----|-----|
| Hi-back pan / cup | **4** | `stl/cascade/cup.stl` |
| Spill catch tray | 1 | `stl/cascade/catch_tray.stl` |
| Tall stand / frame | 1 | `stl/cascade/frame.stl` |
| Upper riffle (L/R) | 1 | `stl/cascade/riffle_upper.stl` |
| Lower riffle (F/B) | **2** | `stl/cascade/riffle_lower.stl` |
| Funnel | 1 | `stl/cascade/funnel.stl` |

### Assemble (cascade)

1. Catch tray + frame; seat four pans in A1/B1/A2/B2 wells.
2. Place **two** lower riffles on the left/right cradles (F/B hoods over the pans).
3. Place the upper riffle on the top cradle so L/R hoods dump into the lower open tops.
4. Seat the funnel in the upper riffle; pour. Quarters collect in all four pans.

---

## Print settings (all kits)

- PLA or PETG · 0.20 mm layers · ≥3 perimeters · 20–30% infill
- Orient each part on its flat base; no supports required
- Clearance between mates: 0.6 mm — sand lightly if your printer runs large

```bash
./scripts/build_stls.sh      # all three STL kits
./scripts/build_renders.sh   # PNG previews
./scripts/build_videos.sh    # orbit + walkthrough MP4s
```

Do **not** mix folders except the cup (throats differ by kit). Split accuracy is unverified until tested with your sediment.

## Walkthrough (2-way, legacy names)

- `video/two_way_splitter_walkthrough.mp4` — how-it-works + orbit
- `video/splitter_3d_orbit.mp4` — rotating assembly only
