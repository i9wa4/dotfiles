{
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage rec {
  pname = "rumdl";
  version = "0.0.206";

  src = fetchFromGitHub {
    owner = "rvben";
    repo = "rumdl";
    rev = "v${version}";
    hash = "sha256-taYwtoJuH5K8OPsBksznsA+pqq8zgk12VzC25TtQOus=";
  };

  cargoHash = "sha256-RwxAlyHODtZCVpd4hHyDcxoBfm9UB/JOq0bsL92lUII=";

  # Tests require the binary in PATH
  doCheck = false;

  meta = {
    description = "High-performance Markdown linter written in Rust";
    homepage = "https://github.com/rvben/rumdl";
  };
}
