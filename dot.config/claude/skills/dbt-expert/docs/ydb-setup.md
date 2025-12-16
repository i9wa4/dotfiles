---
title: "YDB setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/ydb-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* YDB setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fydb-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fydb-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fydb-setup+so+I+can+ask+questions+about+it.)

On this page

## Overview of dbt-ydb

* **Maintained by**: YDB Team* **Authors**: YDB Team* **GitHub repo**: [ydb-platform/dbt-ydb](https://github.com/ydb-platform/dbt-ydb)[![](https://img.shields.io/github/stars/ydb-platform/dbt-ydb?style=for-the-badge)](https://github.com/ydb-platform/dbt-ydb)* **PyPI package**: `dbt-ydb` [![](https://badge.fury.io/py/dbt-ydb.svg)](https://badge.fury.io/py/dbt-ydb)* **Slack channel**: n/a* **Supported dbt Core version**: v1.8.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: n/a

## Installing dbt-ydb

pip is the easiest way to install the adapter:

`python -m pip install dbt-ydb`

Installing `dbt-ydb` will also install `dbt-core` and any other dependencies.

## Configuring dbt-ydb

For YDB-specifc configuration please refer to [YDB Configuration](https://docs.getdbt.com/reference/resource-configs/no-configs)

For further info, refer to the GitHub repository: [ydb-platform/dbt-ydb](https://github.com/ydb-platform/dbt-ydb)

## Connecting to YDB[​](#connecting-to-ydb "Direct link to Connecting to YDB")

To connect to YDB from dbt, you'll need to add a [profile](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles) to your `profiles.yml` file. A YDB profile conforms to the following syntax:

profiles.yml

```
profile-name:
  target: dev
  outputs:
    dev:
      type: ydb
      host: localhost
      port: 2136
      database: /local
      schema: empty_string
      secure: False
      root_certificates_path: empty_string

      # Static credentials
      username: empty_string
      password: empty_string

      # Access token credentials
      token: empty_string

      # Service account credentials
      service_account_credentials_file: empty_string
```

### All configurations[​](#all-configurations "Direct link to All configurations")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Config Required? Default Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | host Yes YDB host|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | port Yes YDB port|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | database Yes YDB database|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | schema No `empty_string` Optional subfolder for dbt models. Use empty string or `/` to use root folder| secure No False If enabled, `grpcs` protocol will be used| root\_certificates\_path No `empty_string` Optional path to root certificates file|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | username No `empty_string` YDB username to use static Ccredentials|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | password No `empty_string` YDB password to use static credentials|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | token No `empty_string` YDB token to use Access Token credentials|  |  |  |  | | --- | --- | --- | --- | | service\_account\_credentials\_file No `empty_string` Path to service account credentials file to use service account credentials | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

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

Yellowbrick setup](https://docs.getdbt.com/docs/core/connect-data-platform/yellowbrick-setup)[Next

MaxCompute setup](https://docs.getdbt.com/docs/core/connect-data-platform/maxcompute-setup)

* [Connecting to YDB](#connecting-to-ydb)
  + [All configurations](#all-configurations)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/ydb-setup.md)
