#!/bin/bash
# Update custom nix packages (not in nixpkgs)
# Usage: bash bin/update-nix-packages.sh

set -euo pipefail

PACKAGES=(
  ghalint
  ghatm
  pinact
)

for pkg in "${PACKAGES[@]}"; do
  echo "Updating ${pkg}..."
  nix run nixpkgs#nix-update -- --flake "$pkg"
done

echo "Done. Review changes with: git diff nix/packages/"
