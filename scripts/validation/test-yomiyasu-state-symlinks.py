"""Check that the packaged yomiyasu never snapshots through state symlinks."""

import os
import subprocess
import sys
import tempfile
from pathlib import Path


def check(script: Path, name: str, link_inputs: bool) -> None:
    with tempfile.TemporaryDirectory(prefix="yomiyasu-symlink-") as temp:
        root = Path(temp)
        project = root / "project"
        project.mkdir()
        (project / ".git").mkdir()
        outside = root / "outside"
        outside.mkdir()
        state = project / ".yomiyasu"
        if link_inputs:
            state.mkdir()
            (state / "inputs").symlink_to(outside, target_is_directory=True)
        else:
            state.symlink_to(outside, target_is_directory=True)
        source = project / "source.md"
        final = project / "final.md"
        source.write_text("確認が必要です。\n")
        final.write_text("確認が必要です。\n")
        env = os.environ.copy()
        env.pop("YOMIYASU_STATE_DIR", None)
        result = subprocess.run(
            [
                sys.executable,
                str(script),
                "run",
                "--source",
                str(source),
                "--final",
                str(final),
            ],
            cwd=project,
            env=env,
            capture_output=True,
            text=True,
            timeout=120,
            check=False,
        )
        if result.returncode not in (0, 1) or list(outside.iterdir()):
            raise AssertionError(
                f"{name}: exit={result.returncode}, outside={list(outside.iterdir())}, "
                f"stderr={result.stderr[-1000:]}"
            )
        print(f"{name}: no external snapshot")


if __name__ == "__main__":
    script_path = Path(sys.argv[1]).resolve()
    check(script_path, "state symlink", False)
    check(script_path, "inputs symlink", True)
