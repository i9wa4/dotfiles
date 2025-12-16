---
title: "MindsDB setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/mindsdb-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* MindsDB setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fmindsdb-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fmindsdb-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fmindsdb-setup+so+I+can+ask+questions+about+it.)

On this page

Vendor-supported plugin

The dbt-mindsdb package allows dbt to connect to [MindsDB](https://github.com/mindsdb/mindsdb).

* **Maintained by**: MindsDB* **Authors**: MindsDB team* **GitHub repo**: [mindsdb/dbt-mindsdb](https://github.com/mindsdb/dbt-mindsdb) [![](https://img.shields.io/github/stars/mindsdb/dbt-mindsdb?style=for-the-badge)](https://github.com/mindsdb/dbt-mindsdb)* **PyPI package**: `dbt-mindsdb` [![](https://badge.fury.io/py/dbt-mindsdb.svg)](https://badge.fury.io/py/dbt-mindsdb)* **Slack channel**: [n/a](https://www.getdbt.com/community)* **Supported dbt Core version**: v1.0.1 and newer* **dbt support**: Not Supported* **Minimum data platform version**: ?

## Installing dbt-mindsdb

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-mindsdb`

## Configuring dbt-mindsdb

For MindsDB-specific configuration, please refer to [MindsDB configs.](https://docs.getdbt.com/reference/resource-configs/mindsdb-configs)

## Configurations[​](#configurations "Direct link to Configurations")

Basic `profile.yml` for connecting to MindsDB:

```
mindsdb:
  outputs:
    dev:
      database: 'mindsdb'
      host: '127.0.0.1'
      password: ''
      port: 47335
      schema: 'mindsdb'
      type: mindsdb
      username: 'mindsdb'
  target: dev
```

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Key Required Description Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | type ✔️ The specific adapter to use `mindsdb`| host ✔️ The MindsDB (hostname) to connect to `cloud.mindsdb.com`| port ✔️ The port to use `3306` or `47335`| schema ✔️ Specify the schema (database) to build models into The MindsDB datasource|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | username ✔️ The username to use to connect to the server `mindsdb` or mindsdb cloud user| password ✔️ The password to use for authenticating to the server `pass | | | | | | | | | | | | | | | | | | | | | | | | | | | |

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

Microsoft SQL Server setup](https://docs.getdbt.com/docs/core/connect-data-platform/mssql-setup)[Next

MySQL setup](https://docs.getdbt.com/docs/core/connect-data-platform/mysql-setup)

* [Configurations](#configurations)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/mindsdb-setup.md)
