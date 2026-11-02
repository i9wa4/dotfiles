"""Exercise the actual commit editor with a deterministic Codex executable."""

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("ai-commit.sh").resolve()


class AICommitTest(unittest.TestCase):
    def test_generation_and_manual_fallback(self):
        for outcome in ("success", "api-error", "partial-error", "empty"):
            with self.subTest(outcome=outcome), tempfile.TemporaryDirectory() as tmp:
                root = Path(tmp)
                repo = root / "repo"
                repo.mkdir()
                tools = root / "bin"
                tools.mkdir()
                home = root / "home"
                home.mkdir()
                # Commit hooks export their owning repository/index. The fixture
                # must never stage or invoke hooks against that real repository.
                env = {
                    key: value
                    for key, value in os.environ.items()
                    if not key.startswith("GIT_")
                } | {
                    "HOME": str(home),
                    "GIT_CONFIG_NOSYSTEM": "1",
                    "PATH": str(tools) + os.pathsep + os.environ["PATH"],
                    "TEST_OUTCOME": outcome,
                    "TEST_ROOT": str(root),
                }

                def git(*args, cwd=repo, config=env):
                    return subprocess.run(
                        ["git", *args],
                        cwd=cwd,
                        env=config,
                        check=True,
                        capture_output=True,
                        text=True,
                    ).stdout

                git("init", "--quiet")
                git("config", "user.name", "Commit fixture")
                git("config", "user.email", "fixture@example.invalid")
                (repo / "change.txt").write_text("staged 日本語\n")
                git("add", "change.txt")
                staged = git("diff", "--cached", "--no-ext-diff")

                def stub(name, source, bin_dir=tools):
                    target = bin_dir / name
                    target.write_text(f"#!{sys.executable}\n" + source)
                    target.chmod(0o755)

                stub(
                    "codex",
                    r"""
import json, os, pathlib, sys
root = pathlib.Path(os.environ['TEST_ROOT'])
args = sys.argv[1:]
(root / 'argv.json').write_text(json.dumps(args))
(root / 'stdin.txt').write_text(sys.stdin.read())
output = pathlib.Path(args[args.index('--output-last-message') + 1])
outcome = os.environ['TEST_OUTCOME']
if outcome == 'success':
    output.write_text('fix(editor): restore suggestion\nignored second line\n')
elif outcome == 'partial-error':
    output.write_text('incomplete failed response\n')
if outcome in ('api-error', 'partial-error'):
    print('HTTP 400 model_not_found: selected model unavailable', file=sys.stderr)
    sys.exit(42)
""",
                )
                stub(
                    "vim",
                    """
import os, pathlib, sys
root = pathlib.Path(os.environ['TEST_ROOT'])
(root / 'editor.txt').write_bytes(pathlib.Path(sys.argv[1]).read_bytes())
sys.exit(73)  # Cancel the editor: the helper must not have committed already.
""",
                )

                result = subprocess.run(
                    ["bash", str(SCRIPT)],
                    cwd=repo,
                    env=env,
                    capture_output=True,
                    text=True,
                    timeout=15,
                    check=False,
                )
                self.assertNotEqual(result.returncode, 0)
                self.assertTrue((root / "editor.txt").exists(), result.stderr)
                args = json.loads((root / "argv.json").read_text())
                self.assertNotIn("-m", args)
                self.assertNotIn("--model", args)
                self.assertNotIn("--ignore-user-config", args)
                self.assertEqual((root / "stdin.txt").read_text(), staged)
                edited = (root / "editor.txt").read_text()
                if outcome == "success":
                    self.assertTrue(
                        edited.startswith("fix(editor): restore suggestion\n\n")
                    )
                    self.assertNotIn("ignored second line", edited)
                else:
                    self.assertNotIn("fix(editor)", edited)
                    self.assertNotIn("incomplete failed response", edited)
                    if outcome != "empty":
                        self.assertIn("model_not_found", result.stderr)
                        self.assertIn("42", result.stderr)
                    else:
                        self.assertIn("empty message", result.stderr)
                self.assertEqual(git("diff", "--cached", "--no-ext-diff"), staged)
                head = subprocess.run(
                    ["git", "rev-parse", "--verify", "HEAD"],
                    cwd=repo,
                    env=env,
                    capture_output=True,
                    check=False,
                )
                self.assertNotEqual(head.returncode, 0, "must not auto-commit")


if __name__ == "__main__":
    unittest.main()
