# Waza CLI from upstream release binaries.
# TODO: Remove this custom package once Waza is available from nixpkgs.
{
  lib,
  stdenvNoCC,
  fetchurl,
  system,
}:
let
  version = "0.39.1";
  sources = {
    aarch64-darwin = {
      asset = "waza-darwin-arm64";
      hash = "sha256-H4QH7nxtJ/wELucsfW6cfBur5rrw1h50A61uu9yF6qU=";
    };
    aarch64-linux = {
      asset = "waza-linux-arm64";
      hash = "sha256-LFXPsX20xr2tbptsjdaVlfa43yY9C5dQutQ7+jAiHe0=";
    };
    x86_64-linux = {
      asset = "waza-linux-amd64";
      hash = "sha256-Q/7bRAWFECFmPXUwm9K29d8xcjmFnIxudB2iBWW1X8E=";
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
