---
title: "iomete setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/iomete-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* iomete setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fiomete-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fiomete-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fiomete-setup+so+I+can+ask+questions+about+it.)

On this page

* **Maintained by**: iomete* **Authors**: Namig Aliyev* **GitHub repo**: [iomete/dbt-iomete](https://github.com/iomete/dbt-iomete) [![](https://img.shields.io/github/stars/iomete/dbt-iomete?style=for-the-badge)](https://github.com/iomete/dbt-iomete)* **PyPI package**: `dbt-iomete` [![](https://badge.fury.io/py/dbt-iomete.svg)](https://badge.fury.io/py/dbt-iomete)* **Slack channel**: [##db-iomete](https://getdbt.slack.com/archives/C03JFG22EP9)* **Supported dbt Core version**: v0.18.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: n/a

## Installing dbt-iomete

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-iomete`

## Configuring dbt-iomete

For iomete-specific configuration, please refer to [iomete configs.](https://docs.getdbt.com/reference/resource-configs/no-configs)

Set up a iomete Target

iomete targets should be set up using the following configuration in your profiles.yml file.

profiles.yml

```
iomete:
  target: dev
  outputs:
    dev:
      type: iomete
      cluster: cluster_name
      host: <region_name>.iomete.com
      port: 443
      schema: database_name
      account_number: iomete_account_number
      user: iomete_user_name
      password: iomete_user_password
```

##### Description of Profile Fields[​](#description-of-profile-fields "Direct link to Description of Profile Fields")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description Required Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | type The specific adapter to use Required `iomete`| cluster The cluster to connect Required `reporting`| host The host name of the connection. It is a combination of  `account_number` with the prefix `dwh-`  and the suffix `.iomete.com`. Required `dwh-12345.iomete.com`| port The port to use. Required `443`| schema Specify the schema (database) to build models into. Required `dbt_finance`| account\_number The iomete account number with single quotes. Required `'1234566789123'`| username The iomete username to use to connect to the server. Required `dbt_user`| password The iomete user password to use to connect to the server. Required `strong_password` | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Supported Functionality[​](#supported-functionality "Direct link to Supported Functionality")

Most dbt Core functionality is supported.

Iceberg specific improvements.

1. Joining the results of `show tables` and `show views`.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Infer setup](https://docs.getdbt.com/docs/core/connect-data-platform/infer-setup)[Next

Layer setup](https://docs.getdbt.com/docs/core/connect-data-platform/layer-setup)

* [Supported Functionality](#supported-functionality)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/iomete-setup.md)
