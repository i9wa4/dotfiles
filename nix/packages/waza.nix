# Waza CLI from upstream release binaries.
# TODO: Remove this custom package once Waza is available from nixpkgs.
{
  lib,
  stdenvNoCC,
  fetchurl,
  system,
}:
let
  version = "0.39.0";
  sources = {
    aarch64-darwin = {
      asset = "waza-darwin-arm64";
      hash = "sha256-9HMuNQph4i9EDd/n/O3C54FmH9fAOc8wBa+QurXVLA8=";
    };
    aarch64-linux = {
      asset = "waza-linux-arm64";
      hash = "sha256-HPZ4hdfdtgR6rJ2pMsUWnIyJ7qAJJvP+w3Bp4CSeYl0=";
    };
    x86_64-linux = {
      asset = "waza-linux-amd64";
      hash = "sha256-qAE4w9N9SOlH71tBShukZXk1tzNNLOvkfPcdAEaA8lA=";
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
