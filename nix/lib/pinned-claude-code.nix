{
  pkgs,
  inputs,
  system,
}:
let
  pin = import ./claude-code-pin.nix;
  inherit (pin) hashes version;
  platformSuffix =
    {
      x86_64-linux = "linux-x64";
      aarch64-linux = "linux-arm64";
      aarch64-darwin = "darwin-arm64";
    }
    .${system};
in
inputs.llm-agents.packages.${system}.claude-code.overrideAttrs (_: {
  inherit version;
  src = pkgs.fetchurl {
    url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/${platformSuffix}/claude";
    hash = hashes.${system};
  };
})
