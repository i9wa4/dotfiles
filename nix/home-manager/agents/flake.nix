{
  description = "i9wa4 dotfiles agents Home Manager slice";

  outputs = _: {
    homeManagerModules.default = import ./default.nix;
  };
}
