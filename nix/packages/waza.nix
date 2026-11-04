# Waza CLI from upstream release binaries.
# TODO: Remove this custom package once Waza is available from nixpkgs.
{
  lib,
  stdenvNoCC,
  fetchurl,
  system,
}:
let
  version = "0.40.0";
  sources = {
    aarch64-darwin = {
      asset = "waza-darwin-arm64";
      hash = "sha256-oMzvkU7UGhk5TnoBtgV4z9N9PM4O86p4VzWsOfqIcrw=";
    };
    aarch64-linux = {
      asset = "waza-linux-arm64";
      hash = "sha256-Om0OHqWA77An1agcKPE+WINb9qZPUnD8OZsBE9ZxdRE=";
    };
    x86_64-linux = {
      asset = "waza-linux-amd64";
      hash = "sha256-0JEXo8Yx9EoApsNiRiyVGu2DyHdR6MJfOZFqd9EBOAI=";
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
