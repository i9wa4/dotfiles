#!/usr/bin/env python3
"""Compose the pinned upstream refresh and cached renderer for a tmux status job."""

import contextlib
import datetime
import json
import os
import stat
import subprocess
import sys
from pathlib import Path

POSTMAN = "@postman@"


def invoke(command, environment):
    try:
        return subprocess.run(
            [POSTMAN, command],
            env=environment,
            text=True,
            capture_output=True,
            encoding="utf-8",
            errors="replace",
            check=False,
        )
    except OSError as error:
        return subprocess.CompletedProcess([POSTMAN, command], 127, "", str(error))


def diagnose(command, result, environment, note=""):
    """Append private evidence; a logging failure never suppresses the renderer."""
    original_umask = os.umask(0o077)
    directory_fd = file_fd = None
    try:
        state = Path(
            environment.get("XDG_STATE_HOME")
            or Path(environment["HOME"]) / ".local/state"
        )
        if not state.is_absolute():
            raise OSError("diagnostics state path must be absolute")
        directory = state / "dotfiles" / "tmux-postman-status"
        directory.mkdir(mode=0o700, parents=True, exist_ok=True)
        directory_fd = os.open(directory, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
        info = os.fstat(directory_fd)
        if info.st_uid != os.geteuid():
            raise OSError("diagnostics directory is not owned by this user")
        os.fchmod(directory_fd, 0o700)
        file_fd = os.open(
            "events.jsonl",
            os.O_WRONLY | os.O_APPEND | os.O_CREAT | os.O_NOFOLLOW | os.O_NONBLOCK,
            0o600,
            dir_fd=directory_fd,
        )
        info = os.fstat(file_fd)
        if not stat.S_ISREG(info.st_mode) or info.st_uid != os.geteuid():
            raise OSError("diagnostics destination is not an owned regular file")
        os.fchmod(file_fd, 0o600)
        try:
            response = json.loads(result.stdout)
        except ValueError:
            response = result.stdout
        record = {
            "at": datetime.datetime.now(datetime.UTC).isoformat(),
            "tmux": environment["TMUX"],
            "command": command,
            "exit_code": result.returncode,
            "response": response,
            "stderr": result.stderr,
            "note": note,
        }
        payload = (json.dumps(record, ensure_ascii=True) + "\n").encode()
        if os.write(file_fd, payload) != len(payload):
            raise OSError("incomplete diagnostics write")
    except (OSError, KeyError, ValueError) as error:
        print(
            "tmux-postman-status: cannot write diagnostics: " + str(error),
            file=sys.stderr,
        )
    finally:
        for descriptor in (file_fd, directory_fd):
            if descriptor is not None:
                with contextlib.suppress(OSError):
                    os.close(descriptor)
        os.umask(original_umask)


def main():
    if len(sys.argv) != 3:
        print("usage: tmux-postman-status SOCKET SERVER_PID", file=sys.stderr)
        return 2
    environment = dict(os.environ, TMUX=sys.argv[1] + "," + sys.argv[2] + ",0")
    environment.pop("TMUX_PANE", None)
    refresh = invoke("refresh-status", environment)
    try:
        response = json.loads(refresh.stdout)
        normal = (
            isinstance(response, dict)
            and response.get("status") in ("updated", "skipped_busy")
            and not response.get("reason")
        )
    except ValueError:
        normal = False
    if refresh.returncode or refresh.stderr or not normal:
        diagnose("refresh-status", refresh, environment)

    # Always attempt this second command, including busy/error/diagnostic failure.
    rendered = invoke("get-status-oneline", environment)
    if rendered.returncode or rendered.stderr or not rendered.stdout.strip():
        diagnose(
            "get-status-oneline",
            rendered,
            environment,
            "empty output" if not rendered.stdout.strip() else "",
        )
    if rendered.returncode or not rendered.stdout.strip():
        print("?")
        return rendered.returncode or 1
    sys.stdout.write(rendered.stdout)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
