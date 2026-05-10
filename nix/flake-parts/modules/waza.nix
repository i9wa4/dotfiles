{
  perSystem =
    { pkgs, system, ... }:
    {
      packages.waza = pkgs.callPackage ../../packages/waza.nix {
        inherit system;
      };
    };
}
