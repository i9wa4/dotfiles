---
title: "Microsoft Fabric Lakehouse setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/fabricspark-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* Microsoft Fabric Lakehouse setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ffabricspark-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ffabricspark-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Ffabricspark-setup+so+I+can+ask+questions+about+it.)

On this page

`profiles.yml` file is for dbt Core and dbt fusion only

If you're using dbt platform, you don't need to create a `profiles.yml` file. This file is only necessary when you use dbt Core or dbt Fusion locally. To learn more about Fusion prerequisites, refer to [Supported features](https://docs.getdbt.com/docs/fusion/supported-features). To connect your data platform to dbt, refer to [About data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections).

Below is a guide for use with [Fabric Data Engineering](https://learn.microsoft.com/en-us/fabric/data-engineering/data-engineering-overview), a new product within Microsoft Fabric. This adapter currently supports connecting to a lakehouse endpoint.

To learn how to set up dbt using Fabric Warehouse, refer to [Microsoft Fabric Data Warehouse](https://docs.getdbt.com/docs/core/connect-data-platform/fabric-setup).

* **Maintained by**: Microsoft* **Authors**: Microsoft* **GitHub repo**: [microsoft/dbt-fabricspark](https://github.com/microsoft/dbt-fabricspark) [![](https://img.shields.io/github/stars/microsoft/dbt-fabricspark?style=for-the-badge)](https://github.com/microsoft/dbt-fabricspark)* **PyPI package**: `dbt-fabricspark` [![](https://badge.fury.io/py/dbt-fabricspark.svg)](https://badge.fury.io/py/dbt-fabricspark)* **Slack channel**: [db-fabric-synapse](https://getdbt.slack.com/archives/C01DRQ178LQ)* **Supported dbt Core version**: v1.7 and newer* **dbt support**: Not supported* **Minimum data platform version**: n/a

## Installing dbt-fabricspark

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-fabricspark`

## Configuring dbt-fabricspark

For Microsoft Fabric-specific configuration, please refer to [Microsoft Fabric configs.](https://docs.getdbt.com/reference/resource-configs/fabricspark-configs)

For further info, refer to the GitHub repository: [microsoft/dbt-fabricspark](https://github.com/microsoft/dbt-fabricspark)

## Connection methods[​](#connection-methods "Direct link to Connection methods")

dbt-fabricspark can connect to Fabric Spark runtime using Fabric Livy API method. The Fabric Livy API allows submitting jobs in two different modes:

* [`session-jobs`](#session-jobs) A Livy session job entails establishing a Spark session that remains active throughout the spark session. A spark session, can run multiple jobs (each job is an action), sharing state and cached data between jobs.
* batch jobs entails submitting a Spark application for a single job execution. In contrast to a Livy session job, a batch job doesn't sustain an ongoing Spark session. With Livy batch jobs, each job initiates a new Spark session that ends when the job finishes.

Supported mode

To share the session state among jobs and reduce the overhead of session management, dbt-fabricspark adapter supports only `session-jobs` mode.

### session-jobs[​](#session-jobs "Direct link to session-jobs")

session-jobs is the preferred method when connecting to Fabric Lakehouse.

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: fabricspark
      method: livy
      authentication: CLI
      endpoint: https://api.fabric.microsoft.com/v1
      workspaceid: [Fabric Workspace GUID]
      lakehouseid: [Lakehouse GUID]
      lakehouse: [Lakehouse Name]
      schema: [Lakehouse Name]
      spark_config:
        name: [Application Name]
        # optional
        archives:
          - "example-archive.zip"
        conf:
            spark.executor.memory: "2g"
            spark.executor.cores: "2"
        tags:
          project: [Project Name]
          user: [User Email]
          driverMemory: "2g"
          driverCores: 2
          executorMemory: "4g"
          executorCores: 4
          numExecutors: 3
      # optional
      connect_retries: 0
      connect_timeout: 10
      retry_all: true
```

## Optional configurations[​](#optional-configurations "Direct link to Optional configurations")

### Retries[​](#retries "Direct link to Retries")

Intermittent errors can crop up unexpectedly while running queries against Fabric Spark. If `retry_all` is enabled, dbt-fabricspark will naively retry any queries that fails, based on the configuration supplied by `connect_timeout` and `connect_retries`. It does not attempt to determine if the query failure was transient or likely to succeed on retry. This configuration is recommended in production environments, where queries ought to be succeeding. The default `connect_retries` configuration is 2.

For instance, this will instruct dbt to retry all failed queries up to 3 times, with a 5 second delay between each retry:

~/.dbt/profiles.yml

```
retry_all: true
connect_timeout: 5
connect_retries: 3
```

### Spark configuration[​](#spark-configuration "Direct link to Spark configuration")

Spark can be customized using [Application Properties](https://spark.apache.org/docs/latest/configuration.html). Using these properties the execution can be customized, for example, to allocate more memory to the driver process. Also, the Spark SQL runtime can be set through these properties. For example, this allows the user to [set a Spark catalogs](https://spark.apache.org/docs/latest/configuration.html#spark-sql).

### Supported functionality[​](#supported-functionality "Direct link to Supported functionality")

Most dbt Core functionality is supported, Please refer to [Delta Lake interoporability](https://learn.microsoft.com/en-us/fabric/fundamentals/delta-lake-interoperability).

Delta-only features:

1. Incremental model updates by `unique_key` instead of `partition_by` (see [`merge` strategy](https://docs.getdbt.com/reference/resource-configs/spark-configs#the-merge-strategy))
2. [Snapshots](https://docs.getdbt.com/docs/build/snapshots)
3. [Persisting](https://docs.getdbt.com/reference/resource-configs/persist_docs) column-level descriptions as database comments

### Limitations[​](#limitations "Direct link to Limitations")

1. Lakehouse schemas are not supported. Refer to [limitations](https://learn.microsoft.com/en-us/fabric/data-engineering/lakehouse-schemas#public-preview-limitations)
2. Service Principal Authentication is not supported yet by Livy API.
3. Only Delta, CSV & Parquet table data formats are supported by Fabric Lakehouse.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Microsoft Fabric Data Warehouse setup](https://docs.getdbt.com/docs/core/connect-data-platform/fabric-setup)[Next

Postgres setup](https://docs.getdbt.com/docs/core/connect-data-platform/postgres-setup)

* [Connection methods](#connection-methods)
  + [session-jobs](#session-jobs)* [Optional configurations](#optional-configurations)
    + [Retries](#retries)+ [Spark configuration](#spark-configuration)+ [Supported functionality](#supported-functionality)+ [Limitations](#limitations)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/fabricspark-setup.md)
