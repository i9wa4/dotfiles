"""Isolated zoxide/ghq navigation checks. Run: python3 scripts/test-zoxide-navigation.py."""

import os
import pathlib
import shutil
import subprocess
import tempfile
import unittest

SOURCE = pathlib.Path(__file__).resolve().parents[1] / "config/zsh/zoxide.zsh"
ZSH = shutil.which("zsh")


class NavigationTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="zoxide-navigation-")
        self.addCleanup(self.temporary.cleanup)
        self.root = pathlib.Path(self.temporary.name).resolve()
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.known = self.root / "known repo"
        self.worktree = self.known / ".worktrees" / "branch.one"
        self.unseen = self.root / "owner" / "never-learned"
        self.exact = self.root / "owner" / "repo"
        self.partial = self.root / "owner" / "repo-extra"
        self.ambiguous = [self.root / owner / "shared" for owner in ("one", "two")]
        for path in (
            self.known,
            self.worktree,
            self.unseen,
            self.exact,
            self.partial,
            *self.ambiguous,
        ):
            path.mkdir(parents=True, exist_ok=True)
        self.ghq = self.root / "ghq.txt"
        self.ghq.write_text(
            "\n".join(
                map(
                    str,
                    (
                        self.known,
                        self.unseen,
                        self.exact,
                        self.partial,
                        *self.ambiguous,
                        self.root / "deleted",
                    ),
                )
            )
            + "\n"
        )
        self.zoxide = self.root / "zoxide.txt"
        self.zoxide.write_text(f"10.5 {self.known}\n4.2 {self.worktree}\n")
        programs = {
            "zoxide": """#!/bin/sh
case "$1" in
  init) exit 0 ;;
  query) if [ "$2" = "--list" ]; then /bin/cat "$ZOXIDE_FIXTURE";
         elif [ -n "$ZOXIDE_HIT" ]; then printf '%s\n' "$ZOXIDE_HIT";
         else exit 1; fi ;;
  add) printf 'add\n' >> "$MUTATION_LOG" ;;
esac
""",
            "ghq": '#!/bin/sh\n/bin/cat "$GHQ_FIXTURE"\n',
            "fzf": """#!/bin/sh
printf '%s\n' "$*" >> "$FZF_LOG"
if [ "$FZF_CANCEL" = 1 ]; then exit 130; fi
/usr/bin/awk -v needle="$FZF_PICK" 'index($0, needle) { print; exit }'
""",
            "tmux": '#!/bin/sh\nprintf "%s\n" "$*" >> "$TMUX_LOG"\n',
        }
        for name, body in programs.items():
            executable = self.bin / name
            executable.write_text(body)
            executable.chmod(0o755)
        self.environment = os.environ.copy()
        self.environment.update(
            SOURCE=str(SOURCE),
            GHQ_FIXTURE=str(self.ghq),
            ZOXIDE_FIXTURE=str(self.zoxide),
            MUTATION_LOG=str(self.root / "mutations"),
            FZF_LOG=str(self.root / "fzf.log"),
            TMUX_LOG=str(self.root / "tmux.log"),
            FZF_PICK=str(self.unseen),
            TMUX="",
            XDG_CACHE_HOME=str(self.root / "cache"),
            XDG_DATA_HOME=str(self.root / "data"),
        )

    def run_zsh(self, code, *, missing=(), **environment):
        bin_dir = self.bin
        if missing:
            bin_dir = self.root / ("without-" + "-".join(missing))
            bin_dir.mkdir(exist_ok=True)
            for executable in self.bin.iterdir():
                if executable.name not in missing:
                    (bin_dir / executable.name).symlink_to(executable)
        env = self.environment.copy()
        env.update(environment)
        env["PATH"] = f"{bin_dir}:/usr/bin:/bin"
        return subprocess.run(
            [ZSH, "-f", "-c", 'source "$SOURCE"; ' + code],
            cwd=self.root,
            env=env,
            text=True,
            capture_output=True,
            check=False,
        )

    def test_boot_command_resolves_unseen_repo_without_picker(self):
        result = self.run_zsh(
            'z never-learned; rc=$?; print -r -- "$PWD"; exit $rc', FZF_CANCEL="1"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), str(self.unseen))
        self.assertFalse((self.root / "fzf.log").exists())
        self.assertFalse((self.root / "mutations").exists())
        self.assertFalse((self.root / "cache").exists())

    def test_exact_basename_wins_over_partial_match(self):
        result = self.run_zsh(
            'z repo; rc=$?; print -r -- "$PWD"; exit $rc', FZF_CANCEL="1"
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), str(self.exact))
        self.assertFalse((self.root / "fzf.log").exists())

    def test_learned_zoxide_match_keeps_precedence(self):
        result = self.run_zsh(
            'z repo; rc=$?; print -r -- "$PWD"; exit $rc',
            ZOXIDE_HIT=str(self.partial),
            FZF_CANCEL="1",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), str(self.partial))
        self.assertFalse((self.root / "fzf.log").exists())

    def test_ambiguous_and_absent_queries_cancel_without_moving(self):
        for query in ("shared", "absent"):
            with self.subTest(query=query):
                result = self.run_zsh(
                    'z "$QUERY"; rc=$?; print -r -- "$PWD"; exit $rc',
                    QUERY=query,
                    FZF_CANCEL="1",
                )
                self.assertEqual(result.returncode, 130, result.stderr)
                self.assertEqual(result.stdout.strip(), str(self.root))
        self.assertEqual(len((self.root / "fzf.log").read_text().splitlines()), 2)

    def test_scored_picker_deduplicates_and_omits_deleted_paths(self):
        result = self.run_zsh("__z_query_paths")
        self.assertEqual(result.returncode, 0, result.stderr)
        rows = result.stdout.splitlines()
        self.assertEqual(rows[:2], [f"10.5 {self.known}", f"4.2 {self.worktree}"])
        self.assertEqual(rows.count(f"0 {self.known}"), 0)
        self.assertIn(f"0 {self.unseen}", rows)
        self.assertNotIn(f"0 {self.root / 'deleted'}", rows)

    def test_zi_spaces_z_minus_and_missing_tools(self):
        result = self.run_zsh('zi; rc=$?; print -r -- "$PWD"; exit $rc')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), str(self.unseen))
        result = self.run_zsh(
            'cd "$FZF_PICK"; cd ..; z - >/dev/null; print -r -- "$PWD"'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), str(self.unseen))
        for missing in (("ghq",), ("zoxide",)):
            with self.subTest(missing=missing):
                result = self.run_zsh("__z_query_paths", missing=missing)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertTrue(result.stdout)

    def test_ctrl_g_quotes_worktree_and_renames_only_fake_tmux(self):
        result = self.run_zsh(
            'function zle() { [[ $1 == accept-line ]] && print -r -- "ACCEPT:$BUFFER"; }; '
            'BUFFER=branch; __zoxide_zi_widget; print -r -- "BUFFER:$BUFFER"',
            FZF_PICK=str(self.worktree),
            TMUX="fake,1,0",
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        quoted = str(self.worktree).replace(" ", "\\ ")
        self.assertIn(f"ACCEPT:cd {quoted}", result.stdout)
        self.assertIn(f"BUFFER:cd {quoted}", result.stdout)
        self.assertEqual(
            (self.root / "tmux.log").read_text().strip(),
            "rename-session known repo-branch-one",
        )


if __name__ == "__main__":
    unittest.main()
