# actrun from upstream release binaries.
# TODO: Remove this custom package once actrun is available from nixpkgs.
{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  system,
}:
let
  version = "0.29.0";
  sources = {
    aarch64-darwin = {
      asset = "actrun-macos-arm64.tar.gz";
      hash = "sha256-cqLtj6eCMjiDfoA3Br7duvQACwSofMHEJjSx1TGdHyo=";
    };
    x86_64-linux = {
      asset = "actrun-linux-x64.tar.gz";
      hash = "sha256-B8WPrLKxhJ+7yrUfyvmdLA+NMq9W82jbl5Korx2HOKY=";
    };
  };
  source = sources.${system} or (throw "actrun: unsupported system ${system}");
in
stdenvNoCC.mkDerivation {
  pname = "actrun";
  inherit version;

  src = fetchurl {
    url = "https://github.com/mizchi/actrun/releases/download/v${version}/${source.asset}";
    inherit (source) hash;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  unpackPhase = ''
    runHook preUnpack
    tar xzf "$src"
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 actrun "$out/bin/actrun"
    runHook postInstall
  '';

  meta = {
    description = "Run GitHub Actions locally";
    homepage = "https://github.com/mizchi/actrun";
    license = lib.licenses.mit;
    mainProgram = "actrun";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
