---
title: "Why dbt compile needs a data platform connection | dbt Developer Hub"
source_url: "https://docs.getdbt.com/faqs/Warehouse/db-connection-dbt-compile"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Frequently asked questions](https://docs.getdbt.com/docs/faqs)* [Warehouse](https://docs.getdbt.com/category/warehouse)* Why dbt compile needs a data platform connection

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FWarehouse%2Fdb-connection-dbt-compile+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FWarehouse%2Fdb-connection-dbt-compile+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FWarehouse%2Fdb-connection-dbt-compile+so+I+can+ask+questions+about+it.)

On this page

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

Database privileges to use dbt](https://docs.getdbt.com/faqs/Warehouse/database-privileges)[Next

Recommendations on tools to get data into your warehouse](https://docs.getdbt.com/faqs/Warehouse/loading-data)

* [dbt compile](#dbt-compile)* [Introspective queries](#introspective-queries)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/faqs/Warehouse/db-connection-dbt-compile.md)
