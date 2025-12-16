---
description: "Issue to PR - 3フェーズで作業管理"
---

# issue-to-pr

Explore → Plan → Code → PR の流れで作業を管理する

参考: [Anthropic's Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices#a-explore-plan-code-commit)

## 1. 前提

- ディレクトリ名もしくはブランチ名から Issue 番号を取得できる
- 各フェーズの開始前と終了後に必ずユーザーに確認を取る

## 2. フェーズ状態の管理

`.i9wa4/phase.log` にフェーズ遷移を記録する

```text
2025-01-01 10:00:00 | START → EXPLORE
2025-01-01 11:00:00 | EXPLORE → PLAN
...
```

途中から再開する場合

1. `.i9wa4/phase.log` の最終行を確認して現在のフェーズを特定
2. 該当フェーズから作業を継続

## 3. フェーズ

### 3.1. EXPLORE (調査フェーズ)

ultrathink 推奨

開始前確認

- Issue 本文とコメントを全件取得して内容を把握
- `.i9wa4/phase.log` に `START → EXPLORE` を記録
- ユーザーに調査開始の確認を取る

実施内容

- 要件の分析
- 影響範囲の調査
- 関連コードの確認
- IMPORTANT: このフェーズではコードを書かない。調査のみ。

終了後確認

- 調査結果を `.i9wa4/explore.md` に保存
- `.i9wa4/phase.log` に `EXPLORE → PLAN` を記録
- ユーザーに調査完了の確認を取る

### 3.2. PLAN (計画フェーズ)

ultrathink 推奨

開始前確認

- ユーザーに計画開始の確認を取る

実施内容

- 技術選択とアーキテクチャ決定
- 実装計画の作成
- テスト方針の決定
- IMPORTANT: このフェーズではコードを書かない。計画のみ。

終了後確認

- 設計内容を `.i9wa4/plan.md` に保存
- `.i9wa4/phase.log` に `PLAN → CODE` を記録
- ユーザーに計画完了の確認を取る

### 3.3. CODE (実装フェーズ)

開始前確認

- ユーザーに実装開始の確認を取る

実施内容

- 計画に沿って実装を進める
- 適宜コミットを行う
- IMPORTANT: ソリューションの妥当性を確認しながら進める

終了後確認

- 全ての実装が完了したことを確認
- `.i9wa4/phase.log` に `CODE → PR` を記録
- ユーザーに実装完了の確認を取る

### 3.4. PR (PR作成フェーズ)

開始前確認

- ユーザーに PR 作成開始の確認を取る

実施内容

1. 直近10件の @i9wa4 の PR を取得して書き味を参考にする

    ```sh
    gh pr list --author i9wa4 --state all --limit 10 --json number,title,body
    ```

2. PR テンプレートがあれば読み込む

    ```sh
    cat .github/PULL_REQUEST_TEMPLATE.md
    ```

3. README やチェンジログの更新が必要か確認し、必要なら更新する

4. ドラフト PR を作成する

    ```sh
    gh pr create --draft --title "タイトル" --body "本文"
    ```

終了後確認

- PR の URL を提示
- `.i9wa4/phase.log` に `PR → COMPLETE` を記録
- ユーザーに完了の確認を取る
