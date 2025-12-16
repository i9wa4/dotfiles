---
title: "Microsoft SQL Server configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/mssql-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Microsoft SQL Server configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fmssql-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fmssql-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fmssql-configs+so+I+can+ask+questions+about+it.)

On this page

## Materializations[​](#materializations "Direct link to Materializations")

Ephemeral materialization is not supported due to T-SQL not supporting nested CTEs. It may work in some cases when you're working with very simple ephemeral models.

### Tables[​](#tables "Direct link to Tables")

Tables will, by default, be materialized as a columnstore tables.
This requires SQL Server 2017 or newer for on-premise instances or service tier S2 or higher for Azure.

This behaviour can be disabled by setting the `as_columnstore` configuration option to `False`.

* Model config* Project config

models/example.sql

```
{{
    config(
        as_columnstore=false
        )
}}

select *
from ...
```

dbt\_project.yml

```
models:
  your_project_name:
    materialized: view
    staging:
      materialized: table
      as_columnstore: False
```

## Seeds[​](#seeds "Direct link to Seeds")

By default, `dbt-sqlserver` will attempt to insert seed files in batches of 400 rows.
If this exceeds SQL Server's 2100 parameter limit, the adapter will automatically limit to the highest safe value possible.

To set a different default seed value, you can set the variable `max_batch_size` in your project configuration.

dbt\_project.yml

```
vars:
  max_batch_size: 200 # Any integer less than or equal to 2100 will do.
```

## Snapshots[​](#snapshots "Direct link to Snapshots")

Columns in source tables can not have any constraints.
If, for example, any column has a `NOT NULL` constraint, an error will be thrown.

## Indices[​](#indices "Direct link to Indices")

You can specify indices to be created for your table by specifying post-hooks calling purpose-built macros.

The following macros are available:

* `create_clustered_index(columns, unique=False)`: columns is a list of columns, unique is an optional boolean (defaults to False).
* `create_nonclustered_index(columns, includes=columns)`: columns is a list of columns, includes is an optional list of columns to include in the index.
* `drop_all_indexes_on_table()`: drops current indices on a table. Only meaningful if the model is incremental.`

Some examples:

models/example.sql

```
{{
    config({
        "as_columnstore": false,
        "materialized": 'table',
        "post-hook": [
            "{{ create_clustered_index(columns = ['row_id', 'row_id_complement'], unique=True) }}",
            "{{ create_nonclustered_index(columns = ['modified_date']) }}",
            "{{ create_nonclustered_index(columns = ['row_id'], includes = ['modified_date']) }}",
        ]
    })

}}

select *
from ...
```

## Grants with auto provisioning[​](#grants-with-auto-provisioning "Direct link to Grants with auto provisioning")

dbt 1.2 introduced the capability to grant/revoke access using the `grants` [configuration option](https://docs.getdbt.com/reference/resource-configs/grants).
In dbt-sqlserver, you can additionally set `auto_provision_aad_principals` to `true` in your model configuration if you are using Microsoft Entra ID authentication with an Azure SQL Database or Azure Synapse Dedicated SQL Pool.

This will automatically create the Microsoft Entra ID principal inside your database if it does not exist yet.
Note that the principals need to exist in your Microsoft Entra ID, this just makes them available to use in your database.

Principals are not removed again when they are removed from the grants configuration.

dbt\_project.yml

```
models:
  your_project_name:
    auto_provision_aad_principals: true
```

## Permissions[​](#permissions "Direct link to Permissions")

The following permissions are required for the user executing dbt:

* `CREATE SCHEMA` on the database level (or you can create the schema in advance)
* `CREATE TABLE` on the database level (or on the user's own schema if the schema is already created)
* `CREATE VIEW` on the database level (or on the user's own schema if the schema is already created
* `SELECT` on the tables/views being used as dbt sources

The 3 `CREATE` permissions above are required on the database level if you want to make use of tests or snapshots in dbt. You can work around this by creating the schemas used for testing and snapshots in advance and granting the right roles.

## cross-database macros[​](#cross-database-macros "Direct link to cross-database macros")

The following macros are currently not supported:

* `bool_or`
* `array_construct`
* `array_concat`
* `array_append`

## dbt-utils[​](#dbt-utils "Direct link to dbt-utils")

Many [`dbt-utils`](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/) are supported,
but require the installation of the [`tsql_utils`](https://hub.getdbt.com/dbt-msft/tsql_utils/latest/) dbt package.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Materialize configurations](https://docs.getdbt.com/reference/resource-configs/materialize-configs)[Next

MindsDB configurations](https://docs.getdbt.com/reference/resource-configs/mindsdb-configs)

* [Materializations](#materializations)
  + [Tables](#tables)* [Seeds](#seeds)* [Snapshots](#snapshots)* [Indices](#indices)* [Grants with auto provisioning](#grants-with-auto-provisioning)* [Permissions](#permissions)* [cross-database macros](#cross-database-macros)* [dbt-utils](#dbt-utils)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/mssql-configs.md)
