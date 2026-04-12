{
  pkgs,
  inputs,
  system,
}:
let
  pin = import ./codex-pin.nix;
  inherit (pin)
    cargoHash
    hash
    version
    ;
  src = pkgs.fetchFromGitHub {
    owner = "openai";
    repo = "codex";
    tag = "rust-v${version}";
    inherit hash;
  };
  librusty_v8 = pkgs.fetchurl {
    name = "librusty_v8-${pin.librusty_v8.version}";
    url = "https://github.com/denoland/rusty_v8/releases/download/v${pin.librusty_v8.version}/librusty_v8_release_${pkgs.stdenv.hostPlatform.rust.rustcTarget}.a.gz";
    hash = pin.librusty_v8.hashes.${system};
    meta.sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
  };
  livekitWebrtcTriple =
    {
      x86_64-darwin = "mac-x64";
      aarch64-darwin = "mac-arm64";
    }
    .${system} or null;
  livekitWebrtc =
    if livekitWebrtcTriple == null then
      null
    else
      pkgs.fetchzip {
        name = "livekit-webrtc-${pin.livekit_webrtc.tag}-${livekitWebrtcTriple}";
        url = "https://github.com/livekit/rust-sdks/releases/download/${pin.livekit_webrtc.tag}/webrtc-${livekitWebrtcTriple}-release.zip";
        hash = pin.livekit_webrtc.hashes.${system};
        meta.sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
      };
in
inputs.llm-agents.packages.${system}.codex.overrideAttrs (_: {
  inherit version src cargoHash;
  env = {
    RUSTY_V8_ARCHIVE = librusty_v8;
  }
  // pkgs.lib.optionalAttrs (livekitWebrtc != null) {
    LK_CUSTOM_WEBRTC = livekitWebrtc;
  };
  meta = pkgs.lib.recursiveUpdate inputs.llm-agents.packages.${system}.codex.meta {
    changelog = "https://github.com/openai/codex/releases/tag/rust-v${version}";
  };
})
