"""Boundary checks for config compilation and launch-time role delivery."""

import json
import os
import pathlib
import runpy
import subprocess
import sys
import tempfile
import unittest

REPO = pathlib.Path(__file__).resolve().parents[2]
LAUNCHER = REPO / "scripts/bin/postman-agent"
COMPILER = REPO / "scripts/bin/postman-team-config"
TEMPLATE = REPO / "config/tmux-a2a-postman/postman.md"
compile_config = runpy.run_path(str(COMPILER))["compile_config"]
role_prompt = runpy.run_path(str(LAUNCHER))["role_prompt"]


class TeamConfigTests(unittest.TestCase):
    def test_release_updater_keeps_landed_pin_until_a_compatible_tag_exists(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            target, gh = root / "flake.nix", root / "gh"
            original = 'tmux-a2a-postman = {\n  url = "github:i9wa4/tmux-a2a-postman/landed";\n};\n'
            gh.write_text(
                '#!/bin/sh\ncase "$*" in\n*--paginate*) echo v0.9.5;;\n*) test "$FIXTURE_COMPATIBLE" = yes;;\nesac\n'
            )
            gh.chmod(0o700)
            env = {
                **os.environ,
                "TMUX_A2A_POSTMAN_GH": str(gh),
                "TMUX_A2A_POSTMAN_FLAKE_NIX": str(target),
            }
            updater = REPO / "scripts/nix/flake-input-update-tmux-a2a-postman.sh"
            for compatible, explicit, expected in [
                ("no", "", 0),
                ("no", "v0.9.5", 1),
                ("yes", "v0.9.5", 0),
            ]:
                with self.subTest(compatible=compatible, explicit=explicit):
                    target.write_text(original)
                    result = subprocess.run(
                        ["bash", str(updater)],
                        check=False,
                        capture_output=True,
                        env={
                            **env,
                            "FIXTURE_COMPATIBLE": compatible,
                            "TMUX_A2A_POSTMAN_TAG": explicit,
                        },
                    )
                    self.assertEqual(result.returncode, expected, result.stderr)
                    self.assertEqual(
                        target.read_text(),
                        original
                        if compatible == "no"
                        else original.replace("/landed", "/v0.9.5"),
                    )

    def test_every_role_has_its_policy_and_explicit_config(self):
        for role in [
            "messenger",
            "orchestrator",
            "worker",
            "worker-alt",
            "approver",
            "guardian",
            "critic",
        ]:
            with self.subTest(role=role):
                prompt = role_prompt(TEMPLATE, role)
                self.assertIn("# Selected role: " + role, prompt)
                self.assertIn("# Common contract", prompt)
                self.assertIn("--config " + str(TEMPLATE), prompt)

    def test_configuration_sections_are_not_roles(self):
        for role in [
            "common_template",
            "message_footer",
            "edges",
            "unknown",
            "../worker",
        ]:
            with self.subTest(role=role), self.assertRaises(ValueError):
                role_prompt(TEMPLATE, role)

    def test_no_fixed_production_depth(self):
        sessions = [{"name": "t0", "parent": None}]
        sessions += [
            {"name": "t" + str(i), "parent": "t" + str(i - 1)} for i in range(1, 100)
        ]
        output = compile_config(TEMPLATE.read_text(), {"sessions": sessions})
        self.assertIn('session_name: "t99"', output)
        self.assertIn('parent_session_name: "t98"', output)
        self.assertEqual(
            output.split("\n---\n", 1)[1], TEMPLATE.read_text().split("\n---\n", 1)[1]
        )

    def test_invalid_trees_fail_before_publication(self):
        cases = [
            [],
            [{"name": "a", "parent": "missing"}],
            [{"name": "a"}, {"name": "b"}],
            [{"name": "a"}, {"name": "a"}],
            [
                {"name": "root"},
                {"name": "a", "parent": "b"},
                {"name": "b", "parent": "a"},
            ],
            [{"name": "a", "parent": "a"}],
            [{"name": "a:b"}],
            [{"name": "a", "authority": "all"}],
        ]
        for sessions in cases:
            with self.subTest(sessions=sessions), self.assertRaises(ValueError):
                compile_config(TEMPLATE.read_text(), {"sessions": sessions})

    def test_existing_config_is_not_overwritten(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            tree, output = root / "tree.json", root / "postman.md"
            tree.write_text(json.dumps({"sessions": [{"name": "root"}]}))
            output.write_text("keep existing user config")
            result = subprocess.run(
                [
                    sys.executable,
                    str(COMPILER),
                    "--template",
                    str(TEMPLATE),
                    "--tree",
                    str(tree),
                    "--output",
                    str(output),
                ],
                check=False,
                capture_output=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(output.read_text(), "keep existing user config")
            self.assertEqual(
                {p.name for p in root.iterdir()}, {"tree.json", "postman.md"}
            )

    def test_launch_requires_native_pane_and_one_literal_placeholder(self):
        for command in [
            ["echo"],
            ["echo", "@postman-prompt", "@postman-prompt"],
            ["echo", "@postman-prompt"],
        ]:
            result = subprocess.run(
                [
                    sys.executable,
                    str(LAUNCHER),
                    "--config",
                    str(TEMPLATE),
                    "worker",
                    "--",
                    *command,
                ],
                check=False,
                env={"PATH": "/usr/bin:/bin"},
                capture_output=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn(b"postman-agent:", result.stderr)


if __name__ == "__main__":
    unittest.main()
