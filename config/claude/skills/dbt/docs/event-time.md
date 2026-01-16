---
title: "event_time | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/event-time"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [General configs](https://docs.getdbt.com/category/general-configs)* event\_time

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fevent-time+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fevent-time+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fevent-time+so+I+can+ask+questions+about+it.)

On this page

💡Did you know...

Available from dbt v1.9 or with the [dbt "Latest" release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks).

* Models* Seeds* Snapshots* Sources

dbt\_project.yml

```
models:
  resource-path:
    +event_time: my_time_field
```

models/properties.yml

```
models:
  - name: model_name
    config:
      event_time: my_time_field
```

models/modelname.sql

```
{{ config(
    event_time='my_time_field'
) }}
```

dbt\_project.yml

```
seeds:
  resource-path:
    +event_time: my_time_field
```

seeds/properties.yml

```
seeds:
  - name: seed_name
    config:
      event_time: my_time_field
```

dbt\_project.yml

```
snapshots:
  resource-path:
    +event_time: my_time_field
```

dbt\_project.yml

```
sources:
  resource-path:
    +event_time: my_time_field
```

models/properties.yml

```
sources:
  - name: source_name
    config:
      event_time: my_time_field
```

## Definition[​](#definition "Direct link to Definition")

dbt uses `event_time` to understand when an event occurred. Configure it in your `dbt_project.yml` file, property YAML file, or config block for [models](https://docs.getdbt.com/docs/build/models), [seeds](https://docs.getdbt.com/docs/build/seeds), or [sources](https://docs.getdbt.com/docs/build/sources).

Required

For incremental microbatch models, if your upstream models don't have `event_time` configured, dbt *cannot* automatically filter them during batch processing and will perform full table scans on every batch run.

To avoid this, configure `event_time` on every upstream model that should be filtered. Learn how to exclude a model from auto-filtering by [opting out of auto-filtering](https://docs.getdbt.com/docs/build/incremental-microbatch#opting-out-of-auto-filtering).

### Usage[​](#usage "Direct link to Usage")

`event_time` is required for the [incremental microbatch](https://docs.getdbt.com/docs/build/incremental-microbatch) strategy and highly recommended for [Advanced CI's compare changes](https://docs.getdbt.com/docs/deploy/advanced-ci#optimizing-comparisons) in CI/CD workflows, where it ensures the same time-slice of data is correctly compared between your CI and production environments.

### Best practices[​](#best-practices "Direct link to Best practices")

Set the `event_time` to the name of the field that represents the actual timestamp of the event (like `account_created_at`). The timestamp of the event should represent "at what time did the row occur" rather than an event ingestion date. Marking a column as the `event_time` when it isn't, diverges from the semantic meaning of the column which may result in user confusion when other tools make use of the metadata.

However, if an ingestion date (like `loaded_at`, `ingested_at`, or `last_updated_at`) are the only timestamps you use, you can set `event_time` to these fields. Here are some considerations to keep in mind if you do this:

* Using `last_updated_at` or `loaded_at` — May result in duplicate entries in the resulting table in the data warehouse over multiple runs. Setting an appropriate [lookback](https://docs.getdbt.com/reference/resource-configs/lookback) value can reduce duplicates but it can't fully eliminate them since some updates outside the lookback window won't be processed.
* Using `ingested_at` — Since this column is created by your ingestion/EL tool instead of coming from the original source, it will change if/when you need to resync your connector for some reason. This means that data will be reprocessed and loaded into your warehouse for a second time against a second date. As long as this never happens (or you run a full refresh when it does), microbatches will be processed correctly when using `ingested_at`.

Here are some examples of recommended and not recommended `event_time` columns:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Status  Column name Description|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ Recommended `account_created_at` Represents the specific time when an account was created, making it a fixed event in time.|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ Recommended `session_began_at` Captures the exact timestamp when a user session started, which won’t change and directly ties to the event.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | ❌ Not recommended `_fivetran_synced` This represents the time the event was ingested, not when it happened.|  |  |  | | --- | --- | --- | | ❌ Not recommended `last_updated_at` Changes over time and isn't tied to the event itself. If used, note the considerations mentioned earlier in [best practices](#best-practices). | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Examples[​](#examples "Direct link to Examples")

* Models* Seeds* Snapshots* Sources

Here's an example in the `dbt_project.yml` file:

dbt\_project.yml

```
models:
  my_project:
    user_sessions:
      +event_time: session_start_time
```

Example in a properties YAML file:

models/properties.yml

```
models:
  - name: user_sessions
    config:
      event_time: session_start_time
```

Example in SQL model config block:

models/user\_sessions.sql

```
{{ config(
    event_time='session_start_time'
) }}
```

This setup sets `session_start_time` as the `event_time` for the `user_sessions` model.

Here's an example in the `dbt_project.yml` file:

dbt\_project.yml

```
seeds:
  my_project:
    my_seed:
      +event_time: record_timestamp
```

Example in a seed properties YAML:

seeds/properties.yml

```
seeds:
  - name: my_seed
    config:
      event_time: record_timestamp
```

This setup sets `record_timestamp` as the `event_time` for `my_seed`.

Here's an example in the `dbt_project.yml` file:

dbt\_project.yml

```
snapshots:
  my_project:
    my_snapshot:
      +event_time: record_timestamp
```

Example in a snapshot properties YAML:

my\_project/properties.yml

```
snapshots:
  - name: my_snapshot
    config:
      event_time: record_timestamp
```

This setup sets `record_timestamp` as the `event_time` for `my_snapshot`.

Here's an example of source properties YAML file:

models/properties.yml

```
sources:
  - name: source_name
    tables:
      - name: table_name
        config:
          event_time: event_timestamp
```

This setup sets `event_timestamp` as the `event_time` for the specified source table.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

enabled](https://docs.getdbt.com/reference/resource-configs/enabled)[Next

full\_refresh](https://docs.getdbt.com/reference/resource-configs/full_refresh)

* [Definition](#definition)
  + [Usage](#usage)+ [Best practices](#best-practices)* [Examples](#examples)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/event-time.md)
