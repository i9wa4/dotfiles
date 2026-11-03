"""Fault-inject the rendered dictionary activation in disposable destinations."""

import argparse
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

DICTIONARIES = (
    "SKK-JISYO.L",
    "SKK-JISYO.jinmei",
    "SKK-JISYO.assoc",
    "SKK-JISYO.emoji.utf8",
)
PAYLOAD = "complete dictionary 日本語\n" * 20
ACTIVATION = ""

TOOL = r"""
import json, os, pathlib, subprocess, sys
root = pathlib.Path(os.environ['TEST_ROOT'])
args = sys.argv[1:]
tool = pathlib.Path(sys.argv[0]).name
scenario = os.environ['TEST_SCENARIO']
with (root / 'calls.jsonl').open('a') as f:
    f.write(json.dumps([tool, *args]) + '\n')
if tool == 'git':
    assert os.environ.get('GIT_CONFIG_GLOBAL') == '/dev/null'
    assert os.environ.get('GIT_CONFIG_NOSYSTEM') == '1'
    probe = subprocess.run([os.environ['REAL_GIT'], 'config', '--global',
                            '--get-regexp', '^url'], capture_output=True, check=False)
    assert probe.returncode == 1 and not probe.stdout
    assert args[:1] == ['-C'] and args[2:5] == ['clone', '--depth', '1']
    assert args[5] in ('https://github.com/skk-dev/dict',
                       'https://github.com/uasi/skk-emoji-jisyo')
    if scenario == 'clone-error' or (scenario == 'emoji-clone-error' and 'emoji' in args[5]):
        sys.exit(17)
    dest = pathlib.Path(args[1]) / args[6]
    dest.mkdir()
    for name in os.environ['DICT_NAMES'].split(','):
        (dest / name).write_text(os.environ['DICT_PAYLOAD'])
elif tool == 'cp':
    if scenario == 'partial-copy':
        pathlib.Path(args[1]).write_text('truncated')
        sys.exit(18)
    os.execv(os.environ['REAL_CP'], [os.environ['REAL_CP'], *args])
elif tool == 'ln':
    assert args[:2] == ['-T', '--']
    target = pathlib.Path(args[-1])
    if scenario == 'publication-error': sys.exit(19)
    if scenario == 'concurrent' and target.name == 'SKK-JISYO.L':
        with target.open('x') as f: f.write('other completed publisher\n')
    os.execv(os.environ['REAL_LN'], [os.environ['REAL_LN'], *args])
elif tool == 'rm':
    for arg in args:
        if not arg.startswith('-'):
            assert pathlib.Path(arg).is_relative_to(root), arg
    if scenario == 'stage-cleanup-error' and args[0] == '-f': sys.exit(20)
    if scenario == 'clone-cleanup-error' and args[0] == '-rf': sys.exit(21)
    os.execv(os.environ['REAL_RM'], [os.environ['REAL_RM'], *args])
else:
    raise AssertionError(tool)
"""


class DictionaryActivationTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.home = self.root / "home"
        self.home.mkdir()
        self.tmp = self.root / "tmp"
        self.tmp.mkdir()
        self.dest = (
            self.home
            / "Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries"
        )
        self.dest.mkdir(parents=True)
        tools = self.root / "bin"
        tools.mkdir()
        for name in ("git", "ln", "cp", "rm"):
            file = tools / name
            file.write_text(f"#!{sys.executable}\n" + TOOL)
            file.chmod(0o755)
        self.env = {k: v for k, v in os.environ.items() if not k.startswith("GIT_")}
        self.env.update(
            {
                "HOME": str(self.home),
                "TMPDIR": str(self.tmp),
                "PATH": str(tools) + os.pathsep + os.environ["PATH"],
                "TEST_ROOT": str(self.root),
                "DICT_NAMES": ",".join(DICTIONARIES),
                "DICT_PAYLOAD": PAYLOAD,
                **{
                    f"REAL_{name.upper()}": shutil.which(name)
                    for name in ("git", "ln", "cp", "rm")
                },
            }
        )
        # The real activation must disable this ambient HTTPS-to-SSH rewrite.
        (self.home / ".gitconfig").write_text(
            '[url "ssh://invalid.test/"]\n insteadOf = https://github.com/\n'
        )
        source, git_count = re.subn(
            r"/nix/store/[^\s/]+/bin/git\b", shlex.quote(str(tools / "git")), ACTIVATION
        )
        source, ln_count = re.subn(
            r"/nix/store/[^\s/]+/bin/ln\b", shlex.quote(str(tools / "ln")), source
        )
        self.assertEqual(
            (git_count, ln_count),
            (2, 1),
            "rendered tool boundaries changed; review the fixture",
        )
        self.script = self.root / "activation.sh"
        self.script.write_text(source)

    def run_activation(self, scenario):
        return subprocess.run(
            ["bash", str(self.script)],
            env=self.env | {"TEST_SCENARIO": scenario},
            capture_output=True,
            text=True,
            timeout=15,
            check=False,
        )

    def assert_clean(self):
        self.assertEqual(list(self.tmp.iterdir()), [])
        self.assertEqual(list(self.dest.glob(".macskk-dict.*")), [])

    def test_partial_copy_and_publication_error_retry_cleanly(self):
        for scenario in (
            "partial-copy",
            "publication-error",
            "clone-error",
            "emoji-clone-error",
        ):
            with self.subTest(scenario=scenario):
                failed = self.run_activation(scenario)
                self.assertNotEqual(failed.returncode, 0)
                self.assertEqual(list(self.dest.iterdir()), [])
                self.assert_clean()
                retried = self.run_activation("success")
                self.assertEqual(retried.returncode, 0, retried.stderr)
                for name in DICTIONARIES:
                    self.assertEqual((self.dest / name).read_text(), PAYLOAD)
                    (self.dest / name).unlink()
                self.assert_clean()

    def test_concurrent_publication_keeps_the_other_complete_file(self):
        result = self.run_activation("concurrent")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            (self.dest / DICTIONARIES[0]).read_text(), "other completed publisher\n"
        )
        for name in DICTIONARIES[1:]:
            self.assertEqual((self.dest / name).read_text(), PAYLOAD)
        self.assert_clean()

    def test_existing_dictionary_is_untouched_and_complete_install_does_not_clone(self):
        existing = self.dest / DICTIONARIES[0]
        existing.write_text("user dictionary\n")
        before = existing.stat()
        result = self.run_activation("success")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(existing.read_text(), "user dictionary\n")
        self.assertEqual(existing.stat().st_mtime_ns, before.st_mtime_ns)
        calls = self.root / "calls.jsonl"
        previous = calls.read_bytes()
        result = self.run_activation("success")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls.read_bytes(), previous)
        self.assert_clean()

    def test_cleanup_errors_are_reported_and_fail_activation(self):
        result = self.run_activation("stage-cleanup-error")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("failed to remove staged dictionary", result.stderr)
        self.assertEqual(list(self.tmp.iterdir()), [])
        self.assertEqual(len(list(self.dest.glob(".macskk-dict.*"))), 1)
        result = self.run_activation("clone-cleanup-error")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("failed to remove temporary clone directory", result.stderr)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--activation", type=Path, required=True)
    options, remaining = parser.parse_known_args()
    ACTIVATION = options.activation.read_text()
    unittest.main(argv=[sys.argv[0], *remaining])
