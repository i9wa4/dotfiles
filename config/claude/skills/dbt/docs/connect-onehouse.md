---
title: "Connect Onehouse | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-onehouse"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Connect your data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections)* Connect Onehouse

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-onehouse+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-onehouse+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-onehouse+so+I+can+ask+questions+about+it.)

On this page

dbt supports connecting to [Onehouse SQL](https://www.onehouse.ai/product/quanton) using the Apache Spark Connector with the Thrift method.

note

Connect to a Onehouse SQL Cluster with the [dbt-spark](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-apache-spark) adapter.\*\*

## Requirements[​](#requirements "Direct link to Requirements")

* For dbt, ensure your Onehouse SQL endpoint is accessible via external DNS/IP, whitelisting dbt IPs.

## What works[​](#what-works "Direct link to What works")

* All dbt Commands, including: `dbt clean`, `dbt compile`, `dbt debug`, `dbt seed`, and `dbt run`.
* dbt materializations: `table` and `incremental`
* Apache Hudi table types of Merge on Read (MoR) and Copy on Write (CoW). It is recommended to use MoR for mutable workloads.

## Limitations[​](#limitations "Direct link to Limitations")

* Views are not supported
* `dbt seed` has row / record limits.
* `dbt seed` only supports Copy on Write tables.

## dbt connection[​](#dbt-connection "Direct link to dbt connection")

Fill in the following fields when creating an **Apache Spark** warehouse connection using the Thrift connection method:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description Examples|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Method The method for connecting to Spark Thrift|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Hostname The hostname of your Onehouse SQL Cluster endpoint `yourProject.sparkHost.com`| Port The port to connect to Spark on 10000|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Cluster Onehouse does not use this field |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Connection Timeout Number of seconds after which to timeout a connection 10|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Connection Retries Number of times to attempt connecting to cluster before failing 0|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Organization Onehouse does not use this field |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | User Optional. Not enabled by default. dbt\_cloud\_user|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Auth Optional, supply if using Kerberos. Not enabled by default. `KERBEROS`| Kerberos Service Name Optional, supply if using Kerberos. Not enabled by default. `hive` | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

[![Onehouse configuration](https://docs.getdbt.com/img/onehouse/onehouse-dbt.png?v=2 "Onehouse configuration")](#)Onehouse configuration

## dbt project[​](#dbt-project "Direct link to dbt project")

We recommend that you set default configurations on the dbt\_project.yml to ensure that the adapter executes with Onehouse compatible sql

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description Required Default Recommended|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | materialized materialization the project/directory will default to Yes without input, `view` `table`| file\_format table format the project will default to Yes N/A hudi|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | location\_root Location of the database in DFS Yes N/A `<your_database_location_dfs>`| hoodie.table.type Merge on Read or Copy on Write No cow mor | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

dbt\_project.yml template

```
      +materialized: table | incremental
      +file_format: hudi
      +location_root: <storage_uri>
      +tblproperties:
         hoodie.table.type: mor | cow
```

A dbt\_project.yml example if using jaffle shop would be

```
models:
  jaffle_shop:
    +file_format: hudi
    +location_root: s3://lakehouse/demolake/dbt_ecomm/
    +tblproperties:
      hoodie.table.type: mor
    staging:
      +materialized: incremental
    marts:
      +materialized: table
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Connect Microsoft Fabric](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-microsoft-fabric)

* [Requirements](#requirements)* [What works](#what-works)* [Limitations](#limitations)* [dbt connection](#dbt-connection)* [dbt project](#dbt-project)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/connect-data-platform/connect-onehouse.md)
