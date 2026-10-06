"""Create a fixed-style YouTube thumbnail from a selected video frame.

Usage:
    uv run scripts/bin/ytthumb.py --path movie.mp4 --time 1:00 --text '["有線イヤホン","への回帰"]'

The --path option selects a video; --time accepts MM:SS or HH:MM:SS; and --text
accepts a JSON array of one to three lines. uv supplies Pillow through the
inline dependency metadata below. The script uses nix run for ffmpeg and
nix build --no-link for UDEV Gothic Bold, so neither needs profile installation.

The result is a 1280x720 PNG beside the video, with the video's base name. An
existing PNG is replaced atomically. The full video frame is preserved; frames
that are not 16:9 receive black padding. Text is centered in white with a black
outline. The largest font size up to 300 px that fits within 80 px margins is
used, stepping down in 2 px increments. Text that cannot fit at 90 px is
rejected without changing an existing PNG.
"""

# /// script
# requires-python = ">=3.11"
# dependencies = ["Pillow>=11,<13"]
# ///

import argparse
import io
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

try:
    from PIL import Image, ImageDraw, ImageFont, ImageOps
except ImportError as exc:
    raise SystemExit("Pillow is required; run this script with uv run.") from exc


SIZE = (1280, 720)
MAX_FONT_SIZE = 300
MIN_FONT_SIZE = 90
STROKE = 7
MARGIN = 80
LINE_GAP = 18
VIDEO_SUFFIXES = {".mp4", ".mov", ".m4v", ".mkv", ".webm"}


def parse_time(value: str) -> int:
    """Return a strict MM:SS or HH:MM:SS timestamp in seconds."""
    if not re.fullmatch(r"\d+:[0-5]\d(?::[0-5]\d)?", value):
        raise ValueError("--time must be MM:SS or HH:MM:SS (for example 1:00)")
    parts = [int(part) for part in value.split(":")]
    if len(parts) == 2:
        return parts[0] * 60 + parts[1]
    return parts[0] * 3600 + parts[1] * 60 + parts[2]


def parse_text(value: str) -> list[str]:
    """Read one to three nonempty lines from a JSON string array."""
    try:
        lines = json.loads(value)
    except json.JSONDecodeError as exc:
        raise ValueError(
            '--text must be a JSON array, e.g. \'["腕時計","やめた"]\''
        ) from exc
    if not isinstance(lines, list) or not 1 <= len(lines) <= 3:
        raise ValueError("--text must contain 1 to 3 lines")
    if any(
        not isinstance(line, str) or not line.strip() or "\n" in line for line in lines
    ):
        raise ValueError("each --text item must be a nonempty, single-line string")
    return lines


def find_font() -> Path:
    """Resolve the fixed font from Nix without adding it to a user profile."""
    result = run_tool(
        ["nix", "build", "nixpkgs#udev-gothic", "--no-link", "--print-out-paths"]
    )
    store_path = result.stdout.decode("utf-8", errors="replace").strip()
    font_path = Path(store_path) / "share/fonts/truetype/UDEVGothic-Bold.ttf"
    if not font_path.is_file():
        raise ValueError("UDEV Gothic Bold font was not found in the Nix output")
    return font_path


def run_tool(
    command: list[str], *, check: bool = True
) -> subprocess.CompletedProcess[bytes]:
    """Run a Nix command and report its stderr on failure."""
    try:
        result = subprocess.run(command, capture_output=True, check=False)
    except FileNotFoundError as exc:
        raise ValueError(f"missing dependency: {command[0]}") from exc
    if check and result.returncode:
        detail = result.stderr.decode("utf-8", errors="replace").strip()
        raise ValueError(f"{command[0]} failed: {detail}")
    return result


def render(video: Path, seconds: int, lines: list[str]) -> Image.Image:
    """Extract the requested frame and draw the fixed text treatment."""
    probe = run_tool(
        [
            "nix",
            "run",
            "nixpkgs#ffmpeg",
            "--",
            "-hide_banner",
            "-i",
            str(video),
        ],
        check=False,
    )
    metadata = probe.stderr.decode("utf-8", errors="replace")
    match = re.search(r"Duration: (\d+):([0-5]\d):([0-5]\d)(?:\.(\d+))?", metadata)
    if match is None:
        raise ValueError(f"could not read video duration: {metadata.strip()}")
    hours, minutes, whole_seconds, fraction = match.groups()
    duration = int(hours) * 3600 + int(minutes) * 60 + int(whole_seconds)
    if fraction:
        duration += int(fraction) / 10 ** len(fraction)
    if seconds >= duration:
        raise ValueError(f"--time is beyond the video duration ({duration:.1f}s)")

    frame = run_tool(
        [
            "nix",
            "run",
            "nixpkgs#ffmpeg",
            "--",
            "-hide_banner",
            "-loglevel",
            "error",
            "-i",
            str(video),
            "-ss",
            str(seconds),
            "-frames:v",
            "1",
            "-f",
            "image2pipe",
            "-vcodec",
            "png",
            "-",
        ]
    )
    if not frame.stdout:
        raise ValueError("ffmpeg did not return a frame at the requested time")
    with Image.open(io.BytesIO(frame.stdout)) as source:
        image = ImageOps.pad(
            source.convert("RGB"), SIZE, method=Image.Resampling.LANCZOS, color="black"
        )

    font_path = find_font()
    draw = ImageDraw.Draw(image)
    for font_size in range(MAX_FONT_SIZE, MIN_FONT_SIZE - 1, -2):
        font = ImageFont.truetype(str(font_path), font_size)
        boxes = [
            draw.textbbox((0, 0), line, font=font, stroke_width=STROKE)
            for line in lines
        ]
        widths = [box[2] - box[0] for box in boxes]
        heights = [box[3] - box[1] for box in boxes]
        total_height = sum(heights) + LINE_GAP * (len(lines) - 1)
        if max(widths) <= SIZE[0] - 2 * MARGIN and total_height <= SIZE[1] - 2 * MARGIN:
            break
    else:
        raise ValueError("text is too long to fit at the minimum readable size")
    y = (SIZE[1] - total_height) // 2
    for line, box, width, height in zip(lines, boxes, widths, heights, strict=True):
        x = (SIZE[0] - width) // 2 - box[0]
        draw.text(
            (x, y - box[1]),
            line,
            font=font,
            fill="white",
            stroke_width=STROKE,
            stroke_fill="black",
        )
        y += height + LINE_GAP
    return image


def main() -> int:
    """Parse CLI options and write a same-name PNG beside the source video."""
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("--path", required=True, type=Path, help="source video")
    parser.add_argument("--time", required=True, help="MM:SS or HH:MM:SS")
    parser.add_argument("--text", required=True, help="JSON array of 1 to 3 lines")
    args = parser.parse_args()
    try:
        video = args.path.expanduser().resolve(strict=True)
        if not video.is_file() or video.suffix.lower() not in VIDEO_SUFFIXES:
            raise ValueError(
                "--path must name a supported video file (.mp4, .mov, .m4v, .mkv, .webm)"
            )
        seconds = parse_time(args.time)
        lines = parse_text(args.text)
        output = video.with_suffix(".png")
        if shutil.which("nix") is None:
            raise ValueError("missing dependency: nix")
        image = render(video, seconds, lines)
        with tempfile.NamedTemporaryFile(
            dir=video.parent, prefix=".thumbnail-", suffix=".png", delete=False
        ) as temp:
            temp_path = Path(temp.name)
        try:
            image.save(temp_path, format="PNG")
            os.replace(temp_path, output)
        finally:
            temp_path.unlink(missing_ok=True)
        print(output)
        return 0
    except (OSError, ValueError) as exc:
        parser.exit(1, f"ytthumb: {exc}\n")


if __name__ == "__main__":
    sys.exit(main())
