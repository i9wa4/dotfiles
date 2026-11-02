{ inputs, ... }:
{
  perSystem =
    {
      config,
      pkgs,
      system,
      ...
    }:
    let
      postman = inputs.tmux-a2a-postman.packages.${system}.default;
    in
    {
      packages.tmux-postman-status = pkgs.callPackage ../../packages/tmux-postman-status.nix {
        inherit postman;
      };
      checks.tmux-postman-status =
        pkgs.runCommand "tmux-postman-status"
          {
            nativeBuildInputs = [
              pkgs.python3
              pkgs.tmux
            ];
          }
          ''
            export POSTMAN_STATUS_DRIVER=${../../../scripts/tmux/postman-status.py}
            export POSTMAN_STATUS_PACKAGE=${config.packages.tmux-postman-status}
            export POSTMAN_STATUS_REAL_BIN=${postman}/bin/tmux-a2a-postman
            export POSTMAN_STATUS_TMUX_CONFIG=${../../../config/tmux/tmux.conf}
            python3 ${../../../scripts/validation/test-tmux-postman-status.py}
            touch "$out"
          '';
    };
}
