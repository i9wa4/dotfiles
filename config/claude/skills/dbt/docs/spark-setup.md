---
title: "Apache Spark setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/spark-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Apache Spark setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fspark-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fspark-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fspark-setup+so+I+can+ask+questions+about+it.)

On this page

`profiles.yml` file is for dbt Core and dbt fusion only

If you're using dbt platform, you don't need to create a `profiles.yml` file. This file is only necessary when you use dbt Core or dbt Fusion locally. To learn more about Fusion prerequisites, refer to [Supported features](https://docs.getdbt.com/docs/fusion/supported-features). To connect your data platform to dbt, refer to [About data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections).

If you're using Databricks, use `dbt-databricks`

If you're using Databricks, the `dbt-databricks` adapter is recommended over `dbt-spark`. If you're still using dbt-spark with Databricks consider [migrating from the dbt-spark adapter to the dbt-databricks adapter](https://docs.getdbt.com/guides/migrate-from-spark-to-databricks).

For the Databricks version of this page, refer to [Databricks setup](#databricks-setup).

* **Maintained by**: dbt Labs* **Authors**: core dbt maintainers* **GitHub repo**: [dbt-labs/dbt-adapters](https://github.com/dbt-labs/dbt-adapters) [![](https://img.shields.io/github/stars/dbt-labs/dbt-adapters?style=for-the-badge)](https://github.com/dbt-labs/dbt-adapters)* **PyPI package**: `dbt-spark` [![](https://badge.fury.io/py/dbt-spark.svg)](https://badge.fury.io/py/dbt-spark)* **Slack channel**: [db-databricks-and-spark](https://getdbt.slack.com/archives/CNGCW8HKL)* **Supported dbt Core version**: v0.15.0 and newer* **dbt support**: Supported* **Minimum data platform version**: n/a

## Installing dbt-spark

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-spark`

## Configuring dbt-spark

For Spark-specific configuration, please refer to [Spark configs.](https://docs.getdbt.com/reference/resource-configs/spark-configs)

If connecting to Databricks via ODBC driver, it requires `pyodbc`. Depending on your system, you can install it separately or via pip. See the [`pyodbc` wiki](https://github.com/mkleehammer/pyodbc/wiki/Install) for OS-specific installation details.

If connecting to a Spark cluster via the generic thrift or http methods, it requires `PyHive`.

```
# odbc connections
$ python -m pip install "dbt-spark[ODBC]"

# thrift or http connections
$ python -m pip install "dbt-spark[PyHive]"
```

```
# session connections
$ python -m pip install "dbt-spark[session]"
```

## Configuring dbt-spark

For Spark-specific configuration please refer to [Spark Configuration](https://docs.getdbt.com/reference/resource-configs/spark-configs)

For further info, refer to the GitHub repository: [dbt-labs/dbt-adapters](https://github.com/dbt-labs/dbt-adapters)

## Connection methods[​](#connection-methods "Direct link to Connection methods")

dbt-spark can connect to Spark clusters by four different methods:

* [`odbc`](#odbc) is the preferred method when connecting to Databricks. It supports connecting to a SQL Endpoint or an all-purpose interactive cluster.
* [`thrift`](#thrift) connects directly to the lead node of a cluster, either locally hosted / on premise or in the cloud (for example, Amazon EMR).
* [`http`](#http) is a more generic method for connecting to a managed service that provides an HTTP endpoint. Currently, this includes connections to a Databricks interactive cluster.
* [`session`](#session) connects to a pySpark session, running locally or on a remote machine.

Advanced functionality

The `session` connection method is intended for advanced users and experimental dbt development. This connection method is not supported by dbt.

### ODBC[​](#odbc "Direct link to ODBC")

Use the `odbc` connection method if you are connecting to a Databricks SQL endpoint or interactive cluster via ODBC driver. (Download the latest version of the official driver [here](https://databricks.com/spark/odbc-driver-download).)

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: spark
      method: odbc
      driver: [path/to/driver]
      schema: [database/schema name]
      host: [yourorg.sparkhost.com]
      organization: [org id]    # Azure Databricks only
      token: [abc123]

      # one of:
      endpoint: [endpoint id]
      cluster: [cluster id]

      # optional
      port: [port]              # default 443
      user: [user]
      server_side_parameters:
        "spark.driver.memory": "4g"
```

### Thrift[​](#thrift "Direct link to Thrift")

Use the `thrift` connection method if you are connecting to a Thrift server sitting in front of a Spark cluster, for example, a cluster running locally or on Amazon EMR.

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: spark
      method: thrift
      schema: [database/schema name]
      host: [hostname]

      # optional
      port: [port]              # default 10001
      user: [user]
      auth: [for example, KERBEROS]
      kerberos_service_name: [for example, hive]
      use_ssl: [true|false]   # value of hive.server2.use.SSL, default false
      server_side_parameters:
        "spark.driver.memory": "4g"
```

### HTTP[​](#http "Direct link to HTTP")

Use the `http` method if your Spark provider supports generic connections over HTTP (for example, Databricks interactive cluster).

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: spark
      method: http
      schema: [database/schema name]
      host: [yourorg.sparkhost.com]
      organization: [org id]    # Azure Databricks only
      token: [abc123]
      cluster: [cluster id]

      # optional
      port: [port]              # default: 443
      user: [user]
      connect_timeout: 60       # default 10
      connect_retries: 5        # default 0
      server_side_parameters:
        "spark.driver.memory": "4g"
```

Databricks interactive clusters can take several minutes to start up. You may
include the optional profile configs `connect_timeout` and `connect_retries`,
and dbt will periodically retry the connection.

### Session[​](#session "Direct link to Session")

Use the `session` method if you want to run `dbt` against a pySpark session.

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: spark
      method: session
      schema: [database/schema name]
      host: NA                           # not used, but required by `dbt-core`
      server_side_parameters:
        "spark.driver.memory": "4g"
```

## Optional configurations[​](#optional-configurations "Direct link to Optional configurations")

### Retries[​](#retries "Direct link to Retries")

Intermittent errors can crop up unexpectedly while running queries against Apache Spark. If `retry_all` is enabled, dbt-spark will naively retry any query that fails, based on the configuration supplied by `connect_timeout` and `connect_retries`. It does not attempt to determine if the query failure was transient or likely to succeed on retry. This configuration is recommended in production environments, where queries ought to be succeeding.

For instance, this will instruct dbt to retry all failed queries up to 3 times, with a 5 second delay between each retry:

~/.dbt/profiles.yml

```
retry_all: true
connect_timeout: 5
connect_retries: 3
```

### Server side configuration[​](#server-side-configuration "Direct link to Server side configuration")

Spark can be customized using [Application Properties](https://spark.apache.org/docs/latest/configuration.html). Using these properties the execution can be customized, for example, to allocate more memory to the driver process. Also, the Spark SQL runtime can be set through these properties. For example, this allows the user to [set a Spark catalogs](https://spark.apache.org/docs/latest/configuration.html#spark-sql).

## Caveats[​](#caveats "Direct link to Caveats")

When facing difficulties, run `poetry run dbt debug --log-level=debug`. The logs are saved at `logs/dbt.log`.

### Usage with EMR[​](#usage-with-emr "Direct link to Usage with EMR")

To connect to Apache Spark running on an Amazon EMR cluster, you will need to run `sudo /usr/lib/spark/sbin/start-thriftserver.sh` on the master node of the cluster to start the Thrift server (see [the docs](https://aws.amazon.com/premiumsupport/knowledge-center/jdbc-connection-emr/) for more information). You will also need to connect to port 10001, which will connect to the Spark backend Thrift server; port 10000 will instead connect to a Hive backend, which will not work correctly with dbt.

### Supported functionality[​](#supported-functionality "Direct link to Supported functionality")

Most dbt Core functionality is supported, but some features are only available
on Delta Lake (Databricks).

Delta-only features:

1. Incremental model updates by `unique_key` instead of `partition_by` (see [`merge` strategy](https://docs.getdbt.com/reference/resource-configs/spark-configs#the-merge-strategy))
2. [Snapshots](https://docs.getdbt.com/docs/build/snapshots)
3. [Persisting](https://docs.getdbt.com/reference/resource-configs/persist_docs) column-level descriptions as database comments

### Default namespace with Thrift connection method[​](#default-namespace-with-thrift-connection-method "Direct link to Default namespace with Thrift connection method")

To run metadata queries in dbt, you need to have a namespace named `default` in Spark when connecting with Thrift. You can check available namespaces by using Spark's `pyspark` and running `spark.sql("SHOW NAMESPACES").show()`. If the default namespace doesn't exist, create it by running `spark.sql("CREATE NAMESPACE default").show()`.

If there's a network connection issue, your logs will display an error like `Could not connect to any of [('127.0.0.1', 10000)]` (or something similar).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Connection profiles](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles)[Next

BigQuery setup](https://docs.getdbt.com/docs/core/connect-data-platform/bigquery-setup)

* [Connection methods](#connection-methods)
  + [ODBC](#odbc)+ [Thrift](#thrift)+ [HTTP](#http)+ [Session](#session)* [Optional configurations](#optional-configurations)
    + [Retries](#retries)+ [Server side configuration](#server-side-configuration)* [Caveats](#caveats)
      + [Usage with EMR](#usage-with-emr)+ [Supported functionality](#supported-functionality)+ [Default namespace with Thrift connection method](#default-namespace-with-thrift-connection-method)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/spark-setup.md)
