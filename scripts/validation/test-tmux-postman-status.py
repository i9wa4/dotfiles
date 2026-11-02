#!/usr/bin/env python3
"""Check this consumer's invocation/logging and real tmux status-job composition."""

import concurrent.futures
import contextlib
import fcntl
import hashlib
import json
import os
import pty
import select
import shlex
import stat
import struct
import subprocess
import sys
import tempfile
import termios
import time
import unittest
from pathlib import Path

SOURCE = Path(
    os.environ.get(
        "POSTMAN_STATUS_DRIVER", Path(__file__).parents[1] / "tmux/postman-status.py"
    )
)
PACKAGE = os.environ.get("POSTMAN_STATUS_PACKAGE")
REAL = os.environ.get("POSTMAN_STATUS_REAL_BIN")
CONFIG = Path(
    os.environ.get(
        "POSTMAN_STATUS_TMUX_CONFIG",
        Path(__file__).parents[2] / "config/tmux/tmux.conf",
    )
)
LINE = "[0]🟩💛:🟢 [3]⬛🟥 [9] [12]\n"


class ConsumerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="status-consumer-")
        self.root = Path(self.temp.name)
        self.home = self.root / "home"
        self.home.mkdir()
        self.state = self.root / "state"
        self.state.mkdir(mode=0o755)
        self.state.chmod(0o755)
        self.spec = self.root / "spec.json"
        self.calls = self.root / "calls.jsonl"
        self.binary = self.root / "pinned postman"
        self.binary.write_text(
            "#!"
            + sys.executable
            + "\n"
            + """
import json,os,pathlib,sys
spec=json.loads(pathlib.Path(os.environ['STATUS_TEST_SPEC']).read_text())
with pathlib.Path(os.environ['STATUS_TEST_CALLS']).open('a') as log:
    log.write(json.dumps({'command':sys.argv[1], 'argv':sys.argv[2:], 'tmux':os.environ.get('TMUX'), 'pane':os.environ.get('TMUX_PANE'), 'binary':sys.argv[0]})+'\\n')
item=spec['refresh' if sys.argv[1]=='refresh-status' else 'render']
sys.stdout.write(item['stdout'])
sys.stderr.write(item.get('stderr',''))
raise SystemExit(item.get('exit',0))
"""
        )
        self.binary.chmod(0o700)
        self.driver = self.root / "driver.py"
        self.driver.write_text(
            SOURCE.read_text().replace("@postman@", str(self.binary))
        )
        self.environment = dict(
            os.environ,
            HOME=str(self.home),
            XDG_STATE_HOME=str(self.state),
            TMUX="/inherited/wrong.sock,999,0",
            TMUX_PANE="%999",
            STATUS_TEST_SPEC=str(self.spec),
            STATUS_TEST_CALLS=str(self.calls),
        )
        self.socket = str(self.root / "socket ' ;$(unused),comma")

    def tearDown(self):
        self.temp.cleanup()

    def run_case(self, refresh=None, render=None):
        self.spec.write_text(
            json.dumps(
                {
                    "refresh": refresh or {"stdout": '{"status":"updated"}\n'},
                    "render": render or {"stdout": LINE},
                }
            )
        )
        result = subprocess.run(
            [sys.executable, str(self.driver), self.socket, "123"],
            env=self.environment,
            text=True,
            capture_output=True,
            check=False,
        )
        calls = [json.loads(line) for line in self.calls.read_text().splitlines()]
        self.assertEqual(
            ["refresh-status", "get-status-oneline"],
            [call["command"] for call in calls],
        )
        for call in calls:
            self.assertEqual(self.socket + ",123,0", call["tmux"])
            self.assertIsNone(call["pane"])
            self.assertEqual([], call["argv"])
            self.assertEqual(str(self.binary), call["binary"])
        return result

    def logs(self):
        path = self.state / "dotfiles/tmux-postman-status/events.jsonl"
        return (
            [json.loads(line) for line in path.read_text().splitlines()]
            if path.exists()
            else []
        )

    def test_success_preserves_upstream_display_without_logs(self):
        result = self.run_case()
        self.assertEqual(
            (0, LINE, ""), (result.returncode, result.stdout, result.stderr)
        )
        self.assertEqual([], self.logs())

    def test_ordinary_busy_skip_still_renders_without_log_growth(self):
        result = self.run_case({"stdout": '{"status":"skipped_busy"}\n'})
        self.assertEqual((0, LINE), (result.returncode, result.stdout))
        self.assertEqual([], self.logs())

    def test_failed_refresh_keeps_cache_and_private_owner_evidence(self):
        response = {
            "status": "partial",
            "reason": "capture timeout",
            "owner": {
                "pid": 42,
                "phase": "aggregate",
                "acquired_at": "2026-01-01T00:00:00Z",
            },
        }
        result = self.run_case(
            {"stdout": json.dumps(response), "stderr": "refresh warning\n", "exit": 1}
        )
        self.assertEqual((0, LINE), (result.returncode, result.stdout))
        self.assertEqual(response, self.logs()[0]["response"])
        self.assertEqual("refresh warning\n", self.logs()[0]["stderr"])
        directory = self.state / "dotfiles/tmux-postman-status"
        self.assertEqual(0o700, stat.S_IMODE(directory.stat().st_mode))
        self.assertEqual(
            0o600, stat.S_IMODE((directory / "events.jsonl").stat().st_mode)
        )
        self.assertEqual(0o755, stat.S_IMODE(self.state.stat().st_mode))

    def test_busy_with_actionable_reason_is_logged(self):
        result = self.run_case(
            {"stdout": '{"status":"skipped_busy","reason":"suspected stalled owner"}'}
        )
        self.assertEqual(LINE, result.stdout)
        self.assertIn("stalled", self.logs()[0]["response"]["reason"])

    def test_malformed_refresh_is_inspectable_without_bar_pollution(self):
        result = self.run_case({"stdout": "damaged response"})
        self.assertEqual(LINE, result.stdout)
        self.assertEqual("damaged response", self.logs()[0]["response"])

    def test_renderer_warning_keeps_the_line_and_logs_stderr(self):
        result = self.run_case(render={"stdout": LINE, "stderr": "stale capture\n"})
        self.assertEqual(LINE, result.stdout)
        self.assertEqual("get-status-oneline", self.logs()[0]["command"])

    def test_missing_or_corrupt_snapshot_is_truthfully_unavailable(self):
        result = self.run_case(
            {"stdout": '{"status":"error","reason":"wrong server"}', "exit": 1},
            {"stdout": "?", "stderr": "snapshot unavailable\n", "exit": 1},
        )
        self.assertEqual((1, "?\n"), (result.returncode, result.stdout))
        self.assertEqual(2, len(self.logs()))

    def test_diagnostic_destination_failure_still_renders(self):
        self.state.rmdir()
        self.state.write_text("not a directory")
        result = self.run_case({"stdout": '{"status":"error"}', "exit": 1})
        self.assertEqual((0, LINE), (result.returncode, result.stdout))
        self.assertIn("cannot write diagnostics", result.stderr)

    def test_diagnostic_symlink_does_not_modify_its_target(self):
        directory = self.state / "dotfiles/tmux-postman-status"
        directory.mkdir(parents=True)
        target = self.root / "untouched"
        target.write_text("original")
        (directory / "events.jsonl").symlink_to(target)
        result = self.run_case({"stdout": '{"status":"error"}', "exit": 1})
        self.assertEqual((0, LINE), (result.returncode, result.stdout))
        self.assertEqual("original", target.read_text())
        self.assertIn("cannot write diagnostics", result.stderr)


@unittest.skipUnless(
    PACKAGE and REAL,
    "native lane needs the Nix-built package and pinned upstream binary",
)
class NativeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="ps-", dir="/tmp")
        self.root = Path(self.temp.name).resolve()
        self.home = self.root / "home"
        self.work = self.home / "work"
        self.work.mkdir(parents=True)
        application_state = self.root / "state/tmux-a2a-postman"
        application_state.mkdir(parents=True)
        application_state.chmod(0o755)
        self.environment = dict(
            os.environ,
            HOME=str(self.home),
            XDG_STATE_HOME=str(self.root / "state"),
            XDG_CONFIG_HOME=str(self.home / ".config"),
            TMUX_PANE="%999",
            BASH_ENV="",
            ENV="",
            ZDOTDIR=str(self.home),
            HISTFILE=os.devnull,
            TERM="xterm-256color",
            PATH=str(Path(PACKAGE) / "bin") + ":" + os.environ["PATH"],
        )
        self.environment.pop("TMUX", None)
        self.sockets = []
        self.servers = {}
        self.clients = []
        self.pty_fds = []
        self.wrapper = str(Path(PACKAGE) / "bin/tmux-postman-status")

    def tm(self, socket, *args):
        return subprocess.check_output(
            ["tmux", "-u", "-S", str(socket), *args], env=self.environment, text=True
        ).strip()

    def start(self, name, keep):
        socket = self.root / name
        self.sockets.append(socket)
        server = subprocess.Popen(
            ["tmux", "-D", "-u", "-S", str(socket), "-f", "/dev/null"],
            env=self.environment,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            text=True,
        )
        self.servers[socket] = server
        deadline = time.monotonic() + 5
        while True:
            if server.poll() is not None:
                self.fail("fixture tmux exited: " + server.stderr.read())
            ready = subprocess.run(
                ["tmux", "-S", str(socket), "show-options", "-g"],
                env=self.environment,
                text=True,
                capture_output=True,
                timeout=2,
                check=False,
            )
            if ready.returncode == 0:
                break
            if time.monotonic() >= deadline:
                self.fail("fixture tmux did not become ready: " + ready.stderr)
            time.sleep(0.01)
        for index in range(max(keep) + 1):
            if index == 0:
                self.tm(
                    socket,
                    "new-session",
                    "-d",
                    "-s",
                    "scope-0",
                    "-c",
                    str(self.work),
                    "sleep 120",
                )
                self.tm(socket, "set-option", "-g", "exit-empty", "off")
            else:
                self.tm(
                    socket,
                    "new-session",
                    "-d",
                    "-s",
                    "scope-" + str(index),
                    "-c",
                    str(self.work),
                    "sleep 120",
                )
        for index in range(max(keep) + 1):
            if index not in keep:
                self.tm(socket, "kill-session", "-t", "scope-" + str(index))
        pid = self.tm(socket, "display-message", "-p", "#{pid}")
        self.assertEqual(str(server.pid), pid)
        return socket, pid

    def status(self, socket, pid, command="get-status"):
        environment = dict(self.environment, TMUX=str(socket) + "," + str(pid) + ",0")
        return subprocess.run(
            [REAL, command],
            check=False,
            env=environment,
            text=True,
            capture_output=True,
        )

    def compose(self, socket, pid):
        return subprocess.run(
            [self.wrapper, str(socket), str(pid)],
            check=False,
            env=self.environment,
            text=True,
            capture_output=True,
        )

    def tearDown(self):
        for client in self.clients:
            if client.poll() is None:
                client.terminate()
            with contextlib.suppress(subprocess.TimeoutExpired):
                client.wait(timeout=3)
            if client.poll() is None:
                client.kill()
                client.wait()
        for socket in self.sockets:
            subprocess.run(
                ["tmux", "-S", str(socket), "kill-server"],
                check=False,
                env=self.environment,
                capture_output=True,
            )
        for server in self.servers.values():
            try:
                server.communicate(timeout=3)
            except subprocess.TimeoutExpired:
                server.kill()
                server.communicate()
        for descriptor in self.pty_fds:
            os.close(descriptor)
        self.temp.cleanup()

    def test_native_ids_two_servers_restart_and_pure_getters(self):
        first, pid = self.start("first.sock", {0, 3, 9, 12})
        second, other_pid = self.start("second.sock", {0, 2})
        self.tm(
            first,
            "new-window",
            "-d",
            "-t",
            "$3",
            "-n",
            "second-window",
            "-c",
            str(self.work),
            "sleep 120",
        )
        self.assertNotEqual(0, self.status(first, pid).returncode)
        result = self.compose(first, pid)
        self.assertEqual(
            (0, "[0] [3] [9] [12]"),
            (result.returncode, result.stdout.strip()),
            result.stderr,
        )
        result = self.compose(second, other_pid)
        self.assertEqual(
            (0, "[0] [2]"), (result.returncode, result.stdout.strip()), result.stderr
        )
        saved = json.loads(self.status(first, pid).stdout)
        self.assertEqual(
            2,
            len(
                next(session for session in saved["sessions"] if session["id"] == "$3")[
                    "windows"
                ]
            ),
        )
        with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
            redraws = list(pool.map(lambda _: self.compose(first, pid), range(4)))
        self.assertTrue(
            all(
                result.returncode == 0 and result.stdout.strip() == "[0] [3] [9] [12]"
                for result in redraws
            )
        )
        self.assertEqual(
            ["$0", "$3", "$9", "$12"], [session["id"] for session in saved["sessions"]]
        )
        for session in saved["sessions"]:
            actual = self.tm(
                first,
                "display-message",
                "-p",
                "-t",
                session["id"],
                "#{session_id}\t#{session_name}",
            )
            self.assertEqual(session["id"] + "\t" + session["name"], actual)
            left = self.tm(
                first,
                "display-message",
                "-p",
                "-t",
                session["id"],
                "[#{s/[^0-9]//g:session_id}]",
            )
            self.assertEqual("[" + session["id"][1:] + "]", left)
        state = self.root / "state"

        def snapshot():
            return {
                str(path.relative_to(state)): hashlib.sha256(
                    path.read_bytes()
                ).hexdigest()
                for path in state.rglob("*")
                if path.is_file()
            }

        before = snapshot()
        self.assertEqual(0, self.status(first, pid).returncode)
        self.assertEqual(0, self.status(first, pid, "get-status-oneline").returncode)
        self.assertEqual(before, snapshot())
        self.assertEqual(
            0o755, stat.S_IMODE((state / "tmux-a2a-postman").stat().st_mode)
        )
        self.tm(first, "rename-session", "-t", "$3", "renamed")
        self.assertEqual(0, self.compose(first, pid).returncode)
        self.assertIn(
            "renamed",
            [
                session["name"]
                for session in json.loads(self.status(first, pid).stdout)["sessions"]
            ],
        )
        self.tm(first, "kill-server")
        self.servers[first].communicate(timeout=5)
        self.sockets.remove(first)
        first, new_pid = self.start("first.sock", {0})
        self.assertNotEqual(pid, new_pid)
        self.assertNotEqual(0, self.status(first, new_pid).returncode)
        result = self.compose(first, new_pid)
        self.assertEqual(
            (0, "[0]"), (result.returncode, result.stdout.strip()), result.stderr
        )
        version = json.loads(subprocess.check_output([REAL, "version"], text=True))
        print(
            json.dumps(
                {
                    "case": "native-ids/restart/pure-read",
                    "version": version,
                    "session_ids": ["$0", "$3", "$9", "$12"],
                }
            )
        )

    def test_loaded_status_job_quotes_real_socket_and_uses_actual_server(self):
        socket, pid = self.start("q';$().sock", {0})
        line = next(
            line
            for line in CONFIG.read_text().splitlines()
            if line.startswith("set-option -g status-format[1] ")
        )
        actual_format = shlex.split(line)[-1]
        self.tm(socket, "set-option", "-g", "status", "2")
        self.tm(socket, "set-option", "-g", "status-interval", "1")
        self.tm(socket, "set-option", "-g", "status-format[1]", actual_format)
        self.assertEqual(
            actual_format, self.tm(socket, "show-options", "-gv", "status-format[1]")
        )
        master, slave = pty.openpty()
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 30, 120, 0, 0))
        self.pty_fds.append(master)
        client = subprocess.Popen(
            ["tmux", "-u", "-S", str(socket), "attach-session", "-t", "scope-0"],
            stdin=slave,
            stdout=slave,
            stderr=slave,
            env=self.environment,
        )
        os.close(slave)
        self.clients.append(client)
        output = b""
        deadline = time.monotonic() + 15
        while time.monotonic() < deadline:
            if select.select([master], [], [], 0.1)[0]:
                output += os.read(master, 65536)
            status = self.status(socket, pid)
            if status.returncode == 0 and b"[0]" in output:
                break
        else:
            self.fail(
                "status job did not publish its actual socket: "
                + output[-1500:].decode(errors="replace")
            )
        saved = json.loads(status.stdout)
        self.assertEqual(str(socket), saved["server"]["socket"])
        self.assertEqual(int(pid), saved["server"]["pid"])
        self.assertEqual(0, self.status(socket, pid, "get-status-oneline").returncode)


if __name__ == "__main__":
    unittest.main(verbosity=2)
