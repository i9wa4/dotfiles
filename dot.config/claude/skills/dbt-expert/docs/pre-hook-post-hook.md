---
title: "pre-hook & post-hook | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [General configs](https://docs.getdbt.com/category/general-configs)* pre-hook & post-hook

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fpre-hook-post-hook+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fpre-hook-post-hook+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fpre-hook-post-hook+so+I+can+ask+questions+about+it.)

On this page

* Models* Seeds* Snapshots

In these examples, we use the `|` symbol to separate two different formatting options for SQL statements in pre-hooks and post-hooks. The first option (without brackets) accepts a single SQL statement as a string, while the second (with brackets) accepts multiple SQL statements as an array of strings. Replace `SQL-STATEMENT` with your SQL.

dbt\_project.yml

```
models:
  <resource-path>:
    +pre-hook: SQL-statement | [SQL-statement]
    +post-hook: SQL-statement | [SQL-statement]
```

models/<model\_name>.sql

```
{{ config(
    pre_hook="SQL-statement" | ["SQL-statement"],
    post_hook="SQL-statement" | ["SQL-statement"],
) }}

select ...
```

models/properties.yml

```
models:
  - name: [<model_name>]
    config:
      pre_hook: <sql-statement> | [<sql-statement>]
      post_hook: <sql-statement> | [<sql-statement>]
```

In these examples, we use the `|` symbol to separate two different formatting options for SQL statements in pre-hooks and post-hooks. The first option (without brackets) accepts a single SQL statement as a string, while the second (with brackets) accepts multiple SQL statements as an array of strings. Replace `SQL-STATEMENT` with your SQL.

dbt\_project.yml

```
seeds:
  <resource-path>:
    +pre-hook: SQL-statement | [SQL-statement]
    +post-hook: SQL-statement | [SQL-statement]
```

seeds/properties.yml

```
seeds:
  - name: [<seed_name>]
    config:
      pre_hook: <sql-statement> | [<sql-statement>]
      post_hook: <sql-statement> | [<sql-statement>]
```

In these examples, we use the `|` symbol to separate two different formatting options for SQL statements in pre-hooks and post-hooks. The first option (without brackets) accepts a single SQL statement as a string, while the second (with brackets) accepts multiple SQL statements as an array of strings. Replace `SQL-STATEMENT` with your SQL.

dbt\_project.yml

```
snapshots:
  <resource-path>:
    +pre-hook: SQL-statement | [SQL-statement]
    +post-hook: SQL-statement | [SQL-statement]
```

snapshots/snapshot.yml

```
snapshots:
  - name: [<snapshot_name>]
    config:
      pre_hook: <sql-statement> | [<sql-statement>]
      post_hook: <sql-statement> | [<sql-statement>]
```

## Definition[​](#definition "Direct link to Definition")

A SQL statement (or list of SQL statements) to be run before or after a model, seed, or snapshot is built.

Pre- and post-hooks can also call macros that return SQL statements. If your macro depends on values available only at execution time, such as using model configurations or `ref()` calls to other resources as inputs, you will need to [wrap your macro call in an extra set of curly braces](https://docs.getdbt.com/best-practices/dont-nest-your-curlies#an-exception).

### Why would I use hooks?[​](#why-would-i-use-hooks "Direct link to Why would I use hooks?")

dbt aims to provide all the boilerplate SQL you need (DDL, DML, and DCL) via out-of-the-box functionality, which you can configure quickly and concisely. In some cases, there may be SQL that you want or need to run, specific to functionality in your data platform, which dbt does not (yet) offer as a built-in feature. In those cases, you can write the exact SQL you need, using dbt's compilation context, and pass it into a `pre-` or `post-` hook to run before or after your model, seed, or snapshot.

#### The render method[​](#the-render-method "Direct link to The render method")

The `.render()` method is generally used to resolve or evaluate Jinja expressions (such as `{{ source(...) }}`) during runtime.

When using the `--empty flag`, dbt may skip processing `ref()` or `source()` for optimization. To avoid compilation errors and to explicitly tell dbt to process a specific relation (`ref()` or `source()`), use the `.render()` method in your model file. For example:

models.sql

```
{{ config(
    pre_hook = [
        "alter external table {{ source('sys', 'customers').render() }} refresh"
    ]
) }}

select ...
```

## Examples[​](#examples "Direct link to Examples")

### [Redshift] Unload one model to S3[​](#redshift-unload-one-model-to-s3 "Direct link to [Redshift] Unload one model to S3")

model.sql

```
{{ config(
  post_hook = "unload ('select from {{ this }}') to 's3:/bucket_name/{{ this }}"
) }}

select ...
```

See: [Redshift docs on `UNLOAD`](https://docs.aws.amazon.com/redshift/latest/dg/r_UNLOAD.html)

### [Apache Spark] Analyze tables after creation[​](#apache-spark-analyze-tables-after-creation "Direct link to [Apache Spark] Analyze tables after creation")

dbt\_project.yml

```
models:
  jaffle_shop: # this is the project name
    marts:
      finance:
        +post-hook:
          # this can be a list
          - "analyze table {{ this }} compute statistics for all columns"
          # or call a macro instead
          - "{{ analyze_table() }}"
```

See: [Apache Spark docs on `ANALYZE TABLE`](https://spark.apache.org/docs/latest/sql-ref-syntax-aux-analyze-table.html)

### Additional examples[​](#additional-examples "Direct link to Additional examples")

We've compiled some more in-depth examples [here](https://docs.getdbt.com/docs/build/hooks-operations#additional-examples).

## Usage notes[​](#usage-notes "Direct link to Usage notes")

### Hooks are cumulative[​](#hooks-are-cumulative "Direct link to Hooks are cumulative")

If you define hooks in both your `dbt_project.yml` and in the `config` block of a model, both sets of hooks will be applied to your model.

### Execution ordering[​](#execution-ordering "Direct link to Execution ordering")

If multiple instances of any hooks are defined, dbt will run each hook using the following ordering:

1. Hooks from dependent packages will be run before hooks in the active package.
2. Hooks defined within the model itself will be run after hooks defined in `dbt_project.yml`.
3. Hooks within a given context will be run in the order in which they are defined.

### Transaction behavior[​](#transaction-behavior "Direct link to Transaction behavior")

If you're using an adapter that uses transactions (namely Postgres or Redshift), it's worth noting that by default hooks are executed inside of the same transaction as your model being created.

There may be occasions where you need to run these hooks *outside* of a transaction, for example:

* You want to run a `VACUUM` in a `post-hook`, however, this cannot be executed within a transaction ([Redshift docs](https://docs.aws.amazon.com/redshift/latest/dg/r_VACUUM_command.html#r_VACUUM_usage_notes))
* You want to insert a record into an audit table at the start of a run and do not want that statement rolled back if the model creation fails.

To achieve this behavior, you can use one of the following syntaxes:

* Important note: Do not use this syntax if you are using a database where dbt does not support transactions. This includes databases like Snowflake, BigQuery, and Spark or Databricks.

* Use before\_begin and after\_commit* Use a dictionary* Use dbt\_project.yml

#### Config block: use the `before_begin` and `after_commit` helper macros[​](#config-block-use-the-before_begin-and-after_commit-helper-macros "Direct link to config-block-use-the-before_begin-and-after_commit-helper-macros")

models/<modelname>.sql

```
{{
  config(
    pre_hook=before_begin("SQL-statement"),
    post_hook=after_commit("SQL-statement")
  )
}}

select ...
```

#### Config block: use a dictionary[​](#config-block-use-a-dictionary "Direct link to Config block: use a dictionary")

models/<modelname>.sql

```
{{
  config(
    pre_hook={
      "sql": "SQL-statement",
      "transaction": False
    },
    post_hook={
      "sql": "SQL-statement",
      "transaction": False
    }
  )
}}

select ...
```

#### `dbt_project.yml`: Use a dictionary[​](#dbt_projectyml-use-a-dictionary "Direct link to dbt_projectyml-use-a-dictionary")

dbt\_project.yml

```
models:
  +pre-hook:
    sql: "SQL-statement"
    transaction: false
  +post-hook:
    sql: "SQL-statement"
    transaction: false
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Using the + prefix](https://docs.getdbt.com/reference/resource-configs/plus-prefix)[Next

schema](https://docs.getdbt.com/reference/resource-configs/schema)

* [Definition](#definition)
  + [Why would I use hooks?](#why-would-i-use-hooks)* [Examples](#examples)
    + [[Redshift] Unload one model to S3](#redshift-unload-one-model-to-s3)+ [[Apache Spark] Analyze tables after creation](#apache-spark-analyze-tables-after-creation)+ [Additional examples](#additional-examples)* [Usage notes](#usage-notes)
      + [Hooks are cumulative](#hooks-are-cumulative)+ [Execution ordering](#execution-ordering)+ [Transaction behavior](#transaction-behavior)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/pre-hook-post-hook.md)
