# Nix Rules

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

- YOU MUST: See README.md section 7.4.2 for adding new custom packages
- IMPORTANT: Hash acquisition flow
    1. Create .nix file with empty hash (`hash = "";`)
    2. Run `git add` then `nix build --no-link`
    3. Copy hash from error message `got:`
    4. For Go use `vendorHash`, for Rust use `cargoHash` similarly
- IMPORTANT: Add `doCheck = false;` if tests fail
