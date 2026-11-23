# macSKK and kitty: Ctrl-J Inserts a Newline

On macOS with macSKK 2.21.0 and kitty 0.49.2, the standard SKK sequence
`l` (ASCII mode), then `Ctrl-J` (hiragana mode) switched the input mode but
also inserted an unwanted newline in the kitty shell. The behavior was
reproduced with `kitty --config NONE`, so the user's kitty configuration
was unlikely to be the cause.

In macSKK's **Compatibility** settings, enable **「1文字目を未変換扱い」**
(treat the first character as unconverted or marked text). The operator
confirmed that `l` → `Ctrl-J` then returned to hiragana without inserting
a newline. To verify, open a kitty shell, enter ASCII mode with `l`, and
press `Ctrl-J`; the input mode should change to hiragana while the shell
prompt stays on the same line.

The `kitty --debug-input` log recorded
`sent encoded key to child (window_id: 1): 0xa` for the `Ctrl-J` press.
`0x0a` is a line feed, confirming that kitty sent the newline to the
shell. The exact mechanism by which the macSKK setting prevents this
forwarding has not been independently verified.

The macSKK **「空文字挿入」** (“Insert empty string”) option was already
enabled but did not resolve this case. Adding `map ctrl+j discard_event`
to kitty also did not change the observed behavior. Keep the native SKK
`Ctrl-J` convention; changing to macOS `Ctrl-Space` is unnecessary for
this workaround.

Related upstream context:
[macSKK #119](https://github.com/mtgto/macSKK/issues/119),
[macSKK #362](https://github.com/mtgto/macSKK/pull/362), and
[macSKK #364](https://github.com/mtgto/macSKK/pull/364).
