{
  pkgs,
  lib,
  ...
}:
{
  # NOTE: dpp must run at least once before this activation produces dict output.
  home.activation.setupSkkDicts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.optionalString pkgs.stdenv.isDarwin ''
      macSkkDir="$HOME/Library/Application Support/macSKK/Dictionaries"
      dppSkkDev="''${XDG_CACHE_HOME:-$HOME/.cache}/dpp/repos/github.com/skk-dev/dict"
      mkdir -p "$macSkkDir"
      [[ -f "$dppSkkDev/SKK-JISYO.L" ]] && cp -f "$dppSkkDev/SKK-JISYO.L" "$macSkkDir/SKK-JISYO.L"
    ''}
  '';
}
