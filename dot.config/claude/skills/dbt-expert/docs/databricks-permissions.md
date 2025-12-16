---
title: "Databricks permissions | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/database-permissions/databricks-permissions"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Database Permissions](https://docs.getdbt.com/reference/database-permissions/about-database-permissions)* Databricks permissions

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdatabase-permissions%2Fdatabricks-permissions+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdatabase-permissions%2Fdatabricks-permissions+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdatabase-permissions%2Fdatabricks-permissions+so+I+can+ask+questions+about+it.)

On this page

In Databricks, permissions are used to control who can perform certain actions on different database objects. Use SQL statements to manage permissions in a Databricks database.

## Example Databricks permissions[​](#example-databricks-permissions "Direct link to Example Databricks permissions")

The following example provides you with the SQL statements you can use to manage permissions.

**Note** that you can grant permissions on `securable_objects` to `principals` (This can be user, service principal, or group). For example, `grant privilege_type` on `securable_object` to `principal`.

```
grant all privileges on schema schema_name to principal;
grant create table on schema schema_name to principal;
grant create view on schema schema_name to principal;
```

Check out the [official documentation](https://docs.databricks.com/en/data-governance/unity-catalog/manage-privileges/privileges.html#privilege-types-by-securable-object-in-unity-catalog) for more information.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About database permissions](https://docs.getdbt.com/reference/database-permissions/about-database-permissions)[Next

Postgres Permissions](https://docs.getdbt.com/reference/database-permissions/postgres-permissions)

* [Example Databricks permissions](#example-databricks-permissions)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/database-permissions/databricks-permissions.md)
