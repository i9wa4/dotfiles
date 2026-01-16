---
title: "Snowflake permissions | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/database-permissions/snowflake-permissions"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Database Permissions](https://docs.getdbt.com/reference/database-permissions/about-database-permissions)* Snowflake permissions

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdatabase-permissions%2Fsnowflake-permissions+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdatabase-permissions%2Fsnowflake-permissions+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdatabase-permissions%2Fsnowflake-permissions+so+I+can+ask+questions+about+it.)

On this page

In Snowflake, permissions are used to control who can perform certain actions on different database objects. Use SQL statements to manage permissions in a Snowflake database.

## Set up Snowflake account[​](#set-up-snowflake-account "Direct link to Set up Snowflake account")

This section explains how to set up permissions and roles within Snowflake. In Snowflake, you would perform these actions using SQL commands and set up your data warehouse and access control within Snowflake's ecosystem.

1. Set up databases

```
use role sysadmin;
create database raw;
create database analytics;
```

2. Set up warehouses

```
create warehouse loading
    warehouse_size = xsmall
    auto_suspend = 3600
    auto_resume = false
    initially_suspended = true;

create warehouse transforming
    warehouse_size = xsmall
    auto_suspend = 60
    auto_resume = true
    initially_suspended = true;

create warehouse reporting
    warehouse_size = xsmall
    auto_suspend = 60
    auto_resume = true
    initially_suspended = true;
```

3. Set up roles and warehouse permissions

```
use role securityadmin;

create role loader;
grant all on warehouse loading to role loader;

create role transformer;
grant all on warehouse transforming to role transformer;

create role reporter;
grant all on warehouse reporting to role reporter;
```

4. Create users, assigning them to their roles

Every person and application gets a separate user and is assigned to the correct role.

```
create user stitch_user -- or fivetran_user
    password = '_generate_this_'
    default_warehouse = loading
    default_role = loader;

create user claire -- or amy, jeremy, etc.
    password = '_generate_this_'
    default_warehouse = transforming
    default_role = transformer
    must_change_password = true;

create user dbt_cloud_user
    password = '_generate_this_'
    default_warehouse = transforming
    default_role = transformer;

create user looker_user -- or mode_user etc.
    password = '_generate_this_'
    default_warehouse = reporting
    default_role = reporter;

-- then grant these roles to each user
grant role loader to user stitch_user; -- or fivetran_user
grant role transformer to user dbt_cloud_user;
grant role transformer to user claire; -- or amy, jeremy
grant role reporter to user looker_user; -- or mode_user, periscope_user
```

5. Let loader load data

Give the role unilateral permission to operate on the raw database

```
use role sysadmin;
grant all on database raw to role loader;
```

6. Let transformer transform data

The transformer role needs to be able to read raw data.

If you do this before you have any data loaded, you can run:

```
grant usage on database raw to role transformer;
grant usage on future schemas in database raw to role transformer;
grant select on future tables in database raw to role transformer;
grant select on future views in database raw to role transformer;
```

If you already have data loaded in the raw database, make sure also you run the following to update the permissions

```
grant usage on all schemas in database raw to role transformer;
grant select on all tables in database raw to role transformer;
grant select on all views in database raw to role transformer;
```

transformer also needs to be able to create in the analytics database:

```
grant all on database analytics to role transformer;
```

7. Let reporter read the transformed data

A previous version of this article recommended this be implemented through hooks in dbt, but this way lets you get away with a one-off statement.

```
grant usage on database analytics to role reporter;
grant usage on future schemas in database analytics to role reporter;
grant select on future tables in database analytics to role reporter;
grant select on future views in database analytics to role reporter;
```

Again, if you already have data in your analytics database, make sure you run:

```
grant usage on all schemas in database analytics to role reporter;
grant select on all tables in database analytics to role reporter;
grant select on all views in database analytics to role reporter;
```

8. Maintain

When new users are added, make sure you add them to the right role! Everything else should be inherited automatically thanks to those `future` grants.

For more discussion and legacy information, refer to [this Discourse article](https://discourse.getdbt.com/t/setting-up-snowflake-the-exact-grant-statements-we-run/439).

## Example Snowflake permissions[​](#example-snowflake-permissions "Direct link to Example Snowflake permissions")

The following example provides you with the SQL statements you can use to manage permissions.

**Note** that `warehouse_name`, `database_name`, and `role_name` are placeholders and you can replace them as needed for your organization's naming convention.

```
grant all on warehouse warehouse_name to role role_name;
grant usage on database database_name to role role_name;
grant create schema on database database_name to role role_name;
grant usage on schema database.an_existing_schema to role role_name;
grant create table on schema database.an_existing_schema to role role_name;
grant create view on schema database.an_existing_schema to role role_name;
grant usage on future schemas in database database_name to role role_name;
grant monitor on future schemas in database database_name to role role_name;
grant select on future tables in database database_name to role role_name;
grant select on future views in database database_name to role role_name;
grant usage on all schemas in database database_name to role role_name;
grant monitor on all schemas in database database_name to role role_name;
grant select on all tables in database database_name to role role_name;
grant select on all views in database database_name to role role_name;
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Redshift permissions](https://docs.getdbt.com/reference/database-permissions/redshift-permissions)

* [Set up Snowflake account](#set-up-snowflake-account)* [Example Snowflake permissions](#example-snowflake-permissions)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/database-permissions/snowflake-permissions.md)
