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
    hash = "sha256-EW/JQlzve46eKCuDqXmvdeU1X3khtuk/WiUD5XoD+N4=";
  };

  cargoHash = "sha256-dres1qO4YqmGwnjFDp6alh5+QTQa4liDBv6iMXFBlck=";

  # Tests require the binary in PATH
  doCheck = false;

  meta = {
    description = "High-performance Markdown linter written in Rust";
    homepage = "https://github.com/rvben/rumdl";
  };
}
