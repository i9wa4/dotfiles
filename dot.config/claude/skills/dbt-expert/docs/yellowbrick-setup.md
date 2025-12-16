---
title: "Yellowbrick setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/yellowbrick-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Yellowbrick setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fyellowbrick-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fyellowbrick-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fyellowbrick-setup+so+I+can+ask+questions+about+it.)

On this page

Community plugin

Some core functionality may be limited.

* **Maintained by**: Community* **Authors**: InfoCapital team* **GitHub repo**: [InfoCapital-AU/dbt-yellowbrick](https://github.com/InfoCapital-AU/dbt-yellowbrick) [![](https://img.shields.io/github/stars/InfoCapital-AU/dbt-yellowbrick?style=for-the-badge)](https://github.com/InfoCapital-AU/dbt-yellowbrick)* **PyPI package**: `dbt-yellowbrick` [![](https://badge.fury.io/py/dbt-yellowbrick.svg)](https://badge.fury.io/py/dbt-yellowbrick)* **Slack channel**: [n/a](https://www.getdbt.com/community)* **Supported dbt Core version**: v1.7.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: Yellowbrick 5.2

## Installing dbt-yellowbrick

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-yellowbrick`

## Configuring dbt-yellowbrick

For Yellowbrick Data-specific configuration, please refer to [Yellowbrick Data configs.](https://docs.getdbt.com/reference/resource-configs/yellowbrick-configs)

## Profile configuration[​](#profile-configuration "Direct link to Profile configuration")

Yellowbrick targets should be set up using the following configuration in your `profiles.yml` file.

~/.dbt/profiles.yml

```
company-name:
  target: dev
  outputs:
    dev:
      type: yellowbrick
      host: [hostname]
      user: [username]
      password: [password]
      port: [port]
      dbname: [database name]
      schema: [dbt schema]
      role: [optional, set the role dbt assumes when executing queries]
      sslmode: [optional, set the sslmode used to connect to the database]
      sslrootcert: [optional, set the sslrootcert config value to a new file path to customize the file location that contains root certificates]
```

### Configuration notes[​](#configuration-notes "Direct link to Configuration notes")

This adapter is based on the dbt-postgres adapter documented here [Postgres profile setup](https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup)

#### role[​](#role "Direct link to role")

The `role` config controls the user role that dbt assumes when opening new connections to the database.

#### sslmode / sslrootcert[​](#sslmode--sslrootcert "Direct link to sslmode / sslrootcert")

The ssl config parameters control how dbt connects to Yellowbrick using SSL. Refer to the [Yellowbrick documentation](https://docs.yellowbrick.com/5.2.27/client_tools/config_ssl_for_clients_intro.html) for
details.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

IBM watsonx.data Spark setup](https://docs.getdbt.com/docs/core/connect-data-platform/watsonx-spark-setup)[Next

YDB setup](https://docs.getdbt.com/docs/core/connect-data-platform/ydb-setup)

* [Profile configuration](#profile-configuration)
  + [Configuration notes](#configuration-notes)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/yellowbrick-setup.md)
