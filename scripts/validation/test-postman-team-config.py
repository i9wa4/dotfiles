"""Config, direct default starts and complete archived-policy source."""

import json
import os
import pathlib
import runpy
import subprocess
import sys
import tempfile
import unittest

REPO = pathlib.Path(__file__).resolve().parents[2]
COMPILER = REPO / "scripts/bin/postman-team-config"
TEMPLATE = REPO / "config/tmux-a2a-postman/postman.md"
compile_config = runpy.run_path(str(COMPILER))["compile_config"]
role_sections = runpy.run_path(str(COMPILER))["role_sections"]


class TeamConfigTests(unittest.TestCase):
    def test_default_team_layout_never_injects_an_initial_prompt(self):
        lines = (REPO / "config/vde/layout.yml").read_text().splitlines()
        commands = [
            line.split("command:", 1)[1].strip() for line in lines if "command:" in line
        ]
        self.assertFalse(
            any(
                "postman-agent" in line or "@postman-prompt" in line
                for line in commands
            )
        )
        self.assertEqual(
            sum(line.startswith(("codex ", "claude ")) for line in commands), 15
        )

    def test_release_updater_keeps_landed_pin_until_a_compatible_tag_exists(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            target, gh = root / "flake.nix", root / "gh"
            original = 'tmux-a2a-postman = {\n  url = "github:i9wa4/tmux-a2a-postman/landed";\n};\n'
            gh.write_text(
                '#!/bin/sh\ncase "$*" in\n*--paginate*) echo v0.9.5;;\n'
                '*skills/postman-team-manager/SKILL.md*) test "$FIXTURE_MANAGER" = yes;;\n'
                '*) test "$FIXTURE_COMPATIBLE" = yes;;\nesac\n'
            )
            gh.chmod(0o700)
            env = {
                **os.environ,
                "TMUX_A2A_POSTMAN_GH": str(gh),
                "TMUX_A2A_POSTMAN_FLAKE_NIX": str(target),
            }
            updater = REPO / "scripts/nix/flake-input-update-tmux-a2a-postman.sh"
            for compatible, manager, explicit, expected, update in [
                ("no", "no", "", 0, False),
                ("no", "no", "v0.9.5", 1, False),
                ("yes", "no", "", 0, False),
                ("yes", "no", "v0.9.5", 1, False),
                ("yes", "yes", "v0.9.5", 0, True),
            ]:
                with self.subTest(
                    compatible=compatible, manager=manager, explicit=explicit
                ):
                    target.write_text(original)
                    result = subprocess.run(
                        ["bash", str(updater)],
                        check=False,
                        capture_output=True,
                        env={
                            **env,
                            "FIXTURE_COMPATIBLE": compatible,
                            "FIXTURE_MANAGER": manager,
                            "TMUX_A2A_POSTMAN_TAG": explicit,
                        },
                    )
                    self.assertEqual(result.returncode, expected, result.stderr)
                    self.assertEqual(
                        target.read_text(),
                        original.replace("/landed", "/v0.9.5") if update else original,
                    )

    def test_every_role_has_its_complete_archived_policy_source(self):
        sections = role_sections(TEMPLATE.read_text())
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
                self.assertTrue(sections[role])
                self.assertTrue(sections["common_template"])

    def test_compiler_rejects_missing_or_duplicate_common_policy(self):
        original = TEMPLATE.read_text()
        for template in [
            original.replace("`common_template`", "`missing_common`"),
            original + "\n## `common_template`\nduplicate\n",
        ]:
            with self.subTest(template=template[:30]), self.assertRaises(ValueError):
                compile_config(template, {"sessions": [{"name": "root"}]})

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


if __name__ == "__main__":
    unittest.main()
