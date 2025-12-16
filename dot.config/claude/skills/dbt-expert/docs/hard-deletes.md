---
title: "hard_deletes | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/hard-deletes"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For snapshots](https://docs.getdbt.com/reference/snapshot-properties)* hard\_deletes

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fhard-deletes+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fhard-deletes+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fhard-deletes+so+I+can+ask+questions+about+it.)

On this page

💡Did you know...

Available from dbt v1.9 or with the [dbt "Latest" release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks).

snapshots/schema.yml

```
snapshots:
  - name: <snapshot_name>
    config:
      hard_deletes: 'ignore' | 'invalidate' | 'new_record'
```

dbt\_project.yml

```
snapshots:
  <resource-path>:
    +hard_deletes: "ignore" | "invalidate" | "new_record"
```

snapshots/<filename>.sql

```
{{
    config(
        unique_key='id',
        strategy='timestamp',
        updated_at='updated_at',
        hard_deletes='ignore' | 'invalidate' | 'new_record'
    )
}}
```

## Description[​](#description "Direct link to Description")

The `hard_deletes` config gives you more control on how to handle deleted rows from the source. Supported options are `ignore` (default), `invalidate` (replaces the legacy `invalidate_hard_deletes=true`), and `new_record`. Note that `new_record` will create a new metadata column in the snapshot table.

You can use `hard_deletes` with dbt-postgres, dbt-bigquery, dbt-snowflake, and dbt-redshift adapters.

 When to use the hard\_deletes and invalidate\_hard\_deletes config?

**Use `invalidate_hard_deletes` (v1.8 and earlier) if:**

* Gaps in the snapshot history (missing records for deleted rows) are acceptable.
* You want to invalidate deleted rows by setting their `dbt_valid_to` timestamp to the current time (implicit delete).
* You are working with smaller datasets where tracking deletions as a separate state is unnecessary.

**Use `hard_deletes: new_record` (v1.9 and higher) if:**

* You want to maintain continuous snapshot history without gaps.
* You want to explicitly track deletions by adding new rows with a `dbt_is_deleted` column (explicit delete).
* You are working with larger datasets where explicitly tracking deleted records improves data lineage clarity.

warning

If you're updating an existing snapshot to use the `hard_deletes` config, dbt *will not* handle migrations automatically. We recommend either only using these settings for net-new snapshots, or [arranging an update](https://docs.getdbt.com/reference/snapshot-configs#snapshot-configuration-migration) of pre-existing tables before enabling this setting.

## Default[​](#default "Direct link to Default")

By default, if you don’t specify `hard_deletes`, it'll automatically default to `ignore`. Deleted rows will not be tracked and their `dbt_valid_to` column remains `NULL`.

The `hard_deletes` config has three methods:

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Methods Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `ignore` (default) No action for deleted records.|  |  |  |  | | --- | --- | --- | --- | | `invalidate` Behaves the same as the existing `invalidate_hard_deletes=true`, where deleted records are invalidated by setting `dbt_valid_to` to current time. This method replaces the `invalidate_hard_deletes` config to give you more control on how to handle deleted rows from the source.| `new_record` Tracks deleted records as new rows using the `dbt_is_deleted` meta field when records are deleted. | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Considerations[​](#considerations "Direct link to Considerations")

* **Backward compatibility**: The `invalidate_hard_deletes` config is still supported for existing snapshots but can't be used alongside `hard_deletes`.
* **New snapshots**: For new snapshots, we recommend using `hard_deletes` instead of `invalidate_hard_deletes`.
* **Migration**: If you switch an existing snapshot to use `hard_deletes` without migrating your data, you may encounter inconsistent or incorrect results, such as a mix of old and new data formats.

## Example[​](#example "Direct link to Example")

snapshots/schema.yml

```
snapshots:
  - name: my_snapshot
    config:
      hard_deletes: new_record  # options are: 'ignore', 'invalidate', or 'new_record'
      strategy: timestamp
      updated_at: updated_at
    columns:
      - name: dbt_valid_from
        description: Timestamp when the record became valid.
      - name: dbt_valid_to
        description: Timestamp when the record stopped being valid.
      - name: dbt_is_deleted
        description: Indicates whether the record was deleted.
```

The resulting snapshot table contains the `hard_deletes: new_record` configuration. If a record is deleted and later restored, the resulting snapshot table might look like this:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id dbt\_scd\_id Status dbt\_updated\_at dbt\_valid\_from dbt\_valid\_to dbt\_is\_deleted|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 1 60a1f1dbdf899a4dd... pending 2024-10-02 ... 2024-05-19... 2024-05-20 ... False|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 1 b1885d098f8bcff51... pending 2024-10-02 ... 2024-05-20 ... 2024-06-03 ... True|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 1 b1885d098f8bcff53... shipped 2024-10-02 ... 2024-06-03 ... False|  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | | 2 b1885d098f8bcff55... active 2024-10-02 ... 2024-05-19 ... False | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

In this example, the `dbt_is_deleted` column is set to `True` when the record is deleted. When the record is restored, the `dbt_is_deleted` column is set to `False`.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

dbt\_valid\_to\_current](https://docs.getdbt.com/reference/resource-configs/dbt_valid_to_current)[Next

invalidate\_hard\_deletes](https://docs.getdbt.com/reference/resource-configs/invalidate_hard_deletes)

* [Description](#description)* [Default](#default)* [Considerations](#considerations)* [Example](#example)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/hard-deletes.md)
