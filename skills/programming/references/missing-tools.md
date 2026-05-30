# Missing Tools

Use this reference when a command needed for repo work is unavailable in the
current shell. This is recovery guidance for command-not-found situations, not
authorization or hook-denial recovery.

## First Distinguish the Failure

- Missing command: errors such as `command not found`, `No such file or
  directory`, or a tool binary that is absent from `PATH`.
- Denied command: hook, permission, sandbox, or policy messages. Stop and report
  the denied operation instead of trying alternate spellings or shells.
- Repeated repo need: if the same tool is needed permanently, propose a
  declarative Nix or Home Manager change instead of a global install.

## Fallback Order

1. Prefer the current checkout's environment. Use the issue helper or repo
   wrapper that already ran `repo-setup`; otherwise verify direnv/dev-shell
   state before rerunning the command.
2. Use `comma` when the missing executable is discoverable through nixpkgs.
3. Use `nix run nixpkgs#<package> -- <args>` when the package name is known and
   the command is a one-shot package entry point.
4. Use `nix shell nixpkgs#<package> --command <command> <args>` when a temporary
   shell environment is needed.
5. If the package is unknown, search nixpkgs or use `comma` for the executable
   name before considering broader changes.

## Examples

```sh
, mmdc --version
```

```sh
nix run nixpkgs#rumdl -- check docs/example.md
```

```sh
nix shell nixpkgs#vale --command vale --config ~/.vale.ini docs/example.md
```

## Boundaries

- Do not use `npm install -g`, `pip install --user`, `brew install`, `apt
  install`, or similar global installs for agent recovery.
- Human setup documents may still ask a user to install prerequisites such as
  Homebrew itself; that is separate from missing-command recovery during a repo
  task.
- Do not change runtime hooks, denied-command lists, Nix modules, or generated
  installed skill output as part of command recovery unless the assigned task
  explicitly asks for that implementation work.

## Evidence to Report

- The original missing command and exact error class.
- The fallback path used: repo environment, `comma`, `nix run`, or `nix shell`.
- Any persistent gap that should become a future declarative package change.
