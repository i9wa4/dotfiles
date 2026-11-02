# Keep the offline verifier available until the pinned nixpkgs catches up.
{
  gh-actions-lock,
  fetchFromGitHub,
}:
gh-actions-lock.overrideAttrs (_: {
  version = "0.4.0";
  src = fetchFromGitHub {
    owner = "github";
    repo = "gh-actions-lock";
    tag = "v0.4.0";
    hash = "sha256-+J5nA1kzwmjY98u0HoJ2rsYD5hLNBhNnwmIT34Gxha4=";
  };
  vendorHash = "sha256-MS0GDAo/COikI5LwfgNPR83MhY6fAFg+Lpmzkv86X3M=";
})
