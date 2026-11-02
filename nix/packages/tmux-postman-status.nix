{
  writeShellApplication,
  replaceVars,
  python3,
  postman,
}:
let
  driver = replaceVars ../../scripts/tmux/postman-status.py {
    postman = "${postman}/bin/tmux-a2a-postman";
  };
in
writeShellApplication {
  name = "tmux-postman-status";
  text = ''
    exec ${python3}/bin/python3 ${driver} "$@"
  '';
}
