---
title: "meta | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/meta"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [General configs](https://docs.getdbt.com/category/general-configs)* meta

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fmeta+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fmeta+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fmeta+so+I+can+ask+questions+about+it.)

* Models* Sources* Seeds* Snapshots* Tests* Unit tests* Analyses* Macros* Exposures* Semantic models* Metrics* Saved queries

dbt\_project.yml

```
models:
  <resource-path>:
    +meta: {<dictionary>}
```

models/schema.yml

```
models:
  - name: model_name
    config:
      meta: {<dictionary>}

    columns:
      - name: column_name
        config:
          meta: {<dictionary>} # changed to config in v1.10 and backported to 1.9
```

The `meta` config can also be defined:

* under the `models` config block in `dbt_project.yml`
* in a `config()` Jinja macro within a model's SQL file

See [configs and properties](https://docs.getdbt.com/reference/configs-and-properties) for details.

dbt\_project.yml

```
sources:
  <resource-path>:
    +meta: {<dictionary>}
```

models/schema.yml

```
sources:
  - name: model_name
    config:
      meta: {<dictionary>}

    tables:
      - name: table_name
        config:
          meta: {<dictionary>}

        columns:
          - name: column_name
            config:
              meta: {<dictionary>} # changed to config in v1.10 and backported to 1.9
```

dbt\_project.yml

```
seeds:
  <resource-path>:
    +meta: {<dictionary>}
```

seeds/schema.yml

```
seeds:
  - name: seed_name
    config:
      meta: {<dictionary>}

    columns:
      - name: column_name
        config:
          meta: {<dictionary>} # changed to config in v1.10 and backported to 1.9
```

The `meta` config can also be defined under the `seeds` config block in `dbt_project.yml`. See [configs and properties](https://docs.getdbt.com/reference/configs-and-properties) for details.

dbt\_project.yml

```
snapshots:
  <resource-path>:
    +meta: {<dictionary>}
```

snapshots/schema.yml

```
snapshots:
  - name: snapshot_name
    config:
      meta: {<dictionary>}

    columns:
      - name: column_name
        config:
          meta: {<dictionary>} # changed to config in v1.10 and backported to 1.9
```

The `meta` config can also be defined:

* under the `snapshots` config block in `dbt_project.yml`
* in a `config()` Jinja macro within a snapshot's SQL block

See [configs and properties](https://docs.getdbt.com/reference/configs-and-properties) for details.

You can't add YAML `meta` configs for [generic tests](https://docs.getdbt.com/docs/build/data-tests#generic-data-tests). However, you can add `meta` properties to [singular tests](https://docs.getdbt.com/docs/build/data-tests#singular-data-tests) using `config()` at the top of the test file.

💡Did you know...

Available from dbt v1.8 or with the [dbt "Latest" release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks).

dbt\_project.yml

```
unit_tests:
  <resource-path>:
    +meta: {<dictionary>}
```

models/<filename>.yml

```
unit_tests:
  - name: <test-name>
    config:
      meta: {<dictionary>}
```

The `meta` config is not currently supported for analyses.

dbt\_project.yml

```
macros:
  <resource-path>:
    +meta: {<dictionary>}
```

macros/schema.yml

```
macros:
  - name: macro_name
    config:
      meta: {<dictionary>} # changed to config in v1.10

    arguments:
      - name: argument_name
```

dbt\_project.yml

```
exposures:
  <resource-path>:
    +meta: {<dictionary>}
```

models/exposures.yml

```
exposures:
  - name: exposure_name
    config:
      meta: {<dictionary>} # changed to config in v1.10
```

Configure `meta` in the your [semantic models](https://docs.getdbt.com/docs/build/semantic-models) YAML file or under the `semantic-models` config block in the `dbt_project.yml` file.

The `meta` config can also be defined under the `semantic-models` config block in `dbt_project.yml`. See [configs and properties](https://docs.getdbt.com/reference/configs-and-properties) for details.

dbt\_project.yml

```
metrics:
  <resource-path>:
    +meta: {<dictionary>}
```

models/metrics.yml

```
metrics:
  - name: number_of_people
    label: "Number of people"
    description: Total count of people
    type: simple
    type_params:
      measure: people
    config:
      meta:
        my_meta_config: 'config_value'
```

dbt\_project.yml

```
saved-queries:
  <resource-path>:
    +meta: {<dictionary>}
```

models/semantic\_models.yml

```
saved_queries:
  - name: saved_query_name
    config:
      meta: {<dictionary>}
```

## Definition[​](#definition "Direct link to Definition")

The `meta` field can be used to set metadata for a resource and accepts any key-value pairs. This metadata is compiled into the `manifest.json` file generated by dbt, and is viewable in the auto-generated documentation.

Depending on the resource you're configuring, `meta` may be available within the `config` property, and/or as a top-level key. (For backwards compatibility, `meta` is often (but not always) supported as a top-level key, though without the capabilities of config inheritance.)

## Examples[​](#examples "Direct link to Examples")

### Designate a model owner[​](#designate-a-model-owner "Direct link to Designate a model owner")

Additionally, indicate the maturity of a model using a `model_maturity:` key.

models/schema.yml

```
models:
  - name: users
    config:
      meta:
        owner: "@alice"
        model_maturity: in dev
```

### Designate a source column as containing PII[​](#designate-a-source-column-as-containing-pii "Direct link to Designate a source column as containing PII")

models/schema.yml

```
sources:
  - name: salesforce
    tables:
      - name: account
        config:
          meta:
            contains_pii: true
        columns:
          - name: email
            config:
              meta: # changed to config in v1.10 and backported to 1.9
                contains_pii: true
```

### Configure one meta attribute for all seeds[​](#configure-one-meta-attribute-for-all-seeds "Direct link to Configure one meta attribute for all seeds")

dbt\_project.yml

```
seeds:
  +meta:
    favorite_color: red
```

### Override one meta attribute for a single model[​](#override-one-meta-attribute-for-a-single-model "Direct link to Override one meta attribute for a single model")

models/my\_model.sql

```
{{ config(meta = {
    'single_key': 'override'
}) }}

select 1 as id
```



### Assign owner and favorite\_color in the dbt\_project.yml as a config property[​](#assign-owner-and-favorite_color-in-the-dbt_projectyml-as-a-config-property "Direct link to Assign owner and favorite_color in the dbt_project.yml as a config property")

dbt\_project.yml

```
models:
  jaffle_shop:
    +meta:
      owner: "@alice"
      favorite_color: red
```

### Assign meta to semantic model[​](#assign-meta-to-semantic-model "Direct link to Assign meta to semantic model")

The following example shows how to assign a `meta` value to a [semantic model](https://docs.getdbt.com/docs/build/semantic-models) in the `semantic_model.yml` file and `dbt_project.yml` file:

* Semantic model* dbt\_project.yml

```
semantic_models:
  - name: transaction
    model: ref('fact_transactions')
    description: "Transaction fact table at the transaction level. This table contains one row per transaction and includes the transaction timestamp."
    defaults:
      agg_time_dimension: transaction_date
    config:
      meta:
        data_owner: "Finance team"
        used_in_reporting: true
```

```
semantic-models:
  jaffle_shop:
    +meta:
      used_in_reporting: true
```

### Assign meta to dimensions, measures, entities[​](#assign-meta-to-dimensions-measures-entities "Direct link to Assign meta to dimensions, measures, entities")

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

group](https://docs.getdbt.com/reference/resource-configs/group)[Next

persist\_docs](https://docs.getdbt.com/reference/resource-configs/persist_docs)
