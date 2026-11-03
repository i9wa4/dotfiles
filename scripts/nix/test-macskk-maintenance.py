"""Verify macSKK pin ordering and cleanup without running Homebrew."""

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("macskk-maintenance.sh")


class MacSKKTest(unittest.TestCase):
    def run_policy(self, action, scenario):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            brew = root / "brew"
            brew.write_text(
                f"#!{sys.executable}\n"
                + r"""
import json, os, pathlib, signal, sys
root = pathlib.Path(os.environ['TEST_ROOT'])
args = sys.argv[1:]
log = root / 'calls.jsonl'
with log.open('a') as f:
    f.write(json.dumps(args) + '\n')
calls = [json.loads(s) for s in log.read_text().splitlines()]
scenario = os.environ['TEST_SCENARIO']
if args == ['list', '--cask']:
    if scenario == 'query-error': sys.exit(19)
    print('kitty')
    if scenario != 'fresh': print('macskk')
elif args == ['pin', '--cask', 'macskk']:
    count = calls.count(args)
    if scenario == 'pin-error': sys.exit(13)
    if count == 2 and 'repin-error' in scenario: sys.exit(23)
elif args == ['unpin', '--cask', 'macskk']:
    if scenario == 'unpin-error': sys.exit(11)
elif args == ['upgrade', '--cask', 'macskk']:
    if scenario.startswith('upgrade-error'): sys.exit(17)
    signals = {'term': signal.SIGTERM, 'int': signal.SIGINT, 'hup': signal.SIGHUP}
    if scenario in signals: os.kill(os.getppid(), signals[scenario])
else:
    raise AssertionError(args)
"""
            )
            brew.chmod(0o755)
            env = os.environ | {"TEST_ROOT": str(root), "TEST_SCENARIO": scenario}
            result = subprocess.run(
                ["bash", str(SCRIPT), action, str(brew)],
                env=env,
                capture_output=True,
                text=True,
                check=False,
                timeout=10,
            )
            calls = [
                json.loads(s) for s in (root / "calls.jsonl").read_text().splitlines()
            ]
            return result, calls

    def test_existing_and_fresh_activation(self):
        for scenario, expected in (
            ("installed", 0),
            ("fresh", 0),
            ("query-error", 19),
            ("pin-error", 13),
        ):
            with self.subTest(scenario=scenario):
                result, calls = self.run_policy("pin-existing", scenario)
                self.assertEqual(result.returncode, expected, result.stderr)
                self.assertEqual(calls[0], ["list", "--cask"])
                if scenario in ("installed", "pin-error"):
                    self.assertEqual(calls[1:], [["pin", "--cask", "macskk"]])
                else:
                    self.assertEqual(len(calls), 1)

    def test_manual_upgrade_cleanup(self):
        for scenario, expected in (
            ("installed", 0),
            ("upgrade-error", 17),
            ("unpin-error", 11),
            ("pin-error", 13),
            ("repin-error", 1),
            ("upgrade-error-repin-error", 17),
            ("term", 143),
            ("int", 130),
            ("hup", 129),
        ):
            with self.subTest(scenario=scenario):
                result, calls = self.run_policy("upgrade", scenario)
                self.assertEqual(result.returncode, expected, result.stderr)
                self.assertEqual(calls[0], ["pin", "--cask", "macskk"])
                if scenario == "pin-error":
                    self.assertEqual(len(calls), 1)
                    continue
                self.assertEqual(calls[1], ["unpin", "--cask", "macskk"])
                self.assertEqual(calls[-1], ["pin", "--cask", "macskk"])
                upgrades = [c for c in calls if c[0] == "upgrade"]
                self.assertEqual(
                    upgrades,
                    []
                    if scenario == "unpin-error"
                    else [["upgrade", "--cask", "macskk"]],
                )
                if "repin-error" in scenario:
                    self.assertIn("could not restore", result.stderr)


if __name__ == "__main__":
    unittest.main()
