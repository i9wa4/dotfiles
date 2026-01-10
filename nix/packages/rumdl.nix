{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "rumdl";
  version = "0.0.213";

  src = fetchFromGitHub {
    owner = "rvben";
    repo = "rumdl";
    rev = "v${version}";
    hash = "sha256-YUo6WU3r9phIrM8g3qfGAVaj1oSAOqgTfCoghsFU/Ng=";
  };

  cargoHash = "sha256-JSHS1/H5jiB4NvQV5qMrui118JGxVLqOfjRLUB/cPTQ=";

  # Tests require the binary in PATH
  doCheck = false;

  meta = {
    description = "High-performance Markdown linter written in Rust";
    homepage = "https://github.com/rvben/rumdl";
  };
}
