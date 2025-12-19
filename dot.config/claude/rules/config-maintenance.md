# 設定最適化ルール

このルールは CLAUDE.md / AGENTS.md や rules/ などの設定ファイルを編集する際に適用される。

## 目的

起動時コンテキストを最小化し、効率的なセッション開始を実現する。

## CLAUDE.md / AGENTS.md の設計指針

- YOU MUST: 役割（ペルソナ）と核心的指針のみに集約する
- YOU MUST: 詳細なルールは `rules/` に分割する
- NEVER: 起動時に不要な情報（参照リンク、詳細な使い方説明）を含めない

## 設定の使い分け

| 種別 | 読み込みタイミング | 用途 |
|------|-------------------|------|
| CLAUDE.md / rules/ | 起動時に全文読み込み | 常に適用すべき全体ルール |
| commands/ | ユーザーが明示的に呼び出し | 定型プロンプト、ワークフロー |
| skills/ | 会話内容に基づき自動発動 | 専門知識、統合機能 |
| agents/ | Task ツールで委譲 | 独立コンテキストでの専門タスク |

## 最適化チェックリスト

CLAUDE.md を編集する際は以下を確認する。

- [ ] ペルソナ定義は簡潔か
- [ ] 基本ルールは本当に常時必要か
- [ ] 詳細説明は rules/ や skills/ に分離できないか
- [ ] 参照リンクは config-maintenance.md に移動したか

## 参考リンク

- Claude Code 設定ガイド: <https://blog.atusy.net/2025/12/15/claude-code-user-config/>
- CLAUDE.md 最小化: <https://blog.atusy.net/2025/12/17/minimizing-claude-md/>
- site2skill (Skills 作成ツール): <https://github.com/laiso/site2skill>
