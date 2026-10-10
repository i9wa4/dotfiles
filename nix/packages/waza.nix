# Waza CLI from upstream release binaries.
# TODO: Remove this custom package once Waza is available from nixpkgs.
{
  lib,
  stdenvNoCC,
  fetchurl,
  system,
}:
let
  version = "0.38.10";
  sources = {
    aarch64-darwin = {
      asset = "waza-darwin-arm64";
      hash = "sha256-ynCGMIDnMuuRV8CqHWkvRB4RWmoHQLgFyihFj0M6twY=";
    };
    aarch64-linux = {
      asset = "waza-linux-arm64";
      hash = "sha256-A3Hn0x2kqp1d30VY6jzUFJDHpMp9FMpPE/hC6Zdw6Ck=";
    };
    x86_64-linux = {
      asset = "waza-linux-amd64";
      hash = "sha256-+uRprzsgymO3ia1k6PLAB6Bp0IQ8yI2eg9Ik3k9wd7M=";
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
