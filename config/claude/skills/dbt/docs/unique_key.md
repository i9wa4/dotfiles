---
title: "unique_key | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/unique_key"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [General configs](https://docs.getdbt.com/category/general-configs)* unique\_key

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Funique_key+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Funique_key+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Funique_key+so+I+can+ask+questions+about+it.)

On this page

unique\_key identifies records for incremental models or snapshots, ensuring changes are captured or updated correctly.

* Models* Snapshots

Configure the `unique_key` in the `config` block of your [incremental model's](https://docs.getdbt.com/docs/build/incremental-models) SQL file, in your `models/properties.yml` file, or in your `dbt_project.yml` file.

models/my\_incremental\_model.sql

```
{{
    config(
        materialized='incremental',
        unique_key='id'
    )
}}
```

models/properties.yml

```
models:
  - name: my_incremental_model
    description: "An incremental model example with a unique key."
    config:
      materialized: incremental
      unique_key: id
```

dbt\_project.yml

```
name: jaffle_shop

models:
  jaffle_shop:
    staging:
      +unique_key: id
```

dbt\_project.yml

```
snapshots:
  <resource-path>:
    +unique_key: column_name_or_expression
```

## Description[​](#description "Direct link to Description")

A column name or expression that uniquely identifies each record in the inputs of a snapshot or incremental model. dbt uses this key to match incoming records to existing records in the target table (either a snapshot or an incremental model) so that changes can be captured or updated correctly:

* In an incremental model, dbt replaces the old row (like a merge key or upsert).
* In a snapshot, dbt keeps history, storing multiple rows for that same `unique_key` as it evolves over time.

In dbt "Latest" release track and from dbt v1.9, [snapshots](https://docs.getdbt.com/docs/build/snapshots) are defined and configured in YAML files within your `snapshots/` directory. You can specify one or multiple `unique_key` values within your snapshot YAML file's `config` key.

caution

Providing a non-unique key will result in unexpected snapshot results. dbt **will not** test the uniqueness of this key, consider [testing](https://docs.getdbt.com/blog/primary-key-testing#how-to-test-primary-keys-with-dbt) the source data to ensure that this key is indeed unique.

## Default[​](#default "Direct link to Default")

This parameter is optional. If you don't provide a `unique_key`, your adapter will default to using `incremental_strategy: append`.

If you leave out the `unique_key` parameter and use strategies like `merge`, `insert_overwrite`, `delete+insert`, or `microbatch`, the adapter will fall back to using `incremental_strategy: append`.

This is different for BigQuery:

* For `incremental_strategy = merge`, you must provide a `unique_key`; leaving it out leads to ambiguous or failing behavior.
* For `insert_overwrite` or `microbatch`, `unique_key` is not required because they work by partition replacement rather than row-level upserts.

## Examples[​](#examples "Direct link to Examples")

### Use an `id` column as a unique key[​](#use-an-id-column-as-a-unique-key "Direct link to use-an-id-column-as-a-unique-key")

* Models* Snapshots

In this example, the `id` column is the unique key for an incremental model.

models/my\_incremental\_model.sql

```
{{
    config(
        materialized='incremental',
        unique_key='id'
    )
}}

select * from ..
```

In this example, the `id` column is used as a unique key for a snapshot.

You can also specify configurations in your `dbt_project.yml` file if multiple snapshots share the same `unique_key`:

dbt\_project.yml

```
snapshots:
  <resource-path>:
    +unique_key: id
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

tags](https://docs.getdbt.com/reference/resource-configs/tags)[Next

Model properties](https://docs.getdbt.com/reference/model-properties)

* [Description](#description)* [Default](#default)* [Examples](#examples)
      + [Use an `id` column as a unique key](#use-an-id-column-as-a-unique-key)+ [Use multiple unique keys](#use-multiple-unique-keys)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/unique_key.md)
