# Waza CLI from upstream release binaries.
# TODO: Remove this custom package once Waza is available from nixpkgs.
{
  lib,
  stdenvNoCC,
  fetchurl,
  system,
}:
let
  version = "0.42.0";
  sources = {
    aarch64-darwin = {
      asset = "waza-darwin-arm64";
      hash = "sha256-S/l6/xhnU7lFrBb3EBriK+eR5bTNBA2taaO4ghHBz+k=";
    };
    aarch64-linux = {
      asset = "waza-linux-arm64";
      hash = "sha256-x5kUSxbR2+uzzQZVAaMgUXoim/kPI6ks3hljNEhmZkc=";
    };
    x86_64-linux = {
      asset = "waza-linux-amd64";
      hash = "sha256-mGXOUQgNAF402zQ72i1jKA3oZKMPmpXWyYa/Amk1tA8=";
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
