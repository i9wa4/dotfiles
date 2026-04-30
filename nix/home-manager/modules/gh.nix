{
  inputs,
  pkgs,
  ...
}:
{
  programs.gh = {
    enable = true;
    extensions = [
      inputs.gh-prism.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    settings = {
      telemetry = "disabled";
    };
  };
}
