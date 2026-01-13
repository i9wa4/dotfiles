---
title: "About dbt source command | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/commands/source"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [List of commands](https://docs.getdbt.com/category/list-of-commands)* source

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fsource+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fsource+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fsource+so+I+can+ask+questions+about+it.)

On this page

The `dbt source` command provides subcommands that are useful when working with source data. This command provides one subcommand, `dbt source freshness`.

### dbt source freshness[​](#dbt-source-freshness "Direct link to dbt source freshness")

If your dbt project is [configured with sources](https://docs.getdbt.com/docs/build/sources), then the `dbt source freshness` command will query all of your defined source tables, determining the "freshness" of these tables. If the tables are stale (based on the `freshness` config specified for your sources) then dbt will report a warning or error accordingly. If a source table is in a stale state, then dbt will exit with a nonzero exit code.

You can also use [source freshness commands](https://docs.getdbt.com/reference/commands/source#source-freshness-commands) to help make sure the data you get is new and not old or outdated.

### Configure source freshness[​](#configure-source-freshness "Direct link to Configure source freshness")

The example below, shows how to configure source freshness in dbt. Refer to [Declaring source freshness](https://docs.getdbt.com/docs/build/sources#declaring-source-freshness) for more information.

models/<filename>.yml

```
sources:
  - name: jaffle_shop
    database: raw
    config:
      freshness: # changed to config in v1.9
        warn_after: {count: 12, period: hour}
        error_after: {count: 24, period: hour}

      loaded_at_field: _etl_loaded_at # changed to config in v1.10

    tables:
      - name: customers

      - name: orders
        config:
          freshness:
            warn_after: {count: 6, period: hour}
            error_after: {count: 12, period: hour}
            filter: datediff('day', _etl_loaded_at, current_timestamp) < 2

      - name: product_skus
        config:
          freshness: null
```

This helps to monitor the data pipeline health.

You can also configure source freshness in the **Execution settings** section in your dbt job **Settings** page. For more information, refer to [Enabling source freshness snapshots](https://docs.getdbt.com/docs/deploy/source-freshness#enabling-source-freshness-snapshots).

### Source freshness commands[​](#source-freshness-commands "Direct link to Source freshness commands")

Source freshness commands ensure you're receiving the most up-to-date, relevant, and accurate information.

Some of the typical commands you can use are:

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **Command** **Description**|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | [`dbt source freshness`](https://docs.getdbt.com/reference/commands/source#dbt-source-freshness) Checks the "freshness" for all sources.|  |  |  |  | | --- | --- | --- | --- | | [`dbt source freshness --output target/source_freshness.json`](https://docs.getdbt.com/reference/commands/source#configuring-source-freshness-output) Output of "freshness" information to a different path.|  |  | | --- | --- | | [`dbt source freshness --select "source:source_name"`](https://docs.getdbt.com/reference/commands/source#specifying-sources-to-snapshot) Checks the "freshness" for specific sources. | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Specifying sources to snapshot[​](#specifying-sources-to-snapshot "Direct link to Specifying sources to snapshot")

By default, `dbt source freshness` will calculate freshness information for all of the sources in your project. To snapshot freshness for a subset of these sources, use the `--select` flag.

```
# Snapshot freshness for all Snowplow tables:
$ dbt source freshness --select "source:snowplow"

# Snapshot freshness for a particular source table:
$ dbt source freshness --select "source:snowplow.event"
```

### Configuring source freshness output[​](#configuring-source-freshness-output "Direct link to Configuring source freshness output")

When `dbt source freshness` completes, a JSON file containing information about the freshness of your sources will be saved to `target/sources.json`. An example `sources.json` will look like:

target/sources.json

```
{
    "meta": {
        "generated_at": "2019-02-15T00:53:03.971126Z",
        "elapsed_time": 0.21452808380126953
    },
    "sources": {
        "source.project_name.source_name.table_name": {
            "max_loaded_at": "2019-02-15T00:45:13.572836+00:00Z",
            "snapshotted_at": "2019-02-15T00:53:03.880509+00:00Z",
            "max_loaded_at_time_ago_in_s": 481.307673,
            "state": "pass",
            "criteria": {
                "warn_after": {
                    "count": 12,
                    "period": "hour"
                },
                "error_after": {
                    "count": 1,
                    "period": "day"
                }
            }
        }
    }
}
```

To override the destination for this `sources.json` file, use the `-o` (or `--output`) flag:

```
# Output source freshness info to a different path
$ dbt source freshness --output target/source_freshness.json
```

### Using source freshness[​](#using-source-freshness "Direct link to Using source freshness")

Snapshots of source freshness can be used to understand:

1. If a specific data source is in a delayed state
2. The trend of data source freshness over time

This command can be run manually to determine the state of your source data freshness at any time. It is also recommended that you run this command on a schedule, storing the results of the freshness snapshot at regular intervals. These longitudinal snapshots will make it possible to be alerted when source data freshness SLAs are violated, as well as understand the trend of freshness over time.

dbt makes it easy to snapshot source freshness on a schedule, and provides a dashboard out of the box indicating the state of freshness for all of the sources defined in your project. For more information on snapshotting freshness in dbt, check out the [docs](https://docs.getdbt.com/docs/build/sources#source-data-freshness).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

snapshot](https://docs.getdbt.com/reference/commands/snapshot)[Next

test](https://docs.getdbt.com/reference/commands/test)

* [dbt source freshness](#dbt-source-freshness)* [Configure source freshness](#configure-source-freshness)* [Source freshness commands](#source-freshness-commands)* [Specifying sources to snapshot](#specifying-sources-to-snapshot)* [Configuring source freshness output](#configuring-source-freshness-output)* [Using source freshness](#using-source-freshness)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/commands/source.md)
