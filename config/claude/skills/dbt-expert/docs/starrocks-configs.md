---
title: "Starrocks configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/starrocks-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Starrocks configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fstarrocks-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fstarrocks-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fstarrocks-configs+so+I+can+ask+questions+about+it.)

On this page

## Model Configuration[​](#model-configuration "Direct link to Model Configuration")

A dbt model can be configured using the following syntax:

* Project file* Property file* Config block

dbt\_project.yml

```
models:
  <resource-path>:
    materialized: table       // table or view or materialized_view
    keys: ['id', 'name', 'some_date']
    table_type: 'PRIMARY'     // PRIMARY or DUPLICATE or UNIQUE
    distributed_by: ['id']
    buckets: 3                // default 10
    partition_by: ['some_date']
    partition_by_init: ["PARTITION p1 VALUES [('1971-01-01 00:00:00'), ('1991-01-01 00:00:00')),PARTITION p1972 VALUES [('1991-01-01 00:00:00'), ('1999-01-01 00:00:00'))"]
    properties: [{"replication_num":"1", "in_memory": "true"}]
    refresh_method: 'async' // only for materialized view default manual
```

models/properties.yml

```
models:
  - name: <model-name>
    config:
      materialized: table       // table or view or materialized_view
      keys: ['id', 'name', 'some_date']
      table_type: 'PRIMARY'     // PRIMARY or DUPLICATE or UNIQUE
      distributed_by: ['id']
      buckets: 3                // default 10
      partition_by: ['some_date']
      partition_by_init: ["PARTITION p1 VALUES [('1971-01-01 00:00:00'), ('1991-01-01 00:00:00')),PARTITION p1972 VALUES [('1991-01-01 00:00:00'), ('1999-01-01 00:00:00'))"]
      properties: [{"replication_num":"1", "in_memory": "true"}]
      refresh_method: 'async' // only for materialized view default manual
```

models/<model\_name>.sql

```
{{ config(
    materialized = 'table',
    keys=['id', 'name', 'some_date'],
    table_type='PRIMARY',
    distributed_by=['id'],
    buckets=3,
    partition_by=['some_date'],
    ....
) }}
```

### Configuration Description[​](#configuration-description "Direct link to Configuration Description")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `materialized` How the model will be materialized into Starrocks. Supports view, table, incremental, ephemeral, and materialized\_view.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `keys` Which columns serve as keys.|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `table_type` Table type, supported are PRIMARY or DUPLICATE or UNIQUE.|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `distributed_by` Specifies the column of data distribution. If not specified, it defaults to random.|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `buckets` The bucket number in one partition. If not specified, it will be automatically inferred.|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | `partition_by` The partition column list.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `partition_by_init` The partition rule or some real partitions item.|  |  |  |  | | --- | --- | --- | --- | | `properties` The table properties configuration of Starrocks. ([Starrocks table properties](https://docs.starrocks.io/en-us/latest/sql-reference/sql-statements/data-definition/CREATE_TABLE#properties))| `refresh_method` How to refresh materialized views. | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Read From Catalog[​](#read-from-catalog "Direct link to Read From Catalog")

First you need to add this catalog to starrocks. The following is an example of hive.

```
CREATE EXTERNAL CATALOG `hive_catalog`
PROPERTIES (
    "hive.metastore.uris"  =  "thrift://127.0.0.1:8087",
    "type"="hive"
);
```

How to add other types of catalogs can be found in the documentation. [Catalog Overview](https://docs.starrocks.io/en-us/latest/data_source/catalog/catalog_overview) Then write the sources.yaml file.

```
sources:
  - name: external_example
    schema: hive_catalog.hive_db
    tables:
      - name: hive_table_name
```

Finally, you might use below marco quote

```
{{ source('external_example', 'hive_table_name') }}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Starburst/Trino configurations](https://docs.getdbt.com/reference/resource-configs/trino-configs)[Next

Salesforce Data Cloud configurations](https://docs.getdbt.com/reference/resource-configs/data-cloud-configs)

* [Model Configuration](#model-configuration)
  + [Configuration Description](#configuration-description)* [Read From Catalog](#read-from-catalog)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/starrocks-configs.md)
