---
title: "MySQL setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/mysql-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* MySQL setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fmysql-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fmysql-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fmysql-setup+so+I+can+ask+questions+about+it.)

On this page

Community plugin

Some core functionality may be limited. If you're interested in contributing, check out the source code for each repository listed below.

* **Maintained by**: Community* **Authors**: Doug Beatty (https://github.com/dbeatty10)* **GitHub repo**: [dbeatty10/dbt-mysql](https://github.com/dbeatty10/dbt-mysql) [![](https://img.shields.io/github/stars/dbeatty10/dbt-mysql?style=for-the-badge)](https://github.com/dbeatty10/dbt-mysql)* **PyPI package**: `dbt-mysql` [![](https://badge.fury.io/py/dbt-mysql.svg)](https://badge.fury.io/py/dbt-mysql)* **Slack channel**: [#db-mysql-family](https://getdbt.slack.com/archives/C03BK0SHC64)* **Supported dbt Core version**: v0.18.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: MySQL 5.7 and 8.0

## Installing dbt-mysql

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-mysql`

## Configuring dbt-mysql

For MySQL-specific configuration, please refer to [MySQL configs.](https://docs.getdbt.com/reference/resource-configs/no-configs)

This is an experimental plugin:

* It has not been tested extensively.
* Storage engines other than the default of InnoDB are untested.
* Only tested with [dbt-adapter-tests](https://github.com/dbt-labs/dbt-adapter-tests) with the following versions:
  + MySQL 5.7
  + MySQL 8.0
  + MariaDB 10.5
* Compatibility with other [dbt packages](https://hub.getdbt.com/) (like [dbt\_utils](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/)) are also untested.

Please read these docs carefully and use at your own risk. [Issues](https://github.com/dbeatty10/dbt-mysql/issues/new) and [PRs](https://github.com/dbeatty10/dbt-mysql/blob/main/CONTRIBUTING.rst#contributing) welcome!

## Connecting to MySQL with dbt-mysql[​](#connecting-to-mysql-with-dbt-mysql "Direct link to Connecting to MySQL with dbt-mysql")

MySQL targets should be set up using the following configuration in your `profiles.yml` file.

Example:

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: mysql
      server: localhost
      port: 3306
      schema: analytics
      username: your_mysql_username
      password: your_mysql_password
      ssl_disabled: True
```

#### Description of MySQL Profile Fields[​](#description-of-mysql-profile-fields "Direct link to Description of MySQL Profile Fields")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Description Required? Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | type The specific adapter to use Required `mysql`, `mysql5` or `mariadb`| server The server (hostname) to connect to Required `yourorg.mysqlhost.com`| port The port to use Optional `3306`| schema Specify the schema (database) to build models into Required `analytics`| username The username to use to connect to the server Required `dbt_admin`| password The password to use for authenticating to the server Required `correct-horse-battery-staple`| ssl\_disabled Set to enable or disable TLS connectivity to mysql5.x Optional `True` or `False` | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Supported features[​](#supported-features "Direct link to Supported features")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| MariaDB 10.5 MySQL 5.7 MySQL 8.0 Feature|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ Table materialization|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ View materialization|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ Incremental materialization|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ❌ ✅ Ephemeral materialization|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ Seeds|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ Sources|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ Custom data tests|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | ✅ ✅ ✅ Docs generate|  |  |  |  | | --- | --- | --- | --- | | 🤷 🤷 ✅ Snapshots | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Notes[​](#notes "Direct link to Notes")

* Ephemeral materializations rely upon [Common Table Expressions](https://en.wikipedia.org/wiki/Hierarchical_and_recursive_queries_in_SQL) (CTEs), which are not supported until MySQL 8.0.
* MySQL 5.7 has some configuration gotchas that might affect dbt snapshots to not work properly due to [automatic initialization and updating for `TIMESTAMP`](https://dev.mysql.com/doc/refman/5.7/en/timestamp-initialization.html).
  + If the output of `SHOW VARIABLES LIKE 'sql_mode'` includes `NO_ZERO_DATE`. A solution is to include the following in a `*.cnf` file:

  ```
  [mysqld]
  explicit_defaults_for_timestamp = true
  sql_mode = "ALLOW_INVALID_DATES,{other_sql_modes}"
  ```

  + Where `{other_sql_modes}` is the rest of the modes from the `SHOW VARIABLES LIKE 'sql_mode'` output.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

MindsDB setup](https://docs.getdbt.com/docs/core/connect-data-platform/mindsdb-setup)[Next

Oracle setup](https://docs.getdbt.com/docs/core/connect-data-platform/oracle-setup)

* [Connecting to MySQL with dbt-mysql](#connecting-to-mysql-with-dbt-mysql)* [Supported features](#supported-features)* [Notes](#notes)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/mysql-setup.md)
