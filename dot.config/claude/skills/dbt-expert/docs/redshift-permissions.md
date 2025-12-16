---
title: "Redshift permissions | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/database-permissions/redshift-permissions"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Database Permissions](https://docs.getdbt.com/reference/database-permissions/about-database-permissions)* Redshift permissions

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdatabase-permissions%2Fredshift-permissions+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdatabase-permissions%2Fredshift-permissions+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdatabase-permissions%2Fredshift-permissions+so+I+can+ask+questions+about+it.)

On this page

In Redshift, permissions are used to control who can perform certain actions on different database objects. Use SQL statements to manage permissions in a Redshift database.

## Example Redshift permissions[​](#example-redshift-permissions "Direct link to Example Redshift permissions")

The following example provides you with the SQL statements you can use to manage permissions.

**Note** that `database_name`, `database.schema_name`, and `user_name` are placeholders and you can replace them as needed for your organization's naming convention.

```
grant create schema on database database_name to user_name;
grant usage on schema database.schema_name to user_name;
grant create table on schema database.schema_name to user_name;
grant create view on schema database.schema_name to user_name;
grant usage for schemas in database database_name to role role_name;
grant select on all tables in database database_name to user_name;
grant select on all views in database database_name to user_name;
```

To connect to the database, confirm with an admin that your user role or group has been added to the database. Note that Redshift permissions differ from Postgres, and commands like [`grant connect`](https://www.postgresql.org/docs/current/sql-grant.html) aren't supported in Redshift.

Check out the [official documentation](https://docs.aws.amazon.com/redshift/latest/dg/r_GRANT.html) for more information.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Postgres Permissions](https://docs.getdbt.com/reference/database-permissions/postgres-permissions)[Next

Snowflake permissions](https://docs.getdbt.com/reference/database-permissions/snowflake-permissions)

* [Example Redshift permissions](#example-redshift-permissions)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/database-permissions/redshift-permissions.md)
