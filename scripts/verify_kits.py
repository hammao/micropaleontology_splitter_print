#!/usr/bin/env python3
"""Check every kit: part bounding boxes, assembled height, footprint,
part-to-part interference and mating gaps. Reads stl/<kit>/*.stl.
Placement numbers mirror scad/splitter_lib.scad and splitter_quarter_lib.scad.
Needs: pip install trimesh manifold3d"""
from __future__ import annotations
import itertools, sys
from pathlib import Path
import numpy as np
import trimesh
from trimesh.transformations import translation_matrix as T, rotation_matrix as R

ROOT = Path(__file__).resolve().parents[1]
TRAY_FLOOR, SLOT_D = 2.0, 0.8
Z0 = 2.0 + 24 + 0.5 + 1.6          # riffle base = frame top
CUP_Y, CX = 21.0, 25.0
H2, HOP, H1 = 12, 14, 23.5
RZ = R(np.pi, [0, 0, 1])

def kit_layout(kit):
    if kit == "2way":
        return [("catch_tray", np.eye(4)), ("frame", T([0, 0, TRAY_FLOOR - SLOT_D])),
                ("cup", T([0, -CUP_Y, TRAY_FLOOR])), ("cup", T([0, CUP_Y, TRAY_FLOOR]) @ RZ),
                ("cup", T([51.5, -CUP_Y, TRAY_FLOOR - SLOT_D])), ("cup", T([51.5, CUP_Y, TRAY_FLOOR - SLOT_D]) @ RZ),
                ("riffle", T([0, 0, Z0])), ("funnel", T([0, 0, Z0 + 24]))]
    base = [("catch_tray", np.eye(4)), ("frame", T([0, 0, TRAY_FLOOR - SLOT_D]))]
    for sx in (-1, 1):
        base += [("cup", T([sx * CX, -CUP_Y, TRAY_FLOOR])), ("cup", T([sx * CX, CUP_Y, TRAY_FLOOR]) @ RZ)]
    ztop = Z0 + H2 + HOP + H1
    if kit == "4way":
        return base + [("riffle", T([0, 0, Z0])), ("funnel", T([0, 0, ztop]))]
    return base + [("riffle_lower", T([CX, 0, Z0])), ("riffle_lower", RZ @ T([CX, 0, Z0])),
                   ("riffle_upper", T([0, 0, Z0 + H2 + HOP])), ("funnel", T([0, 0, ztop]))]

def min_gap(a, b, n=3000):
    """Approximate minimum surface distance between two meshes (sampled)."""
    pts = np.vstack([a.sample(n), a.vertices])
    return float(np.abs(trimesh.proximity.signed_distance(b, pts)).min())

def flow_checks() -> bool:
    """Each chute outlet footprint must fall inside the cup interior below it."""
    cw, vt, ct = 3.6, 1.6, 1.6
    span = lambda n: n * cw + (n - 1) * vt
    def inside(o, c):
        return o[0] >= c[0] and o[1] <= c[1] and o[2] >= c[2] and o[3] <= c[3]
    ok = True
    # 2-way: 8 chutes, a = 8, dy = 14, cups centred at x = 0, y = +-21
    out = (-span(8) / 2, span(8) / 2, -8 - 14, 8 - 14)
    cup = (-22.5 + ct, 22.5 - ct, -CUP_Y - 19.5 + ct, -CUP_Y + 19.5 - ct)
    print(f"  2-way outlet {out} inside cup {cup}: {inside(out, cup)}"); ok &= inside(out, cup)
    # quartering stage 2: 8 chutes centred x = 25, a = 6, dy = 10
    out = (CX - span(8) / 2, CX + span(8) / 2, -6 - 10, 6 - 10)
    cup = (CX - 22.5 + ct, CX + 22.5 - ct, -CUP_Y - 19.5 + ct, -CUP_Y + 19.5 - ct)
    print(f"  stage-2 outlet {out} inside cup {cup}: {inside(out, cup)}"); ok &= inside(out, cup)
    # quartering stage 1 outlet (x 13..29, y +-20) == hopper aperture; hopper bottom == stage-2 inlet
    print("  stage-1 outlet x 13..29, y +-20 = hopper aperture (same parameters ap_x0/ap_x1, span(n1))")
    return ok

def main() -> int:
    print("=== flow paths ===")
    ok = flow_checks()
    for kit in ("2way", "4way", "cascade"):
        print(f"\n=== {kit} ===")
        cache = {}
        for f in sorted((ROOT / "stl" / kit).glob("*.stl")):
            m = trimesh.load(f)
            cache[f.stem] = m
            e = m.extents
            print(f"  {f.stem:13s} {e[0]:6.1f} x {e[1]:6.1f} x {e[2]:5.1f} mm  watertight={m.is_watertight}  vol={m.volume/1000:5.1f} cm3")
            ok &= bool(m.is_watertight)
        placed = [(n, cache[n].copy().apply_transform(M)) for n, M in kit_layout(kit)]
        allv = np.vstack([m.vertices for _, m in placed])
        lo, hi = allv.min(0), allv.max(0)
        print(f"  ASSEMBLED: height {hi[2]-lo[2]:.1f} mm, footprint {hi[0]-lo[0]:.1f} x {hi[1]-lo[1]:.1f} mm")
        ok &= bool((hi[2] - lo[2]) <= 100)
        for (na, a), (nb, b) in itertools.combinations(placed, 2):
            ba, bb = a.bounds, b.bounds
            if np.any(ba[1] < bb[0] - 1) or np.any(bb[1] < ba[0] - 1):
                continue
            inter = a.intersection(b, engine="manifold")
            v = 0.0 if inter.is_empty else inter.volume
            gap = min_gap(a, b)
            bad = v > 1e-3
            ok &= not bad
            print(f"  {na:13s} <-> {nb:13s} overlap {v:8.3f} mm3   min gap {gap:5.2f} mm {'OVERLAP' if bad else ''}")
    print("\nALL CHECKS PASS" if ok else "\nCHECK FAILURES")
    return 0 if ok else 1

if __name__ == "__main__":
    sys.exit(main())
