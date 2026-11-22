"""Isolated behavior checks for repo-setup; never trusts a real checkout."""

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent / "bin" / "repo-setup"
GIT = shutil.which("git")


class RepoSetupTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="repo-setup-test-")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name) / "fixture"
        self.root.mkdir()
        self.root = self.root.resolve()
        subprocess.run([GIT, "init", "-q", str(self.root)], check=True)
        self.bin = Path(self.temporary.name) / "bin"
        self.bin.mkdir()
        for name in ("bash", "git", "basename"):
            (self.bin / name).symlink_to(shutil.which(name))
        self.log = Path(self.temporary.name) / "calls.log"
        self.env = os.environ.copy()
        self.env.update(PATH=str(self.bin), TEST_LOG=str(self.log))

    def stub(self, name, body):
        path = self.bin / name
        path.write_text("#!/bin/sh\n" + body)
        path.chmod(0o755)

    def direnv(self):
        self.stub(
            "direnv",
            'printf "direnv %s\\n" "$*" >> "$TEST_LOG"\n'
            'if [ "$1" = exec ] && [ "${FAIL_DIRENV_EXEC:-0}" = 1 ]; then exit 7; fi\n',
        )

    def nix(self):
        self.stub(
            "nix",
            'printf "nix %s\\n" "$*" >> "$TEST_LOG"\n'
            'if [ "${FAIL_NIX:-0}" = 1 ]; then exit 8; fi\n'
            'printf "repos: []\\n" > .pre-commit-config.yaml\n',
        )

    def flake(self, hooks=False):
        (self.root / "flake.nix").write_text("{}\n")
        if hooks:
            module = self.root / "nix/flake-parts/modules/pre-commit.nix"
            module.parent.mkdir(parents=True)
            module.write_text("{}\n")

    def run_setup(self, *flags, cwd=None):
        return subprocess.run(
            [str(SCRIPT), *flags],
            cwd=cwd or self.root,
            env=self.env,
            text=True,
            capture_output=True,
            check=False,
        )

    def calls(self):
        return self.log.read_text() if self.log.exists() else ""

    def test_no_flake_does_not_create_or_trust_envrc(self):
        result = self.run_setup()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.root / ".envrc").exists())
        self.assertEqual(self.calls(), "")

    def test_missing_envrc_is_exact_and_loaded_once(self):
        self.flake()
        self.direnv()
        result = self.run_setup()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.root / ".envrc").read_bytes(), b"use flake\n")
        self.assertEqual(
            self.calls(),
            f"direnv allow {self.root / '.envrc'}\ndirenv exec {self.root} true\n",
        )

    def test_existing_envrc_requires_explicit_allow_and_is_preserved(self):
        self.flake()
        self.direnv()
        envrc = self.root / ".envrc"
        envrc.write_text("custom setup\n")
        default = self.run_setup()
        self.assertEqual(default.returncode, 0, default.stderr)
        self.assertEqual(self.calls(), "")
        allowed = self.run_setup("--allow-direnv")
        self.assertEqual(allowed.returncode, 0, allowed.stderr)
        self.assertEqual(envrc.read_text(), "custom setup\n")
        self.assertIn(f"direnv allow {envrc}\n", self.calls())
        self.assertIn(f"direnv exec {self.root} true\n", self.calls())

    def test_external_worktree_can_deny_generated_envrc_trust(self):
        self.flake()
        self.direnv()
        result = self.run_setup("--no-allow-generated-envrc")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.root / ".envrc").read_bytes(), b"use flake\n")
        self.assertEqual(self.calls(), "")

    def test_missing_direnv_fails_only_when_trust_requested(self):
        self.flake()
        result = self.run_setup()
        self.assertEqual(result.returncode, 1)
        self.assertIn("direnv command not found", result.stderr)
        self.assertEqual((self.root / ".envrc").read_bytes(), b"use flake\n")
        (self.root / ".envrc").unlink()
        denied = self.run_setup("--no-allow-generated-envrc")
        self.assertEqual(denied.returncode, 0, denied.stderr)

    def test_failed_direnv_load_warns_and_continues(self):
        self.flake()
        self.direnv()
        self.env["FAIL_DIRENV_EXEC"] = "1"
        result = self.run_setup()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("could not load .envrc", result.stderr)
        self.assertIn("direnv exec", self.calls())

    def test_missing_nix_skips_dotfiles_hooks(self):
        self.flake(hooks=True)
        result = self.run_setup("--no-allow-generated-envrc")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("nix command not found", result.stdout)
        self.assertFalse((self.root / ".pre-commit-config.yaml").exists())

    def test_devshell_failure_warns_without_generated_hooks(self):
        self.flake(hooks=True)
        self.nix()
        self.env["FAIL_NIX"] = "1"
        result = self.run_setup("--no-allow-generated-envrc")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("could not install devshell hooks", result.stderr)
        self.assertIn(f"nix develop {self.root}#default --command true\n", self.calls())
        self.assertFalse((self.root / ".pre-commit-config.yaml").exists())

    def test_hook_installation_and_skip_preserve_existing_hook(self):
        self.flake(hooks=True)
        self.nix()
        hook = self.root / ".git/hooks/pre-commit"
        hook.write_text("existing hook\n")
        skipped = self.run_setup("--no-allow-generated-envrc", "--skip-devshell-hooks")
        self.assertEqual(skipped.returncode, 0, skipped.stderr)
        self.assertEqual(self.calls(), "")
        installed = self.run_setup("--no-allow-generated-envrc")
        self.assertEqual(installed.returncode, 0, installed.stderr)
        self.assertTrue((self.root / ".pre-commit-config.yaml").exists())
        self.assertEqual(hook.read_text(), "existing hook\n")

    def test_example_names_do_not_run_project_installers(self):
        self.stub("npm", 'printf "npm %s\\n" "$*" >> "$TEST_LOG"\n')
        self.root.rename(self.root.with_name("my-frontend-app"))
        self.root = self.root.with_name("my-frontend-app")
        frontend = self.run_setup()
        self.assertEqual(frontend.returncode, 0, frontend.stderr)
        self.assertEqual(self.calls(), "")
        self.root.rename(self.root.with_name("my-backend-api"))
        self.root = self.root.with_name("my-backend-api")
        (self.root / ".env").write_text("secret fixture\n")
        child = self.root / "child"
        child.mkdir()
        backend = self.run_setup(cwd=child)
        self.assertEqual(backend.returncode, 0, backend.stderr)
        self.assertFalse((child / ".env").exists())
        self.assertEqual(self.calls(), "")


if __name__ == "__main__":
    unittest.main()
