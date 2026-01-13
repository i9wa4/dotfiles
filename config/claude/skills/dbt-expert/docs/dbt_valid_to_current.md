---
title: "dbt_valid_to_current | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/dbt_valid_to_current"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For snapshots](https://docs.getdbt.com/reference/snapshot-properties)* dbt\_valid\_to\_current

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fdbt_valid_to_current+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fdbt_valid_to_current+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fdbt_valid_to_current+so+I+can+ask+questions+about+it.)

On this page

💡Did you know...

Available from dbt v1.9 or with the [dbt "Latest" release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks).

snapshots/schema.yml

```
snapshots:
  - name: my_snapshot
    config:
      dbt_valid_to_current: "string"
```

snapshots/<filename>.sql

```
{{
    config(
        unique_key='id',
        strategy='timestamp',
        updated_at='updated_at',
        dbt_valid_to_current='string'
    )
}}
```

dbt\_project.yml

```
snapshots:
  <resource-path>:
    +dbt_valid_to_current: "string"
```

## Description[​](#description "Direct link to Description")

Use the `dbt_valid_to_current` config to set a custom indicator for the value of `dbt_valid_to` in current snapshot records (like a future date). By default, this value is `NULL`. When set, dbt will use this specified value instead of `NULL` for `dbt_valid_to` for current records in the snapshot table.

This approach makes it easier to assign a custom date, work in a join, or perform range-based filtering that requires an end date.

warning

To avoid any unintentional data modification, dbt will *not* automatically adjust the current value in the existing `dbt_valid_to` column. Existing current records will still have `dbt_valid_to` set to `NULL`.

Any new records inserted *after* applying the `dbt_valid_to_current` configuration will have `dbt_valid_to` set to the specified value (like '9999-12-31'), instead of the default `NULL` value.

### Considerations[​](#considerations "Direct link to Considerations")

* **Date expressions** — Provide a hardcoded date expression compatible with your data platform, such as `to_date('9999-12-31')`. Note that syntax may vary by warehouse (for example, `to_date('YYYY-MM-DD'`) or `date(YYYY, MM, DD)`).
* **Jinja limitation** — `dbt_valid_to_current` only accepts static SQL expressions. Jinja expressions (like `{{ var('my_future_date') }}`) are not supported.
* **Deferral and `state:modified`** — Changes to `dbt_valid_to_current` are compatible with deferral and `--select state:modified`. When this configuration changes, it'll appear in `state:modified` selections, raising a warning to manually make the necessary snapshot updates.

## Default[​](#default "Direct link to Default")

By default, `dbt_valid_to` is set to `NULL` for current (most recent) records in your snapshot table. This means that these records are still valid and have no defined end date.

If you prefer to use a specific value instead of `NULL` for `dbt_valid_to` in current and future records, you can use the `dbt_valid_to_current` configuration option. For example, setting a date in the far future, `9999-12-31`.

The value assigned to `dbt_valid_to_current` should be a string representing a valid date or timestamp, depending on your database's requirements. Use expressions that work within the data platform.

## Impact on snapshot records[​](#impact-on-snapshot-records "Direct link to Impact on snapshot records")

When you set `dbt_valid_to_current`, it affects how dbt manages the `dbt_valid_to` column in your snapshot table:

* **For existing records** — To avoid any unintentional data modification, dbt will *not* automatically adjust the current value in the existing `dbt_valid_to` column. Existing current records will still have `dbt_valid_to` set to `NULL`.
* **For new records** — Any new records inserted after applying the `dbt_valid_to_current` configuration will have `dbt_valid_to` set to the specified value (for example, '9999-12-31'), instead of `NULL`.

This means your snapshot table will have current records with `dbt_valid_to` values of both `NULL` (from existing data) and the new specified value (from new data). If you'd rather have consistent `dbt_valid_to` values for current records, you can manually update existing records in your snapshot table (where `dbt_valid_to` is `NULL`) to match your `dbt_valid_to_current` value.

## Example[​](#example "Direct link to Example")

snapshots/schema.yml

```
snapshots:
  - name: my_snapshot
    config:
      strategy: timestamp
      updated_at: updated_at
      dbt_valid_to_current: "to_date('9999-12-31')"
    columns:
      - name: dbt_valid_from
        description: The timestamp when the record became valid.
      - name: dbt_valid_to
        description: >
          The timestamp when the record ceased to be valid. For current records,
          this is either `NULL` or the value specified in `dbt_valid_to_current`
          (like `'9999-12-31'`).
```

The resulting snapshot table contains the configured dbt\_valid\_to column value:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| id dbt\_scd\_id dbt\_updated\_at dbt\_valid\_from dbt\_valid\_to|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 1 60a1f1dbdf899a4dd... 2024-10-02 ... 2024-10-02 ... 9999-12-31 ...|  |  |  |  |  | | --- | --- | --- | --- | --- | | 2 b1885d098f8bcff51... 2024-10-02 ... 2024-10-02 ... 9999-12-31 ... | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

check\_cols](https://docs.getdbt.com/reference/resource-configs/check_cols)[Next

hard\_deletes](https://docs.getdbt.com/reference/resource-configs/hard-deletes)

* [Description](#description)
  + [Considerations](#considerations)* [Default](#default)* [Impact on snapshot records](#impact-on-snapshot-records)* [Example](#example)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/dbt_valid_to_current.md)
