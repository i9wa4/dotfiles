# Keep gh at the first version with auto-refreshing expiring OAuth credentials
# until nixpkgs-unstable includes it.
final: prev: {
  gh = prev.gh.overrideAttrs (old: {
    version = "2.103.0";
    src = final.fetchFromGitHub {
      owner = "cli";
      repo = "cli";
      tag = "v2.103.0";
      hash = "sha256-unaFckDrXrSV/75/eUAUG4ZxMt+SgcY7GRgVwdNHARg=";
      postCheckout = ''
        git -C "$out" log -1 --pretty=%ct > $out/SOURCE_DATE_EPOCH
      '';
    };
    vendorHash = "sha256-o4p/SBVzlj+Qf3XNt5UzAbQUFrJHHOEjTCCE03+kvJs=";
    env = old.env // {
      GH_VERSION = "2.103.0";
    };
  });
}
