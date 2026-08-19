---
name: human-facing-gist
description: |
  USE FOR: 人間が読む日本語の計画・レビュー・完了報告を作り、
  非公開（secret）GitHub Gistへ安全にアップロードしてPostmanで引き継ぐ。
  DO NOT USE FOR: 公開Gist、秘密情報の転載、外部公開の承認、またはアクセス制御された保管。
  URLの共有前に可視性を確認し、失敗時はローカル記録を正本として扱う。
---

# 人間向け成果物と非公開 Gist

人間向けの最終本文は日本語で書き、`mkmd` の作業記録を正本にする。
実行手順やコード中の識別子は必要に応じて英語のまま残す。

## 1. 手順

1. 秘密情報を除去し、`gh auth status` でアカウントを確認する。
2. `--public` を付けずに `gh gist create` を実行する。
3. URLの本文と可視性を確認し、Gist URL、`mkmd`
   パス、検証結果、残課題をPostmanで日本語報告する。

```sh
gh auth status
gh gist create --filename report-ja.md --description '日本語の人間向け成果物' ./report-ja.md
```

詳細なプライバシー、失敗時、削除時の手順は
[references/workflow.md](references/workflow.md) を参照する。
