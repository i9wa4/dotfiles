# pnpm global packages (managed via activation scripts)
# Installs/updates pnpm packages on home-manager switch
{
  pkgs,
  lib,
  homeDir,
  nodejsPackage,
  ...
}:
let
  nodejs = nodejsPackage;
  # npm is retained only to clean packages previously managed under the old
  # npm prefix.
  npm = "${nodejs}/bin/npm";
  pnpm = "${pkgs.pnpm}/bin/pnpm";
  pnpmMinimumReleaseAgeHours = 3 * 24;
  pnpmMinimumReleaseAgeMinutes = pnpmMinimumReleaseAgeHours * 60;
  pnpmHome = "${homeDir}/.local/share/pnpm";
  pnpmBin = "${homeDir}/.local/bin";
  pnpmGlobalDir = "${pnpmHome}/global";
  pnpmStoreDir = "${pnpmHome}/store";
  legacyNpmPrefix = "${homeDir}/.local";
in
{
  home.activation = {
    # 0. Clean temporary files (node package-manager caches)
    cleanTemporaryFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "Cleaning temporary files..."
      rm -rf "${homeDir}/.npm"
      rm -rf "${homeDir}/.cache/pnpm"
    '';

    # 1. Install/update pnpm packages.
    installPnpmPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${pnpmBin} ${pnpmGlobalDir} ${pnpmStoreDir}
      export PNPM_HOME="${pnpmHome}"
      export PATH="${pnpmBin}:${pkgs.pnpm}/bin:${nodejs}/bin:$PATH"

      ${pnpm} config set --location=global globalBinDir "${pnpmBin}" >/dev/null
      ${pnpm} config set --location=global globalDir "${pnpmGlobalDir}" >/dev/null
      ${pnpm} config set --location=global storeDir "${pnpmStoreDir}" >/dev/null
      ${pnpm} config set --location=global minimumReleaseAge ${toString pnpmMinimumReleaseAgeMinutes} >/dev/null

      pnpmPackageInstalled() {
        ${pnpm} list -g --depth=0 --json 2>/dev/null |
          ${pkgs.jq}/bin/jq -e --arg pkg "$1" '
            if type == "array" then
              (.[0].dependencies // {})
            else
              (.dependencies // {})
            end | has($pkg)
          ' >/dev/null
      }

      pnpmPackageReady() {
        pnpmPackageInstalled "$1" || return 1
        case "$1" in
          "ctx7")
            [ -x "${pnpmBin}/ctx7" ]
            ;;
          "vde-layout")
            [ -x "${pnpmBin}/vde-layout" ]
            ;;
          "vde-monitor")
            [ -x "${pnpmBin}/vde-monitor" ] &&
              [ -x "${pnpmBin}/vde-monitor-hook" ]
            ;;
          *)
            return 0
            ;;
        esac
      }

      removeLegacyNpmPackageDir() {
        pkg="$1"
        pkgDir="${legacyNpmPrefix}/lib/node_modules/$pkg"
        if [ -e "$pkgDir" ] || [ -L "$pkgDir" ]; then
          echo "Removing legacy npm package residue $pkg..."
          rm -rf "$pkgDir"
        fi
        case "$pkg" in
          @*/*)
            scope="''${pkg%%/*}"
            rmdir "${legacyNpmPrefix}/lib/node_modules/$scope" 2>/dev/null || true
            ;;
        esac
      }

      removeLegacyNpmShim() {
        shim="${pnpmBin}/$1"
        if [ -L "$shim" ]; then
          target=$(readlink "$shim" || true)
          case "$target" in
            "${legacyNpmPrefix}/lib/node_modules/"* | ../lib/node_modules/*)
              echo "Removing legacy npm shim $1..."
              rm -f "$shim"
              ;;
          esac
        elif [ -f "$shim" ] &&
          { grep -Fq "${legacyNpmPrefix}/lib/node_modules" "$shim" ||
            grep -Fq "../lib/node_modules" "$shim"; }; then
          echo "Removing legacy npm shim $1..."
          rm -f "$shim"
        fi
      }

      SAFE_CHAIN_PACKAGE="@aikidosec/safe-chain"
      PNPM_PACKAGES=(
        "ctx7"
        "vde-layout"
        "vde-monitor"
      )
      RETAINED_PNPM_PACKAGES=(
        "$SAFE_CHAIN_PACKAGE"
        "''${PNPM_PACKAGES[@]}"
      )

      LEGACY_NPM_PACKAGES=(
        "$SAFE_CHAIN_PACKAGE"
        "''${PNPM_PACKAGES[@]}"
      )
      LEGACY_NPM_SHIMS=(
        "aikido-bun"
        "aikido-bunx"
        "aikido-npm"
        "aikido-npx"
        "aikido-pip"
        "aikido-pip3"
        "aikido-pipx"
        "aikido-pnpm"
        "aikido-pnpx"
        "aikido-poetry"
        "aikido-python"
        "aikido-python3"
        "aikido-uv"
        "aikido-uvx"
        "aikido-yarn"
        "ctx7"
        "safe-chain"
        "vde-layout"
        "vde-monitor"
        "vde-monitor-hook"
      )
      for pkg in "''${LEGACY_NPM_PACKAGES[@]}"; do
        if ${npm} --prefix ${legacyNpmPrefix} list -g --depth=0 "$pkg" >/dev/null 2>&1; then
          echo "Removing legacy npm-managed package $pkg..."
          ${npm} --prefix ${legacyNpmPrefix} uninstall -g "$pkg" >/dev/null 2>&1 || true
        fi
        removeLegacyNpmPackageDir "$pkg"
      done
      for shim in "''${LEGACY_NPM_SHIMS[@]}"; do
        removeLegacyNpmShim "$shim"
      done
      rmdir "${legacyNpmPrefix}/lib/node_modules" 2>/dev/null || true
      rmdir "${legacyNpmPrefix}/lib" 2>/dev/null || true

      # Install/update Safe Chain first, then use its explicit pnpm wrapper for
      # package-changing operations in this non-interactive activation script.
      if pnpmPackageInstalled "$SAFE_CHAIN_PACKAGE"; then
        safeChainWasInstalled=1
      else
        safeChainWasInstalled=0
      fi
      echo "Installing/updating $SAFE_CHAIN_PACKAGE..."
      ${pnpm} add -g "$SAFE_CHAIN_PACKAGE"
      safeChain="${pnpmBin}/safe-chain"
      if [ ! -x "$safeChain" ]; then
        echo "Expected $safeChain after installing $SAFE_CHAIN_PACKAGE" >&2
        exit 1
      fi
      if [ "$safeChainWasInstalled" -eq 0 ] || [ ! -f "${homeDir}/.safe-chain/scripts/init-posix.sh" ]; then
        "$safeChain" setup
      fi
      guardedPnpm="${pnpmBin}/aikido-pnpm"
      if [ ! -x "$guardedPnpm" ]; then
        echo "Expected $guardedPnpm after installing $SAFE_CHAIN_PACKAGE" >&2
        exit 1
      fi
      export SAFE_CHAIN_LOGGING=silent
      export SAFE_CHAIN_MINIMUM_PACKAGE_AGE_HOURS=${toString pnpmMinimumReleaseAgeHours}

      installedJson=$(${pnpm} list -g --depth=0 --json 2>/dev/null || true)
      installedPackages=""
      if [ -n "$installedJson" ]; then
        installedPackages=$(printf '%s\n' "$installedJson" |
          ${pkgs.jq}/bin/jq -r '
            if type == "array" then
              (.[0].dependencies // {})
            else
              (.dependencies // {})
            end | keys[]?
          ' || true)
      fi
      for pkg in $installedPackages; do
        keep=0
        for want in "''${RETAINED_PNPM_PACKAGES[@]}"; do
          if [ "$pkg" = "$want" ]; then
            keep=1
            break
          fi
        done
        if [ "$keep" -eq 0 ]; then
          echo "Uninstalling unmanaged pnpm package $pkg..."
          ${pnpm} remove -g "$pkg"
        fi
      done

      missingPackages=()
      for pkg in "''${PNPM_PACKAGES[@]}"; do
        if ! pnpmPackageReady "$pkg"; then
          echo "Installing $pkg..."
          missingPackages+=("$pkg")
        fi
      done
      if [ "''${#missingPackages[@]}" -gt 0 ]; then
        "$guardedPnpm" add -g "''${missingPackages[@]}"
      fi

      # Update only repo-managed packages; the pnpm global directory may
      # contain user-managed globals too.
      outdatedJson=$(${pnpm} outdated -g --format json 2>/dev/null || true)
      outdated=""
      if [ -n "$outdatedJson" ]; then
        outdated=$(printf '%s\n' "$outdatedJson" |
          ${pkgs.jq}/bin/jq -r '
            if type == "array" then
              .[] | .name? // .packageName? // empty
            else
              keys[]?
            end
          ' || true)
      fi
      managedOutdatedPackages=()
      for pkg in $outdated; do
        for want in "''${PNPM_PACKAGES[@]}"; do
          if [ "$pkg" = "$want" ]; then
            managedOutdatedPackages+=("$pkg")
            break
          fi
        done
      done
      if [ "''${#managedOutdatedPackages[@]}" -gt 0 ]; then
        echo "Updating outdated packages:"
        printf '%s\n' "''${managedOutdatedPackages[@]}"
        "$guardedPnpm" add -g "''${managedOutdatedPackages[@]}"
      else
        echo "No managed pnpm package updates needed."
      fi
    '';
  };
}
