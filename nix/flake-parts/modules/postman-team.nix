{ inputs, lib, ... }:
{
  perSystem =
    { pkgs, system, ... }:
    let
      postman = inputs.tmux-a2a-postman.packages.${system}.default;
      teamSource = lib.fileset.toSource {
        root = ../../..;
        fileset = lib.fileset.unions [
          ../../../config/tmux-a2a-postman/postman.md
          ../../../config/tmux/tmux.conf
          ../../../config/vde/layout.yml
          ../../../config/zsh/snippet.zsh
          ../../../scripts/bin/postman-team-config
          ../../../scripts/nix/flake-input-update-tmux-a2a-postman.sh
          ../../../scripts/validation/postman-team
          ../../../scripts/validation/test-postman-team-config.py
          ../../../scripts/validation/validate-postman-team.py
          ../../../skills
        ];
      };
      runtime = [
        pkgs.python3
        pkgs.bash
        pkgs.zsh
        pkgs.tmux
        pkgs.git
        pkgs.coreutils
      ];
      validate = pkgs.writeShellApplication {
        name = "postman-team-check";
        runtimeInputs = runtime;
        text = ''
          ${lib.getExe pkgs.python3} ${teamSource}/scripts/validation/validate-postman-team.py \
            --postman ${lib.getExe' postman "tmux-a2a-postman"} \
            --upstream-fixtures ${inputs.tmux-a2a-postman}/scripts/validation "$@"
        '';
      };
    in
    {
      apps.postman-team-check = {
        type = "app";
        program = lib.getExe validate;
        meta.description = "Verify recursive team mail flows in private tmux sessions";
      };
      checks.postman-team = pkgs.runCommand "postman-team" { nativeBuildInputs = runtime; } ''
        export HOME="$TMPDIR/home"
        mkdir -p "$HOME"
        export POSTMAN_TEST_BINARY=${lib.getExe' postman "tmux-a2a-postman"}
        python3 ${teamSource}/scripts/validation/test-postman-team-config.py
        ${lib.getExe validate} --output "$TMPDIR/team-results.json"
        mkdir -p "$out"
        cp "$TMPDIR/team-results.json" "$out/results.json"
      '';
    };
}
