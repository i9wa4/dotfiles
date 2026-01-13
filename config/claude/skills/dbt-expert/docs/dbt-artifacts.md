---
title: "About dbt artifacts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/artifacts/dbt-artifacts"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * dbt Artifacts

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fartifacts%2Fdbt-artifacts+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fartifacts%2Fdbt-artifacts+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fartifacts%2Fdbt-artifacts+so+I+can+ask+questions+about+it.)

On this page

With every invocation, dbt generates and saves one or more *artifacts*. Several of these are JSON files (`semantic_manifest.json`, `manifest.json`, `catalog.json`, `run_results.json`, and `sources.json`) that are used to power:

* [documentation](https://docs.getdbt.com/docs/explore/build-and-view-your-docs)
* [state](https://docs.getdbt.com/reference/node-selection/syntax#about-node-selection)
* [visualizing source freshness](https://docs.getdbt.com/docs/build/sources#source-data-freshness)

They could also be used to:

* gain insights into your [Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl)
* calculate project-level test coverage
* perform longitudinal analysis of run timing
* identify historical changes in table structure
* do much, much more

### When are artifacts produced? [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#when-are-artifacts-produced- "Direct link to when-are-artifacts-produced-")

Most dbt commands (and corresponding RPC methods) produce artifacts:

* [semantic manifest](https://docs.getdbt.com/reference/artifacts/sl-manifest): produced whenever your dbt project is parsed
* [manifest](https://docs.getdbt.com/reference/artifacts/manifest-json): produced by commands that read and understand your project
* [run results](https://docs.getdbt.com/reference/artifacts/run-results-json): produced by commands that run, compile, or catalog nodes in your DAG
* [catalog](https://docs.getdbt.com/reference/artifacts/catalog-json): produced by `docs generate`
* [sources](https://docs.getdbt.com/reference/artifacts/sources-json): produced by `source freshness`

When running commands from the [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation), all artifacts are downloaded by default. If you want to change this behavior, refer to [How to skip artifacts from being downloaded](https://docs.getdbt.com/docs/cloud/configure-cloud-cli#how-to-skip-artifacts-from-being-downloaded).

## Where are artifacts produced?[​](#where-are-artifacts-produced "Direct link to Where are artifacts produced?")

By default, artifacts are written to the `/target` directory of your dbt project. You can configure the location using the [`target-path` flag](https://docs.getdbt.com/reference/global-configs/json-artifacts).

## Common metadata[​](#common-metadata "Direct link to Common metadata")

All artifacts produced by dbt include a `metadata` dictionary with these properties:

* `dbt_version`: Version of dbt that produced this artifact. For details about release versioning, refer to [Versioning](https://docs.getdbt.com/reference/commands/version#versioning).
* `dbt_schema_version`: URL of this artifact's schema. See notes below.
* `generated_at`: Timestamp in UTC when this artifact was produced.
* `adapter_type`: The adapter (database), e.g. `postgres`, `spark`, etc.
* `env`: Any environment variables prefixed with `DBT_ENV_CUSTOM_ENV_` will be included in a dictionary, with the prefix-stripped variable name as its key.
* [`invocation_id`](https://docs.getdbt.com/reference/dbt-jinja-functions/invocation_id): Unique identifier for this dbt invocation

In the manifest, the `metadata` may also include:

* `send_anonymous_usage_stats`: Whether this invocation sent [anonymous usage statistics](https://docs.getdbt.com/reference/global-configs/usage-stats) while executing.
* `project_name`: The `name` defined in the root project's `dbt_project.yml`. (Added in manifest v10 / dbt Core v1.6)
* `project_id`: Project identifier, hashed from `project_name`, sent with anonymous usage stats if enabled.
* `user_id`: User identifier, stored by default in `~/dbt/.user.yml`, sent with anonymous usage stats if enabled.

#### Notes:[​](#notes "Direct link to Notes:")

* The structure of dbt artifacts is canonized by [JSON schemas](https://json-schema.org/), which are hosted at [schemas.getdbt.com](https://schemas.getdbt.com/).
* Artifact versions may change in any minor version of dbt (`v1.x.0`). Each artifact is versioned independently.

## Related docs[​](#related-docs "Direct link to Related docs")

* [Other artifacts](https://docs.getdbt.com/reference/artifacts/other-artifacts) files such as `index.html` or `graph_summary.json`.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

dbt Classes](https://docs.getdbt.com/reference/dbt-classes)[Next

About dbt artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts)

* [When are artifacts produced?](#when-are-artifacts-produced-) * [Where are artifacts produced?](#where-are-artifacts-produced)* [Common metadata](#common-metadata)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/artifacts/dbt-artifacts.md)
