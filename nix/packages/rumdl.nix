{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "rumdl";
  version = "0.0.222";

  src = fetchFromGitHub {
    owner = "rvben";
    repo = "rumdl";
    rev = "v${version}";
    hash = "sha256-SUP8DiB/tqdDekFHMHO+8ieHuS3Zt1auH2HInez5Fag=";
  };

  cargoHash = "sha256-5Gb70nRcL4CYWhfgbyxxWmJj8ABZJH92nanGIQcUex0=";

  # Tests require the binary in PATH
  doCheck = false;

  meta = {
    description = "High-performance Markdown linter written in Rust";
    homepage = "https://github.com/rvben/rumdl";
  };
}
