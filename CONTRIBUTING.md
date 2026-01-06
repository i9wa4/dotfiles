# CONTRIBUTING

## 1. Package Management

### 1.1. Overview

This repository uses nix as the source of truth for package versions.

```text
nix (source of truth)
├── flake.lock          # nixpkgs versions
└── nix/packages/*.nix  # custom package versions
        ↓ sync
    mise.toml           # for CI (GitHub Actions)
```

Environment separation:

| Environment | Tool Provider |
|-------------|---------------|
| Local | devShell (auto-activated by direnv) |
| CI | mise.toml (`mise install`) |

### 1.2. Check for Updates

```sh
uv run python bin/nix-update-check.py
```

### 1.3. Update All Packages

```sh
uv run python bin/nix-update-all.py
```

This command:

1. Runs `nix flake update` (updates flake.lock)
2. Runs `nix-update` for custom packages (updates nix/packages/*.nix)
3. Syncs versions to mise.toml

### 1.4. Adding a New Package

#### 1.4.1. nixpkgs Package

1. Add to `flake.nix` devShells.ciPackages
2. Add to `mise.toml`

The nix attribute is auto-inferred from mise key
(e.g., `aqua:owner/Repo` -> `repo`).

#### 1.4.2. Custom Package (not in nixpkgs)

1. Create `nix/packages/<name>.nix` with empty hashes

   Go package:

   ```nix
   {
     buildGoModule,
     fetchFromGitHub,
   }:
   buildGoModule rec {
     pname = "<name>";
     version = "<version>";

     src = fetchFromGitHub {
       owner = "<owner>";
       repo = "<repo>";
       rev = "v${version}";
       hash = "";
     };

     vendorHash = "";

     meta = {
       description = "<description>";
       homepage = "https://github.com/<owner>/<repo>";
     };
   }
   ```

   Rust package:

   ```nix
   {
     rustPlatform,
     fetchFromGitHub,
   }:
   rustPlatform.buildRustPackage rec {
     pname = "<name>";
     version = "<version>";

     src = fetchFromGitHub {
       owner = "<owner>";
       repo = "<repo>";
       rev = "v${version}";
       hash = "";
     };

     cargoHash = "";

     meta = {
       description = "<description>";
       homepage = "https://github.com/<owner>/<repo>";
     };
   }
   ```

2. Add to `flake.nix` packages section

   ```nix
   packages = forAllSystems (system: let
     pkgs = nixpkgs.legacyPackages.${system};
   in {
     # ... existing packages ...
     <name> = pkgs.callPackage ./nix/packages/<name>.nix {};
   });
   ```

3. Stage and build to get hashes

   ```sh
   git add nix/packages/<name>.nix flake.nix
   nix build '.#<name>' --no-link
   ```

   The build will fail with hash mismatch errors. Copy the "got" hash:

   ```text
   error: hash mismatch in fixed-output derivation:
            specified: sha256-AAA...
               got:    sha256-XXX...
   ```

4. Update `hash` in nix file, rebuild,
   then update `vendorHash` (Go) or `cargoHash` (Rust)

5. Verify build succeeds

   ```sh
   git add nix/packages/<name>.nix
   nix build '.#<name>' --no-link
   ```

6. Add to devShells if needed (CI tools)

7. Add to `mise.toml` with `aqua:<owner>/<repo>` key

8. Custom packages are auto-detected from `nix/packages/*.nix`
   by `bin/nix_packages.py`

#### 1.4.3. Custom Package (packages only, no mise)

For rarely used tools, add only to `flake.nix` packages section.
You can run them without installation:

```sh
nix run '.#<name>' -- <args>
```
