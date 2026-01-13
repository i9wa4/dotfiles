---
title: "materialized | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/materialized"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For models](https://docs.getdbt.com/reference/model-properties)* materialized

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fmaterialized+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fmaterialized+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fmaterialized+so+I+can+ask+questions+about+it.)

On this page

* Project file* Property file* Config block

dbt\_project.yml

```
config-version: 2

models:
  <resource-path>:
    +materialized: <materialization_name>
```

models/properties.yml

```
models:
  - name: <model_name>
    config:
      materialized: <materialization_name>
```

models/<model\_name>.sql

```
{{ config(
  materialized="<materialization_name>"
) }}

select ...
```

## Definition[​](#definition "Direct link to Definition")

[Materializations](https://docs.getdbt.com/docs/build/materializations#materializations) are strategies for persisting dbt models in a warehouse. These are the materialization types built into dbt:

* `ephemeral` — [ephemeral](https://docs.getdbt.com/docs/build/materializations#ephemeral) models are not directly built into the database
* `table` — a model is rebuilt as a [table](https://docs.getdbt.com/docs/build/materializations#table) on each run
* `view` — a model is rebuilt as a [view](https://docs.getdbt.com/docs/build/materializations#view) on each run
* `materialized_view` — allows the creation and maintenance of [materialized views](https://docs.getdbt.com/docs/build/materializations#materialized-view) in the target database
* `incremental` — [incremental](https://docs.getdbt.com/docs/build/materializations#incremental) models allow dbt to insert or update records into a table since the last time that model was run

You can also configure [custom materializations](https://docs.getdbt.com/guides/create-new-materializations?step=1) in dbt. Custom materializations are a powerful way to extend dbt's functionality to meet your specific needs.

## Creation Precedence[​](#creation-precedence "Direct link to Creation Precedence")

Materializations are implemented following this "drop through" life cycle:

1. If a model does not exist with the provided path, create the new model.
2. If a model exists, but has a different type, drop the existing model and create the new model.
3. If [`--full-refresh`](https://docs.getdbt.com/reference/resource-configs/full_refresh) is supplied, replace the existing model regardless of configuration changes and the [`on_configuration_change`](https://docs.getdbt.com/reference/resource-configs/on_configuration_change) setting.
4. If there are no configuration changes, perform the default action for that type (e.g. apply refresh for a materialized view).
5. Determine whether to apply the configuration changes according to the `on_configuration_change` setting.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

lookback](https://docs.getdbt.com/reference/resource-configs/lookback)[Next

model\_name](https://docs.getdbt.com/reference/resource-properties/model_name)

* [Definition](#definition)* [Creation Precedence](#creation-precedence)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/materialized.md)
