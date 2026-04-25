{
  pkgs,
  lib,
  dotfilesDir,
  homeDir,
  ...
}:
{
  # NOTE: dpp must run at least once before this activation produces full dict output.
  home.activation.setupSkkDicts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    skkDir="$HOME/.local/share/skk"
    dppDir="''${XDG_CACHE_HOME:-$HOME/.cache}/dpp/repos/github.com"
    mkdir -p "$skkDir"

    for f in SKK-JISYO.L SKK-JISYO.jinmei SKK-JISYO.assoc; do
      src="$dppDir/skk-dev/dict/$f"
      [[ -f "$src" ]] && cp -f "$src" "$skkDir/$f"
    done
    src="$dppDir/uasi/skk-emoji-jisyo/SKK-JISYO.emoji.utf8"
    [[ -f "$src" ]] && cp -f "$src" "$skkDir/SKK-JISYO.emoji.utf8"

    [[ ! -f "$skkDir/skkdict.utf8" ]] && cp "${dotfilesDir}/config/vim/dpp/skkdict.utf8" "$skkDir/skkdict.utf8"

    ${lib.optionalString pkgs.stdenv.isDarwin ''
      macSkkDir="$HOME/Library/Application Support/macSKK/Dictionaries"
      mkdir -p "$macSkkDir"
      for f in SKK-JISYO.L SKK-JISYO.jinmei SKK-JISYO.assoc SKK-JISYO.emoji.utf8; do
        [[ -f "$skkDir/$f" ]] && cp -f "$skkDir/$f" "$macSkkDir/$f"
      done
      [[ ! -f "$macSkkDir/skkdict.utf8" ]] && [[ -f "$skkDir/skkdict.utf8" ]] && cp "$skkDir/skkdict.utf8" "$macSkkDir/skkdict.utf8"
    ''}
  '';
}
