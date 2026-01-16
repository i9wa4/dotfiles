---
title: "DuckDB setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/duckdb-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* DuckDB setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fduckdb-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fduckdb-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fduckdb-setup+so+I+can+ask+questions+about+it.)

On this page

Community plugin

Some core functionality may be limited. If you're interested in contributing, check out the source code for each repository listed below.

* **Maintained by**: Community* **Authors**: Josh Wills (https://github.com/jwills)* **GitHub repo**: [duckdb/dbt-duckdb](https://github.com/duckdb/dbt-duckdb) [![](https://img.shields.io/github/stars/duckdb/dbt-duckdb?style=for-the-badge)](https://github.com/duckdb/dbt-duckdb)* **PyPI package**: `dbt-duckdb` [![](https://badge.fury.io/py/dbt-duckdb.svg)](https://badge.fury.io/py/dbt-duckdb)* **Slack channel**: [#db-duckdb](https://getdbt.slack.com/archives/C039D1J1LA2)* **Supported dbt Core version**: v1.0.1 and newer* **dbt support**: Not Supported* **Minimum data platform version**: DuckDB 0.3.2

## Installing dbt-duckdb

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-duckdb`

## Configuring dbt-duckdb

For Duck DB-specific configuration, please refer to [Duck DB configs.](https://docs.getdbt.com/reference/resource-configs/no-configs)

## Connecting to DuckDB with dbt-duckdb[​](#connecting-to-duckdb-with-dbt-duckdb "Direct link to Connecting to DuckDB with dbt-duckdb")

[DuckDB](http://duckdb.org) is an embedded database, similar to SQLite, but designed for OLAP-style analytics instead of OLTP. The only configuration parameter that is required in your profile (in addition to `type: duckdb`) is the `path` field, which should refer to a path on your local filesystem where you would like the DuckDB database file (and it's associated write-ahead log) to be written. You can also specify the `schema` parameter if you would like to use a schema besides the default (which is called `main`).

There is also a `database` field defined in the `DuckDBCredentials` class for consistency with the parent `Credentials` class, but it defaults to `main` and setting it to be something else will likely cause strange things to happen that cannot be fully predicted, so please avoid changing it.

As of version 1.2.3, you can load any supported [DuckDB extensions](https://duckdb.org/docs/extensions/overview) by listing them in the `extensions` field in your profile. You can also set any additional [DuckDB configuration options](https://duckdb.org/docs/sql/configuration) via the `settings` field, including options that are supported in any loaded extensions.

For example, to be able to connect to `s3` and read/write `parquet` files using an AWS access key and secret, your profile would look something like this:

profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: 'file_path/database_name.duckdb'
      extensions:
        - httpfs
        - parquet
      settings:
        s3_region: my-aws-region
        s3_access_key_id: "{{ env_var('S3_ACCESS_KEY_ID') }}"
        s3_secret_access_key: "{{ env_var('S3_SECRET_ACCESS_KEY') }}"
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Dremio setup](https://docs.getdbt.com/docs/core/connect-data-platform/dremio-setup)[Next

Exasol setup](https://docs.getdbt.com/docs/core/connect-data-platform/exasol-setup)

* [Connecting to DuckDB with dbt-duckdb](#connecting-to-duckdb-with-dbt-duckdb)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/duckdb-setup.md)
