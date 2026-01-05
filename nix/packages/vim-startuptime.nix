{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "vim-startuptime";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "rhysd";
    repo = "vim-startuptime";
    rev = "v${version}";
    hash = "sha256-d6AXTWTUawkBCXCvMs3C937qoRUZmy0qCFdSLcWh0BE=";
  };

  vendorHash = null;

  # Tests require vim/nvim in PATH
  doCheck = false;

  meta = {
    description = "Vim/Neovim startup time profiler";
    homepage = "https://github.com/rhysd/vim-startuptime";
  };
}
