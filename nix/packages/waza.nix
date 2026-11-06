# Waza CLI from upstream release binaries.
# TODO: Remove this custom package once Waza is available from nixpkgs.
{
  lib,
  stdenvNoCC,
  fetchurl,
  system,
}:
let
  version = "0.40.1";
  sources = {
    aarch64-darwin = {
      asset = "waza-darwin-arm64";
      hash = "sha256-9hLrk3OLQs3r3w3cB9L+nzmmro4qR40Jt8lv7b97bSY=";
    };
    aarch64-linux = {
      asset = "waza-linux-arm64";
      hash = "sha256-cZKcv8IPooQWHfCsllxJRmTHx4l+qFRg2vaNeLF4Qr8=";
    };
    x86_64-linux = {
      asset = "waza-linux-amd64";
      hash = "sha256-RMJgdeFZuNnnJTyeReR9JGjAn4GAuN6NUitPr3N2elw=";
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
