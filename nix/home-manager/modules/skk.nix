{
  pkgs,
  lib,
  dotfilesDir,
  homeDir,
  ...
}:
{
  # NOTE: dpp must run at least once before this activation produces dict output.
  home.activation.setupSkkDicts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.optionalString pkgs.stdenv.isDarwin ''
      macSkkDir="$HOME/Library/Application Support/macSKK/Dictionaries"
      dppDir="''${XDG_CACHE_HOME:-$HOME/.cache}/dpp/repos/github.com"
      mkdir -p "$macSkkDir"

      for f in SKK-JISYO.L SKK-JISYO.jinmei SKK-JISYO.assoc; do
        src="$dppDir/skk-dev/dict/$f"
        [[ -f "$src" ]] && cp -f "$src" "$macSkkDir/$f"
      done
      src="$dppDir/uasi/skk-emoji-jisyo/SKK-JISYO.emoji.utf8"
      [[ -f "$src" ]] && cp -f "$src" "$macSkkDir/SKK-JISYO.emoji.utf8"

      [[ ! -f "$macSkkDir/skkdict.utf8" ]] && cp "${dotfilesDir}/config/vim/dpp/skkdict.utf8" "$macSkkDir/skkdict.utf8"
    ''}
  '';
}
