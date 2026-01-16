---
title: "Postgres Permissions | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/database-permissions/postgres-permissions"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Database Permissions](https://docs.getdbt.com/reference/database-permissions/about-database-permissions)* Postgres Permissions

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdatabase-permissions%2Fpostgres-permissions+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdatabase-permissions%2Fpostgres-permissions+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdatabase-permissions%2Fpostgres-permissions+so+I+can+ask+questions+about+it.)

On this page

In Postgres, permissions are used to control who can perform certain actions on different database objects. Use SQL statements to manage permissions in a Postgres database.

## Example Postgres permissions[​](#example-postgres-permissions "Direct link to Example Postgres permissions")

The following example provides you with the SQL statements you can use to manage permissions. These examples allow you to run dbt smoothly without encountering permission issues, such as creating schemas, reading existing data, and accessing the information schema.

**Note** that `database_name`, `source_schema`, `destination_schema`, and `user_name` are placeholders and you can replace them as needed for your organization's naming convention.

```
grant connect on database database_name to user_name;

-- Grant read permissions on the source schema
grant usage on schema source_schema to user_name;
grant select on all tables in schema source_schema to user_name;
alter default privileges in schema source_schema grant select on tables to user_name;

-- Create destination schema and make user_name the owner
create schema if not exists destination_schema;
alter schema destination_schema owner to user_name;

-- Grant write permissions on the destination schema
grant usage on schema destination_schema to user_name;
grant create on schema destination_schema to user_name;
grant insert, update, delete, truncate on all tables in schema destination_schema to user_name;
alter default privileges in schema destination_schema grant insert, update, delete, truncate on tables to user_name;
```

Check out the [official documentation](https://www.postgresql.org/docs/current/sql-grant.html) for more information.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Databricks permissions](https://docs.getdbt.com/reference/database-permissions/databricks-permissions)[Next

Redshift permissions](https://docs.getdbt.com/reference/database-permissions/redshift-permissions)

* [Example Postgres permissions](#example-postgres-permissions)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/database-permissions/postgres-permissions.md)
