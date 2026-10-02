# Waza CLI from upstream release binaries.
# TODO: Remove this custom package once Waza is available from nixpkgs.
{
  lib,
  stdenvNoCC,
  fetchurl,
  system,
}:
let
  version = "0.38.8";
  sources = {
    aarch64-darwin = {
      asset = "waza-darwin-arm64";
      hash = "sha256-9PNvvf3WC218G9VVslpsbTNIXlf9+OZ8HGWoJABiJgE=";
    };
    aarch64-linux = {
      asset = "waza-linux-arm64";
      hash = "sha256-JyEme1nbymgudU4OStOSRz5zQdvb1kV47xvum1Laoxs=";
    };
    x86_64-linux = {
      asset = "waza-linux-amd64";
      hash = "sha256-G8mIbPIlTlDPqyK8G8x6zZcV5p4MIFfAQHnJW49oEy4=";
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
