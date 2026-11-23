"""Offline behavior checks for the Lazygit AI commit helper."""

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("ai-commit.sh")

CODEX = """#!/usr/bin/env python3
import os
from pathlib import Path
import subprocess
import sys

args = sys.argv[1:]
output = Path(args[args.index('--output-last-message') + 1])
diff = sys.stdin.read()
Path(os.environ['CODEX_LOG']).write_text(diff)
mode = os.environ['CODEX_MODE']
if mode == 'stage':
    Path('note.txt').write_text('new staged content\\n')
    subprocess.run(['git', 'add', 'note.txt'], check=True)
if mode == 'failure':
    print('stub API failure', file=sys.stderr)
    sys.exit(1)
if mode == 'interrupt':
    sys.exit(130)
output.write_text({
    'success': 'chore(test): summarize old content\\n',
    'stage': 'chore(test): summarize old content\\n',
    'empty': '',
    'malformed': 'not a conventional subject\\n',
}[mode])
"""

VIM = """#!/usr/bin/env python3
import os
from pathlib import Path
import subprocess
import sys

message = Path(sys.argv[1])
Path(os.environ['VIM_LOG']).write_text(message.read_text())
mode = os.environ['VIM_MODE']
if mode == 'cancel':
    sys.exit(1)
if mode == 'stage':
    Path('note.txt').write_text('new staged content\\n')
    subprocess.run(['git', 'add', 'note.txt'], check=True)
if not message.read_text().startswith('chore(test):'):
    message.write_text('chore(test): manual fallback\\n')
"""


class AICommitTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="lazygit ai commit ")
        self.addCleanup(self.tmp.cleanup)
        self.repo = Path(self.tmp.name) / "repo with spaces"
        self.repo.mkdir()
        self.bin = Path(self.tmp.name) / "stub bin"
        self.bin.mkdir()
        for name, body in (("codex", CODEX), ("vim", VIM)):
            path = self.bin / name
            path.write_text(body)
            path.chmod(0o755)
        self.git("init", "-q")
        self.git("config", "user.name", "Test")
        self.git("config", "user.email", "test@example.invalid")
        self.git("config", "commit.gpgsign", "false")
        (self.repo / "note.txt").write_text("base\n")
        self.git("add", "note.txt")
        self.git("commit", "-qm", "chore(test): base")
        (self.repo / "note.txt").write_text("old staged content\n")
        self.git("add", "note.txt")
        self.base_head = self.git("rev-parse", "HEAD").stdout.strip()
        self.codex_log = Path(self.tmp.name) / "codex.log"
        self.vim_log = Path(self.tmp.name) / "vim.log"

    def git(self, *args):
        return subprocess.run(
            ["git", *args], cwd=self.repo, text=True, capture_output=True, check=True
        )

    def helper(self, codex_mode="success", vim_mode="success", missing_codex=False):
        if missing_codex:
            (self.bin / "codex").unlink()
        env = os.environ.copy()
        env.update(
            {
                "PATH": f"{self.bin}:/usr/bin:/bin",
                "CODEX_MODE": codex_mode,
                "VIM_MODE": vim_mode,
                "CODEX_LOG": str(self.codex_log),
                "VIM_LOG": str(self.vim_log),
                "GIT_CONFIG_GLOBAL": "/dev/null",
            }
        )
        return subprocess.run(
            ["/bin/bash", str(SCRIPT)],
            check=False,
            cwd=self.repo,
            env=env,
            text=True,
            capture_output=True,
        )

    def assert_no_commit(self):
        self.assertEqual(self.git("rev-parse", "HEAD").stdout.strip(), self.base_head)

    def test_success_uses_staged_diff_and_opens_editor(self):
        result = self.helper()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("old staged content", self.codex_log.read_text())
        self.assertIn("chore(test): summarize old content", self.vim_log.read_text())
        self.assertEqual(
            self.git("show", "HEAD:note.txt").stdout, "old staged content\n"
        )

    def test_failure_and_missing_codex_use_manual_editor(self):
        for missing in (False, True):
            with self.subTest(missing=missing):
                if not missing:
                    result = self.helper(codex_mode="failure")
                    self.assertIn("stub API failure", result.stderr)
                else:
                    result = self.helper(missing_codex=True)
                    self.assertIn("codex not found", result.stderr)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(
                    self.git("log", "-1", "--format=%s").stdout.strip(),
                    "chore(test): manual fallback",
                )
                if not missing:
                    self.git("reset", "--soft", self.base_head)

    def test_empty_and_malformed_output_use_manual_editor(self):
        for mode in ("empty", "malformed"):
            with self.subTest(mode=mode):
                result = self.helper(codex_mode=mode)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(
                    self.git("log", "-1", "--format=%s").stdout.strip(),
                    "chore(test): manual fallback",
                )
                self.git("reset", "--soft", self.base_head)

    def test_editor_cancel_aborts_commit(self):
        result = self.helper(vim_mode="cancel")
        self.assertNotEqual(result.returncode, 0)
        self.assert_no_commit()

    def test_generation_interrupt_aborts_without_editor(self):
        result = self.helper(codex_mode="interrupt")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.vim_log.exists())
        self.assert_no_commit()

    def test_staging_change_during_generation_aborts(self):
        result = self.helper(codex_mode="stage")
        self.assertNotEqual(result.returncode, 0)
        self.assert_no_commit()
        self.assertEqual(self.git("show", ":note.txt").stdout, "new staged content\n")

    def test_staging_change_in_editor_aborts(self):
        result = self.helper(vim_mode="stage")
        self.assertNotEqual(result.returncode, 0)
        self.assert_no_commit()
        self.assertEqual(self.git("show", ":note.txt").stdout, "new staged content\n")


if __name__ == "__main__":
    unittest.main()
