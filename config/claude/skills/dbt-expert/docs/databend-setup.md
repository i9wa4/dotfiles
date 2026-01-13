---
title: "Databend Cloud setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/databend-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Databend Cloud setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdatabend-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdatabend-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdatabend-setup+so+I+can+ask+questions+about+it.)

On this page

Vendor-supported plugin

Some [core functionality](https://github.com/databendcloud/dbt-databend#supported-features) may be limited.
If you're interested in contributing, check out the source code repository listed below.

* **Maintained by**: Databend Cloud* **Authors**: Shanjie Han* **GitHub repo**: [databendcloud/dbt-databend](https://github.com/databendcloud/dbt-databend) [![](https://img.shields.io/github/stars/databendcloud/dbt-databend?style=for-the-badge)](https://github.com/databendcloud/dbt-databend)* **PyPI package**: `dbt-databend-cloud` [![](https://badge.fury.io/py/dbt-databend-cloud.svg)](https://badge.fury.io/py/dbt-databend-cloud)* **Slack channel**: * **Supported dbt Core version**: v1.0.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: n/a

## Installing dbt-databend-cloud

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-databend-cloud`

## Configuring dbt-databend-cloud

For Databend Cloud-specific configuration, please refer to [Databend Cloud configs.](https://docs.getdbt.com/reference/resource-configs/no-configs)

## Connecting to Databend Cloud with **dbt-databend-cloud**[​](#connecting-to-databend-cloud-with-dbt-databend-cloud "Direct link to connecting-to-databend-cloud-with-dbt-databend-cloud")

### User / Password Authentication[​](#user--password-authentication "Direct link to User / Password Authentication")

Configure your dbt profile for using Databend Cloud:

#### Databend Cloud connection profile[​](#databend-cloud-connection-profile "Direct link to Databend Cloud connection profile")

profiles.yml

```
dbt-databend-cloud:
  target: dev
  outputs:
    dev:
      type: databend
      host: databend-cloud-host
      port: 443
      schema: database_name
      user: username
      pass: password
```

#### Description of Profile Fields[​](#description-of-profile-fields "Direct link to Description of Profile Fields")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Description Required? Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | type The specific adapter to use Required `databend`| host The host (hostname) to connect to Required `yourorg.datafusecloud.com`| port The port to use Required `443`| schema Specify the schema (database) to build models into Required `default`| user The username to use to connect to the host Required `dbt_admin`| pass The password to use for authenticating to the host Required `awesome_password` | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Database User Privileges[​](#database-user-privileges "Direct link to Database User Privileges")

Your database user would be able to have some abilities to read or write, such as `SELECT`, `CREATE`, and so on.
You can find some help [here](https://docs.databend.com/using-databend-cloud/warehouses/connecting-a-warehouse) with Databend Cloud privileges management.

|  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Required Privilege|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | SELECT|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | CREATE|  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | | CREATE TEMPORARY TABLE|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | CREATE VIEW|  |  |  |  |  | | --- | --- | --- | --- | --- | | INSERT|  |  |  |  | | --- | --- | --- | --- | | DROP|  |  |  | | --- | --- | --- | | SHOW DATABASE|  |  | | --- | --- | | SHOW VIEW|  | | --- | | SUPER | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Supported features[​](#supported-features "Direct link to Supported features")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ok Feature|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ Table materialization|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ View materialization|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ Incremental materialization|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ❌ Ephemeral materialization|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ Seeds|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ Sources|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ Custom data tests|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | ✅ Docs generate|  |  |  |  | | --- | --- | --- | --- | | ❌ Snapshots|  |  | | --- | --- | | ✅ Connection retry | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

**Note:**

* Databend does not support `Ephemeral` and `SnapShot`. You can find more detail [here](https://github.com/datafuselabs/databend/issues/8685)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

CrateDB setup](https://docs.getdbt.com/docs/core/connect-data-platform/cratedb-setup)[Next

Decodable setup](https://docs.getdbt.com/docs/core/connect-data-platform/decodable-setup)

* [Connecting to Databend Cloud with **dbt-databend-cloud**](#connecting-to-databend-cloud-with-dbt-databend-cloud)
  + [User / Password Authentication](#user--password-authentication)* [Database User Privileges](#database-user-privileges)* [Supported features](#supported-features)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/databend-setup.md)
