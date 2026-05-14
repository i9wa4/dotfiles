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
  pnpmMinimumReleaseAgeMinutes = 3 * 24 * 60;
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
      export PATH="${pnpmBin}:${nodejs}/bin:$PATH"

      ${pnpm} config set --location=global globalBinDir "${pnpmBin}" >/dev/null
      ${pnpm} config set --location=global globalDir "${pnpmGlobalDir}" >/dev/null
      ${pnpm} config set --location=global storeDir "${pnpmStoreDir}" >/dev/null
      ${pnpm} config set --location=global minimumReleaseAge ${toString pnpmMinimumReleaseAgeMinutes} >/dev/null

      PNPM_PACKAGES=(
        "ctx7"
        "vde-layout"
        "vde-monitor"
      )

      LEGACY_NPM_PACKAGES=(
        "@aikidosec/safe-chain"
        "''${PNPM_PACKAGES[@]}"
      )
      for pkg in "''${LEGACY_NPM_PACKAGES[@]}"; do
        if ${npm} --prefix ${legacyNpmPrefix} list -g --depth=0 "$pkg" >/dev/null 2>&1; then
          echo "Removing legacy npm-managed package $pkg..."
          ${npm} --prefix ${legacyNpmPrefix} uninstall -g "$pkg" >/dev/null 2>&1 || true
        fi
      done

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
        for want in "''${PNPM_PACKAGES[@]}"; do
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
        if ! ${pnpm} list -g --depth=0 "$pkg" >/dev/null 2>&1; then
          echo "Installing $pkg..."
          missingPackages+=("$pkg")
        fi
      done
      if [ "''${#missingPackages[@]}" -gt 0 ]; then
        ${pnpm} add -g "''${missingPackages[@]}"
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
        ${pnpm} add -g "''${managedOutdatedPackages[@]}"
      else
        echo "No managed pnpm package updates needed."
      fi
    '';
  };
}
