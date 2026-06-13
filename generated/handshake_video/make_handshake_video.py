from __future__ import annotations

import math
import shutil
import subprocess
from pathlib import Path

from PIL import Image, ImageDraw


WIDTH = 1280
HEIGHT = 720
FPS = 30
DURATION_SECONDS = 5
FRAME_COUNT = FPS * DURATION_SECONDS

ROOT = Path(__file__).resolve().parent
FRAMES = ROOT / "frames"
OUTPUT = ROOT / "handshake.mp4"


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def smoothstep(t: float) -> float:
    t = max(0.0, min(1.0, t))
    return t * t * (3 - 2 * t)


def draw_limb(draw: ImageDraw.ImageDraw, points: list[tuple[float, float]], color: str, width: int) -> None:
    draw.line(points, fill=color, width=width, joint="curve")
    radius = width // 2
    for x, y in points:
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=color)


def draw_person(
    draw: ImageDraw.ImageDraw,
    *,
    center_x: float,
    side: int,
    skin: str,
    shirt: str,
    pants: str,
    approach: float,
    shake: float,
) -> dict[str, tuple[float, float]]:
    head_x = center_x
    head_y = 210
    shoulder_y = 315
    hip_y = 480

    draw.ellipse((head_x - 46, head_y - 46, head_x + 46, head_y + 46), fill=skin)
    draw.ellipse((head_x - 19, head_y - 6, head_x - 11, head_y + 2), fill="#253044")
    draw.ellipse((head_x + 11, head_y - 6, head_x + 19, head_y + 2), fill="#253044")
    draw.arc((head_x - 18, head_y - 5, head_x + 18, head_y + 28), 20, 160, fill="#8a4c3d", width=4)

    torso = [
        (head_x - 62, shoulder_y),
        (head_x + 62, shoulder_y),
        (head_x + 78, hip_y),
        (head_x - 78, hip_y),
    ]
    draw.polygon(torso, fill=shirt)
    draw.line((head_x - 62, shoulder_y, head_x + 62, shoulder_y), fill="#ffffff", width=5)

    draw_limb(
        draw,
        [(head_x - 34, hip_y), (head_x - 47, 610), (head_x - 105, 610)],
        pants,
        32,
    )
    draw_limb(
        draw,
        [(head_x + 34, hip_y), (head_x + 47, 610), (head_x + 105, 610)],
        pants,
        32,
    )

    near_shoulder = (head_x + side * 56, shoulder_y + 22)
    handshake_x = lerp(head_x + side * 120, WIDTH / 2, approach)
    handshake_y = 370 + shake
    elbow = (
        lerp(near_shoulder[0], handshake_x, 0.48),
        lerp(near_shoulder[1], handshake_y, 0.48) - 26,
    )
    draw_limb(draw, [near_shoulder, elbow, (handshake_x, handshake_y)], skin, 28)

    far_shoulder = (head_x - side * 58, shoulder_y + 24)
    relaxed_hand = (head_x - side * 86, 453)
    far_elbow = (head_x - side * 115, 385)
    draw_limb(draw, [far_shoulder, far_elbow, relaxed_hand], skin, 24)

    return {"hand": (handshake_x, handshake_y)}


def draw_frame(index: int) -> Image.Image:
    t = index / max(1, FRAME_COUNT - 1)
    approach = smoothstep(min(t / 0.35, 1.0))
    exit_t = smoothstep(max((t - 0.82) / 0.18, 0.0))
    presence = 1.0 - exit_t
    shake = math.sin(t * math.tau * 5) * 12 * approach * presence

    img = Image.new("RGB", (WIDTH, HEIGHT), "#eef3f8")
    draw = ImageDraw.Draw(img)

    for y in range(HEIGHT):
        mix = y / HEIGHT
        r = int(238 * (1 - mix) + 221 * mix)
        g = int(243 * (1 - mix) + 232 * mix)
        b = int(248 * (1 - mix) + 225 * mix)
        draw.line((0, y, WIDTH, y), fill=(r, g, b))

    draw.rectangle((0, 620, WIDTH, HEIGHT), fill="#d8e2df")
    draw.ellipse((265, 594, 575, 654), fill="#c9d4d1")
    draw.ellipse((705, 594, 1015, 654), fill="#c9d4d1")

    left_x = lerp(365, 438, approach) - 70 * exit_t
    right_x = lerp(915, 842, approach) + 70 * exit_t

    left = draw_person(
        draw,
        center_x=left_x,
        side=1,
        skin="#c9835c",
        shirt="#2d6cdf",
        pants="#26354f",
        approach=approach,
        shake=shake,
    )
    right = draw_person(
        draw,
        center_x=right_x,
        side=-1,
        skin="#f0b17d",
        shirt="#23856d",
        pants="#2f4058",
        approach=approach,
        shake=-shake,
    )

    if approach > 0.72 and presence > 0.05:
        hx = (left["hand"][0] + right["hand"][0]) / 2
        hy = (left["hand"][1] + right["hand"][1]) / 2
        angle = math.sin(t * math.tau * 5) * 0.08
        draw.rounded_rectangle(
            (hx - 58, hy - 23 + angle * 40, hx + 58, hy + 23 + angle * 40),
            radius=18,
            fill="#d6966d",
            outline="#996148",
            width=3,
        )
        draw.line((hx - 9, hy - 20, hx + 11, hy + 20), fill="#996148", width=3)

    if 0.23 < t < 0.78:
        pulse = math.sin((t - 0.23) / 0.55 * math.pi)
        ring = 22 + 42 * pulse
        alpha_color = "#7ba98b"
        cx, cy = WIDTH / 2, 370
        draw.arc((cx - ring, cy - ring, cx + ring, cy + ring), 210, 330, fill=alpha_color, width=5)
        draw.arc((cx - ring, cy - ring, cx + ring, cy + ring), 30, 150, fill=alpha_color, width=5)

    return img


def main() -> None:
    if FRAMES.exists():
        shutil.rmtree(FRAMES)
    FRAMES.mkdir(parents=True)

    for index in range(FRAME_COUNT):
        draw_frame(index).save(FRAMES / f"frame_{index:04d}.png")

    subprocess.run(
        [
            "ffmpeg",
            "-y",
            "-framerate",
            str(FPS),
            "-i",
            str(FRAMES / "frame_%04d.png"),
            "-c:v",
            "libx264",
            "-pix_fmt",
            "yuv420p",
            "-movflags",
            "+faststart",
            str(OUTPUT),
        ],
        check=True,
    )


if __name__ == "__main__":
    main()
