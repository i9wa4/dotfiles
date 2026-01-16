---
title: "TiDB setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/tidb-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* TiDB setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ftidb-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ftidb-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ftidb-setup+so+I+can+ask+questions+about+it.)

On this page

Vendor-supported plugin

Some [core functionality](https://github.com/pingcap/dbt-tidb/blob/main/README.md#supported-features) may be limited.
If you're interested in contributing, check out the source code repository listed below.

* **Maintained by**: PingCAP* **Authors**: Xiang Zhang, Qiang Wu, Yuhang Shi* **GitHub repo**: [pingcap/dbt-tidb](https://github.com/pingcap/dbt-tidb) [![](https://img.shields.io/github/stars/pingcap/dbt-tidb?style=for-the-badge)](https://github.com/pingcap/dbt-tidb)* **PyPI package**: `dbt-tidb` [![](https://badge.fury.io/py/dbt-tidb.svg)](https://badge.fury.io/py/dbt-tidb)* **Slack channel**: [#db-tidb](https://getdbt.slack.com/archives/C03CC86R1NY)* **Supported dbt Core version**: v1.0.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: n/a

## Installing dbt-tidb

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-tidb`

## Configuring dbt-tidb

For TiDB-specific configuration, please refer to [TiDB configs.](https://docs.getdbt.com/reference/resource-configs/no-configs)

## Connecting to TiDB with **dbt-tidb**[​](#connecting-to-tidb-with-dbt-tidb "Direct link to connecting-to-tidb-with-dbt-tidb")

### User / Password Authentication[​](#user--password-authentication "Direct link to User / Password Authentication")

Configure your dbt profile for using TiDB:

#### TiDB connection profile[​](#tidb-connection-profile "Direct link to TiDB connection profile")

profiles.yml

```
dbt-tidb:
  target: dev
  outputs:
    dev:
      type: tidb
      server: 127.0.0.1
      port: 4000
      schema: database_name
      username: tidb_username
      password: tidb_password

      # optional
      retries: 3 # default 1
```

#### Description of Profile Fields[​](#description-of-profile-fields "Direct link to Description of Profile Fields")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Description Required? Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | type The specific adapter to use Required `tidb`| server The server (hostname) to connect to Required `yourorg.tidb.com`| port The port to use Required `4000`| schema Specify the schema (database) to build models into Required `analytics`| username The username to use to connect to the server Required `dbt_admin`| password The password to use for authenticating to the server Required `awesome_password`| retries The retry times after an unsuccessful connection Optional `default 1` | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Database User Privileges[​](#database-user-privileges "Direct link to Database User Privileges")

Your database user would be able to have some abilities to read or write, such as `SELECT`, `CREATE`, and so on.
You can find some help [here](https://docs.pingcap.com/tidb/v4.0/privilege-management) with TiDB privileges management.

|  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Required Privilege|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | SELECT|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | CREATE|  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | | CREATE TEMPORARY TABLE|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | CREATE VIEW|  |  |  |  |  | | --- | --- | --- | --- | --- | | INSERT|  |  |  |  | | --- | --- | --- | --- | | DROP|  |  |  | | --- | --- | --- | | SHOW DATABASE|  |  | | --- | --- | | SHOW VIEW|  | | --- | | SUPER | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Supported features[​](#supported-features "Direct link to Supported features")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| TiDB 4.X TiDB 5.0 ~ 5.2 TiDB >= 5.3 Feature|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ Table materialization|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ View materialization|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ❌ ❌ ✅ Incremental materialization|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ❌ ✅ ✅ Ephemeral materialization|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ Seeds|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ Sources|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ Custom data tests|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ Docs generate|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ❌ ❌ ✅ Snapshots|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ Grant|  |  |  |  | | --- | --- | --- | --- | | ✅ ✅ ✅ Connection retry | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

**Note:**

* TiDB 4.0 ~ 5.0 does not support [CTE](https://docs.pingcap.com/tidb/dev/sql-statement-with),
  you should avoid using `WITH` in your SQL code.
* TiDB 4.0 ~ 5.2 does not support creating a [temporary table or view](https://docs.pingcap.com/tidb/v5.2/sql-statement-create-table#:~:text=sec)-,MySQL%20compatibility,-TiDB%20does%20not).
* TiDB 4.X does not support using SQL func in `CREATE VIEW`, avoid it in your SQL code.
  You can find more detail [here](https://github.com/pingcap/tidb/pull/27252).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Teradata setup](https://docs.getdbt.com/docs/core/connect-data-platform/teradata-setup)[Next

Upsolver setup](https://docs.getdbt.com/docs/core/connect-data-platform/upsolver-setup)

* [Connecting to TiDB with **dbt-tidb**](#connecting-to-tidb-with-dbt-tidb)
  + [User / Password Authentication](#user--password-authentication)* [Database User Privileges](#database-user-privileges)* [Supported features](#supported-features)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/tidb-setup.md)
