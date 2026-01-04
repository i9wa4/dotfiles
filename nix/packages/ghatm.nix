{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "ghatm";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "suzuki-shunsuke";
    repo = "ghatm";
    rev = "v${version}";
    hash = "sha256-MX1VilyfxJ9GKIkDSGeAE007DyjPkWL5W4b08EqAyC4=";
  };

  vendorHash = "sha256-CQ2HAyBuULKbmGdJ9RmPYFr2nZYxDePoJu+k8cjKxpk=";

  meta = {
    description = "GitHub Actions timeout manager";
    homepage = "https://github.com/suzuki-shunsuke/ghatm";
  };
}
