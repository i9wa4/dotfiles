---
title: "Custom databases | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/custom-databases"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Organize your outputs](https://docs.getdbt.com/docs/build/organize-your-outputs)* Custom databases

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fcustom-databases+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fcustom-databases+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fcustom-databases+so+I+can+ask+questions+about+it.)

On this page

A word on naming

Different warehouses have different names for *logical databases*. The information in this document covers "databases" on Snowflake, Redshift, and Postgres; "projects" on BigQuery; and "catalogs" on Databricks Unity Catalog.

The values `project` and `database` are interchangeable in BigQuery project configurations.

## Configuring custom databases[​](#configuring-custom-databases "Direct link to Configuring custom databases")

The logical database that dbt models are built into can be configured using the `database` model configuration. If this configuration is not supplied to a model, then dbt will use the database configured in the active target from your `profiles.yml` file. If the `database` configuration *is* supplied for a model, then dbt will build the model into the configured database.

The `database` configuration can be supplied for groups of models in the `dbt_project.yml` file, or for individual models in model SQL files.

### Configuring database overrides in `dbt_project.yml`:[​](#configuring-database-overrides-in-dbt_projectyml "Direct link to configuring-database-overrides-in-dbt_projectyml")

This config changes all models in the `jaffle_shop` project to be built into a database called `jaffle_shop`.

dbt\_project.yml

```
name: jaffle_shop

models:
  jaffle_shop:
    +database: jaffle_shop

    # For BigQuery users:
    # project: jaffle_shop
```

### Configuring database overrides in a model file[​](#configuring-database-overrides-in-a-model-file "Direct link to Configuring database overrides in a model file")

This config changes a specific model to be built into a database called `jaffle_shop`.

models/my\_model.sql

```
{{ config(database="jaffle_shop") }}

select * from ...
```

### generate\_database\_name[​](#generate_database_name "Direct link to generate_database_name")

The database name generated for a model is controlled by a macro called `generate_database_name`. This macro can be overridden in a dbt project to change how dbt generates model database names. This macro works similarly to the [generate\_schema\_name](https://docs.getdbt.com/docs/build/custom-schemas#advanced-custom-schema-configuration) macro.

To override dbt's database name generation, create a macro named `generate_database_name` in your own dbt project. The `generate_database_name` macro accepts two arguments:

1. The custom database supplied in the model config
2. The node that a custom database is being generated for

The default implementation of `generate_database_name` simply uses the supplied `database` config if one is present, otherwise the database configured in the active `target` is used. This implementation looks like this:

get\_custom\_database.sql

```
{% macro generate_database_name(custom_database_name=none, node=none) -%}

    {%- set default_database = target.database -%}
    {%- if custom_database_name is none -%}

        {{ default_database }}

    {%- else -%}

        {{ custom_database_name | trim }}

    {%- endif -%}

{%- endmacro %}
```

💡 Use Jinja's whitespace control to tidy your macros!

When you're modifying macros in your project, you might notice extra white space in your code in the `target/compiled` folder.

You can remove unwanted spaces and lines with Jinja's [whitespace control](https://docs.getdbt.com/faqs/Jinja/jinja-whitespace) by using a minus sign. For example, use `{{- ... -}}` or `{%- ... %}` around your macro definitions (such as `{%- macro generate_schema_name(...) -%} ... {%- endmacro -%}`).

### Managing different behaviors across packages[​](#managing-different-behaviors-across-packages "Direct link to Managing different behaviors across packages")

See docs on macro `dispatch`: ["Managing different global overrides across packages"](https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch)

## Considerations[​](#considerations "Direct link to Considerations")

### BigQuery[​](#bigquery "Direct link to BigQuery")

When dbt opens a BigQuery connection, it will do so using the `project_id` defined in your active `profiles.yml` target. This `project_id` will be billed for the queries that are executed in the dbt run, even if some models are configured to be built in other projects.

## Related docs[​](#related-docs "Direct link to Related docs")

* [Customize dbt models database, schema, and alias](https://docs.getdbt.com/guides/customize-schema-alias?step=1) to learn how to customize dbt models database, schema, and alias
* [Custom schema](https://docs.getdbt.com/docs/build/custom-schemas) to learn how to customize dbt model schema
* [Custom aliases](https://docs.getdbt.com/docs/build/custom-aliases) to learn how to customize dbt model alias name

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Custom schemas](https://docs.getdbt.com/docs/build/custom-schemas)[Next

Custom aliases](https://docs.getdbt.com/docs/build/custom-aliases)

* [Configuring custom databases](#configuring-custom-databases)
  + [Configuring database overrides in `dbt_project.yml`:](#configuring-database-overrides-in-dbt_projectyml)+ [Configuring database overrides in a model file](#configuring-database-overrides-in-a-model-file)+ [generate\_database\_name](#generate_database_name)+ [Managing different behaviors across packages](#managing-different-behaviors-across-packages)* [Considerations](#considerations)
    + [BigQuery](#bigquery)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/custom-databases.md)
