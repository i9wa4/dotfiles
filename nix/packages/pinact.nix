{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "pinact";
  version = "3.8.0";

  src = fetchFromGitHub {
    owner = "suzuki-shunsuke";
    repo = "pinact";
    rev = "v${version}";
    hash = "sha256-eZHJ1JK0EwjO6zSH2vKCkwQV3NUVqe2I0+QFMO7VHN0=";
  };

  vendorHash = "sha256-EqfhHy9OUiaoCI/VFjUJlm917un3Lf4/cUmeHG7w9Bg=";

  meta = {
    description = "Pin GitHub Actions versions";
    homepage = "https://github.com/suzuki-shunsuke/pinact";
  };
}
