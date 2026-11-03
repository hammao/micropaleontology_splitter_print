#!/usr/bin/env python3
"""Build a clear 'how it works' MP4 for the 4-compartment Jones splitter."""
from __future__ import annotations

import math
import subprocess
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "video" / "4way_how_it_works.mp4"
ASSEMBLY = ROOT / "render" / "4way" / "assembly.png"
EXPLODED = ROOT / "render" / "4way" / "exploded.png"
W, H = 1280, 720
FPS = 8


def font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for path in (
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial.ttf",
    ):
        p = Path(path)
        if p.exists():
            return ImageFont.truetype(str(p), size)
    return ImageFont.load_default()


def blank(color=(18, 20, 24)) -> Image.Image:
    return Image.new("RGB", (W, H), color)


def fit(img: Image.Image, box: tuple[int, int, int, int]) -> Image.Image:
    x0, y0, x1, y1 = box
    bw, bh = x1 - x0, y1 - y0
    src = img.convert("RGBA")
    src.thumbnail((bw, bh), Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
    ox = (bw - src.width) // 2
    oy = (bh - src.height) // 2
    canvas.paste(src, (ox, oy), src)
    return canvas


def card(title: str, subtitle: str = "") -> Image.Image:
    im = blank()
    d = ImageDraw.Draw(im)
    d.text((W // 2, H // 2 - 40), title, fill=(245, 245, 245), font=font(48), anchor="mm")
    if subtitle:
        d.text((W // 2, H // 2 + 30), subtitle, fill=(180, 190, 200), font=font(28), anchor="mm")
    return im


def overlay_caption(base: Image.Image, title: str, lines: list[str]) -> Image.Image:
    im = blank()
    # place render on right
    panel = fit(base, (420, 40, W - 40, H - 40))
    im.paste(panel, (420, 40), panel)
    d = ImageDraw.Draw(im)
    d.rectangle((0, 0, 400, H), fill=(28, 32, 38))
    d.text((28, 48), title, fill=(250, 250, 250), font=font(32))
    y = 120
    for line in lines:
        d.text((28, y), line, fill=(200, 210, 220), font=font(22))
        y += 36
    return im


def schematic(t: float) -> Image.Image:
    """Animated 4-compartment flow diagram. t in [0, 1]."""
    im = blank((22, 26, 32))
    d = ImageDraw.Draw(im)
    d.text((W // 2, 36), "4-way Jones riffle — how sediment splits", fill=(245, 245, 245), font=font(34), anchor="mt")
    d.text(
        (W // 2, 80),
        "One pour → 16 alternating chutes → four equal streams (A1 / B1 / A2 / B2)",
        fill=(160, 170, 180),
        font=font(20),
        anchor="mt",
    )

    # Funnel
    funnel = [(640, 130), (780, 210), (500, 210)]
    d.polygon(funnel, fill=(70, 110, 170), outline=(200, 220, 255))
    d.text((640, 155), "FUNNEL", fill=(255, 255, 255), font=font(18), anchor="mm")

    # Riffle bank
    d.rounded_rectangle((460, 220, 820, 320), radius=8, fill=(90, 95, 105), outline=(200, 200, 210))
    d.text((640, 245), "RIFFLE BANK (16 chutes)", fill=(240, 240, 240), font=font(18), anchor="mm")

    # chute ticks cycling colors
    colors = [
        (240, 180, 40),   # A1 FL
        (60, 140, 230),   # B1 FR
        (230, 110, 50),   # A2 RL
        (70, 180, 90),    # B2 RR
    ]
    labels = ["A1 FL", "B1 FR", "A2 RL", "B2 RR"]
    for i in range(16):
        x0 = 475 + i * 21
        c = colors[i % 4]
        d.rectangle((x0, 270, x0 + 14, 310), fill=c)

    # pans
    pans = [
        ((220, 430, 480, 620), colors[0], labels[0], (-1, -1)),
        ((800, 430, 1060, 620), colors[1], labels[1], (1, -1)),
        ((220, 430, 480, 620), colors[2], labels[2], (-1, 1)),  # overwritten below
        ((800, 430, 1060, 620), colors[3], labels[3], (1, 1)),
    ]
    # 2x2 layout
    pans = [
        ((180, 400, 460, 560), colors[0], "A1  FRONT-LEFT", (-1, -1)),
        ((820, 400, 1100, 560), colors[1], "B1  FRONT-RIGHT", (1, -1)),
        ((180, 580, 460, 700), colors[2], "A2  REAR-LEFT", (-1, 1)),
        ((820, 580, 1100, 700), colors[3], "B2  REAR-RIGHT", (1, 1)),
    ]

    # flowing particles
    n_particles = 24
    for p in range(n_particles):
        phase = (t + p / n_particles) % 1.0
        lane = p % 4
        # path: funnel → chute → pan
        if phase < 0.25:
            u = phase / 0.25
            x = 640 + (lane - 1.5) * 12
            y = 150 + u * 80
        elif phase < 0.55:
            u = (phase - 0.25) / 0.30
            x = 475 + (lane * 4 + 1.5) * 21 + 7
            y = 280 + u * 40
        else:
            u = (phase - 0.55) / 0.45
            box = pans[lane][0]
            tx = (box[0] + box[2]) / 2
            ty = (box[1] + box[3]) / 2 - 10
            x = 640 + (tx - 640) * u
            y = 320 + (ty - 320) * u
        r = 5
        d.ellipse((x - r, y - r, x + r, y + r), fill=colors[lane])

    for box, col, lab, _ in pans:
        d.rounded_rectangle(box, radius=10, fill=(40, 44, 52), outline=col, width=4)
        # fill level animates
        fill_h = int((box[3] - box[1] - 24) * min(1.0, t * 1.2))
        if fill_h > 0:
            d.rectangle(
                (box[0] + 8, box[3] - 8 - fill_h, box[2] - 8, box[3] - 8),
                fill=col + (0,),
            )
            # solid fill without alpha issues
            d.rectangle(
                (box[0] + 8, box[3] - 8 - fill_h, box[2] - 8, box[3] - 8),
                fill=tuple(max(0, c - 40) for c in col),
            )
        d.text(((box[0] + box[2]) // 2, box[1] + 18), lab, fill=col, font=font(18), anchor="mt")

    # center legend
    d.text((640, 360), "i % 4  →  four corners", fill=(210, 215, 220), font=font(22), anchor="mm")
    d.text((640, 390), "true simultaneous 1 : 1 : 1 : 1 quartering", fill=(150, 160, 170), font=font(18), anchor="mm")
    return im


def hold(img: Image.Image, frames: int, paths: list[Path], start: int) -> int:
    for i in range(frames):
        p = paths[0].parent / f"frame_{start + i:04d}.png"
        img.save(p)
    return start + frames


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="how4way_") as td:
        tdir = Path(td)
        idx = 0
        paths: list[Path] = []

        def add(img: Image.Image, n: int = 1) -> None:
            nonlocal idx
            for _ in range(n):
                p = tdir / f"frame_{idx:04d}.png"
                img.save(p)
                paths.append(p)
                idx += 1

        add(card("4-way Jones splitter", "How the four-compartment riffle works"), 16)
        add(
            card("Goal", "One pour of dry sediment → four equal quarters"),
            12,
        )

        # schematic animation ~3s
        for f in range(32):
            add(schematic(f / 31.0), 1)

        if ASSEMBLY.exists():
            add(
                overlay_caption(
                    Image.open(ASSEMBLY),
                    "Assembled kit",
                    [
                        "• Funnel on top",
                        "• 16-chute 4-way riffle",
                        "• Four ACTIVE pans",
                        "  A1  B1",
                        "  A2  B2",
                        "",
                        "No spare bay —",
                        "all four collect.",
                    ],
                ),
                20,
            )
        if EXPLODED.exists():
            add(
                overlay_caption(
                    Image.open(EXPLODED),
                    "Print & assemble",
                    [
                        "Print from stl/4way/:",
                        "  cup ×4",
                        "  catch_tray",
                        "  frame",
                        "  riffle",
                        "  funnel",
                        "",
                        "Seat pans in labeled wells,",
                        "then riffle + funnel.",
                    ],
                ),
                20,
            )

        add(
            card("Result", "Four labeled compartments — true 1:1:1:1 split"),
            14,
        )

        # stitch
        subprocess.run(
            [
                "ffmpeg",
                "-y",
                "-loglevel",
                "error",
                "-framerate",
                str(FPS),
                "-i",
                str(tdir / "frame_%04d.png"),
                "-c:v",
                "libx264",
                "-pix_fmt",
                "yuv420p",
                "-crf",
                "20",
                str(OUT),
            ],
            check=True,
        )
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
