---
title: "DeltaStream configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/deltastream-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* DeltaStream configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fdeltastream-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fdeltastream-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fdeltastream-configs+so+I+can+ask+questions+about+it.)

On this page

## Supported materializations[​](#supported-materializations "Direct link to Supported materializations")

DeltaStream supports several unique materialization types that align with its streaming processing capabilities:

### Standard materializations[​](#standard-materializations "Direct link to Standard materializations")

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Materialization Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `ephemeral` This materialization uses common table expressions in DeltaStream under the hood.|  |  |  |  | | --- | --- | --- | --- | | `table` Traditional batch table materialization|  |  | | --- | --- | | `materialized_view` Continuously updated view that automatically refreshes as underlying data changes | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Streaming materializations[​](#streaming-materializations "Direct link to Streaming materializations")

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| Materialization Description|  |  |  |  | | --- | --- | --- | --- | | `stream` Pure streaming transformation that processes data in real-time|  |  | | --- | --- | | `changelog` Change data capture (CDC) stream that tracks changes in data | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Infrastructure materializations[​](#infrastructure-materializations "Direct link to Infrastructure materializations")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Materialization Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `store` External system connection (Kafka, PostgreSQL, etc.)|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `entity` Entity definition within a store|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `database` Database definition|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `compute_pool` Compute pool definition for resource management|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | `function` User-defined functions (UDFs) in Java|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `function_source` JAR file sources for UDFs|  |  |  |  | | --- | --- | --- | --- | | `descriptor_source` Protocol buffer schema sources|  |  | | --- | --- | | `schema_registry` Schema registry connections (Confluent, and so on.) | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## SQL model configurations[​](#sql-model-configurations "Direct link to SQL model configurations")

### Table materialization[​](#table-materialization "Direct link to Table materialization")

Creates a traditional batch table for aggregated data:

**Project file configuration:**

```
models:
  <resource-path>:
    +materialized: table
```

**Config block configuration:**

```
{{ config(materialized = "table") }}

SELECT
    date,
    SUM(amount) as daily_total
FROM {{ ref('transactions') }}
GROUP BY date
```

### Stream materialization[​](#stream-materialization "Direct link to Stream materialization")

Creates a continuous streaming transformation:

**Project file configuration:**

```
models:
  <resource-path>:
    +materialized: stream
    +parameters:
      topic: 'stream_topic'
      value.format: 'json'
      key.format: 'primitive'
      key.type: 'VARCHAR'
      timestamp: 'event_time'
```

**Config block configuration:**

```
{{ config(
    materialized='stream',
    parameters={
        'topic': 'purchase_events',
        'value.format': 'json',
        'key.format': 'primitive',
        'key.type': 'VARCHAR',
        'timestamp': 'event_time'
    }
) }}

SELECT
    event_time,
    user_id,
    action
FROM {{ ref('source_stream') }}
WHERE action = 'purchase'
```

#### Stream configuration options[​](#stream-configuration-options "Direct link to Stream configuration options")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Description Required?|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `materialized` How the model will be materialized. Must be `stream` to create a streaming model. Required|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `topic` The topic name for the stream output. Required|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `value.format` Format for the stream values (like 'json', 'avro'). Required|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `key.format` Format for the stream keys (like 'primitive', 'json'). Optional|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `key.type` Data type for the stream keys (like 'VARCHAR', 'BIGINT'). Optional|  |  |  | | --- | --- | --- | | `timestamp` Column name to use as the event timestamp. Optional | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Changelog materialization[​](#changelog-materialization "Direct link to Changelog materialization")

Captures changes in the data stream:

**Project file configuration:**

```
models:
  <resource-path>:
    +materialized: changelog
    +parameters:
      topic: 'changelog_topic'
      value.format: 'json'
    +primary_key: [column_name]
```

**Config block configuration:**

```
{{ config(
    materialized='changelog',
    parameters={
        'topic': 'order_updates',
        'value.format': 'json'
    },
    primary_key=['order_id']
) }}

SELECT
    order_id,
    status,
    updated_at
FROM {{ ref('orders_stream') }}
```

#### Changelog configuration options[​](#changelog-configuration-options "Direct link to Changelog configuration options")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Option Description Required?|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `materialized` How the model will be materialized. Must be `changelog` to create a changelog model. Required|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `topic` The topic name for the changelog output. Required|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `value.format` Format for the changelog values (like 'json', 'avro'). Required|  |  |  | | --- | --- | --- | | `primary_key` List of column names that uniquely identify rows for change tracking. Required | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Materialized view[​](#materialized-view "Direct link to Materialized view")

Creates a continuously updated view:

**Config block configuration:**

```
{{ config(materialized='materialized_view') }}

SELECT
    product_id,
    COUNT(*) as purchase_count
FROM {{ ref('purchase_events') }}
GROUP BY product_id
```

## YAML-only resource configurations[​](#yaml-only-resource-configurations "Direct link to YAML-only resource configurations")

DeltaStream supports two types of model definitions for infrastructure components:

1. **Managed Resources (Models)** - Automatically included in the dbt DAG
2. **Unmanaged Resources (Sources)** - Created on-demand using specific macros

### Should you use managed or unmanaged resources?[​](#should-you-use-managed-or-unmanaged-resources "Direct link to Should you use managed or unmanaged resources?")

* Use managed resources if you plan to recreate all the infrastructure in different environments and/or use graph operators to execute only the creation of specific resources and downstream transformations.
* Otherwise, it might be simpler to use unmanaged resources to avoid placeholder files.

### Managed resources (models)[​](#managed-resources-models "Direct link to Managed resources (models)")

Managed resources are automatically included in the dbt DAG and defined as models:

```
version: 2
models:
  - name: my_kafka_store
    config:
      materialized: store
      parameters:
        type: KAFKA
        access_region: "AWS us-east-1"
        uris: "kafka.broker1.url:9092,kafka.broker2.url:9092"
        tls.ca_cert_file: "@/certs/us-east-1/self-signed-kafka-ca.crt"

  - name: ps_store
    config:
      materialized: store
      parameters:
        type: POSTGRESQL
        access_region: "AWS us-east-1"
        uris: "postgresql://mystore.com:5432/demo"
        postgres.username: "user"
        postgres.password: "password"

  - name: user_events_stream
    config:
      materialized: stream
      columns:
        event_time:
          type: TIMESTAMP
          not_null: true
        user_id:
          type: VARCHAR
        action:
          type: VARCHAR
      parameters:
        topic: 'user_events'
        value.format: 'json'
        key.format: 'primitive'
        key.type: 'VARCHAR'
        timestamp: 'event_time'

  - name: order_changes
    config:
      materialized: changelog
      columns:
        order_id:
          type: VARCHAR
          not_null: true
        status:
          type: VARCHAR
        updated_at:
          type: TIMESTAMP
      primary_key:
        - order_id
      parameters:
        topic: 'order_updates'
        value.format: 'json'

  - name: pv_kinesis
    config:
      materialized: entity
      store: kinesis_store
      parameters:
        'kinesis.shards': 3

  - name: my_compute_pool
    config:
      materialized: compute_pool
      parameters:
        'compute_pool.size': 'small'
        'compute_pool.timeout_min': 5

  - name: my_function_source
    config:
      materialized: function_source
      parameters:
        file: '@/path/to/my-functions.jar'
        description: 'Custom utility functions'

  - name: my_descriptor_source
    config:
      materialized: descriptor_source
      parameters:
        file: '@/path/to/schemas.desc'
        description: 'Protocol buffer schemas for data structures'

  - name: my_custom_function
    config:
      materialized: function
      parameters:
        args:
          - name: input_text
            type: VARCHAR
        returns: VARCHAR
        language: JAVA
        source.name: 'my_function_source'
        class.name: 'com.example.TextProcessor'

  - name: my_schema_registry
    config:
      materialized: schema_registry
      parameters:
        type: "CONFLUENT"
        access_region: "AWS us-east-1"
        uris: "https://url.to.schema.registry.listener:8081"
        'confluent.username': 'fake_username'
        'confluent.password': 'fake_password'
        'tls.client.cert_file': '@/path/to/tls/client_cert_file'
        'tls.client.key_file': '@/path/to/tls_key'
```

**Note:** Due to current dbt limitations, managed YAML-only resources require a placeholder .sql file that doesn't contain a SELECT statement. For example, create `my_kafka_store.sql` with:

```
-- Placeholder
```

### Unmanaged resources (sources)[​](#unmanaged-resources-sources "Direct link to Unmanaged resources (sources)")

Unmanaged resources are defined as sources and created on-demand using specific macros:

```
version: 2
sources:
  - name: infrastructure
    tables:
      - name: my_kafka_store
        config:
          materialized: store
          parameters:
            type: KAFKA
            access_region: "AWS us-east-1"
            uris: "kafka.broker1.url:9092,kafka.broker2.url:9092"
            tls.ca_cert_file: "@/certs/us-east-1/self-signed-kafka-ca.crt"

      - name: ps_store
        config:
          materialized: store
          parameters:
            type: POSTGRESQL
            access_region: "AWS us-east-1"
            uris: "postgresql://mystore.com:5432/demo"
            postgres.username: "user"
            postgres.password: "password"

      - name: user_events_stream
        config:
          materialized: stream
          columns:
            event_time:
              type: TIMESTAMP
              not_null: true
            user_id:
              type: VARCHAR
            action:
              type: VARCHAR
          parameters:
            topic: 'user_events'
            value.format: 'json'
            key.format: 'primitive'
            key.type: 'VARCHAR'
            timestamp: 'event_time'

      - name: order_changes
        config:
          materialized: changelog
          columns:
            order_id:
              type: VARCHAR
              not_null: true
            status:
              type: VARCHAR
            updated_at:
              type: TIMESTAMP
          primary_key:
            - order_id
          parameters:
            topic: 'order_updates'
            value.format: 'json'

      - name: pv_kinesis
        config:
          materialized: entity
          store: kinesis_store
          parameters:
            'kinesis.shards': 3

      - name: compute_pool_small
        config:
          materialized: compute_pool
          parameters:
            'compute_pool.size': 'small'
            'compute_pool.timeout_min': 5

      - name: my_function_source
        config:
          materialized: function_source
          parameters:
            file: '@/path/to/my-functions.jar'
            description: 'Custom utility functions'

      - name: my_descriptor_source
        config:
          materialized: descriptor_source
          parameters:
            file: '@/path/to/schemas.desc'
            description: 'Protocol buffer schemas for data structures'

      - name: my_custom_function
        config:
          materialized: function
          parameters:
            args:
              - name: input_text
                type: VARCHAR
            returns: VARCHAR
            language: JAVA
            source.name: 'my_function_source'
            class.name: 'com.example.TextProcessor'

      - name: my_schema_registry
        config:
          materialized: schema_registry
          parameters:
            type: "CONFLUENT"
            access_region: "AWS us-east-1"
            uris: "https://url.to.schema.registry.listener:8081"
            'confluent.username': 'fake_username'
            'confluent.password': 'fake_password'
            'tls.client.cert_file': '@/path/to/tls/client_cert_file'
            'tls.client.key_file': '@/path/to/tls_key'
```

To create unmanaged resources:

```
# Create all sources
dbt run-operation create_sources

# Create a specific source
dbt run-operation create_source_by_name --args '{source_name: infrastructure}'
```

## Store configurations[​](#store-configurations "Direct link to Store configurations")

### Kafka store[​](#kafka-store "Direct link to Kafka store")

```
- name: my_kafka_store
  config:
    materialized: store
    parameters:
      type: KAFKA
      access_region: "AWS us-east-1"
      uris: "kafka.broker1.url:9092,kafka.broker2.url:9092"
      tls.ca_cert_file: "@/certs/us-east-1/self-signed-kafka-ca.crt"
```

### PostgreSQL store[​](#postgresql-store "Direct link to PostgreSQL store")

```
- name: postgres_store
  config:
    materialized: store
    parameters:
      type: POSTGRESQL
      access_region: "AWS us-east-1"
      uris: "postgresql://mystore.com:5432/demo"
      postgres.username: "user"
      postgres.password: "password"
```

## Entity configuration[​](#entity-configuration "Direct link to Entity configuration")

```
- name: kinesis_entity
  config:
    materialized: entity
    store: kinesis_store
    parameters:
      'kinesis.shards': 3
```

## Compute pool configuration[​](#compute-pool-configuration "Direct link to Compute pool configuration")

```
- name: processing_pool
  config:
    materialized: compute_pool
    parameters:
      'compute_pool.size': 'small'
      'compute_pool.timeout_min': 5
```

## Referencing resources[​](#referencing-resources "Direct link to Referencing resources")

### Managed resources[​](#managed-resources "Direct link to Managed resources")

Use the standard `ref()` function:

```
select * from {{ ref('my_kafka_stream') }}
```

### Unmanaged resources[​](#unmanaged-resources "Direct link to Unmanaged resources")

Use the `source()` function:

```
SELECT * FROM {{ source('infrastructure', 'user_events_stream') }}
```

## Seeds[​](#seeds "Direct link to Seeds")

Load CSV data into existing DeltaStream entities using the `seed` materialization. Unlike traditional dbt seeds that create new tables, DeltaStream seeds insert data into pre-existing entities.

### Configuration[​](#configuration "Direct link to Configuration")

Seeds must be configured in YAML with the following properties:

**Required:**

* `entity`: The name of the target entity to insert data into

**Optional:**

* `store`: The name of the store containing the entity (omit if entity is not in a store)
* `with_params`: A dictionary of parameters for the WITH clause
* `quote_columns`: Control which columns get quoted. Default: `false` (no columns quoted). Can be:
  + `true`: Quote all columns
  + `false`: Quote no columns (default)
  + `string`: If set to `'*'`, quote all columns
  + `list`: List of column names to quote

### Example configuration[​](#example-configuration "Direct link to Example configuration")

**With Store (quoting enabled):**

```
# seeds.yml
version: 2

seeds:
  - name: user_data_with_store_quoted
    config:
      entity: 'user_events'
      store: 'kafka_store'
      with_params:
        kafka.topic.retention.ms: '86400000'
        partitioned: true
      quote_columns: true  # Quote all columns
```

### Usage[​](#usage "Direct link to Usage")

1. Place CSV files in your `seeds/` directory
2. Configure seeds in YAML with the required `entity` parameter
3. Optionally specify `store` if the entity is in a store
4. Run `dbt seed` to load the data

Important

The target entity must already exist in DeltaStream before running seeds. Seeds only insert data, they do not create entities.

## Function and source materializations[​](#function-and-source-materializations "Direct link to Function and source materializations")

DeltaStream supports user-defined functions (UDFs) and their dependencies through specialized materializations.

### File attachment support[​](#file-attachment-support "Direct link to File attachment support")

The adapter provides seamless file attachment for function sources and descriptor sources:

* **Standardized Interface**: Common file handling logic for both function sources and descriptor sources
* **Path Resolution**: Supports both absolute paths and relative paths (including `@` syntax for project-relative paths)
* **Automatic Validation**: Files are validated for existence and accessibility before attachment

### Function source[​](#function-source "Direct link to Function source")

Creates a function source from a JAR file containing Java functions:

**Config block configuration:**

```
{{ config(
    materialized='function_source',
    parameters={
        'file': '@/path/to/my-functions.jar',
        'description': 'Custom utility functions'
    }
) }}

SELECT 1 as placeholder
```

### Descriptor source[​](#descriptor-source "Direct link to Descriptor source")

Creates a descriptor source from compiled protocol buffer descriptor files:

**Config block configuration:**

```
{{ config(
    materialized='descriptor_source',
    parameters={
        'file': '@/path/to/schemas.desc',
        'description': 'Protocol buffer schemas for data structures'
    }
) }}

SELECT 1 as placeholder
```

Note

Descriptor sources require compiled `.desc` files, not raw `.proto` files. Compile your protobuf schemas using:

```
protoc --descriptor_set_out=schemas/my_schemas.desc schemas/my_schemas.proto
```

### Function[​](#function "Direct link to Function")

Creates a user-defined function that references a function source:

**Config block configuration:**

```
{{ config(
    materialized='function',
    parameters={
        'args': [
            {'name': 'input_text', 'type': 'VARCHAR'}
        ],
        'returns': 'VARCHAR',
        'language': 'JAVA',
        'source.name': 'my_function_source',
        'class.name': 'com.example.TextProcessor'
    }
) }}

SELECT 1 as placeholder
```

### Schema registry[​](#schema-registry "Direct link to Schema registry")

Creates a schema registry connection:

**Config block configuration:**

```
{{ config(
    materialized='schema_registry',
    parameters={
        'type': 'CONFLUENT',
        'access_region': 'AWS us-east-1',
        'uris': 'https://url.to.schema.registry.listener:8081',
        'confluent.username': 'fake_username',
        'confluent.password': 'fake_password',
        'tls.client.cert_file': '@/path/to/tls/client_cert_file',
        'tls.client.key_file': '@/path/to/tls_key'
    }
) }}

SELECT 1 as placeholder
```

## Query management macros[​](#query-management-macros "Direct link to Query management macros")

DeltaStream dbt adapter provides macros to help you manage and terminate running queries directly from dbt.

### List all queries[​](#list-all-queries "Direct link to List all queries")

The `list_all_queries` macro displays all queries currently known to DeltaStream, including their state, owner, and SQL:

```
dbt run-operation list_all_queries
```

### Describe query[​](#describe-query "Direct link to Describe query")

Use the `describe_query` macro to check the logs and details of a specific query:

```
dbt run-operation describe_query --args '{query_id: "<QUERY_ID>"}'
```

### Terminate a specific query[​](#terminate-a-specific-query "Direct link to Terminate a specific query")

Use the `terminate_query` macro to terminate a query by its ID:

```
dbt run-operation terminate_query --args '{query_id: "<QUERY_ID>"}'
```

### Terminate all running queries[​](#terminate-all-running-queries "Direct link to Terminate all running queries")

Use the `terminate_all_queries` macro to terminate all currently running queries:

```
dbt run-operation terminate_all_queries
```

### Restart a query[​](#restart-a-query "Direct link to Restart a query")

Use the `restart_query` macro to restart a failed query by its ID:

```
dbt run-operation restart_query --args '{query_id: "<QUERY_ID>"}'
```

## Application macro[​](#application-macro "Direct link to Application macro")

### Execute multiple statements as a unit[​](#execute-multiple-statements-as-a-unit "Direct link to Execute multiple statements as a unit")

The `application` macro allows you to execute multiple DeltaStream SQL statements as a single unit of work with all-or-nothing semantics:

```
dbt run-operation application --args '{
  application_name: "my_data_pipeline",
  statements: [
    "USE DATABASE my_db",
    "CREATE STREAM user_events WITH (topic='"'"'events'"'"', value.format='"'"'json'"'"')",
    "CREATE MATERIALIZED VIEW user_counts AS SELECT user_id, COUNT(*) FROM user_events GROUP BY user_id"
  ]
}'
```

## Troubleshooting[​](#troubleshooting "Direct link to Troubleshooting")

### Function source readiness[​](#function-source-readiness "Direct link to Function source readiness")

If you encounter "function source is not ready" errors when creating functions:

1. **Automatic Retry**: The adapter automatically retries function creation with exponential backoff
2. **Timeout Configuration**: The default 30-second timeout can be extended if needed for large JAR files
3. **Dependency Order**: Ensure function sources are created before dependent functions
4. **Manual Retry**: If automatic retry fails, wait a few minutes and retry the operation

### File attachment issues[​](#file-attachment-issues "Direct link to File attachment issues")

For problems with file attachments in function sources and descriptor sources:

1. **File Paths**: Use `@/path/to/file` syntax for project-relative paths
2. **File Types**:

   * Function sources require `.jar` files
   * Descriptor sources require compiled `.desc` files (not `.proto`)
3. **File Validation**: The adapter validates file existence before attempting attachment
4. **Compilation**: For descriptor sources, ensure protobuf files are compiled:

   ```
   protoc --descriptor_set_out=output.desc input.proto
   ```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Databricks configurations](https://docs.getdbt.com/reference/resource-configs/databricks-configs)[Next

Doris/SelectDB configurations](https://docs.getdbt.com/reference/resource-configs/doris-configs)

* [Supported materializations](#supported-materializations)
  + [Standard materializations](#standard-materializations)+ [Streaming materializations](#streaming-materializations)+ [Infrastructure materializations](#infrastructure-materializations)* [SQL model configurations](#sql-model-configurations)
    + [Table materialization](#table-materialization)+ [Stream materialization](#stream-materialization)+ [Changelog materialization](#changelog-materialization)+ [Materialized view](#materialized-view)* [YAML-only resource configurations](#yaml-only-resource-configurations)
      + [Should you use managed or unmanaged resources?](#should-you-use-managed-or-unmanaged-resources)+ [Managed resources (models)](#managed-resources-models)+ [Unmanaged resources (sources)](#unmanaged-resources-sources)* [Store configurations](#store-configurations)
        + [Kafka store](#kafka-store)+ [PostgreSQL store](#postgresql-store)* [Entity configuration](#entity-configuration)* [Compute pool configuration](#compute-pool-configuration)* [Referencing resources](#referencing-resources)
              + [Managed resources](#managed-resources)+ [Unmanaged resources](#unmanaged-resources)* [Seeds](#seeds)
                + [Configuration](#configuration)+ [Example configuration](#example-configuration)+ [Usage](#usage)* [Function and source materializations](#function-and-source-materializations)
                  + [File attachment support](#file-attachment-support)+ [Function source](#function-source)+ [Descriptor source](#descriptor-source)+ [Function](#function)+ [Schema registry](#schema-registry)* [Query management macros](#query-management-macros)
                    + [List all queries](#list-all-queries)+ [Describe query](#describe-query)+ [Terminate a specific query](#terminate-a-specific-query)+ [Terminate all running queries](#terminate-all-running-queries)+ [Restart a query](#restart-a-query)* [Application macro](#application-macro)
                      + [Execute multiple statements as a unit](#execute-multiple-statements-as-a-unit)* [Troubleshooting](#troubleshooting)
                        + [Function source readiness](#function-source-readiness)+ [File attachment issues](#file-attachment-issues)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/deltastream-configs.md)
