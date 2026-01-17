---
name: nix
description: |
  Nix commands and package management guide.
  Use when:
  - Running nix build, nix run
  - Adding custom packages
  - Using nurl for hash acquisition
---

# Nix Skill

## 1. nix build

- YOU MUST: Always use `--no-link` option with `nix build`

    ```sh
    nix build .#rumdl --no-link
    ```

- IMPORTANT: Without `--no-link`, a `./result` symlink is created

## 2. nix run

- IMPORTANT: Packages registered in packages can be run with `nix run`

    ```sh
    nix run .#pike -- scan -d ./terraform
    ```

## 3. Adding Custom Packages

- YOU MUST: See CONTRIBUTING.md section 1.4.2 for adding new custom packages
- IMPORTANT: Hash acquisition flow
    1. Get `hash` using nurl: `nurl https://github.com/<owner>/<repo> <tag>`
    2. Get `vendorHash`/`cargoHash` via build error (`got:` line)
- IMPORTANT: Add `doCheck = false;` if tests fail

## 4. nurl

- IMPORTANT: nurl generates Nix fetcher calls from repository URLs

    ```sh
    nurl https://github.com/rvben/rumdl v0.0.206
    ```

- IMPORTANT: Output can be used directly in fetchFromGitHub

    ```nix
    fetchFromGitHub {
      owner = "rvben";
      repo = "rumdl";
      rev = "v0.0.206";
      hash = "sha256-XXX...";
    }
    ```

- IMPORTANT: For cargoHash/vendorHash, use build error method
  (nurl does not support these)
