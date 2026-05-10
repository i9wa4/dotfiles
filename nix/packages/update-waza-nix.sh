#!/usr/bin/env bash
set -euo pipefail

repo="${WAZA_REPO:-microsoft/waza}"
target="${WAZA_NIX_FILE:-nix/packages/waza.nix}"
gh_bin="${WAZA_GH:-gh}"
nix_bin="${WAZA_NIX:-nix}"

tag="$("$gh_bin" release view --repo "$repo" --json tagName --jq .tagName)"
version="${tag#v}"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

"$gh_bin" release download --repo "$repo" "$tag" -p checksums.txt -D "$tmp_dir" --clobber >/dev/null
checksums="$tmp_dir/checksums.txt"

hash_for() {
  local asset="$1"
  local hex
  hex="$(awk -v asset="$asset" '$2 == asset { print $1 }' "$checksums")"
  if [[ -z $hex ]]; then
    echo "update-waza-nix: checksum for $asset not found in $repo $tag" >&2
    return 1
  fi
  "$nix_bin" hash convert --hash-algo sha256 --from base16 --to sri "$hex"
}

darwin_arm64_hash="$(hash_for waza-darwin-arm64)"
linux_amd64_hash="$(hash_for waza-linux-amd64)"
linux_arm64_hash="$(hash_for waza-linux-arm64)"

generated="$tmp_dir/waza.nix"
cat >"$generated" <<EOF
# Waza CLI from upstream release binaries.
# TODO: Remove this custom package once Waza is available from nixpkgs.
{
  lib,
  stdenvNoCC,
  fetchurl,
  system,
}:
let
  version = "$version";
  sources = {
    aarch64-darwin = {
      asset = "waza-darwin-arm64";
      hash = "$darwin_arm64_hash";
    };
    aarch64-linux = {
      asset = "waza-linux-arm64";
      hash = "$linux_arm64_hash";
    };
    x86_64-linux = {
      asset = "waza-linux-amd64";
      hash = "$linux_amd64_hash";
    };
  };
  source = sources.\${system} or (throw "waza: unsupported system \${system}");
in
stdenvNoCC.mkDerivation {
  pname = "waza";
  inherit version;

  src = fetchurl {
    url = "https://github.com/microsoft/waza/releases/download/v\${version}/\${source.asset}";
    inherit (source) hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "\$src" "\$out/bin/waza"
    runHook postInstall
  '';

  meta = {
    description = "CLI / Framework for Agent Skills";
    homepage = "https://github.com/microsoft/waza";
    license = lib.licenses.mit;
    mainProgram = "waza";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
EOF

mkdir -p "$(dirname "$target")"
if [[ -f $target ]] && cmp -s "$generated" "$target"; then
  echo "waza.nix already at $tag"
else
  install -m 0644 "$generated" "$target"
  echo "updated $target to $tag"
fi
