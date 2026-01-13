---
title: "Exasol setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/exasol-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Exasol setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fexasol-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fexasol-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fexasol-setup+so+I+can+ask+questions+about+it.)

On this page

Community plugin

Some core functionality may be limited. If you're interested in contributing, check out the source code for each repository listed below.

* **Maintained by**: Community* **Authors**: Torsten Glunde, Ilija Kutle* **GitHub repo**: [tglunde/dbt-exasol](https://github.com/tglunde/dbt-exasol) [![](https://img.shields.io/github/stars/tglunde/dbt-exasol?style=for-the-badge)](https://github.com/tglunde/dbt-exasol)* **PyPI package**: `dbt-exasol` [![](https://badge.fury.io/py/dbt-exasol.svg)](https://badge.fury.io/py/dbt-exasol)* **Slack channel**: [n/a](https://www.getdbt.com/community)* **Supported dbt Core version**: v0.14.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: Exasol 6.x

## Installing dbt-exasol

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-exasol`

## Configuring dbt-exasol

For Exasol-specific configuration, please refer to [Exasol configs.](https://docs.getdbt.com/reference/resource-configs/no-configs)

### Connecting to Exasol with **dbt-exasol**[​](#connecting-to-exasol-with-dbt-exasol "Direct link to connecting-to-exasol-with-dbt-exasol")

#### User / password authentication[​](#user--password-authentication "Direct link to User / password authentication")

Configure your dbt profile for using Exasol:

##### Exasol connection information[​](#exasol-connection-information "Direct link to Exasol connection information")

profiles.yml

```
dbt-exasol:
  target: dev
  outputs:
    dev:
      type: exasol
      threads: 1
      dsn: HOST:PORT
      user: USERNAME
      password: PASSWORD
      dbname: db
      schema: SCHEMA
```

#### Optional parameters[​](#optional-parameters "Direct link to Optional parameters")

* **`connection_timeout`** — defaults to pyexasol default
* **`socket_timeout`** — defaults to pyexasol default
* **`query_timeout`** — defaults to pyexasol default
* **`compression`** — default: False
* **`encryption`** — default: False
* **`protocol_version`** — default: v3
* **`row_separator`** — default: CRLF for windows - LF otherwise
* **`timestamp_format`** — default: `YYYY-MM-DDTHH:MI:SS.FF6`

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

DuckDB setup](https://docs.getdbt.com/docs/core/connect-data-platform/duckdb-setup)[Next

Extrica Setup](https://docs.getdbt.com/docs/core/connect-data-platform/extrica-setup)

* [Connecting to Exasol with **dbt-exasol**](#connecting-to-exasol-with-dbt-exasol)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/exasol-setup.md)
