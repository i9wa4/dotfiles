#!/usr/bin/env bash
set -euo pipefail

repo="${ACTRUN_REPO:-mizchi/actrun}"
target="${ACTRUN_NIX_FILE:-nix/packages/actrun.nix}"
gh_bin="${ACTRUN_GH:-gh}"
nix_bin="${ACTRUN_NIX:-nix}"
jq_bin="${ACTRUN_JQ:-jq}"

release_json="$("$gh_bin" release view --repo "$repo" --json tagName,assets)"
tag="$("$jq_bin" -r .tagName <<<"$release_json")"
version="${tag#v}"

hash_for() {
  local asset="$1"
  local digest hex
  # shellcheck disable=SC2016 # jq receives $asset via --arg.
  digest="$("$jq_bin" -r --arg asset "$asset" '.assets[] | select(.name == $asset) | .digest // empty' <<<"$release_json")"
  if [[ -z $digest ]]; then
    echo "actrun-nix-update: digest for $asset not found in $repo $tag" >&2
    return 1
  fi
  hex="${digest#sha256:}"
  if [[ $hex == "$digest" || -z $hex ]]; then
    echo "actrun-nix-update: unsupported digest for $asset: $digest" >&2
    return 1
  fi
  "$nix_bin" hash convert --hash-algo sha256 --from base16 --to sri "$hex"
}

darwin_arm64_hash="$(hash_for actrun-macos-arm64.tar.gz)"
linux_x64_hash="$(hash_for actrun-linux-x64.tar.gz)"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
generated="$tmp_dir/actrun.nix"

cat >"$generated" <<EOF
# actrun from upstream release binaries.
# TODO: Remove this custom package once actrun is available from nixpkgs.
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  system,
}:
let
  version = "$version";
  sources = {
    aarch64-darwin = {
      asset = "actrun-macos-arm64.tar.gz";
      hash = "$darwin_arm64_hash";
    };
    x86_64-linux = {
      asset = "actrun-linux-x64.tar.gz";
      hash = "$linux_x64_hash";
    };
  };
  source = sources.\${system} or (throw "actrun: unsupported system \${system}");
in
stdenvNoCC.mkDerivation {
  pname = "actrun";
  inherit version;

  src = fetchurl {
    url = "https://github.com/mizchi/actrun/releases/download/v\${version}/\${source.asset}";
    inherit (source) hash;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  unpackPhase = ''
    runHook preUnpack
    tar xzf "\$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 actrun "\$out/bin/actrun"
    runHook postInstall
  '';

  meta = {
    description = "Run GitHub Actions locally";
    homepage = "https://github.com/mizchi/actrun";
    license = lib.licenses.mit;
    mainProgram = "actrun";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
EOF

mkdir -p "$(dirname "$target")"
if [[ -f $target ]] && cmp -s "$generated" "$target"; then
  echo "actrun.nix already at $tag"
else
  install -m 0644 "$generated" "$target"
  echo "updated $target to $tag"
fi
