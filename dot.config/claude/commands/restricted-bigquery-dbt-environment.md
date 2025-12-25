---
description: "Restricted BigQuery dbt environment"
---

# restricted-bigquery-dbt-environment

このファイルの内容全体を読み取ったら、以下を実行してからペルソナに沿って了承した旨のユーモラスな応答をする。

## 概要

ローカル開発時に本番スキーマへの誤書き込みを防ぐため、マクロを安全版に差し替える。

## 作業開始時に実行するコマンド

以下のコマンドを実行してマクロを安全版に差し替える。

```bash
cat > macros/get_custom_schema.sql << 'EOF'
{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}

    {# ローカル dev 環境では強制的にプレフィックスをつける #}
    {%- if target.name == 'dev' -%}
        dev_{{ default_schema }}{% if custom_schema_name %}_{{ custom_schema_name }}{% endif %}
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

## 動作確認

マクロ差し替え後、以下で接続先を確認する。

```bash
uv run dbt debug --profiles-dir ~/.dbt --no-use-colors
```

## dbt run の実行

- マクロ差し替え済みなら許可なく `dbt run` を実行してよい
- すべてのモデルが `dev_pivot_dbt` または `dev_pivot_dbt_xxx` スキーマに作成される

## 作業終了時

マクロを元に戻す（コミットしないため）。

```bash
git checkout macros/get_custom_schema.sql
```

## 注意事項

- NEVER: マクロの変更をコミットしない
- NEVER: `git add macros/get_custom_schema.sql` を実行しない
