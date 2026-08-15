# Waza CLI from upstream release binaries.
# TODO: Remove this custom package once Waza is available from nixpkgs.
{
  lib,
  stdenvNoCC,
  fetchurl,
  system,
}:
let
  version = "0.38.6";
  sources = {
    aarch64-darwin = {
      asset = "waza-darwin-arm64";
      hash = "sha256-FbFWwCL/X0ITo66Iras0WBVG1Xq30fxg7Cam/VcTGi8=";
    };
    aarch64-linux = {
      asset = "waza-linux-arm64";
      hash = "sha256-AwMPD7cQ5EnWavam/RHn3PGzIg7uYMXsdcnxkSos8dI=";
    };
    x86_64-linux = {
      asset = "waza-linux-amd64";
      hash = "sha256-p5lYd5X9RiQRynx69frM7n4k8I5B0VLBBzjTEzTRwGM=";
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
