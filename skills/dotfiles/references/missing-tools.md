# Missing Tools

Use this workflow when a command is unavailable in the current shell
(`command not found`). Adapted from
<https://github.com/ryoppippi/dotfiles/blob/main/agents/skills/missing-tools/SKILL.md>
for this repo's Nix + direnv + zsh environment.

## 1. Priority Order

1. Try the current project's direnv environment first. Project dev shells
   often already provide the right tool version and environment variables:

   ```sh
   direnv exec . <command>
   ```

2. Use [comma](https://github.com/nix-community/comma) for one-off runs of
   tools from nixpkgs. Comma finds and runs the nixpkgs package containing
   the requested command:

   ```sh
   , <command>
   ```

3. Use `nix run` when a specific nixpkgs package is needed:

   ```sh
   nix run nixpkgs#<package> -- <args>
   ```

4. Use `nix shell` as the last resort, for multi-command sessions:

   ```sh
   nix shell nixpkgs#<package> --command <command>
   ```

## 2. Rules

- Never install missing tools globally. Do not resolve a missing command
  with `npm install -g`, `pnpm add -g`, `yarn global add`, `bun add -g`,
  `uv tool install`, `pip install --user`, `brew install`, or any other
  global installer.
- If a tool is needed permanently, add it declaratively to the Home Manager
  configuration under `nix/home-manager/` and run `nix run '.#switch'`
  instead of installing it imperatively.
- This repo's interactive environment is zsh managed by Home Manager; when a
  command works in a login shell but not in the agent shell, retry with:

  ```sh
  zsh -lc '<simple command>'
  ```
