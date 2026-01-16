---
title: "About model object | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/model"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* model

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fmodel+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fmodel+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fmodel+so+I+can+ask+questions+about+it.)

On this page

`model` is the dbt [graph object](https://docs.getdbt.com/reference/dbt-jinja-functions/graph) (or node) for the current model. It can be used to:

* Access `config` settings, say, in a post-hook
* Access the path to the model

For example:

```
{% if model.config.materialized == 'view' %}
  {{ log(model.name ~ " is a view.", info=True) }}
{% endif %}
```

To view the contents of `model` for a given model:

* Command line interface* Studio IDE

If you're using the command line interface (CLI), use [log()](https://docs.getdbt.com/reference/dbt-jinja-functions/log) to print the full contents:

```
{{ log(model, info=True) }}
```

If you're using the Studio IDE, compile the following to print the full contents:


```
{{ model | tojson(indent = 4) }}
```

## Batch properties for microbatch models[​](#batch-properties-for-microbatch-models "Direct link to Batch properties for microbatch models")

Starting in dbt Core v1.9, the model object includes a `batch` property (`model.batch`), which provides details about the current batch when executing an [incremental microbatch](https://docs.getdbt.com/docs/build/incremental-microbatch) model. This property is only populated during the batch execution of a microbatch model.

The following table describes the properties of the `batch` object. Note that dbt appends the property to the `model` and `batch` objects.

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Property Description Example|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `id` The unique identifier for the batch within the context of the microbatch model. `model.batch.id`| `event_time_start` The start time of the batch's [`event_time`](https://docs.getdbt.com/reference/resource-configs/event-time) filter (inclusive). `model.batch.event_time_start`| `event_time_end` The end time of the batch's `event_time` filter (exclusive). `model.batch.event_time_end` | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Usage notes[​](#usage-notes "Direct link to Usage notes")

`model.batch` is only available during the execution of a microbatch model batch. Outside of the microbatch execution, `model.batch` is `None`, and its sub-properties aren't accessible.

#### Example of safeguarding access to batch properties[​](#example-of-safeguarding-access-to-batch-properties "Direct link to Example of safeguarding access to batch properties")

We recommend to always check if `model.batch` is populated before accessing its properties. To do this, use an `if` statement for safe access to `batch` properties:

```
{% if model.batch %}
  {{ log(model.batch.id) }}  # Log the batch ID #
  {{ log(model.batch.event_time_start) }}  # Log the start time of the batch #
  {{ log(model.batch.event_time_end) }}  # Log the end time of the batch #
{% endif %}
```

In this example, the `if model.batch` statement makes sure that the code only runs during a batch execution. `log()` is used to print the `batch` properties for debugging.

#### Example of log batch details[​](#example-of-log-batch-details "Direct link to Example of log batch details")

This is a practical example of how you might use `model.batch` in a microbatch model to log batch details for the `batch.id`:

```
{% if model.batch %}
  {{ log("Processing batch with ID: " ~ model.batch.id, info=True) }}
  {{ log("Batch event time range: " ~ model.batch.event_time_start ~ " to " ~ model.batch.event_time_end, info=True) }}
{% endif %}
```

In this example, the `if model.batch` statement makes sure that the code only runs during a batch execution. `log()` is used to print the `batch` properties for debugging.

## Model structure and JSON schema[​](#model-structure-and-json-schema "Direct link to Model structure and JSON schema")

To view the structure of `models` and their definitions:

* Refer to [dbt JSON Schema](https://schemas.getdbt.com/) for describing and consuming dbt generated artifacts
* Select the corresponding manifest version under **Manifest**. For example if you're on dbt v1.8, then you would select Manifest v12
  + The `manifest.json` version number is related to (but not *equal* to) your dbt version, so you *must* use the correct `manifest.json` version for your dbt version. To find the correct `manifest.json` version, refer to [Manifest](https://docs.getdbt.com/reference/artifacts/manifest-json) and select the dbt version on the top navigation (such as `v1.5`). This will help you find out which tags are associated with your model.
* Then go to `nodes` --> Select Additional properties --> `CompiledModelNode` or view other definitions/objects.

Use the following table to understand how the versioning pattern works and match the Manifest version with the dbt version:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| dbt version Manifest version|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | dbt Fusion Engine v2.0 v20 (Identical to [v12](https://schemas.getdbt.com/dbt/manifest/v12/index.html))| Core v1.11 [v12](https://schemas.getdbt.com/dbt/manifest/v12/index.html)| Core v1.10 [v12](https://schemas.getdbt.com/dbt/manifest/v12/index.html)| Core v1.9 [v12](https://schemas.getdbt.com/dbt/manifest/v12/index.html)| Core v1.8 [v12](https://schemas.getdbt.com/dbt/manifest/v12/index.html)| Core v1.7 [v11](https://schemas.getdbt.com/dbt/manifest/v11/index.html)| Core v1.6 [v10](https://schemas.getdbt.com/dbt/manifest/v10/index.html)| Core v1.5 [v9](https://schemas.getdbt.com/dbt/manifest/v9/index.html)| Core v1.4 [v8](https://schemas.getdbt.com/dbt/manifest/v8/index.html)| Core v1.3 [v7](https://schemas.getdbt.com/dbt/manifest/v7/index.html) | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Related docs[​](#related-docs "Direct link to Related docs")

* [dbt JSON Schema](https://schemas.getdbt.com/)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

log](https://docs.getdbt.com/reference/dbt-jinja-functions/log)[Next

modules](https://docs.getdbt.com/reference/dbt-jinja-functions/modules)

* [Batch properties for microbatch models](#batch-properties-for-microbatch-models)
  + [Usage notes](#usage-notes)* [Model structure and JSON schema](#model-structure-and-json-schema)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/model.md)
