---
description: "Restricted dbt environment"
---

# restricted-dbt-environment

今回の開発環境が dbt コマンドの実行に制限があります

## 1. 許可されたコマンド

環境へ影響を与えないコマンドのみが許可されています。

- `dbt debug`
- `dbt deps`
- `dbt show`
- `dbt compile`

## 2. 禁止されたコマンド

環境へ影響を与えるコマンドは禁止です。

- NEVER: `dbt build`
- NEVER: `dbt run`
- NEVER: `dbt seed`
- NEVER: `dbt snapshot`
