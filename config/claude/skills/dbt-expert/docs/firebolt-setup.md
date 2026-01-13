---
title: "Firebolt setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/firebolt-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Firebolt setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ffirebolt-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ffirebolt-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ffirebolt-setup+so+I+can+ask+questions+about+it.)

On this page

Some core functionality may be limited. If you're interested in contributing, check out the source code for the repository listed below.

* **Maintained by**: Firebolt* **Authors**: Firebolt* **GitHub repo**: [firebolt-db/dbt-firebolt](https://github.com/firebolt-db/dbt-firebolt) [![](https://img.shields.io/github/stars/firebolt-db/dbt-firebolt?style=for-the-badge)](https://github.com/firebolt-db/dbt-firebolt)* **PyPI package**: `dbt-firebolt` [![](https://badge.fury.io/py/dbt-firebolt.svg)](https://badge.fury.io/py/dbt-firebolt)* **Slack channel**: [#db-firebolt](https://getdbt.slack.com/archives/C03K2PTHHTP)* **Supported dbt Core version**: v1.1.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: n/a

## Installing dbt-firebolt

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-firebolt`

## Configuring dbt-firebolt

For Firebolt-specific configuration, please refer to [Firebolt configs.](https://docs.getdbt.com/reference/resource-configs/firebolt-configs)

For other information including Firebolt feature support, see the [GitHub README](https://github.com/firebolt-db/dbt-firebolt/blob/main/README.md) and the [changelog](https://github.com/firebolt-db/dbt-firebolt/blob/main/CHANGELOG.md).

## Connecting to Firebolt[​](#connecting-to-firebolt "Direct link to Connecting to Firebolt")

To connect to Firebolt from dbt, you'll need to add a [profile](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles) to your `profiles.yml` file. A Firebolt profile conforms to the following syntax:

profiles.yml

```
<profile-name>:
  target: <target-name>
  outputs:
    <target-name>:
      type: firebolt
      client_id: "<id>"
      client_secret: "<secret>"
      database: "<database-name>"
      engine_name: "<engine-name>"
      account_name: "<account-name>"
      schema: <tablename-prefix>
      threads: 1
      #optional fields
      host: "<hostname>"
```

#### Description of Firebolt Profile Fields[​](#description-of-firebolt-profile-fields "Direct link to Description of Firebolt Profile Fields")

To specify values as environment variables, use the format `{{ env_var('<variable_name>' }}`. For example, `{{ env_var('DATABASE_NAME' }}`.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `type` This must be included either in `profiles.yml` or in the `dbt_project.yml` file. Must be set to `firebolt`.| `client_id` Required. Your [service account](https://docs.firebolt.io/godocs/Guides/managing-your-organization/service-accounts.html) id.| `client_secret` Required. The secret associated with the specified `client_id`.| `database` Required. The name of the Firebolt database to connect to.|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `engine_name` Required. The name (not the URL) of the Firebolt engine to use in the specified `database`. This must be a general purpose read-write engine and the engine must be running. If omitted in earlier versions, the default engine for the specified `database` is used.| `account_name` Required. Specifies the account name under which the specified `database` exists.| `schema` Recommended. A string to add as a prefix to the names of generated tables when using the [custom schemas workaround](https://docs.getdbt.com/docs/core/connect-data-platform/firebolt-setup#supporting-concurrent-development).| `threads` Required. Set to higher number to improve performance.|  |  | | --- | --- | | `host` Optional. The host name of the connection. For all customers it is `api.app.firebolt.io`, which will be used if omitted. | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Troubleshooting Connections[​](#troubleshooting-connections "Direct link to Troubleshooting Connections")

If you encounter issues connecting to Firebolt from dbt, make sure the following criteria are met:

* You must have adequate permissions to access the engine and the database.
* Your service account must be attached to a user.
* The engine must be running.

## Supporting Concurrent Development[​](#supporting-concurrent-development "Direct link to Supporting Concurrent Development")

In dbt, database schemas are used to compartmentalize developer environments so that concurrent development does not cause table name collisions. Firebolt, however, does not currently support database schemas (it is on the roadmap). To work around this, we recommend that you add the following macro to your project. This macro will take the `schema` field of your `profiles.yml` file and use it as a table name prefix.

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

For an example of how this works, let’s say Shahar and Eric are both working on the same project.

In her `.dbt/profiles.yml`, Sharar sets `schema=sh`, whereas Eric sets `schema=er` in his. When each runs the `customers` model, the models will land in the database as tables named `sh_customers` and `er_customers`, respectively. When running dbt in production, you would use yet another `profiles.yml` with a string of your choice.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Extrica Setup](https://docs.getdbt.com/docs/core/connect-data-platform/extrica-setup)[Next

Greenplum setup](https://docs.getdbt.com/docs/core/connect-data-platform/greenplum-setup)

* [Connecting to Firebolt](#connecting-to-firebolt)* [Supporting Concurrent Development](#supporting-concurrent-development)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/firebolt-setup.md)
