---
title: "About adapter object | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/adapter"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* adapter

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fadapter+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fadapter+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fadapter+so+I+can+ask+questions+about+it.)

On this page

Your database communicates with dbt using an internal database adapter object. For example, BaseAdapter and SnowflakeAdapter. The Jinja object `adapter` is a wrapper around this internal database adapter object.

`adapter` grants the ability to invoke adapter methods of that internal class via:

* `{% do adapter.<method name> %}` -- invoke internal adapter method
* `{{ adapter.<method name> }}` -- invoke internal adapter method and capture its return value for use in materialization or other macros

For example, the adapter methods below will be translated into specific SQL statements depending on the type of adapter your project is using:

* [adapter.dispatch](https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch)
* [adapter.get\_missing\_columns](#get_missing_columns)
* [adapter.expand\_target\_column\_types](#expand_target_column_types)
* [adapter.get\_relation](#get_relation) or [load\_relation](#load_relation)
* [adapter.get\_columns\_in\_relation](#get_columns_in_relation)
* [adapter.create\_schema](#create_schema)
* [adapter.drop\_schema](#drop_schema)
* [adapter.drop\_relation](#drop_relation)
* [adapter.rename\_relation](#rename_relation)
* [adapter.quote](#quote)

### Deprecated adapter functions[​](#deprecated-adapter-functions "Direct link to Deprecated adapter functions")

The following adapter functions are deprecated, and will be removed in a future release.

* [adapter.get\_columns\_in\_table](#get_columns_in_table) **(deprecated)**
* [adapter.already\_exists](#already_exists) **(deprecated)**
* [adapter\_macro](#adapter_macro) **(deprecated)**

## dispatch[​](#dispatch "Direct link to dispatch")

Moved to separate page: [dispatch](https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch)

## get\_missing\_columns[​](#get_missing_columns "Direct link to get_missing_columns")

**Args**:

* `from_relation`: The source [Relation](https://docs.getdbt.com/reference/dbt-classes#relation)
* `to_relation`: The target [Relation](https://docs.getdbt.com/reference/dbt-classes#relation)

Returns a list of [Columns](https://docs.getdbt.com/reference/dbt-classes#column) that is the difference of the columns in the `from_table`
and the columns in the `to_table`, i.e. (`set(from_relation.columns) - set(to_table.columns)`).
Useful for detecting new columns in a source table.

**Usage**:

models/example.sql

```
{%- set target_relation = api.Relation.create(
      database='database_name',
      schema='schema_name',
      identifier='table_name') -%}


{% for col in adapter.get_missing_columns(target_relation, this) %}
  alter table {{this}} add column "{{col.name}}" {{col.data_type}};
{% endfor %}
```

## expand\_target\_column\_types[​](#expand_target_column_types "Direct link to expand_target_column_types")

**Args**:

* `from_relation`: The source [Relation](https://docs.getdbt.com/reference/dbt-classes#relation) to use as a template
* `to_relation`: The [Relation](https://docs.getdbt.com/reference/dbt-classes#relation) to mutate

Expand the `to_relation` table's column types to match the schema of `from_relation`. Column expansion is constrained to string and numeric types on supported databases. Typical usage involves expanding column types (from eg. `varchar(16)` to `varchar(32)`) to support insert statements.

**Usage**:

example.sql

```
{% set tmp_relation = adapter.get_relation(...) %}
{% set target_relation = adapter.get_relation(...) %}

{% do adapter.expand_target_column_types(tmp_relation, target_relation) %}
```

## get\_relation[​](#get_relation "Direct link to get_relation")

**Args**:

* `database`: The database of the relation to fetch
* `schema`: The schema of the relation to fetch
* `identifier`: The identifier of the relation to fetch

Returns a cached [Relation](https://docs.getdbt.com/reference/dbt-classes#relation) object identified by the `database.schema.identifier` provided to the method, or `None` if the relation does not exist.

**Usage**:

example.sql

```
{%- set source_relation = adapter.get_relation(
      database="analytics",
      schema="dbt_drew",
      identifier="orders") -%}

{{ log("Source Relation: " ~ source_relation, info=true) }}
```

## load\_relation[​](#load_relation "Direct link to load_relation")

**Args**:

* `relation`: The [Relation](https://docs.getdbt.com/reference/dbt-classes#relation) to try to load

A convenience wrapper for [get\_relation](#get_relation). Returns the cached version of the [Relation](https://docs.getdbt.com/reference/dbt-classes#relation) object, or `None` if the relation does not exist.

**Usage**:

example.sql

```
{% set relation_exists = load_relation(ref('my_model')) is not none %}
{% if relation_exists %}
      {{ log("my_model has already been built", info=true) }}
{% else %}
      {{ log("my_model doesn't exist in the warehouse. Maybe it was dropped?", info=true) }}
{% endif %}
```

## get\_columns\_in\_relation[​](#get_columns_in_relation "Direct link to get_columns_in_relation")

**Args**:

* `relation`: The [Relation](https://docs.getdbt.com/reference/dbt-classes#relation) to find the columns for

Returns a list of [Columns](https://docs.getdbt.com/reference/dbt-classes#column) in a table.

**Usage**:

example.sql

```
{%- set columns = adapter.get_columns_in_relation(this) -%}

{% for column in columns %}
  {{ log("Column: " ~ column, info=true) }}
{% endfor %}
```

## create\_schema[​](#create_schema "Direct link to create_schema")

**Args**:

* `relation`: A relation object with the database and schema to create. Any identifier on the relation will be ignored.

Creates a schema (or equivalent) in the target database. If the target schema already exists, then this method is a no-op.

**Usage:**

example.sql

```
{% do adapter.create_schema(api.Relation.create(database=target.database, schema="my_schema")) %}
```

## drop\_schema[​](#drop_schema "Direct link to drop_schema")

**Args**:

* `relation`: A relation object with the database and schema to drop. Any identifier on the relation will be ignored.

Drops a schema (or equivalent) in the target database. If the target schema does not exist, then this method is a no-op. The specific implementation is adapter-dependent, but adapters should implement a cascading drop, such that objects in the schema are also dropped. **Note**: this adapter method is destructive, so please use it with care!

**Usage:**

example.sql

```
{% do adapter.drop_schema(api.Relation.create(database=target.database, schema="my_schema")) %}
```

## drop\_relation[​](#drop_relation "Direct link to drop_relation")

**Args**:

* `relation`: The Relation to drop

Drops a Relation in the database. If the target relation does not exist, then this method is a no-op. The specific implementation is adapter-dependent, but adapters should implement a cascading drop, such that bound views downstream of the dropped relation are also dropped. **Note**: this adapter method is destructive, so please use it with care!

The `drop_relation` method will remove the specified relation from dbt's relation cache.

**Usage:**

example.sql

```
{% do adapter.drop_relation(this) %}
```

## rename\_relation[​](#rename_relation "Direct link to rename_relation")

**Args**:

* `from_relation`: The Relation to rename
* `to_relation`: The destination Relation to rename `from_relation` to

Renames a Relation the database. The `rename_relation` method will rename the specified relation in dbt's relation cache.

**Usage:**

example.sql

```
{%- set old_relation = adapter.get_relation(
      database=this.database,
      schema=this.schema,
      identifier=this.identifier) -%}

{%- set backup_relation = adapter.get_relation(
      database=this.database,
      schema=this.schema,
      identifier=this.identifier ~ "__dbt_backup") -%}

{% do adapter.rename_relation(old_relation, backup_relation) %}
```

## quote[​](#quote "Direct link to quote")

**Args**:

* `identifier`: A string to quote

Encloses `identifier` in the correct quotes for the adapter when escaping reserved column names etc.

**Usage:**

example.sql

```
select
      'abc' as {{ adapter.quote('table_name') }},
      'def' as {{ adapter.quote('group by') }}
```

## get\_columns\_in\_table[​](#get_columns_in_table "Direct link to get_columns_in_table")

Deprecated

This method is deprecated and will be removed in a future release. Please use [get\_columns\_in\_relation](#get_columns_in_relation) instead.

**Args**:

* `schema_name`: The schema to test
* `table_name`: The table (or view) from which to select columns

Returns a list of [Columns](https://docs.getdbt.com/reference/dbt-classes#column) in a table.

models/example.sql

```
{% set dest_columns = adapter.get_columns_in_table(schema, identifier) %}
{% set dest_cols_csv = dest_columns | map(attribute='quoted') | join(', ') %}

insert into {{ this }} ({{ dest_cols_csv }}) (
  select {{ dest_cols_csv }}
  from {{ref('another_table')}}
);
```

## already\_exists[​](#already_exists "Direct link to already_exists")

Deprecated

This method is deprecated and will be removed in a future release. Please use [get\_relation](#get_relation) instead.

**Args**:

* `schema`: The schema to test
* `table`: The relation to look for

Returns true if a relation named like `table` exists in schema `schema`, false otherwise.

models/example.sql

```
select * from {{ref('raw_table')}}

{% if adapter.already_exists(this.schema, this.name) %}
  where id > (select max(id) from {{this}})
{% endif %}
```

## adapter\_macro[​](#adapter_macro "Direct link to adapter_macro")

Deprecated

This method is deprecated and will be removed in a future release. Please use [adapter.dispatch](#dispatch) instead.

**Usage:**

macros/concat.sql

```
{% macro concat(fields) -%}
  {{ adapter_macro('concat', fields) }}
{%- endmacro %}


{% macro default__concat(fields) -%}
    concat({{ fields|join(', ') }})
{%- endmacro %}


{% macro redshift__concat(fields) %}
    {{ fields|join(' || ') }}
{% endmacro %}


{% macro snowflake__concat(fields) %}
    {{ fields|join(' || ') }}
{% endmacro %}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)[Next

as\_bool](https://docs.getdbt.com/reference/dbt-jinja-functions/as_bool)

* [Deprecated adapter functions](#deprecated-adapter-functions)* [dispatch](#dispatch)* [get\_missing\_columns](#get_missing_columns)* [expand\_target\_column\_types](#expand_target_column_types)* [get\_relation](#get_relation)* [load\_relation](#load_relation)* [get\_columns\_in\_relation](#get_columns_in_relation)* [create\_schema](#create_schema)* [drop\_schema](#drop_schema)* [drop\_relation](#drop_relation)* [rename\_relation](#rename_relation)* [quote](#quote)* [get\_columns\_in\_table](#get_columns_in_table)* [already\_exists](#already_exists)* [adapter\_macro](#adapter_macro)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/adapter.md)
