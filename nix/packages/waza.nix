# Waza CLI from upstream release binaries.
# TODO: Remove this custom package once Waza is available from nixpkgs.
{
  lib,
  stdenvNoCC,
  fetchurl,
  system,
}:
let
  version = "0.41.0";
  sources = {
    aarch64-darwin = {
      asset = "waza-darwin-arm64";
      hash = "sha256-jqI49tU5wjphFs1ZcQB180H/swXFZ0w0y055mNNFmr0=";
    };
    aarch64-linux = {
      asset = "waza-linux-arm64";
      hash = "sha256-pkN/RofXDzs/1DhjnUs8dU3EeOaSdnq9Ome6qHNPBIc=";
    };
    x86_64-linux = {
      asset = "waza-linux-amd64";
      hash = "sha256-nHOX2NKBJ9fJnsatH6tzDL1DgXSjlgr7yCw6YNrMy3Q=";
    };
  };
  source = sources.${system} or (throw "waza: unsupported system ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "waza";
  inherit version;

  src = fetchurl {
    url = "https://github.com/microsoft/waza/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/waza"
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
