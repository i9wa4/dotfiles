{ lib, stdenv, fetchurl }:

let
  # Hashes sourced from github:openclaw/nix-steipete-tools nix/pkgs/gogcli.nix:5-16
  # Tarballs: GoReleaser v0.11.0 release binary tarballs (2026-02-15)
  # x86_64-darwin excluded (Apple Silicon only, per flake.nix supported systems)
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.11.0/gogcli_0.11.0_darwin_arm64.tar.gz";
      hash = "sha256-ESaGjD+TmhSqlld9Vlj1/vHhU58zJzC/NaBudBYsnmE=";
    };
    "x86_64-linux" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.11.0/gogcli_0.11.0_linux_amd64.tar.gz";
      hash = "sha256-ypi6VuKczTcT/nv4Nf3KAK4bl83LewvF45Pn7bQInIQ=";
    };
    "aarch64-linux" = {
      url = "https://github.com/steipete/gogcli/releases/download/v0.11.0/gogcli_0.11.0_linux_arm64.tar.gz";
      hash = "sha256-G/6YBUVkFQFIj+2Txm/HZnHHKkYFKF9XRXLaxwDv3TU=";
    };
  };
in
stdenv.mkDerivation {
  pname = "gogcli";
  version = "0.11.0";

  src = fetchurl sources.${stdenv.hostPlatform.system};

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    tar -xzf "$src"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    # Tarball extracts gog flat to working directory
    cp gog "$out/bin/gog"
    chmod 0755 "$out/bin/gog"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Google CLI for Gmail, Calendar, Drive, and Contacts";
    homepage = "https://github.com/steipete/gogcli";
    license = licenses.mit;
    # x86_64-darwin excluded (Apple Silicon only per this flake's supported systems)
    platforms = builtins.attrNames sources;
    mainProgram = "gog";
  };
}
