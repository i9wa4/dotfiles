{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "ghalint";
  version = "1.5.4";

  src = fetchFromGitHub {
    owner = "suzuki-shunsuke";
    repo = "ghalint";
    rev = "v${version}";
    hash = "sha256-pfLXnMbrxXAMpfmjctah85z5GHfI/+NZDrIu1LcBH8M=";
  };

  vendorHash = "sha256-VCv5ZCeUWHld+q7tkHSUyeVagMhSN9893vYHyO/VlAI=";

  meta = {
    description = "GitHub Actions linter";
    homepage = "https://github.com/suzuki-shunsuke/ghalint";
  };
}
