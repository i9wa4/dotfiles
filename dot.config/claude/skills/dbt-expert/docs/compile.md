---
title: "About dbt compile command | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/commands/compile"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [List of commands](https://docs.getdbt.com/category/list-of-commands)* compile

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fcompile+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fcompile+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fcompile+so+I+can+ask+questions+about+it.)

On this page

`dbt compile` generates executable SQL from source `model`, `test`, and `analysis` files. You can find these compiled SQL files in the `target/` directory of your dbt project.

The `compile` command is useful for:

1. Visually inspecting the compiled output of model files. This is useful for validating complex Jinja logic or macro usage.
2. Manually running compiled SQL. While debugging a model or schema test, it's often useful to execute the underlying `select` statement to find the source of the bug.
3. Compiling `analysis` files. Read more about analysis files [here](https://docs.getdbt.com/docs/build/analyses).

Some common misconceptions:

* `dbt compile` is *not* a pre-requisite of `dbt run`, or other building commands. Those commands will handle compilation themselves.
* If you just want dbt to read and validate your project code, without connecting to the data warehouse, use `dbt parse` instead.

### Interactive compile[​](#interactive-compile "Direct link to Interactive compile")

Starting in dbt v1.5, `compile` can be "interactive" in the CLI, by displaying the compiled code of a node or arbitrary dbt-SQL query:

* `--select` a specific node *by name*
* `--inline` an arbitrary dbt-SQL query

This will log the compiled SQL to the terminal, in addition to writing to the `target/` directory.

For example:

```
dbt compile --select "stg_orders"
dbt compile --inline "select * from {{ ref('raw_orders') }}"
```

returns the following:

```
dbt compile --select "stg_orders"

21:17:09  Running with dbt=1.7.5
21:17:09  Registered adapter: postgres=1.7.5
21:17:09  Found 5 models, 3 seeds, 20 tests, 0 sources, 0 exposures, 0 metrics, 401 macros, 0 groups, 0 semantic models
21:17:09
21:17:09 Concurrency: 24 threads (target='dev')
21:17:09
21:17:09  Compiled node 'stg_orders' is:
with source as (
    select * from "jaffle_shop"."main"."raw_orders"

),

renamed as (

    select
        id as order_id,
        user_id as customer_id,
        order_date,
        status

    from source

)

select * from renamed
```

```
dbt compile --inline "select * from {{ ref('raw_orders') }}"

18:15:49  Running with dbt=1.7.5
18:15:50  Registered adapter: postgres=1.7.5
18:15:50  Found 5 models, 3 seeds, 20 tests, 0 sources, 0 exposures, 0 metrics, 401 macros, 0 groups, 0 semantic models
18:15:50
18:15:50  Concurrency: 5 threads (target='postgres')
18:15:50
18:15:50  Compiled inline node is:
select * from "jaffle_shop"."main"."raw_orders"
```

The command accesses the data platform to cache-related metadata, and to run introspective queries. Use the flags:

* `--no-populate-cache` to disable the initial cache population. If metadata is needed, it will be a cache miss, requiring dbt to run the metadata query. This is a `dbt` flag, which means you need to add `dbt` as a prefix. For example: `dbt --no-populate-cache`.
* `--no-introspect` to disable [introspective queries](https://docs.getdbt.com/faqs/Warehouse/db-connection-dbt-compile#introspective-queries). dbt will raise an error if a model's definition requires running one. This is a `dbt compile` flag, which means you need to add `dbt compile` as a prefix. For example:`dbt compile --no-introspect`.

### FAQs[​](#faqs "Direct link to FAQs")

Why dbt compile needs a data platform connection

`dbt compile` needs a data platform connection in order to gather the info it needs (including from introspective queries) to prepare the SQL for every model in your project.

### dbt compile[​](#dbt-compile "Direct link to dbt compile")

The [`dbt compile` command](https://docs.getdbt.com/reference/commands/compile) generates executable SQL from `source`, `model`, `test`, and `analysis` files. `dbt compile` is similar to `dbt run` except that it doesn't materialize the model's compiled SQL into an existing table. So, up until the point of materialization, `dbt compile` and `dbt run` are similar because they both require a data platform connection, run queries, and have an [`execute` variable](https://docs.getdbt.com/reference/dbt-jinja-functions/execute) set to `True`.

However, here are some things to consider:

* You don't need to execute `dbt compile` before `dbt run`
* In dbt, `compile` doesn't mean `parse`. This is because `parse` validates your written `YAML`, configured tags, and so on.

### Introspective queries[​](#introspective-queries "Direct link to Introspective queries")

To generate the compiled SQL for many models, dbt needs to run introspective queries, (which is when dbt needs to run SQL in order to pull data back and do something with it) against the data platform.

These introspective queries include:

* Populating the relation cache. For more information, refer to the [Create new materializations](https://docs.getdbt.com/guides/create-new-materializations) guide. Caching speeds up the metadata checks, including whether an [incremental model](https://docs.getdbt.com/docs/build/incremental-models) already exists in the data platform.
* Resolving [macros](https://docs.getdbt.com/docs/build/jinja-macros#macros), such as `run_query` or `dbt_utils.get_column_values` that you're using to template out your SQL. This is because dbt needs to run those queries during model SQL compilation.

Without a data platform connection, dbt can't perform these introspective queries and won't be able to generate the compiled SQL needed for the next steps in the dbt workflow. You can [`parse`](https://docs.getdbt.com/reference/commands/parse) a project and use the [`list`](https://docs.getdbt.com/reference/commands/list) resources in the project, without an internet or data platform connection. Parsing a project is enough to produce a [manifest](https://docs.getdbt.com/reference/artifacts/manifest-json), however, keep in mind that the written-out manifest won't include compiled SQL.

To configure a project, you do need a [connection profile](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles) (`profiles.yml` if using the CLI). You need this file because the project's configuration depends on its contents. For example, you may need to use [`{{target}}`](https://docs.getdbt.com/reference/dbt-jinja-functions/target) for conditional configs or know what platform you're running against so that you can choose the right flavor of SQL.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

docs](https://docs.getdbt.com/reference/commands/cmd-docs)[Next

debug](https://docs.getdbt.com/reference/commands/debug)

* [Interactive compile](#interactive-compile)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/commands/compile.md)
