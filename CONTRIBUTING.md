# CONTRIBUTING

## 1. Package Management

### 1.1. Overview

This repository uses nix as the source of truth for package versions.

```text
nix (source of truth)
└── flake.lock          # nixpkgs versions
```

### 1.3. Update Packages

```sh
# Update flake.lock (nixpkgs packages)
nix flake update
```

### 1.4. Adding a New Package

#### 1.4.1. nixpkgs Package

Add to `flake.nix` devShells section.

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

3. Get `hash` using nurl

   ```sh
   nurl https://github.com/<owner>/<repo> v<version>
   ```

   Copy the `hash` value from output:

   ```nix
   fetchFromGitHub {
     owner = "<owner>";
     repo = "<repo>";
     rev = "v<version>";
     hash = "sha256-XXX...";  # <- Copy this
   }
   ```

4. Update `hash` in nix file, then get `vendorHash`/`cargoHash`

   Stage and build to get vendor/cargo hash:

   ```sh
   git add nix/packages/<name>.nix flake.nix
   nix build '.#<name>' --no-link
   ```

   The build will fail with hash mismatch. Copy the "got" hash:

   ```text
   error: hash mismatch in fixed-output derivation:
            specified: sha256-AAA...
               got:    sha256-XXX...
   ```

   Update `vendorHash` (Go) or `cargoHash` (Rust) with this value

5. Verify build succeeds

   ```sh
   git add nix/packages/<name>.nix
   nix build '.#<name>' --no-link
   ```

6. Add to devShells if needed

#### 1.4.3. Run without installation

For rarely used tools, add only to `flake.nix` packages section.
You can run them without installation:

```sh
nix run '.#<name>' -- <args>
```
