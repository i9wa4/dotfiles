---
title: "Parallel microbatch execution | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/parallel-batch-execution"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Enhance your models](https://docs.getdbt.com/docs/build/enhance-your-models)* [Incremental models](https://docs.getdbt.com/docs/build/incremental-models-overview)* Parallel microbatch execution

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fparallel-batch-execution+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fparallel-batch-execution+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fparallel-batch-execution+so+I+can+ask+questions+about+it.)

On this page

Use parallel batch execution to process your microbatch models faster.

The microbatch strategy offers the benefit of updating a model in smaller, more manageable batches. Depending on your use case, configuring your microbatch models to run in parallel offers faster processing, in comparison to running batches sequentially.

Parallel batch execution means that multiple batches are processed at the same time, instead of one after the other (sequentially) for faster processing of your microbatch models.

dbt automatically detects whether a batch can be run in parallel in most cases, which means you don’t need to configure this setting. However, the [`concurrent_batches` config](https://docs.getdbt.com/reference/resource-properties/concurrent_batches) is available as an override (not a gate), allowing you to specify whether batches should or shouldn’t be run in parallel in specific cases.

For example, if you have a microbatch model with 12 batches, you can execute those batches to run in parallel. Specifically they'll run in parallel limited by the number of [available threads](https://docs.getdbt.com/docs/running-a-dbt-project/using-threads).

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

To use parallel execution, you must meet the following prerequisites:

* Use Snowflake as a supported adapter.
  + We'll continue to test and add concurrency support for more adapters in the future.
* A batch can only be run in parallel if:
  + The batch is *not* the first batch.
  + The batch is *not* the last batch.

## How parallel batch execution works[​](#how-parallel-batch-execution-works "Direct link to How parallel batch execution works")

After checking for the conditions in the [prerequisites](#prerequisites), and if `concurrent_batches` value isn't set, dbt will intelligently auto-detect if the model invokes the [`{{ this }}`](https://docs.getdbt.com/reference/dbt-jinja-functions/this) Jinja function. If it references `{{ this }}`, the batches will run sequentially since `{{ this }}` represents the database of the current model and referencing the same relation causes conflict.

Otherwise, if `{{ this }}` isn't detected (and other conditions are met), the batches will run in parallel, which can be overriden when you [set a value for `concurrent_batches`](https://docs.getdbt.com/reference/resource-properties/concurrent_batches).

## Parallel or sequential execution[​](#parallel-or-sequential-execution "Direct link to Parallel or sequential execution")

Choosing between parallel batch execution and sequential processing depends on the specific requirements of your use case.

* Parallel batch execution is faster but requires logic independent of batch execution order. For example, if you're developing a data pipeline for a system that processes user transactions in batches, each batch is executed in parallel for better performance. However, the logic used to process each transaction shouldn't depend on the order of how batches are executed or completed.
* Sequential processing is slower but essential for calculations like [cumulative metrics](https://docs.getdbt.com/docs/build/cumulative) in microbatch models. It processes data in the correct order, allowing each step to build on the previous one.

## Configure `concurrent_batches`[​](#configure-concurrent_batches "Direct link to configure-concurrent_batches")

By default, dbt auto-detects whether batches can run in parallel for microbatch models, and this works correctly in most cases. However, you can override dbt's detection by setting the [`concurrent_batches` config](https://docs.getdbt.com/reference/resource-properties/concurrent_batches) in your `dbt_project.yml` or model `.sql` file to specify parallel or sequential execution, given you meet all the [conditions](#prerequisites):

* dbt\_project.yml* my\_model.sql

dbt\_project.yml

```
models:
  +concurrent_batches: true # value set to true to run batches in parallel
```

models/my\_model.sql

```
{{
  config(
    materialized='incremental',
    incremental_strategy='microbatch',
    event_time='session_start',
    begin='2020-01-01',
    batch_size='day',
    concurrent_batches=true, # value set to true to run batches in parallel
    ...
  )
}}

select ...
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Microbatch incremental models](https://docs.getdbt.com/docs/build/incremental-microbatch)[Next

Enhance your code](https://docs.getdbt.com/docs/build/enhance-your-code)

* [Prerequisites](#prerequisites)* [How parallel batch execution works](#how-parallel-batch-execution-works)* [Parallel or sequential execution](#parallel-or-sequential-execution)* [Configure `concurrent_batches`](#configure-concurrent_batches)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/parallel-batch-execution.md)
