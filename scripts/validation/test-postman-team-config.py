"""Config, direct default starts and complete archived-policy source."""

import hashlib
import json
import os
import pathlib
import runpy
import shutil
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


class NativeTeamBootTests(unittest.TestCase):
    def setUp(self):
        self.binary = os.environ.get("POSTMAN_TEST_BINARY")
        if not self.binary or not shutil.which("tmux") or not shutil.which("zsh"):
            self.skipTest("native boot regression requires Postman, tmux and zsh")
        self.temporary = tempfile.TemporaryDirectory(prefix="pm-boot-", dir="/tmp")
        self.addCleanup(self.temporary.cleanup)
        self.root = pathlib.Path(self.temporary.name).resolve()
        self.home = self.root / "home"
        self.home.mkdir()
        self.socket = str(self.root / "s")
        self.config = self.root / "postman.md"
        self.config.write_text(
            "## `edges`\n```mermaid\ngraph LR\nworker --- peer\n```\n## `worker`\nWorker\n## `peer`\nPeer\n"
        )
        self.bin = self.root / "bin"
        self.bin.mkdir()
        stub = self.bin / "vde-layout"
        stub.write_text(
            "#!"
            + sys.executable
            + "\nimport json,os,pathlib,sys\npathlib.Path(os.environ['BOOT_TRACE']).write_text(json.dumps(sys.argv[1:]))\n"
        )
        stub.chmod(0o700)
        self.env = {
            **os.environ,
            "HOME": str(self.home),
            "XDG_STATE_HOME": str(self.root / "state"),
            "PATH": str(self.bin) + os.pathsep + os.environ["PATH"],
            "TMUX": self.socket + ",0,0",
            "BOOT_TRACE": str(self.root / "boot.json"),
        }
        self.addCleanup(
            lambda: subprocess.run(
                ["tmux", "-S", self.socket, "kill-server"],
                capture_output=True,
                timeout=3,
                check=False,
            )
        )

    def tmux(self, *args):
        result = subprocess.run(
            ["tmux", "-S", self.socket, *args],
            input="",
            capture_output=True,
            text=True,
            timeout=5,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.strip()

    def session_at_home(self, name):
        directory = self.home / name
        directory.mkdir()
        pane = self.tmux(
            "-f",
            "/dev/null",
            "new-session",
            "-d",
            "-s",
            name,
            "-c",
            str(self.home),
            "-P",
            "-F",
            "#{pane_id}",
            "exec sleep 120",
        )
        self.tmux("select-pane", "-t", pane, "-T", "pane")
        return directory, pane

    def roles(self, name, directory):
        worker = self.tmux(
            "new-window",
            "-d",
            "-t",
            name,
            "-c",
            str(directory),
            "-P",
            "-F",
            "#{pane_id}",
            "exec sleep 120",
        )
        peer = self.tmux(
            "split-window",
            "-d",
            "-t",
            worker,
            "-c",
            str(directory),
            "-P",
            "-F",
            "#{pane_id}",
            "exec sleep 120",
        )
        self.tmux("select-pane", "-t", worker, "-T", "worker")
        self.tmux("select-pane", "-t", peer, "-T", "peer")
        return worker

    def boot(self, pane, directory):
        return subprocess.run(
            [
                "zsh",
                "-f",
                "-c",
                'source "$1"; __snippet_vde_team "$2"',
                "fixture",
                str(REPO / "config/zsh/snippet.zsh"),
                "preset-p",
            ],
            cwd=directory,
            env={**self.env, "TMUX_PANE": pane},
            capture_output=True,
            text=True,
            timeout=8,
            check=False,
        )

    def send(self, pane, directory, body):
        result = subprocess.run(
            [self.binary, "send-heredoc", "--config", str(self.config), "--to", "peer"],
            cwd=directory,
            env={**self.env, "TMUX_PANE": pane},
            input=body,
            capture_output=True,
            text=True,
            timeout=15,
            check=False,
        )
        return result.returncode, json.loads(result.stdout)

    def test_home_creation_navigation_and_boot_do_not_collide_or_move_old_mail(self):
        old, old_pane = self.session_at_home("old-repo")
        old_worker = self.roles("old-repo", old)
        code, initial = self.send(old_worker, old, "old workspace evidence")
        self.assertEqual(
            (code, initial["workspace"], initial["success"]), (0, "~", True)
        )
        fresh, fresh_pane = self.session_at_home("new-repo")
        # Before boot both sessions still have HOME as their native root.
        self.assertEqual(
            self.tmux("display-message", "-p", "-t", fresh_pane, "#{session_path}"),
            str(self.home),
        )
        old_root = self.root / "state/tmux-a2a-postman/%00"
        snapshot = lambda: {
            str(p.relative_to(old_root)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in old_root.rglob("*")
            if p.is_file()
        }
        before = snapshot()
        geometry = self.tmux(
            "display-message", "-p", "-t", fresh_pane, "#{pane_width} #{pane_height}"
        )
        result = self.boot(fresh_pane, fresh)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "")
        self.assertEqual(
            json.loads((self.root / "boot.json").read_text()), ["preset-p"]
        )
        self.assertEqual(
            self.tmux("display-message", "-p", "-t", fresh_pane, "#{session_path}"),
            str(fresh),
        )
        self.assertEqual(
            self.tmux(
                "display-message",
                "-p",
                "-t",
                fresh_pane,
                "#{pane_width} #{pane_height}",
            ),
            geometry,
        )
        self.assertEqual(self.tmux("list-clients", "-F", "#{client_name}"), "")
        worker = self.roles("new-repo", fresh)
        code, sent = self.send(worker, fresh, "fresh workspace evidence")
        self.assertEqual(
            (code, sent["workspace"], sent["success"]), (0, "~/new-repo", True)
        )
        # Later command cwd is not a boot and must not choose another mailbox.
        code, later = self.send(worker, old, "later cd retains native workspace")
        self.assertEqual(
            (code, later["workspace"], later["success"]), (0, "~/new-repo", True)
        )
        self.assertEqual(snapshot(), before)
        blocked = self.boot(fresh_pane, old)
        self.assertNotEqual(blocked.returncode, 0)
        self.assertIn("team role already exists", blocked.stderr)
        self.assertEqual(
            self.tmux("display-message", "-p", "-t", fresh_pane, "#{session_path}"),
            str(fresh),
        )
        # Another live owner is still protected; boot never rewrites its state.
        self.assertEqual(
            self.tmux("display-message", "-p", "-t", old_pane, "#{session_path}"),
            str(self.home),
        )

    def test_existing_generic_agent_cannot_be_rebound_to_a_different_root(self):
        fresh, pane = self.session_at_home("new-repo")
        self.tmux("select-pane", "-t", pane, "-T", "agent")
        result = self.boot(pane, fresh)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("agent already exists", result.stderr)
        self.assertEqual(
            self.tmux("display-message", "-p", "-t", pane, "#{session_path}"),
            str(self.home),
        )
        self.assertFalse((self.root / "boot.json").exists())


if __name__ == "__main__":
    unittest.main()
