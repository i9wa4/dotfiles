---
title: "Semantic manifest | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/artifacts/sl-manifest"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt Artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts)* Semantic manifest

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fartifacts%2Fsl-manifest+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fartifacts%2Fsl-manifest+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fartifacts%2Fsl-manifest+so+I+can+ask+questions+about+it.)

On this page

**Produced by:** Any command that parses your project. This includes all commands *except* [`deps`](https://docs.getdbt.com/reference/commands/deps), [`clean`](https://docs.getdbt.com/reference/commands/clean), [`debug`](https://docs.getdbt.com/reference/commands/debug), and [`init`](https://docs.getdbt.com/reference/commands/init).

dbt creates an [artifact](https://docs.getdbt.com/reference/artifacts/dbt-artifacts) file called the *Semantic Manifest* (`semantic_manifest.json`), which MetricFlow requires to build and run metric queries properly for the dbt Semantic Layer. This artifact contains comprehensive information about your dbt Semantic Layer. It is an internal file that acts as the integration point with MetricFlow.

By using the semantic manifest produced by dbt Core, MetricFlow will instantiate a data flow plan and generate SQL from Semantic Layer query requests. It's a valuable reference that you can use to understand the structure and details of your data models.

Similar to the [`manifest.json` file](https://docs.getdbt.com/reference/artifacts/manifest-json), the `semantic_manifest.json` file also lives in the [target directory](https://docs.getdbt.com/reference/global-configs/json-artifacts) of your dbt project where dbt stores various artifacts (such as compiled models and tests) generated during the execution of your project.

There are two reasons why `semantic_manifest.json` exists alongside `manifest.json`:

* Deserialization: `dbt-core` and MetricFlow use different libraries for handling data serialization.
* Efficiency and performance: MetricFlow and the dbt Semantic Layer need specific semantic details from the manifest. By trimming down the information printed into `semantic_manifest.json`, the process becomes more efficient and enables faster data handling between `dbt-core` and MetricFlow.

## Top-level keys[​](#top-level-keys "Direct link to Top-level keys")

Top-level keys for the semantic manifest are:

* `semantic_models` — Starting points of data with entities, dimensions, and measures, and correspond to models in your dbt project.
* `metrics` — Functions combining measures, constraints, and so on to define quantitative indicators.
* `project_configuration` — Contains information around your project configurations
* `saved_queries` — Saves commonly used queries in MetricFlow

### Example[​](#example "Direct link to Example")

target/semantic\_manifest.json

```
{
    "semantic_models": [
        {
            "name": "semantic model name",
            "defaults": null,
            "description": "semantic model description",
            "node_relation": {
                "alias": "model alias",
                "schema_name": "model schema",
                "database": "model db",
                "relation_name": "Fully qualified relation name"
            },
            "entities": ["entities in the semantic model"],
            "measures": ["measures in the semantic model"],
            "dimensions": ["dimensions in the semantic model" ],
        }
    ],
    "metrics": [
        {
            "name": "name of the metric",
            "description": "metric description",
            "type": "metric type",
            "type_params": {
                "measure": {
                    "name": "name for measure",
                    "filter": "filter for measure",
                    "alias": "alias for measure"
                },
                "numerator": null,
                "denominator": null,
                "expr": null,
                "window": null,
                "grain_to_date": null,
                "metrics": ["metrics used in defining the metric. this is used in derived metrics"],
                "input_measures": []
            },
            "filter": null,
            "metadata": null
        }
    ],
    "project_configuration": {
        "time_spine_table_configurations": [
            {
                "location": "fully qualified table name for timespine",
                "column_name": "date column",
                "grain": "day"
            }
        ],
        "metadata": null,
        "dsi_package_version": {}
    },
    "saved_queries": [
        {
            "name": "name of the saved query",
            "query_params": {
                "metrics": [
                    "metrics used in the saved query"
                ],
                "group_by": [
                    "TimeDimension('model_primary_key__date_column', 'day')",
                    "Dimension('model_primary_key__metric_one')",
                    "Dimension('model__dimension')"
                ],
                "where": null
            },
            "description": "Description of the saved query",
            "metadata": null,
            "label": null,
            "exports": [
                {
                    "name": "saved_query_name",
                    "config": {
                        "export_as": "view",
                        "schema_name": null,
                        "alias": null
                    }
                }
            ]
        }
    ]
}
```

## Related docs[​](#related-docs "Direct link to Related docs")

* [Semantic Layer API](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-api-overview)
* [About dbt artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Sources](https://docs.getdbt.com/reference/artifacts/sources-json)

* [Top-level keys](#top-level-keys)
  + [Example](#example)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/artifacts/sl-manifest.md)
