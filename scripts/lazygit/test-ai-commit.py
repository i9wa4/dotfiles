"""Offline regression tests for the Lazygit AI commit helper."""

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("ai-commit.sh")


class AICommitTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="lazygit-ai-commit-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.stubs = self.root / "stubs"
        self.stubs.mkdir()
        self.log = self.root / "log"
        self.log.mkdir()
        self.git("init", "-q")
        self.git("config", "user.name", "Fixture")
        self.git("config", "user.email", "fixture@example.invalid")
        (self.repo / "README.md").write_text("baseline\n")
        self.git("add", "README.md")
        self.git("commit", "-qm", "baseline")
        (self.repo / "initial.txt").write_text("initial staged content\n")
        self.git("add", "initial.txt")

        self.executable(
            self.stubs / "codex",
            """#!/usr/bin/env bash
set -euo pipefail
out=
while [ "$#" -gt 0 ]; do
  if [ "$1" = --output-last-message ]; then out=$2; shift 2; else shift; fi
done
cat > "$TRIAL_LOG/ai.diff"
printf 'test: fixture commit\\n' > "$out"
""",
        )
        self.executable(
            self.stubs / "vim",
            """#!/usr/bin/env bash
set -euo pipefail
touch "$TRIAL_LOG/editor_opened"
if [ "${TRIAL_EDITOR_STAGE:-0}" = 1 ]; then
  printf 'added by editor\\n' > extra.txt
  git add extra.txt
fi
""",
        )
        self.executable(
            self.repo / ".git/hooks/pre-commit",
            """#!/usr/bin/env bash
set -euo pipefail
if [ "${TRIAL_HOOK_STAGE:-0}" = 1 ]; then
  printf 'added by hook\\n' > extra.txt
  git add extra.txt
fi
""",
        )

    def executable(self, path, contents):
        path.write_text(contents)
        path.chmod(0o755)

    def git(self, *args):
        return subprocess.run(
            ["git", *args], cwd=self.repo, check=True, text=True, capture_output=True
        ).stdout.strip()

    def helper(self, **flags):
        environment = os.environ.copy()
        environment["PATH"] = f"{self.stubs}{os.pathsep}{environment['PATH']}"
        environment["TRIAL_LOG"] = str(self.log)
        environment.update(flags)
        return subprocess.run(
            ["bash", str(SCRIPT)],
            check=False,
            cwd=self.repo,
            env=environment,
            text=True,
            capture_output=True,
            timeout=15,
        )

    def test_normal_commit_uses_staged_diff(self):
        result = self.helper()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("initial.txt", (self.log / "ai.diff").read_text())
        self.assertTrue((self.log / "editor_opened").exists())
        self.assertEqual(
            self.git("show", "--pretty=format:", "--name-only", "HEAD"), "initial.txt"
        )
        self.assertEqual(self.git("status", "--short"), "")

    def test_hook_stage_change_aborts_commit(self):
        before = self.git("rev-parse", "HEAD")
        result = self.helper(TRIAL_HOOK_STAGE="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Staged changes changed", result.stderr)
        self.assertEqual(self.git("rev-parse", "HEAD"), before)
        self.assertFalse((self.log / "editor_opened").exists())
        self.assertIn("A  extra.txt", self.git("status", "--short"))

    def test_editor_stage_change_aborts_commit(self):
        before = self.git("rev-parse", "HEAD")
        result = self.helper(TRIAL_EDITOR_STAGE="1")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Staged changes changed", result.stderr)
        self.assertEqual(self.git("rev-parse", "HEAD"), before)
        self.assertTrue((self.log / "editor_opened").exists())
        self.assertIn("A  extra.txt", self.git("status", "--short"))


if __name__ == "__main__":
    unittest.main()
