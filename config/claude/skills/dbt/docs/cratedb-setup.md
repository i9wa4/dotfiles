---
title: "CrateDB setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/cratedb-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* CrateDB setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fcratedb-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fcratedb-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fcratedb-setup+so+I+can+ask+questions+about+it.)

On this page

* **Maintained by**: Crate.io, Inc.* **Authors**: CrateDB maintainers* **GitHub repo**: [crate/dbt-cratedb2](https://github.com/crate/dbt-cratedb2) [![](https://img.shields.io/github/stars/crate/dbt-cratedb2?style=for-the-badge)](https://github.com/crate/dbt-cratedb2)* **PyPI package**: `dbt-cratedb2` [![](https://badge.fury.io/py/dbt-cratedb2.svg)](https://badge.fury.io/py/dbt-cratedb2)* **Slack channel**: [Community Forum](https://community.cratedb.com/)* **Supported dbt Core version**: v1.0.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: n/a

## Installing dbt-cratedb2

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-cratedb2`

## Configuring dbt-cratedb2

For CrateDB-specific configuration, please refer to [CrateDB configs.](https://docs.getdbt.com/reference/resource-configs/no-configs)

[CrateDB](https://cratedb.com/database) is compatible with PostgreSQL, so its dbt adapter strongly depends on
dbt-postgres, documented at [PostgreSQL profile setup](https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup).

CrateDB targets are configured exactly the same way, see also [PostgreSQL
configuration](https://docs.getdbt.com/reference/resource-configs/postgres-configs), with just a few things to consider which are special to
CrateDB. Relevant details are outlined at [using dbt with CrateDB](https://cratedb.com/docs/guide/integrate/dbt/),
which also includes up-to-date information.

## Profile configuration[​](#profile-configuration "Direct link to Profile configuration")

CrateDB targets should be set up using a configuration like this minimal sample
of settings in your [`profiles.yml`](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml) file.

~/.dbt/profiles.yml

```
cratedb_analytics:
  target: dev
  outputs:
    dev:
      type: cratedb
      host: [clustername].aks1.westeurope.azure.cratedb.net
      port: 5432
      user: [username]
      pass: [password]
      dbname: crate         # Do not change this value. CrateDB's only catalog is `crate`.
      schema: doc           # Define the schema name. CrateDB's default schema is `doc`.
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

ClickHouse setup](https://docs.getdbt.com/docs/core/connect-data-platform/clickhouse-setup)[Next

Databend Cloud setup](https://docs.getdbt.com/docs/core/connect-data-platform/databend-setup)

* [Profile configuration](#profile-configuration)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/cratedb-setup.md)
