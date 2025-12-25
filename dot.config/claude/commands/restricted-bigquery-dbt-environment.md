---
description: "Restricted BigQuery dbt environment"
---

# restricted-bigquery-dbt-environment

このファイルの内容全体を読み取ったら、以下を実行してからペルソナに沿って了承した旨のユーモラスな応答をする。

## 概要

ローカル開発時に本番スキーマへの誤書き込みを防ぐため、マクロを安全版に差し替える。

## 1. 環境セットアップ (初回のみ)

pyproject.toml から依存パッケージをインストールする。

```bash
uv pip install --requirement pyproject.toml
```

## 2. マクロを安全版に差し替え

以下のコマンドを実行してマクロを安全版に差し替える。

```bash
cat > macros/get_custom_schema.sql << 'EOF'
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {# ローカル dev 環境では強制的にプレフィックスをつける #}
    {%- if target.name == 'dev' -%}
        {%- if custom_schema_name is none -%}
            {% if node.fqn[1:-1]|length == 0 %}
                z_dev_{{ default_schema }}
            {% else %}
                {% set suffix = node.fqn[1:-1]|join('_') %}
                z_dev_{{ suffix | trim }}
            {% endif %}
        {%- else -%}
            z_dev_{{ default_schema }}_{{ custom_schema_name | trim }}
        {%- endif -%}
    {%- else -%}
        {# 既存ロジック (dbt Cloud 等) #}
        {%- if custom_schema_name is none -%}
            {% if node.fqn[1:-1]|length == 0 %}
                {{ default_schema }}
            {% else %}
                {% set suffix = node.fqn[1:-1]|join('_') %}
                {{ suffix | trim }}
            {% endif %}
        {%- else -%}
            {{ default_schema }}_{{ custom_schema_name | trim }}
        {%- endif -%}
    {%- endif -%}

{%- endmacro %}
EOF
```

## 3. 動作確認

マクロ差し替え後、以下で接続先を確認する。

```bash
source .venv/bin/activate && dbt debug --profiles-dir ~/.dbt --no-use-colors
```

## dbt run の実行

- YOU MUST: `dbt run` 実行前に manifest.json でスキーマ名を確認し、ユーザーに許可を取る
- すべてのモデルが `z_dev_stg_ga`, `z_dev_whs_xxx`, `z_dev_mart` 等のスキーマに作成される

## 作業終了時

マクロを元に戻す（コミットしないため）。

```bash
git checkout macros/get_custom_schema.sql
```

## 注意事項

- NEVER: マクロの変更をコミットしない
- NEVER: `git add macros/get_custom_schema.sql` を実行しない
