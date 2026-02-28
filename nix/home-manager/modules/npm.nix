# npm global packages (managed via activation scripts)
# Installs/updates npm packages on home-manager switch
{
  pkgs,
  lib,
  username,
  ...
}:
let
  homeDir = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
  npm = "${pkgs.nodejs}/bin/npm";
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
      export PATH="${npmPrefix}/bin:${pkgs.nodejs}/bin:$PATH"
      if ! ${npm} --prefix ${npmPrefix} list -g --depth=0 @aikidosec/safe-chain >/dev/null 2>&1; then
        echo "Installing @aikidosec/safe-chain..."
        ${npm} --prefix ${npmPrefix} install -g @aikidosec/safe-chain
        safe-chain setup
      else
        echo "Updating @aikidosec/safe-chain..."
        ${npm} --prefix ${npmPrefix} update -g @aikidosec/safe-chain
      fi
    '';

    # 2. Install/update npm packages (after safe-chain, so they get scanned)
    installNpmPackages = lib.hm.dag.entryAfter [ "setupSafeChain" ] ''
      export PATH="${npmPrefix}/bin:${pkgs.nodejs}/bin:$PATH"
      NPM_PACKAGES=(
        "vde-layout"
        "vde-monitor"
        "vde-worktree"
      )

      # Install missing packages
      for pkg in "''${NPM_PACKAGES[@]}"; do
        if ! ${npm} --prefix ${npmPrefix} list -g --depth=0 "$pkg" >/dev/null 2>&1; then
          echo "Installing $pkg..."
          ${npm} --prefix ${npmPrefix} install -g "$pkg"
        fi
      done

      # Update outdated packages in one batch
      outdated=$(${npm} --prefix ${npmPrefix} outdated -g --parseable --depth=0 2>/dev/null | cut -d: -f4 || true)
      if [ -n "$outdated" ]; then
        echo "Updating outdated packages: $outdated"
        echo "$outdated" | xargs ${npm} --prefix ${npmPrefix} install -g
      fi

      # Remove unlisted packages (keep npm, corepack, safe-chain)
      # --parseable gives paths like .../node_modules/pkg or .../node_modules/@scope/pkg
      # Extract package name by stripping the node_modules prefix
      node_modules="${npmPrefix}/lib/node_modules"
      installed=$(${npm} --prefix ${npmPrefix} list -g --depth=0 --parseable 2>/dev/null | tail -n +2 || true)
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
          ${npm} --prefix ${npmPrefix} uninstall -g "$pkg"
        fi
      done
    '';
  };
}
