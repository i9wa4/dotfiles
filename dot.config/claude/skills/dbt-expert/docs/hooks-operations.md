---
title: "Hooks and operations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/hooks-operations"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Enhance your code](https://docs.getdbt.com/docs/build/enhance-your-code)* Hooks and operations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fhooks-operations+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fhooks-operations+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fhooks-operations+so+I+can+ask+questions+about+it.)

On this page

## Related documentation[​](#related-documentation "Direct link to Related documentation")

* [pre-hook & post-hook](https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook)
* [on-run-start & on-run-end](https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end)
* [`run-operation` command](https://docs.getdbt.com/reference/commands/run-operation)

### Assumed knowledge[​](#assumed-knowledge "Direct link to Assumed knowledge")

* [Project configurations](https://docs.getdbt.com/reference/dbt_project.yml)
* [Model configurations](https://docs.getdbt.com/reference/model-configs)
* [Macros](https://docs.getdbt.com/docs/build/jinja-macros#macros)

## Getting started with hooks and operations[​](#getting-started-with-hooks-and-operations "Direct link to Getting started with hooks and operations")

Effective database administration sometimes requires additional SQL statements to be run, for example:

* Creating UDFs
* Managing row- or column-level permissions
* Vacuuming tables on Redshift
* Creating partitions in Redshift Spectrum external tables
* Resuming/pausing/resizing warehouses in Snowflake
* Refreshing a pipe in Snowflake
* Create a share on Snowflake
* Cloning a database on Snowflake

dbt provides hooks and operations so you can version control and execute these statements as part of your dbt project.

## About hooks[​](#about-hooks "Direct link to About hooks")

Hooks are snippets of SQL that are executed at different times:

* `pre-hook`: executed *before* a model, seed or snapshot is built.
* `post-hook`: executed *after* a model, seed or snapshot is built.
* `on-run-start`: executed at the *start* of

  `dbt build`, `dbt compile`, `dbt docs generate`, `dbt run`, `dbt seed`, `dbt snapshot`, or `dbt test`.
* `on-run-end`: executed at the *end* of

  `dbt build`, `dbt compile`, `dbt docs generate`, `dbt run`, `dbt seed`, `dbt snapshot`, or `dbt test`.

Hooks are a more-advanced capability that enable you to run custom SQL, and leverage database-specific actions, beyond what dbt makes available out-of-the-box with standard materializations and configurations.

If (and only if) you can't leverage the [`grants` resource-config](https://docs.getdbt.com/reference/resource-configs/grants), you can use `post-hook` to perform more advanced workflows:

* Need to apply `grants` in a more complex way, which the dbt Core `grants` config doesn't (yet) support.
* Need to perform post-processing that dbt does not support out-of-the-box. For example, `analyze table`, `alter table set property`, `alter table ... add row access policy`, etc.

### Examples using hooks[​](#examples-using-hooks "Direct link to Examples using hooks")

You can use hooks to trigger actions at certain times when running an operation or building a model, seed, or snapshot.

For more information about when hooks can be triggered, see reference sections for [`on-run-start` and `on-run-end` hooks](https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end) and [`pre-hook`s and `post-hook`s](https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook).

You can use hooks to provide database-specific functionality not available out-of-the-box with dbt. For example, you can use a `config` block to run an `ALTER TABLE` statement right after building an individual model using a `post-hook`:

models/<model\_name>.sql

```
{{ config(
    post_hook=[
      "alter table {{ this }} ..."
    ]
) }}
```

### Calling a macro in a hook[​](#calling-a-macro-in-a-hook "Direct link to Calling a macro in a hook")

You can also use a [macro](https://docs.getdbt.com/docs/build/jinja-macros#macros) to bundle up hook logic. Check out some of the examples in the reference sections for [on-run-start and on-run-end hooks](https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end) and [pre- and post-hooks](https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook).

models/<model\_name>.sql

```
{{ config(
    pre_hook=[
      "{{ some_macro() }}"
    ]
) }}
```

models/properties.yml

```
models:
  - name: <model_name>
    config:
      pre_hook:
        - "{{ some_macro() }}"
```

dbt\_project.yml

```
models:
  <project_name>:
    +pre-hook:
      - "{{ some_macro() }}"
```

## About operations[​](#about-operations "Direct link to About operations")

Operations are [macros](https://docs.getdbt.com/docs/build/jinja-macros#macros) that you can run using the [`run-operation`](https://docs.getdbt.com/reference/commands/run-operation) command. As such, operations aren't actually a separate resource in your dbt project — they are just a convenient way to invoke a macro without needing to run a model.

Explicitly execute the SQL in an operation

Unlike hooks, you need to explicitly execute a query within a macro, by using either a [statement block](https://docs.getdbt.com/reference/dbt-jinja-functions/statement-blocks) or a helper macro like the [run\_query](https://docs.getdbt.com/reference/dbt-jinja-functions/run_query) macro. Otherwise, dbt will return the query as a string without executing it.

This macro performs a similar action as the above hooks:

macros/grant\_select.sql

```
{% macro grant_select(role) %}
{% set sql %}
    grant usage on schema {{ target.schema }} to role {{ role }};
    grant select on all tables in schema {{ target.schema }} to role {{ role }};
    grant select on all views in schema {{ target.schema }} to role {{ role }};
{% endset %}

{% do run_query(sql) %}
{% do log("Privileges granted", info=True) %}
{% endmacro %}
```

To invoke this macro as an operation, execute `dbt run-operation grant_select --args '{role: reporter}'`.

```
$ dbt run-operation grant_select --args '{role: reporter}'
Running with dbt=1.6.0
Privileges granted
```

Full usage docs for the `run-operation` command can be found [here](https://docs.getdbt.com/reference/commands/run-operation).

## Additional examples[​](#additional-examples "Direct link to Additional examples")

These examples from the community highlight some of the use-cases for hooks and operations!

* [In-depth discussion of granting privileges using hooks and operations, for dbt Core versions prior to 1.2](https://discourse.getdbt.com/t/the-exact-grant-statements-we-use-in-a-dbt-project/430)
* [Staging external tables](https://github.com/dbt-labs/dbt-external-tables)
* [Performing a zero copy clone on Snowflake to reset a dev environment](https://discourse.getdbt.com/t/creating-a-dev-environment-quickly-on-snowflake/1151/2)
* [Running `vacuum` and `analyze` on a Redshift warehouse](https://github.com/dbt-labs/redshift/tree/0.2.3/#redshift_maintenance_operation-source)
* [Creating a Snowflake share](https://discourse.getdbt.com/t/how-drizly-is-improving-collaboration-with-external-partners-using-dbt-snowflake-shares/1110)
* [Unloading files to S3 on Redshift](https://github.com/dbt-labs/redshift/tree/0.2.3/#unload_table-source)
* [Creating audit events for model timing](https://github.com/dbt-labs/dbt-event-logging)
* [Creating UDFs](https://discourse.getdbt.com/t/using-dbt-to-manage-user-defined-functions/18)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Environment variables](https://docs.getdbt.com/docs/build/environment-variables)[Next

Packages](https://docs.getdbt.com/docs/build/packages)

* [Related documentation](#related-documentation)
  + [Assumed knowledge](#assumed-knowledge)* [Getting started with hooks and operations](#getting-started-with-hooks-and-operations)* [About hooks](#about-hooks)
      + [Examples using hooks](#examples-using-hooks)+ [Calling a macro in a hook](#calling-a-macro-in-a-hook)* [About operations](#about-operations)* [Additional examples](#additional-examples)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/hooks-operations.md)
