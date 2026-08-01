# Waza CLI from upstream release binaries.
# TODO: Remove this custom package once Waza is available from nixpkgs.
{
  lib,
  stdenvNoCC,
  fetchurl,
  system,
}:
let
  version = "0.38.4";
  sources = {
    aarch64-darwin = {
      asset = "waza-darwin-arm64";
      hash = "sha256-s18FlqjuN6E6vPc9yR9N7hoaoJGbP0INfSeoaHxJxNc=";
    };
    aarch64-linux = {
      asset = "waza-linux-arm64";
      hash = "sha256-CjxPq8u3hnbBC9mqJQyrOMLowEKwpA2wA/PwkRJO1j8=";
    };
    x86_64-linux = {
      asset = "waza-linux-amd64";
      hash = "sha256-EiLEXOQGjk6eaMyZTxgR3dcbKeyfILSzHIJ9P6XILG4=";
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
