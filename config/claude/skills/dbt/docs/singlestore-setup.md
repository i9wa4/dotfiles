---
title: "SingleStore setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/singlestore-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* SingleStore setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fsinglestore-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fsinglestore-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fsinglestore-setup+so+I+can+ask+questions+about+it.)

On this page

Vendor-supported plugin

Certain core functionality may vary. If you would like to report a bug, request a feature, or contribute, you can check out the linked repository and open an issue.

* **Maintained by**: SingleStore, Inc.* **Authors**: SingleStore, Inc.* **GitHub repo**: [memsql/dbt-singlestore](https://github.com/memsql/dbt-singlestore) [![](https://img.shields.io/github/stars/memsql/dbt-singlestore?style=for-the-badge)](https://github.com/memsql/dbt-singlestore)* **PyPI package**: `dbt-singlestore` [![](https://badge.fury.io/py/dbt-singlestore.svg)](https://badge.fury.io/py/dbt-singlestore)* **Slack channel**: [db-singlestore](https://getdbt.slack.com/archives/C02V2QHFF7U)* **Supported dbt Core version**: v1.0.0 and newer* **dbt support**: Not supported* **Minimum data platform version**: v7.5

## Installing dbt-singlestore

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-singlestore`

## Configuring dbt-singlestore

For SingleStore-specific configuration, please refer to [SingleStore configs.](https://docs.getdbt.com/reference/resource-configs/singlestore-configs)

### Set up a SingleStore Target[​](#set-up-a-singlestore-target "Direct link to Set up a SingleStore Target")

SingleStore targets should be set up using the following configuration in your `profiles.yml` file. If you are using SingleStore Managed Service, required connection details can be found on your Cluster Page under "Connect" -> "SQL IDE" tab.

~/.dbt/profiles.yml

```
singlestore:
  target: dev
  outputs:
    dev:
      type: singlestore
      host: [hostname]  # optional, default localhost
      port: [port number]  # optional, default 3306
      user: [user]  # optional, default root
      password: [password]  # optional, default empty
      database: [database name]  # required
      schema: [prefix for tables that dbt will generate]  # required
      threads: [1 or more]  # optional, default 1
```

It is recommended to set optional parameters as well.

### Description of SingleStore Profile Fields[​](#description-of-singlestore-profile-fields "Direct link to Description of SingleStore Profile Fields")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Required Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `type` Yes Must be set to `singlestore`. This must be included either in `profiles.yml` or in the `dbt_project.yml` file.| `host` No The host name of the SingleStore server to connect to.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `user` No Your SingleStore database username.|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `password` No Your SingleStore database password.|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `database` Yes The name of your database. If you are using custom database names in your models config, they must be created prior to running those models.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `schema` Yes The string to prefix the names of generated tables if `generate_alias_name` macro is added (see below). If you are using a custom schema name in your model config, it will be concatenated with the one specified in profile using `_`.| `threads` No The number of threads available to dbt. | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Schema and Concurrent Development[​](#schema-and-concurrent-development "Direct link to Schema and Concurrent Development")

SingleStore doesn't have a concept of `schema` that corresponds to one used in `dbt` (namespace within a database). `schema` in your profile is required for `dbt` to work correctly with your project metadata. For example, you will see it on "dbt docs" page, even though it's not present in the database.

In order to support concurrent development, `schema` can be used to prefix table names that `dbt` is building within your database. In order to enable this, add the following macro to your project. This macro will take the `schema` field of your `profiles.yml` file and use it as a table name prefix.

```
-- macros/generate_alias_name.sql
{% macro generate_alias_name(custom_alias_name=none, node=none) -%}
    {%- if custom_alias_name is none -%}
        {{ node.schema }}__{{ node.name }}
    {%- else -%}
        {{ node.schema }}__{{ custom_alias_name | trim }}
    {%- endif -%}
{%- endmacro %}
```

Therefore, if you set `schema=dev` in your `.dbt/profiles.yml` file and run the `customers` model with the corresponding profile, `dbt` will create a table named `dev__customers` in your database.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Rockset setup](https://docs.getdbt.com/docs/core/connect-data-platform/rockset-setup)[Next

SQLite setup](https://docs.getdbt.com/docs/core/connect-data-platform/sqlite-setup)

* [Set up a SingleStore Target](#set-up-a-singlestore-target)* [Description of SingleStore Profile Fields](#description-of-singlestore-profile-fields)* [Schema and Concurrent Development](#schema-and-concurrent-development)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/singlestore-setup.md)
