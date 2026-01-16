---
title: "Doris setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/doris-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Doris setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdoris-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdoris-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fdoris-setup+so+I+can+ask+questions+about+it.)

On this page

* **Maintained by**: SelectDB* **Authors**: catpineapple,JNSimba* **GitHub repo**: [selectdb/dbt-doris](https://github.com/selectdb/dbt-doris) [![](https://img.shields.io/github/stars/selectdb/dbt-doris?style=for-the-badge)](https://github.com/selectdb/dbt-doris)* **PyPI package**: `dbt-doris` [![](https://badge.fury.io/py/dbt-doris.svg)](https://badge.fury.io/py/dbt-doris)* **Slack channel**: [#db-doris](https://www.getdbt.com/community)* **Supported dbt Core version**: v1.3.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**:

## Installing dbt-doris

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-doris`

## Configuring dbt-doris

For Apache Doris / SelectDB-specific configuration, please refer to [Apache Doris / SelectDB configs.](https://docs.getdbt.com/reference/resource-configs/doris-configs)

## Connecting to Doris/SelectDB with **dbt-doris**[​](#connecting-to-dorisselectdb-with-dbt-doris "Direct link to connecting-to-dorisselectdb-with-dbt-doris")

### User / Password Authentication[​](#user--password-authentication "Direct link to User / Password Authentication")

Configure your dbt profile for using Doris:

#### Doris connection profile[​](#doris-connection-profile "Direct link to Doris connection profile")

profiles.yml

```
dbt-doris:
  target: dev
  outputs:
    dev:
      type: doris
      host: 127.0.0.1
      port: 9030
      schema: database_name
      username: username
      password: password
```

#### Description of Profile Fields[​](#description-of-profile-fields "Direct link to Description of Profile Fields")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Description Required? Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | type The specific adapter to use Required `doris`| host The hostname to connect to Required `127.0.0.1`| port The port to use Required `9030`| schema Specify the schema (database) to build models into, doris have not schema to make a collection of table or view' like PostgreSql Required `dbt`| username The username to use to connect to the doris Required `root`| password The password to use for authenticating to the doris Required `password` | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Database User Privileges[​](#database-user-privileges "Direct link to Database User Privileges")

Your Doris/SelectDB database user would be able to have some abilities to read or write.
You can find some help [here](https://doris.apache.org/docs/admin-manual/privilege-ldap/user-privilege) with Doris privileges management.

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| Required Privilege|  |  |  |  |  | | --- | --- | --- | --- | --- | | Select\_priv|  |  |  |  | | --- | --- | --- | --- | | Load\_priv|  |  |  | | --- | --- | --- | | Alter\_priv|  |  | | --- | --- | | Create\_priv|  | | --- | | Drop\_priv | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Decodable setup](https://docs.getdbt.com/docs/core/connect-data-platform/decodable-setup)[Next

Dremio setup](https://docs.getdbt.com/docs/core/connect-data-platform/dremio-setup)

* [Connecting to Doris/SelectDB with **dbt-doris**](#connecting-to-dorisselectdb-with-dbt-doris)
  + [User / Password Authentication](#user--password-authentication)* [Database User Privileges](#database-user-privileges)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/doris-setup.md)
