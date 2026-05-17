# Nix Package Workflow

Use this reference for general Nix package workflow guidance. Agent runtime,
Home Manager agent config, hooks, and installed outputs belong to
`agent-harness-engineering`.

## Fetcher Hashes

Use `nurl` when acquiring a Nix fetcher call from a repository URL.

```sh
nix run 'nixpkgs#nurl' -- https://github.com/rvben/rumdl v0.0.206
```

The output can be adapted directly into `fetchFromGitHub`.

```nix
fetchFromGitHub {
  owner = "rvben";
  repo = "rumdl";
  rev = "v0.0.206";
  hash = "sha256-XXX...";
}
```

For `cargoHash` or `vendorHash`, use the normal build-error hash replacement
flow; `nurl` does not provide those hashes.

## Verification

- `nix run nixpkgs#statix -- check <file>`
- `nix flake check` when the change touches shared Nix modules or build graph
  behavior.
