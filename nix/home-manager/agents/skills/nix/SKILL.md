---
name: nix
description: |
  Nix commands and package management guide.
  Use when:
  - Using nurl for hash acquisition
---

# Nix Skill

## 1. nurl

- IMPORTANT: nurl generates Nix fetcher calls from repository URLs

  ```sh
  nix run 'nixpkgs#nurl' -- https://github.com/rvben/rumdl v0.0.206
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
