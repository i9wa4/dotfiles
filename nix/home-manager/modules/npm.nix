# npm global packages (managed via activation scripts)
# Installs/updates npm packages on home-manager switch
{
  pkgs,
  lib,
  username,
  nodejsPackage,
  ...
}:
let
  homeDir = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
  nodejs = nodejsPackage;
  npm = "${nodejs}/bin/npm";
  npmMinReleaseAgeDays = 3;
  npmPrefix = "${homeDir}/.local";
in
{
  home.activation = {
    # 0. Clean temporary files (node caches for security)
    cleanTemporaryFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "Cleaning temporary files..."
      # Node.js caches
      rm -rf "${homeDir}/.npm"
    '';

    # 1. Install/update safe-chain first (security scanner for npm)
    setupSafeChain = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${npmPrefix}
      export PATH="${npmPrefix}/bin:${nodejs}/bin:$PATH"
      if ! ${npm} --prefix ${npmPrefix} list -g --depth=0 @aikidosec/safe-chain >/dev/null 2>&1; then
        echo "Installing @aikidosec/safe-chain..."
        ${npm} --prefix ${npmPrefix} --min-release-age=${toString npmMinReleaseAgeDays} install -g @aikidosec/safe-chain
        safe-chain setup
      else
        echo "Updating @aikidosec/safe-chain..."
        ${npm} --prefix ${npmPrefix} --min-release-age=${toString npmMinReleaseAgeDays} update -g @aikidosec/safe-chain
      fi
    '';

    # 2. Install/update npm packages (after safe-chain, so they get scanned)
    installNpmPackages = lib.hm.dag.entryAfter [ "setupSafeChain" ] ''
      export PATH="${npmPrefix}/bin:${nodejs}/bin:$PATH"
      # safe-chain setup wires shell aliases for interactive shells, but this
      # activation script calls package-manager commands directly. Use the
      # explicit wrapper binary so the guarded path is active in practice.
      guardedNpm="${npmPrefix}/bin/aikido-npm"
      NPM_PACKAGES=(
        "freee-mcp"
        "vde-layout"
        "vde-monitor"
        "vde-tmux-manager"
        "vde-worktree"
      )

      # Install missing packages
      for pkg in "''${NPM_PACKAGES[@]}"; do
        if ! "$guardedNpm" --prefix ${npmPrefix} list -g --depth=0 "$pkg" >/dev/null 2>&1; then
          echo "Installing $pkg..."
          "$guardedNpm" --prefix ${npmPrefix} --min-release-age=${toString npmMinReleaseAgeDays} install -g "$pkg"
        fi
      done

      # Update outdated packages in one batch
      outdatedJson=$("$guardedNpm" --prefix ${npmPrefix} outdated -g --json --depth=0 2>/dev/null |
        ${pkgs.gawk}/bin/awk '
          /^[[:space:]]*{/ && !capturing {
            capturing = 1
          }
          capturing {
            print
            line = $0
            opens = gsub(/\{/, "{", line)
            closes = gsub(/\}/, "}", line)
            depth += opens - closes
            if (depth == 0) {
              exit
            }
          }
        ' || true)
      outdated=""
      if [ -n "$outdatedJson" ]; then
        outdated=$(printf '%s\n' "$outdatedJson" | ${pkgs.jq}/bin/jq -r 'keys[]?' || true)
      fi
      if [ -n "$outdated" ]; then
        echo "Updating outdated packages:"
        printf '%s\n' "$outdated"
        printf '%s\n' "$outdated" | xargs "$guardedNpm" --prefix ${npmPrefix} --min-release-age=${toString npmMinReleaseAgeDays} install -g
      fi

      # Remove unlisted packages (keep npm, corepack, safe-chain)
      # --parseable gives paths like .../node_modules/pkg or .../node_modules/@scope/pkg
      # Extract package name by stripping the node_modules prefix
      node_modules="${npmPrefix}/lib/node_modules"
      installed=$("$guardedNpm" --prefix ${npmPrefix} list -g --depth=0 --parseable 2>/dev/null | tail -n +2 || true)
      for pkg_path in $installed; do
        pkg="''${pkg_path#"$node_modules"/}"
        case "$pkg" in
          npm|corepack|@aikidosec/*) continue ;;
        esac
        found=0
        for want in "''${NPM_PACKAGES[@]}"; do
          if [ "$pkg" = "$want" ]; then found=1; break; fi
        done
        if [ "$found" = "0" ]; then
          echo "Removing unlisted package: $pkg"
          "$guardedNpm" --prefix ${npmPrefix} uninstall -g "$pkg"
        fi
      done
    '';
  };
}
