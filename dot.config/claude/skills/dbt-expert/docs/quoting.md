---
title: "Configuring quoting in projects | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/quoting"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* quoting

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fquoting+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fquoting+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fquoting+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
quoting:
  database: true | false
  schema: true | false
  identifier: true | false
  snowflake_ignore_case: true | false  # Fusion-only config. Aligns with Snowflake's session parameter QUOTED_IDENTIFIERS_IGNORE_CASE behavior.
                                       # Ignored by dbt Core and other adapters.
```

## Definition[​](#definition "Direct link to Definition")

You can optionally enable quoting in a dbt project to control whether dbt wraps database, schema, or identifier names in quotes when generating SQL. dbt uses this configuration when:

* Creating relations (For example, tables or views)
* Resolving a `ref()` function to a direct relation reference

BigQuery terminology

Note that for BigQuery quoting configuration, `database` and `schema` should be used here, though these configs will apply to `project` and `dataset` names respectively

## Default[​](#default "Direct link to Default")

The default values vary by database.

* Default* Snowflake

For most adapters, quoting is set to `true` by default.

Why? It's equally easy to select from relations with quoted or unquoted identifiers. Quoting allows you to use reserved words and special characters in those identifiers, though we recommend avoiding reserved words and special characters in identifiers whenever possible.

dbt\_project.yml

```
quoting:
  database: true
  schema: true
  identifier: true
```

For Snowflake, quoting is set to `false` by default.

Creating relations with quoted identifiers also makes those identifiers case sensitive. It's much more difficult to select from them. You can re-enable quoting for relations identifiers that are case sensitive, reserved words, or contain special characters, but we recommend you avoid this as much as possible.

dbt\_project.yml

```
quoting:
  database: false
  schema: false
  identifier: false
  snowflake_ignore_case: false  # Fusion-only config. Aligns with Snowflake's session parameter QUOTED_IDENTIFIERS_IGNORE_CASE behavior.
                                # Ignored by dbt Core and other adapters.
```

## Examples[​](#examples "Direct link to Examples")

Set quoting to `false` for a project:

dbt\_project.yml

```
quoting:
  database: false
  schema: false
  identifier: false
  snowflake_ignore_case: false  # Fusion-only config. Aligns with Snowflake's session parameter QUOTED_IDENTIFIERS_IGNORE_CASE behavior.
                                # Ignored by dbt Core and other adapters.
```

dbt will then create relations without quotes:

```
create table analytics.dbt_alice.dim_customers
```

## Recommendations[​](#recommendations "Direct link to Recommendations")

### Snowflake[​](#snowflake "Direct link to Snowflake")

If you're using Snowflake, we recommend:

* Setting all quoting configs to `False` in your [`dbt_project.yml`](https://docs.getdbt.com/reference/dbt_project.yml) to avoid quoting model and column names unnecessarily and to help prevent case sensitivity issues.

  + Setting all quoting configs to `False` also means you cannot use reserved words as identifiers, such as model or table names. We recommend you avoid using these reserved words anyway.
* If you're using Fusion and your Snowflake environment sets the session parameter `QUOTED_IDENTIFIERS_IGNORE_CASE = true` (for example, in an orchestrator or pre-hook), you should also enable quoting and `snowflake_ignore_case` in your `dbt_project.yml` to preserve the exact case of database, schema, and identifier:

  ```
  quoting:
    database: true
    schema: true
    identifier: true
    snowflake_ignore_case: true  # Fusion-only config. Aligns with Snowflake's session parameter QUOTED_IDENTIFIERS_IGNORE_CASE behavior.
                                 # Ignored by dbt Core and other adapters.
  ```

  Setting `snowflake_ignore_case: true` ensures that dbt compiles column and identifier names match Snowflake’s behavior at runtime, preserving parity between compile-time and runtime logic. Without this, you may encounter "column not found" errors.

Quoting a source

If a Snowflake source table uses a quoted database, schema, or table identifier, you can configure this in the source.yml file. Refer to [configuring quoting](https://docs.getdbt.com/reference/resource-properties/quoting) for more information.

#### Explanation[​](#explanation "Direct link to Explanation")

dbt skips quoting on Snowflake so lowercase model names work seamlessly in downstream queries and BI tools without worrying about case or quotes.

Unlike most databases (which lowercase unquoted identifiers), Snowflake uppercases them. When you quote identifiers, Snowflake will preserve their case and make them case-sensitive. This means when you create a table with quoted, lowercase identifiers, the table should always be referenced with quotes and use the exact same case, which can easily break downstream queries in BI tools or ad-hoc SQL.

Because dbt conventions use lowercase model and file names, quoting them in Snowflake risks breaking downstream queries in BI tools or ad-hoc SQL. If dbt instead used uppercase names by convention, the safe defaults for other databases would be at risk of breaking downstream queries.

snowflake\_casing.sql

```
/*
  Run these queries to understand how Snowflake handles casing and quoting.
*/

-- This is the output of an example `orders.sql` model with quoting enabled
create table "analytics"."orders" as (

  select 1 as id

);

/*
    These queries WILL NOT work! Since the table above was created with quotes,
    Snowflake created the orders table with a lowercase schema and identifier.

    Since unquoted identifiers are automatically uppercased, both of the
    following queries are equivalent, and neither will work correctly.
*/

select * from analytics.orders;
select * from ANALYTICS.ORDERS;

/*
    To query this table, you'll need to quote the schema and table. This
    query should indeed complete without error.
*/

select * from "analytics"."orders";


/*
    To avoid this quoting madness, you can disable quoting for schemas
    and identifiers in your dbt_project.yml file. This means that you
    won't be able to use reserved words as model names, but you should avoid that anyway! Assuming schema and identifier quoting is
    disabled, the following query would indeed work:
*/

select * from analytics.orders;
```

### Other warehouses[​](#other-warehouses "Direct link to Other warehouses")

Leave the default values for your warehouse.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

query-comment](https://docs.getdbt.com/reference/project-configs/query-comment)[Next

require-dbt-version](https://docs.getdbt.com/reference/project-configs/require-dbt-version)

* [Definition](#definition)* [Default](#default)* [Examples](#examples)* [Recommendations](#recommendations)
        + [Snowflake](#snowflake)+ [Other warehouses](#other-warehouses)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/quoting.md)
