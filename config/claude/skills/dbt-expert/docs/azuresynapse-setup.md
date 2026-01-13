---
title: "Microsoft Azure Synapse Analytics setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/azuresynapse-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Microsoft Azure Synapse Analytics setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fazuresynapse-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fazuresynapse-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fazuresynapse-setup+so+I+can+ask+questions+about+it.)

On this page

info

The following is a guide to using Azure Synapse Analytics dedicated SQL pools (formerly SQL DW). For more info, refer to [What is dedicated SQL pool (formerly SQL DW) in Azure Synapse Analytics?](https://learn.microsoft.com/azure/synapse-analytics/sql-data-warehouse/sql-data-warehouse-overview-what-is) for more info.

For Microsoft Fabric setup with dbt, refer to [Microsoft Fabric Data Warehouse](https://docs.getdbt.com/docs/core/connect-data-platform/fabric-setup).

* **Maintained by**: Microsoft* **Authors**: Microsoft (https://github.com/Microsoft)* **GitHub repo**: [Microsoft/dbt-synapse](https://github.com/Microsoft/dbt-synapse) [![](https://img.shields.io/github/stars/Microsoft/dbt-synapse?style=for-the-badge)](https://github.com/Microsoft/dbt-synapse)* **PyPI package**: `dbt-synapse` [![](https://badge.fury.io/py/dbt-synapse.svg)](https://badge.fury.io/py/dbt-synapse)* **Slack channel**: [#db-synapse](https://getdbt.slack.com/archives/C01DRQ178LQ)* **Supported dbt Core version**: v0.18.0 and newer* **dbt support**: Supported* **Minimum data platform version**: Azure Synapse 10

## Installing dbt-synapse

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-synapse`

## Configuring dbt-synapse

For Synapse-specific configuration, please refer to [Synapse configs.](https://docs.getdbt.com/reference/resource-configs/azuresynapse-configs)

Dedicated SQL only

Azure Synapse Analytics offers both dedicated SQL pools and serverless SQL pools.
\*\*Only Dedicated SQL Pools are supported by this adapter.

### Prerequisites[​](#prerequisites "Direct link to Prerequisites")

On Debian/Ubuntu make sure you have the ODBC header files before installing

```
sudo apt install unixodbc-dev
```

Download and install the [Microsoft ODBC Driver 18 for SQL Server](https://docs.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server?view=sql-server-ver15).
If you already have ODBC Driver 17 installed, then that one will work as well.

Default settings change in dbt-synapse v1.2 / ODBC Driver 18

Microsoft made several changes related to connection encryption. Read more about the changes [here](https://docs.getdbt.com/docs/core/connect-data-platform/mssql-setup).

### Authentication methods[​](#authentication-methods "Direct link to Authentication methods")

This adapter is based on the adapter for Microsoft SQL Server.
Therefore, the same authentication methods are supported.

The configuration is the same except for 1 major difference:
instead of specifying `type: sqlserver`, you specify `type: synapse`.

Example:

profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: synapse
      driver: 'ODBC Driver 17 for SQL Server' # (The ODBC Driver installed on your system)
      server: workspacename.sql.azuresynapse.net # (Dedicated SQL endpoint of your workspace here)
      port: 1433
      database: exampledb
      schema: schema_name
      user: username
      password: password
```

You can find all the available options and the documentation and how to configure them on [the documentation page for the dbt-sqlserver adapter](https://docs.getdbt.com/docs/core/connect-data-platform/mssql-setup).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Materialize setup](https://docs.getdbt.com/docs/core/connect-data-platform/materialize-setup)[Next

Microsoft SQL Server setup](https://docs.getdbt.com/docs/core/connect-data-platform/mssql-setup)

* [Prerequisites](#prerequisites)* [Authentication methods](#authentication-methods)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/azuresynapse-setup.md)
