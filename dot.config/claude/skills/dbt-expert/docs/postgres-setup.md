---
title: "Postgres setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Postgres setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fpostgres-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fpostgres-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fpostgres-setup+so+I+can+ask+questions+about+it.)

On this page

`profiles.yml` file is for dbt Core and dbt fusion only

If you're using dbt platform, you don't need to create a `profiles.yml` file. This file is only necessary when you use dbt Core or dbt Fusion locally. To learn more about Fusion prerequisites, refer to [Supported features](https://docs.getdbt.com/docs/fusion/supported-features). To connect your data platform to dbt, refer to [About data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections).

* **Maintained by**: dbt Labs* **Authors**: core dbt maintainers* **GitHub repo**: [dbt-labs/dbt-adapters](https://github.com/dbt-labs/dbt-adapters) [![](https://img.shields.io/github/stars/dbt-labs/dbt-adapters?style=for-the-badge)](https://github.com/dbt-labs/dbt-adapters)* **PyPI package**: `dbt-postgres` [![](https://badge.fury.io/py/dbt-postgres.svg)](https://badge.fury.io/py/dbt-postgres)* **Slack channel**: [#db-postgres](https://getdbt.slack.com/archives/C0172G2E273)* **Supported dbt Core version**: v0.4.0 and newer* **dbt support**: Supported* **Minimum data platform version**: n/a

## Installing dbt-postgres

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-postgres`

## Configuring dbt-postgres

For Postgres-specific configuration, please refer to [Postgres configs.](https://docs.getdbt.com/reference/resource-configs/postgres-configs)

## Profile Configuration[​](#profile-configuration "Direct link to Profile Configuration")

Postgres targets should be set up using the following configuration in your `profiles.yml` file.

~/.dbt/profiles.yml

```
company-name:
  target: dev
  outputs:
    dev:
      type: postgres
      host: [hostname]
      user: [username]
      password: [password]
      port: [port]
      dbname: [database name] # or database instead of dbname
      schema: [dbt schema]
      threads: [optional, 1 or more]
      keepalives_idle: 0 # default 0, indicating the system default. See below
      connect_timeout: 10 # default 10 seconds
      retries: 1  # default 1 retry on error/timeout when opening connections
      search_path: [optional, override the default postgres search_path]
      role: [optional, set the role dbt assumes when executing queries]
      sslmode: [optional, set the sslmode used to connect to the database]
      sslcert: [optional, set the sslcert to control the certifcate file location]
      sslkey: [optional, set the sslkey to control the location of the private key]
      sslrootcert: [optional, set the sslrootcert config value to a new file path in order to customize the file location that contain root certificates]
```

### Configurations[​](#configurations "Direct link to Configurations")

#### search\_path[​](#search_path "Direct link to search_path")

The `search_path` config controls the Postgres "search path" that dbt configures when opening new connections to the database. By default, the Postgres search path is `"$user, public"`, meaning that unqualified table names will be searched for in the `public` schema, or a schema with the same name as the logged-in user. **Note:** Setting the `search_path` to a custom value is not necessary or recommended for typical usage of dbt.

#### role[​](#role "Direct link to role")

The `role` config controls the Postgres role that dbt assumes when opening new connections to the database.

#### sslmode[​](#sslmode "Direct link to sslmode")

The `sslmode` config controls how dbt connects to Postgres databases using SSL. See [the Postgres docs](https://www.postgresql.org/docs/9.1/libpq-ssl.html) on `sslmode` for usage information. When unset, dbt will connect to databases using the Postgres default, `prefer`, as the `sslmode`.

#### sslcert[​](#sslcert "Direct link to sslcert")

The `sslcert` config controls the location of the certificate file used to connect to Postgres when using client SSL connections. To use a certificate file that is not in the default location, set that file path using this value. Without this config set, dbt uses the Postgres default locations. See [Client Certificates](https://www.postgresql.org/docs/current/libpq-ssl.html#LIBPQ-SSL-CLIENTCERT) in the Postgres SSL docs for the default paths.

#### sslkey[​](#sslkey "Direct link to sslkey")

The `sslkey` config controls the location of the private key for connecting to Postgres using client SSL connections. If this config is omitted, dbt uses the default key location for Postgres. See [Client Certificates](https://www.postgresql.org/docs/current/libpq-ssl.html#LIBPQ-SSL-CLIENTCERT) in the Postgres SSL docs for the default locations.

#### sslrootcert[​](#sslrootcert "Direct link to sslrootcert")

When connecting to a Postgres server using a client SSL connection, dbt verifies that the server provides an SSL certificate signed by a trusted root certificate. These root certificates are in the `~/.postgresql/root.crt` file by default. To customize the location of this file, set the `sslrootcert` config value to a new file path.

### `keepalives_idle`[​](#keepalives_idle "Direct link to keepalives_idle")

If the database closes its connection while dbt is waiting for data, you may see the error `SSL SYSCALL error: EOF detected`. Lowering the [`keepalives_idle` value](https://www.postgresql.org/docs/9.3/libpq-connect.html) may prevent this, because the server will send a ping to keep the connection active more frequently.

[dbt's default setting](https://github.com/dbt-labs/dbt-core/blob/main/plugins/postgres/dbt/adapters/postgres/connections.py#L28) is 0 (the server's default value), but can be configured lower (perhaps 120 or 60 seconds), at the cost of a chattier network connection.

#### retries[​](#retries "Direct link to retries")

If `dbt-postgres` encounters an operational error or timeout when opening a new connection, it will retry up to the number of times configured by `retries`. The default value is 1 retry. If set to 2+ retries, dbt will wait 1 second before retrying. If set to 0, dbt will not retry at all.

### `psycopg2` vs `psycopg2-binary`[​](#psycopg2-vs-psycopg2-binary "Direct link to psycopg2-vs-psycopg2-binary")

`psycopg2-binary` is installed by default when installing `dbt-postgres`.
Installing `psycopg2-binary` uses a pre-built version of `psycopg2` which may not be optimized for your particular machine.
This is ideal for development and testing workflows where performance is less of a concern and speed and ease of install is more important.
However, production environments will benefit from a version of `psycopg2` which is built from source for your particular operating system, and architecture. In this scenario, speed and ease of install is less important as the on-going usage is the focus.

To use `psycopg2`:

1. Install `dbt-postgres`
2. Uninstall `psycopg2-binary`
3. Install the equivalent version of `psycopg2`

```
pip install dbt-postgres
if [[ $(pip show psycopg2-binary) ]]; then
    PSYCOPG2_VERSION=$(pip show psycopg2-binary | grep Version | cut -d " " -f 2)
    pip uninstall -y psycopg2-binary && pip install psycopg2==$PSYCOPG2_VERSION
fi
```

Installing `psycopg2` often requires OS level dependencies.
These dependencies may vary across operating systems and architectures.

For example, on Ubuntu, you need to install `libpq-dev` and `python-dev`:

```
sudo apt-get update
sudo apt-get install libpq-dev python-dev
```

whereas on Mac, you need to install `postgresql`:

```
brew install postgresql
pip install psycopg2
```

Your OS may have its own dependencies based on your particular scenario.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Microsoft Fabric Lakehouse setup](https://docs.getdbt.com/docs/core/connect-data-platform/fabricspark-setup)[Next

AlloyDB setup](https://docs.getdbt.com/docs/core/connect-data-platform/alloydb-setup)

* [Profile Configuration](#profile-configuration)
  + [Configurations](#configurations)+ [`keepalives_idle`](#keepalives_idle)+ [`psycopg2` vs `psycopg2-binary`](#psycopg2-vs-psycopg2-binary)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/postgres-setup.md)
