---
title: "enabled | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/enabled"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [General configs](https://docs.getdbt.com/category/general-configs)* enabled

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fenabled+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fenabled+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fenabled+so+I+can+ask+questions+about+it.)

On this page

* Models* Seeds* Snapshots* Tests* Unit tests* Sources* Metrics* Exposures* Semantic models* Saved queries

dbt\_project.yml

```
models:
  <resource-path>:
    +enabled: true | false
```

models/<modelname>.sql

```
{{ config(
  enabled=true | false
) }}

select ...
```

dbt\_project.yml

```
seeds:
  <resource-path>:
    +enabled: true | false
```

dbt\_project.yml

```
snapshots:
  <resource-path>:
    +enabled: true | false
```

snapshots/<filename>.sql

```
# Configuring in a SQL file is a legacy method and not recommended. Use the YAML file instead.

{% snapshot snapshot_name %}

{{ config(
  enabled=true | false
) }}

select ...

{% endsnapshot %}
```

dbt\_project.yml

```
data_tests:
  <resource-path>:
    +enabled: true | false
```

tests/<filename>.sql

```
{% test <testname>() %}

{{ config(
  enabled=true | false
) }}

select ...

{% endtest %}
```

tests/<filename>.sql

```
{{ config(
  enabled=true | false
) }}
```

💡Did you know...

Available from dbt v1.8 or with the [dbt "Latest" release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks).

dbt\_project.yml

```
unit_tests:
  <resource-path>:
    +enabled: true | false
```

models/<filename>.yml

```
unit_tests:
  - name: [<test-name>]
    config:
      enabled: true | false
```

dbt\_project.yml

```
sources:
  <resource-path>:
    +enabled: true | false
```

models/properties.yml

```
sources:
  - name: [<source-name>]
    config:
      enabled: true | false
    tables:
      - name: [<source-table-name>]
        config:
          enabled: true | false
```

dbt\_project.yml

```
metrics:
  <resource-path>:
    +enabled: true | false
```

models/metrics.yml

```
metrics:
  - name: [<metric-name>]
    config:
      enabled: true | false
```

dbt\_project.yml

```
exposures:
  <resource-path>:
    +enabled: true | false
```

models/exposures.yml

```
exposures:
  - name: [<exposure-name>]
    config:
      enabled: true | false
```

dbt\_project.yml

```
semantic-models:
  <resource-path>:
    +enabled: true | false
```

models/semantic\_models.yml

```
semantic_models:
  - name: [<semantic_model_name>]
    config:
      enabled: true | false
```

dbt\_project.yml

```
saved-queries:
  <resource-path>:
    +enabled: true | false
```

models/semantic\_models.yml

```
saved_queries:
  - name: [<saved_query_name>]
    config:
      enabled: true | false
```

## Definition[​](#definition "Direct link to Definition")

An optional configuration for enabling or disabling a resource.

* Default: true

When a resource is disabled, dbt will not consider it as part of your project. Note that this can cause compilation errors.

If you instead want to exclude a model from a particular run, consider using the `--exclude` parameter as part of the [model selection syntax](https://docs.getdbt.com/reference/node-selection/syntax)

If you are disabling models because they are no longer being used, but you want to version control their SQL, consider making them an [analysis](https://docs.getdbt.com/docs/build/analyses) instead.

## Examples[​](#examples "Direct link to Examples")

### Disable a model in a package in order to use your own version of the model.[​](#disable-a-model-in-a-package-in-order-to-use-your-own-version-of-the-model "Direct link to Disable a model in a package in order to use your own version of the model.")

This could be useful if you want to change the logic of a model in a package. For example, if you need to change the logic in the `segment_web_page_views` from the `segment` package ([original model](https://github.com/dbt-labs/segment/blob/a8ff2f892b009a69ec36c3061a87e437f0b0ea93/models/base/segment_web_page_views.sql)):

1. Add a model named `segment_web_page_views` (the same name) to your own project.
2. To avoid a compilation error due to duplicate models, disable the segment package's version of the model like so:

dbt\_project.yml

```
models:
  segment:
    base:
      segment_web_page_views:
        +enabled: false
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

docs](https://docs.getdbt.com/reference/resource-configs/docs)[Next

event\_time](https://docs.getdbt.com/reference/resource-configs/event-time)

* [Definition](#definition)* [Examples](#examples)
    + [Disable a model in a package in order to use your own version of the model.](#disable-a-model-in-a-package-in-order-to-use-your-own-version-of-the-model)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/enabled.md)
