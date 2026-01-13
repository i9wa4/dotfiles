---
title: "Add snapshots to your DAG | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/snapshots"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your DAG](https://docs.getdbt.com/docs/build/models)* Snapshots

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fsnapshots+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fsnapshots+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fsnapshots+so+I+can+ask+questions+about+it.)

On this page

## Related documentation[​](#related-documentation "Direct link to Related documentation")

* [Snapshot configurations](https://docs.getdbt.com/reference/snapshot-configs)
* [Snapshot properties](https://docs.getdbt.com/reference/snapshot-properties)
* [`snapshot` command](https://docs.getdbt.com/reference/commands/snapshot)

Learn by video!

For video tutorials on Snapshots, go to dbt Learn and check out the [Snapshots course](https://learn.getdbt.com/courses/snapshots).

## What are snapshots?[​](#what-are-snapshots "Direct link to What are snapshots?")

Analysts often need to "look back in time" at previous data states in their mutable tables. While some source data systems are built in a way that makes accessing historical data possible, this is not always the case. dbt provides a mechanism, **snapshots**, which records changes to a mutable table over time.

Snapshots implement [type-2 Slowly Changing Dimensions](https://en.wikipedia.org/wiki/Slowly_changing_dimension#Type_2:_add_new_row) over mutable source tables. These Slowly Changing Dimensions (or SCDs) identify how a row in a table changes over time. Imagine you have an `orders` table where the `status` field can be overwritten as the order is processed.

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| id status updated\_at|  |  |  | | --- | --- | --- | | 1 pending 2024-01-01 | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Now, imagine that the order goes from "pending" to "shipped". That same record will now look like:

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| id status updated\_at|  |  |  | | --- | --- | --- | | 1 shipped 2024-01-02 | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

This order is now in the "shipped" state, but we've lost the information about when the order was last in the "pending" state. This makes it difficult (or impossible) to analyze how long it took for an order to ship. dbt can "snapshot" these changes to help you understand how values in a row change over time. Here's an example of a snapshot table for the previous example:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id status updated\_at dbt\_valid\_from dbt\_valid\_to|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 1 pending 2024-01-01 2024-01-01 2024-01-02|  |  |  |  |  | | --- | --- | --- | --- | --- | | 1 shipped 2024-01-02 2024-01-02 `null` | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Configuring snapshots[​](#configuring-snapshots "Direct link to Configuring snapshots")

### Configuration best practices[​](#configuration-best-practices "Direct link to Configuration best practices")

 Use the timestamp strategy where possible

The timestamp strategy is recommended because it handles column additions and deletions more efficiently than the `check` strategy. This is because it's more robust to schema changes, especially when columns are added or removed over time.

The timestamp strategy relies on a single `updated_at` field, which means it avoids the need to constantly update your snapshot configuration as your source table evolves.

Why timestamp is the preferred strategy:

* Requires tracking only one column (`updated_at`)
* Automatically handles new or removed columns in the source table
* Less prone to errors when the table schema evolves over time (for example, if using the `check` strategy, you might need to update the `check_cols` configuration)

 Use dbt\_valid\_to\_current for easier date range queries

By default, `dbt_valid_to` is `NULL` for current records. However, if you set the [`dbt_valid_to_current` configuration](https://docs.getdbt.com/reference/resource-configs/dbt_valid_to_current) (available in dbt Core v1.9+), `dbt_valid_to` will be set to your specified value (such as `9999-12-31`) for current records.

This allows for straightforward date range filtering.

 Ensure your unique key is really unique

The unique key is used by dbt to match rows up, so it's extremely important to make sure this key is actually unique! If you're snapshotting a source, I'd recommend adding a uniqueness test to your source ([example](https://github.com/dbt-labs/jaffle_shop/blob/8e7c853c858018180bef1756ec93e193d9958c5b/models/staging/schema.yml#L26)).

### How snapshots work[​](#how-snapshots-work "Direct link to How snapshots work")

When you run the [`dbt snapshot` command](https://docs.getdbt.com/reference/commands/snapshot):

* **On the first run:** dbt will create the initial snapshot table — this will be the result set of your `select` statement, with additional columns including `dbt_valid_from` and `dbt_valid_to`. All records will have a `dbt_valid_to = null` or the value specified in [`dbt_valid_to_current`](https://docs.getdbt.com/reference/resource-configs/dbt_valid_to_current) (available in dbt Core 1.9+) if configured.
* **On subsequent runs:** dbt will check which records have changed or if any new records have been created:
  + The `dbt_valid_to` column will be updated for any existing records that have changed.
  + The updated record and any new records will be inserted into the snapshot table. These records will now have `dbt_valid_to = null` or the value configured in `dbt_valid_to_current` (available in dbt Core v1.9+).

Snapshots can be referenced in downstream models the same way as referencing models — by using the [ref](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) function.

## Detecting row changes[​](#detecting-row-changes "Direct link to Detecting row changes")

Snapshot "strategies" define how dbt knows if a row has changed. There are two strategies built-in to dbt:

* [Timestamp](#timestamp-strategy-recommended) — Uses an `updated_at` column to determine if a row has changed.
* [Check](#check-strategy) — Compares a list of columns between their current and historical values to determine if a row has changed.

### Timestamp strategy (recommended)[​](#timestamp-strategy-recommended "Direct link to Timestamp strategy (recommended)")

The `timestamp` strategy uses an `updated_at` field to determine if a row has changed. If the configured `updated_at` column for a row is more recent than the last time the snapshot ran, then dbt will invalidate the old record and record the new one. If the timestamps are unchanged, then dbt will not take any action.

Why timestamp is recommended?

* Requires tracking only one column (`updated_at`)
* Automatically handles new or removed columns in the source table
* Less prone to errors when the table schema evolves over time (for example, if using the `check` strategy, you might need to update the `check_cols` configuration)

The `timestamp` strategy requires the following configurations:

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| Config Description Example|  |  |  | | --- | --- | --- | | updated\_at A column which represents when the source row was last updated. May support ISO date strings and unix epoch integers, depending on the data platform you use. `updated_at` | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

**Example usage:**

### Check strategy[​](#check-strategy "Direct link to Check strategy")

The `check` strategy is useful for tables which do not have a reliable `updated_at` column. This strategy works by comparing a list of columns between their current and historical values. If any of these columns have changed, then dbt will invalidate the old record and record the new one. If the column values are identical, then dbt will not take any action.

The `check` strategy requires the following configurations:

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| Config Description Example|  |  |  | | --- | --- | --- | | check\_cols A list of columns to check for changes, or `all` to check all columns `["name", "email"]` | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

check\_cols = 'all'

The `check` snapshot strategy can be configured to track changes to *all* columns by supplying `check_cols = 'all'`. It is better to explicitly enumerate the columns that you want to check. Consider using a surrogate key to condense many columns into a single column.

#### Example usage[​](#example-usage "Direct link to Example usage")

#### Example usage with `updated_at`[​](#example-usage-with-updated_at "Direct link to example-usage-with-updated_at")

When using the `check` strategy, dbt tracks changes by comparing values in `check_cols`. By default, dbt uses the timestamp to update `dbt_updated_at`, `dbt_valid_from` and `dbt_valid_to` fields. Optionally you can set an `updated_at` column:

* If `updated_at` is configured, the `check` strategy uses this column instead, as with the timestamp strategy.
* If `updated_at` value is null, dbt defaults to using the current timestamp.

Check out the following example, which shows how to use the `check` strategy with `updated_at`:

```
snapshots:
  - name: orders_snapshot
    relation: ref('stg_orders')
    config:
      schema: snapshots
      unique_key: order_id
      strategy: check
      check_cols:
        - status
        - is_cancelled
      updated_at: updated_at
```

In this example:

* If at least one of the specified `check_cols` changes, the snapshot creates a new row. If the `updated_at` column has a value (is not null), the snapshot uses it; otherwise, it defaults to the timestamp.
* If `updated_at` isn’t set, then dbt automatically falls back to [using the current timestamp](#sample-results-for-the-check-strategy) to track changes.
* Use this approach when your `updated_at` column isn't reliable for tracking record updates, but you still want to use it — rather than the snapshot's execution time — whenever row changes are detected.

### Hard deletes (opt-in)[​](#hard-deletes-opt-in "Direct link to Hard deletes (opt-in)")

## Snapshot meta-fields[​](#snapshot-meta-fields "Direct link to Snapshot meta-fields")

Snapshot tables will be created as a clone of your source dataset, plus some additional meta-fields\*.

In dbt Core v1.9+ (or available sooner in [the "Latest" release track in dbt](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks)):

* These column names can be customized to your team or organizational conventions using the [`snapshot_meta_column_names`](https://docs.getdbt.com/reference/resource-configs/snapshot_meta_column_names) config.
* Use the [`dbt_valid_to_current` config](https://docs.getdbt.com/reference/resource-configs/dbt_valid_to_current) to set a custom indicator for the value of `dbt_valid_to` in current snapshot records (like a future date such as `9999-12-31`). By default, this value is `NULL`. When set, dbt will use this specified value instead of `NULL` for `dbt_valid_to` for current records in the snapshot table.
* Use the [`hard_deletes`](https://docs.getdbt.com/reference/resource-configs/hard-deletes) config to track deleted records as new rows with the `dbt_is_deleted` meta field when using the `hard_deletes='new_record'` field.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Meaning  Notes Example|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `dbt_valid_from` The timestamp when this snapshot row was first inserted and became valid. This column can be used to order the different "versions" of a record. `snapshot_meta_column_names: {dbt_valid_from: start_date}`| `dbt_valid_to` The timestamp when this row became invalidated. For current records, this is `NULL` by default or the value specified in `dbt_valid_to_current`. The most recent snapshot record will have `dbt_valid_to` set to `NULL` or the specified value. `snapshot_meta_column_names: {dbt_valid_to: end_date}`| `dbt_scd_id` A unique key generated for each snapshot row. This is used internally by dbt. `snapshot_meta_column_names: {dbt_scd_id: scd_id}`| `dbt_updated_at` The `updated_at` timestamp of the source record when this snapshot row was inserted. This is used internally by dbt. `snapshot_meta_column_names: {dbt_updated_at: modified_date}`| `dbt_is_deleted` A string value indicating if the record has been deleted. (`True` if deleted, `False` if not deleted). Added when `hard_deletes='new_record'` is configured. `snapshot_meta_column_names: {dbt_is_deleted: is_deleted}` | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

All of these column names can be customized using the `snapshot_meta_column_names` config. Refer to this [example](https://docs.getdbt.com/reference/resource-configs/snapshot_meta_column_names#example) for more details.

\*The timestamps used for each column are subtly different depending on the strategy you use:

* For the `timestamp` strategy, the configured `updated_at` column is used to populate the `dbt_valid_from`, `dbt_valid_to` and `dbt_updated_at` columns.

   Sample results for the timestamp strategy

  Snapshot query results at `2024-01-01 11:00`

  |  |  |  |  |  |  |
  | --- | --- | --- | --- | --- | --- |
  | id status updated\_at|  |  |  | | --- | --- | --- | | 1 pending 2024-01-01 10:47 | | | | | |

  |  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  ||  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  | Loading table... | | | | |

  Snapshot results (note that `11:00` is not used anywhere):

  |  |  |  |  |  |  |  |  |  |  |  |  |
  | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
  | id status updated\_at dbt\_valid\_from dbt\_valid\_to dbt\_updated\_at|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | 1 pending 2024-01-01 10:47 2024-01-01 10:47 2024-01-01 10:47 | | | | | | | | | | | |

  |  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  ||  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  | Loading table... | | | | |

  Query results at `2024-01-01 11:30`:

  |  |  |  |  |  |  |
  | --- | --- | --- | --- | --- | --- |
  | id status updated\_at|  |  |  | | --- | --- | --- | | 1 shipped 2024-01-01 11:05 | | | | | |

  |  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  ||  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  | Loading table... | | | | |

  Snapshot results (note that `11:30` is not used anywhere):

  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
  | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
  | id status updated\_at dbt\_valid\_from dbt\_valid\_to dbt\_updated\_at|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 1 pending 2024-01-01 10:47 2024-01-01 10:47 2024-01-01 11:05 2024-01-01 10:47|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | 1 shipped 2024-01-01 11:05 2024-01-01 11:05 2024-01-01 11:05 | | | | | | | | | | | | | | | | | |

  |  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  ||  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  | Loading table... | | | | |

  Snapshot results with `hard_deletes='new_record'`:

  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
  | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
  | id status updated\_at dbt\_valid\_from dbt\_valid\_to dbt\_updated\_at dbt\_is\_deleted|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 1 pending 2024-01-01 10:47 2024-01-01 10:47 2024-01-01 11:05 2024-01-01 10:47 False|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 1 shipped 2024-01-01 11:05 2024-01-01 11:05 2024-01-01 11:20 2024-01-01 11:05 False|  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | | 1 deleted 2024-01-01 11:20 2024-01-01 11:20 2024-01-01 11:20 True | | | | | | | | | | | | | | | | | | | | | | | | | | | |

  |  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  ||  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  | Loading table... | | | | |
* For the `check` strategy, the current timestamp is used to populate each column. If configured, the `check` strategy uses the `updated_at` column instead, as with the timestamp strategy.

   Sample results for the check strategy

  Snapshot query results at `2024-01-01 11:00`

  |  |  |  |  |
  | --- | --- | --- | --- |
  | id status|  |  | | --- | --- | | 1 pending | | | |

  |  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  ||  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  | Loading table... | | | | |

  Snapshot results:

  |  |  |  |  |  |  |  |  |  |  |
  | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
  | id status dbt\_valid\_from dbt\_valid\_to dbt\_updated\_at|  |  |  |  |  | | --- | --- | --- | --- | --- | | 1 pending 2024-01-01 11:00 2024-01-01 11:00 | | | | | | | | | |

  |  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  ||  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  | Loading table... | | | | |

  Query results at `2024-01-01 11:30`:

  |  |  |  |  |
  | --- | --- | --- | --- |
  | id status|  |  | | --- | --- | | 1 shipped | | | |

  |  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  ||  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  | Loading table... | | | | |

  Snapshot results:

  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
  | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
  | id status dbt\_valid\_from dbt\_valid\_to dbt\_updated\_at|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 1 pending 2024-01-01 11:00 2024-01-01 11:30 2024-01-01 11:00|  |  |  |  |  | | --- | --- | --- | --- | --- | | 1 shipped 2024-01-01 11:30 2024-01-01 11:30 | | | | | | | | | | | | | | |

  |  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  ||  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  | Loading table... | | | | |

  Snapshot results with `hard_deletes='new_record'`:

  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
  | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
  | id status dbt\_valid\_from dbt\_valid\_to dbt\_updated\_at dbt\_is\_deleted|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 1 pending 2024-01-01 11:00 2024-01-01 11:30 2024-01-01 11:00 False|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 1 shipped 2024-01-01 11:30 2024-01-01 11:40 2024-01-01 11:30 False|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | 1 deleted 2024-01-01 11:40 2024-01-01 11:40 True | | | | | | | | | | | | | | | | | | | | | | | |

  |  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  ||  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  | Loading table... | | | | |

## FAQs[​](#faqs "Direct link to FAQs")

How do I run one snapshot at a time?

To run one snapshot, use the `--select` flag, followed by the name of the snapshot:

```
$ dbt snapshot --select order_snapshot
```

Check out the [model selection syntax documentation](https://docs.getdbt.com/reference/node-selection/syntax) for more operators and examples.

How often should I run the snapshot command?

Snapshots are a batch-based approach to [change data capture](https://en.wikipedia.org/wiki/Change_data_capture). The `dbt snapshot` command must be run on a schedule to ensure that changes to tables are actually recorded! While individual use-cases may vary, snapshots are intended to be run between hourly and daily. If you find yourself snapshotting more frequently than that, consider if there isn't a more appropriate way to capture changes in your source data tables.

What happens if I add new columns to my snapshot query?

When the columns of your source query changes, dbt will attempt to reconcile this change in the destination snapshot table. dbt does this by:

1. Creating new columns from the source query in the destination table
2. Expanding the size of string types where necessary (eg. `varchar`s on Redshift)

dbt *will not* delete columns in the destination snapshot table if they are removed from the source query. It will also not change the type of a column beyond expanding the size of varchar columns. That is, if a `string` column is changed to a `date` column in the snapshot source query, dbt will not attempt to change the type of the column in the destination table.

Do hooks run with snapshots?

Yes! The following hooks are available for snapshots:

* [pre-hooks](https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook)
* [post-hooks](https://docs.getdbt.com/reference/resource-configs/pre-hook-post-hook)
* [on-run-start](https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end)
* [on-run-end](https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end)

Can I store my snapshots in a directory other than the `snapshot` directory in my project?

By default, dbt expects your snapshot files to be located in the `snapshots` subdirectory of your project.

To change this, update the [snapshot-paths](https://docs.getdbt.com/reference/project-configs/snapshot-paths) configuration in your `dbt_project.yml`
file, like so:

dbt\_project.yml

```
snapshot-paths: ["snapshots"]
```

Note that you cannot co-locate snapshots and models in the same directory.

Debug Snapshot target is not a snapshot table errors

If you see the following error when you try executing the snapshot command:

> Snapshot target is not a snapshot table (missing `dbt_scd_id`, `dbt_valid_from`, `dbt_valid_to`)

Double check that you haven't inadvertently caused your snapshot to behave like table materializations by setting its `materialized` config to be `table`. Prior to dbt version 1.4, it was possible to have a snapshot like this:

```
{% snapshot snappy %}
  {{ config(materialized = 'table', ...) }}
  ...
{% endsnapshot %}
```

dbt is treating snapshots like tables (issuing `create or replace table ...` statements) **silently** instead of actually snapshotting data (SCD2 via `insert` / `merge` statements). When upgrading to dbt versions 1.4 and higher, dbt now raises a Parsing Error (instead of silently treating snapshots like tables) that reads:

```
A snapshot must have a materialized value of 'snapshot'
```

This tells you to change your `materialized` config to `snapshot`. But when you make that change, you might encounter an error message saying that certain fields like `dbt_scd_id` are missing. This error happens because, previously, when dbt treated snapshots as tables, it didn't include the necessary [snapshot meta-fields](https://docs.getdbt.com/docs/build/snapshots#snapshot-meta-fields) in your target table. Since those meta-fields don't exist, dbt correctly identifies that you're trying to create a snapshot in a table that isn't actually a snapshot.

When this happens, you have to start from scratch — re-snapshotting your source data as if it was the first time by dropping your "snapshot" which isn't a real snapshot table. Then dbt snapshot will create a new snapshot and insert the snapshot meta-fields as expected.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

View documentation](https://docs.getdbt.com/docs/build/view-documentation)[Next

Seeds](https://docs.getdbt.com/docs/build/seeds)

* [Related documentation](#related-documentation)* [What are snapshots?](#what-are-snapshots)* [Configuring snapshots](#configuring-snapshots)
      + [Add a snapshot to your project](#add-a-snapshot-to-your-project)+ [Configuration best practices](#configuration-best-practices)+ [How snapshots work](#how-snapshots-work)* [Detecting row changes](#detecting-row-changes)
        + [Timestamp strategy (recommended)](#timestamp-strategy-recommended)+ [Check strategy](#check-strategy)+ [Hard deletes (opt-in)](#hard-deletes-opt-in)* [Snapshot meta-fields](#snapshot-meta-fields)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/snapshots.md)
