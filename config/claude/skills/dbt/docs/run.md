---
title: "About dbt run command | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/commands/run"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [List of commands](https://docs.getdbt.com/category/list-of-commands)* run

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Frun+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Frun+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Frun+so+I+can+ask+questions+about+it.)

On this page

## Overview[​](#overview "Direct link to Overview")

The `dbt run` command only applies to models. It doesn't run tests, snapshots, seeds, or other resource types. To run those commands, use the appropriate dbt commands found in the [dbt commands](https://docs.getdbt.com/reference/dbt-commands) section — such as `dbt test`, `dbt snapshot`, or `dbt seed`. Alternatively, use `dbt build` with a [resource type selector](https://docs.getdbt.com/reference/node-selection/methods#resource_type).

You can use the `dbt run` command when you want to build or rebuild models in your project.

### How does `dbt run` work?[​](#how-does-dbt-run-work "Direct link to how-does-dbt-run-work")

* `dbt run` executes compiled SQL model files against the current `target` database.
* dbt connects to the target database and runs the relevant SQL required to materialize all data models using the specified materialization strategies.
* Models are run in the order defined by the dependency graph generated during compilation. Intelligent multi-threading is used to minimize execution time without violating dependencies.
* Deploying new models frequently involves destroying prior versions of these models. In these cases, `dbt run` minimizes downtime by first building each model with a temporary name, then dropping and renaming within a single transaction (for adapters that support transactions).

## Refresh incremental models[​](#refresh-incremental-models "Direct link to Refresh incremental models")

If you provide the `--full-refresh` flag to `dbt run`, dbt will treat incremental models as table models. This is useful when

1. The schema of an incremental model changes and you need to recreate it.
2. You want to reprocess the entirety of the incremental model because of new logic in the model code.

bash

```
dbt run --full-refresh
```

You can also supply the flag by its short name: `dbt run -f`.

In the dbt compilation context, this flag will be available as [flags.FULL\_REFRESH](https://docs.getdbt.com/reference/dbt-jinja-functions/flags). Further, the `is_incremental()` macro will return `false` for *all* models in response when the `--full-refresh` flag is specified.

models/example.sql

```
select * from all_events

-- if the table already exists and `--full-refresh` is
-- not set, then only add new records. otherwise, select
-- all records.
{% if is_incremental() %}
   where collector_tstamp > (
     select coalesce(max(max_tstamp), '0001-01-01') from {{ this }}
   )
{% endif %}
```

## Running specific models[​](#running-specific-models "Direct link to Running specific models")

dbt will also allow you select which specific models you'd like to materialize. This can be useful during special scenarios where you may prefer running a different set of models at various intervals. This can also be helpful when you may want to limit the tables materialized while you develop and test new models.

For more information, see the [Model Selection Syntax Documentation](https://docs.getdbt.com/reference/node-selection/syntax).

For more information on running parents or children of specific models, see the [Graph Operators Documentation](https://docs.getdbt.com/reference/node-selection/graph-operators).

## Treat warnings as errors[​](#treat-warnings-as-errors "Direct link to Treat warnings as errors")

See [global configs](https://docs.getdbt.com/reference/global-configs/warnings)

## Failing fast[​](#failing-fast "Direct link to Failing fast")

See [global configs](https://docs.getdbt.com/reference/global-configs/failing-fast)

## Enable or Disable Colorized Logs[​](#enable-or-disable-colorized-logs "Direct link to Enable or Disable Colorized Logs")

See [global configs](https://docs.getdbt.com/reference/global-configs/print-output#print-color)

## The `--empty` flag[​](#the---empty-flag "Direct link to the---empty-flag")

The `run` command supports the `--empty` flag for building schema-only dry runs. The `--empty` flag limits the refs and sources to zero rows. dbt will still execute the model SQL against the target data warehouse but will avoid expensive reads of input data. This validates dependencies and ensures your models will build properly.

## Status codes[​](#status-codes "Direct link to Status codes")

When calling the [list\_runs api](https://docs.getdbt.com/dbt-cloud/api-v2#/operations/List%20Runs), you will get a status code for each run returned. The available run status codes are as follows:

* Queued = 1
* Starting = 2
* Running = 3
* Success = 10
* Error = 20
* Canceled = 30
* Skipped = 40

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

rpc](https://docs.getdbt.com/reference/commands/rpc)[Next

run-operation](https://docs.getdbt.com/reference/commands/run-operation)

* [Overview](#overview)
  + [How does `dbt run` work?](#how-does-dbt-run-work)* [Refresh incremental models](#refresh-incremental-models)* [Running specific models](#running-specific-models)* [Treat warnings as errors](#treat-warnings-as-errors)* [Failing fast](#failing-fast)* [Enable or Disable Colorized Logs](#enable-or-disable-colorized-logs)* [The `--empty` flag](#the---empty-flag)* [Status codes](#status-codes)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/commands/run.md)
