#!/usr/bin/env bash
set -euo pipefail

# Copy config files for Windows (WSL only)

GITHUB_DIR="$(ghq root)/github.com"
WIN_UTIL_DIR="/mnt/c/work/util"

# WSL2
cat <<'EOF' | sudo tee /etc/wsl.conf
[boot]
systemd=true

[interop]
appendWindowsPath=true
EOF

# Windows
mkdir -p "${WIN_UTIL_DIR}/etc"
cat <<'EOF' | tee "${WIN_UTIL_DIR}/etc/dot.wslconfig"
[wsl2]
localhostForwarding=true
processors=2
swap=0

[experimental]
autoMemoryReclaim=gradual
EOF

rm -rf "${WIN_UTIL_DIR}"
cp -rf "${GITHUB_DIR}/i9wa4/dotfiles/bin" "${WIN_UTIL_DIR}"
