---
title: "About config property | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-properties/config"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [General properties](https://docs.getdbt.com/category/general-properties)* config

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Fconfig+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Fconfig+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-properties%2Fconfig+so+I+can+ask+questions+about+it.)

* Models* Seeds* Snapshots* Tests* Unit tests* Sources* Metrics* Exposures* Semantic models* Saved queries

models/<filename>.yml

```
models:
  - name: <model_name>
    config:
      <model_config>: <config_value>
      ...
```

seeds/<filename>.yml

```
seeds:
  - name: <seed_name>
    config:
      <seed_config>: <config_value>
      ...
```

snapshots/<filename>.yml

```
snapshots:
  - name: <snapshot_name>
    config:
      <snapshot_config>: <config_value>
      ...
```

<resource\_path>/<filename>.yml

```
<resource_type>:
  - name: <resource_name>
    data_tests:
      - <test_name>:
          arguments: # available in v1.10.5 and higher. Older versions can set the <argument_name> as the top-level property.
            <argument_name>: <argument_value>
          config:
            <test_config>: <config-value>
            ...

    columns:
      - name: <column_name>
        data_tests:
          - <test_name>
          - <test_name>:
              arguments: # available in v1.10.5 and higher. Older versions can set the <argument_name> as the top-level property.
                <argument_name>: <argument_value>
              config:
                <test_config>: <config-value>
                ...
```

💡Did you know...

Available from dbt v1.8 or with the [dbt "Latest" release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks).

models/<filename>.yml

```
unit_tests:
  - name: <test-name>
    config:
      enabled: true | false
      meta: {dictionary}
      tags: <string>
```

models/<filename>.yml

```
sources:
  - name: <source_name>
    config:
      <source_config>: <config_value>
    tables:
      - name: <table_name>
        config:
          <source_config>: <config_value>
```

models/<filename>.yml

```
metrics:
  - name: <metric_name>
    config:
      enabled: true | false
      group: <string>
      meta: {dictionary}
```

models/<filename>.yml

```
exposures:
  - name: <exposure_name>
    config:
      enabled: true | false
      meta: {dictionary}
```

models/<filename>.yml

```
semantic_models:
  - name: <semantic_model_name>
    config:
      enabled: true | false
      group: <string>
      meta: {dictionary}
```

models/<filename>.yml

```
saved-queries:
  - name: <saved_query_name>
    config:
      cache:
        enabled: true | false
      enabled: true | false
      group: <string>
      meta: {dictionary}
      schema: <string>
    exports:
      - name: <export_name>
        config:
          export_as: view | table
          alias: <string>
          schema: <string>
```

## Definition[​](#definition "Direct link to Definition")

The `config` property allows you to configure resources at the same time you're defining properties in YAML files.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

columns](https://docs.getdbt.com/reference/resource-properties/columns)[Next

constraints](https://docs.getdbt.com/reference/resource-properties/constraints)
