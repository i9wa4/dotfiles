{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "rumdl";
  version = "0.0.216";

  src = fetchFromGitHub {
    owner = "rvben";
    repo = "rumdl";
    rev = "v${version}";
    hash = "sha256-aHgaqsU6cvAfWF4q1aynE9H+Ok46Tld9ukRvS0urfRU=";
  };

  cargoHash = "sha256-G7++F3Av56KVan6PTsqI0AjSlKLTY7Ypk9mZBrhqevI=";

  # Tests require the binary in PATH
  doCheck = false;

  meta = {
    description = "High-performance Markdown linter written in Rust";
    homepage = "https://github.com/rvben/rumdl";
  };
}
