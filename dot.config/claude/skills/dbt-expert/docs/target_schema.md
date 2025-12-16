---
title: "target_schema | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/target_schema"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For snapshots](https://docs.getdbt.com/reference/snapshot-properties)* target\_schema

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ftarget_schema+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ftarget_schema+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ftarget_schema+so+I+can+ask+questions+about+it.)

On this page

note

Starting in dbt Core v1.9+, this functionality is no longer utilized. Use the [schema](https://docs.getdbt.com/reference/resource-configs/schema) config as an alternative to define a custom schema while still respecting the `generate_schema_name` macro.

Try it now in the [dbt "Latest" release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks).

dbt\_project.yml

```
snapshots:
  <resource-path>:
    +target_schema: string
```

snapshots/<filename>.sql

```
{{ config(
      target_schema="string"
) }}
```

## Description[​](#description "Direct link to Description")

The schema that dbt should build a [snapshot](https://docs.getdbt.com/docs/build/snapshots) table into. When `target_schema` is provided, snapshots build into the same `target_schema`, no matter who is running them.

On **BigQuery**, this is analogous to a `dataset`.

## Default[​](#default "Direct link to Default")

## Examples[​](#examples "Direct link to Examples")

### Build all snapshots in a schema named `snapshots`[​](#build-all-snapshots-in-a-schema-named-snapshots "Direct link to build-all-snapshots-in-a-schema-named-snapshots")

dbt\_project.yml

```
snapshots:
  +target_schema: snapshots
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

target\_database](https://docs.getdbt.com/reference/resource-configs/target_database)[Next

updated\_at](https://docs.getdbt.com/reference/resource-configs/updated_at)

* [Description](#description)* [Default](#default)* [Examples](#examples)
      + [Build all snapshots in a schema named `snapshots`](#build-all-snapshots-in-a-schema-named-snapshots)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/target_schema.md)
