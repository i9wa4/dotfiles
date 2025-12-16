---
title: "freshness | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/freshness"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For models](https://docs.getdbt.com/reference/model-properties)* freshness

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ffreshness+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ffreshness+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Ffreshness+so+I+can+ask+questions+about+it.)

On this page

💡Did you know...

Available from dbt v1.10 or with the [dbt "Latest" release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks).

* Project file* Model YAML* Config block

dbt\_project.yml

```
models:
  <resource-path>:
    +freshness:
      build_after:  # build this model no more often than every X amount of time, as long as it has new data. Available only on dbt platform Enterprise tiers.
        count: <positive_integer>
        period: minute | hour | day
        updates_on: any | all # optional config
```

models/<filename>.yml

```
models:
  - name: stg_orders
    config:
      freshness:
        build_after:  # build this model no more often than every X amount of time, as long as it has new data. Available only on dbt platform Enterprise tiers.
          count: <positive_integer>
          period: minute | hour | day
          updates_on: any | all # optional config
```

models/<filename>.sql

```
{{
    config(
      freshness={
        "build_after": {     # build this model no more often than every X amount of time, as long as as it has new data
        "count": <positive_integer>,
        "period": "minute" | "hour" | "day",
        "updates_on": "any" | "all" # optional config
        }
      }
    )
}}
```

## Definition[​](#definition "Direct link to Definition")

The model `freshness` config powers state-aware orchestration by rebuilding models *only when new source or upstream data is available*, helping you reduce unnecessary rebuilds and optimize spend. This is useful for models that depend on other models but only need to be updated periodically.

`freshness` works alongside dbt job orchestration by helping you determine when models should be rebuilt in a scheduled job. When a job runs, dbt makes sure models run only when needed, which helps avoid overbuilding models unnecessarily. dbt does this by:

* Checking if there's new data available for the model
* Ensuring enough time has passed since the last build, based on `count` and `period`

For sources and upstream models (for mesh), dbt considers data "new" based on custom freshness calculations (if configured). If a source's freshness goes past its warning/error threshold, dbt raises a warning/error during the build.

The configuration consists of the following parts:

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Configuration Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `build_after` Available on dbt platform Enterprise tiers only. Config nested under `freshness`. Used to determine whether a model should be rebuilt when new data is present, based on whether the specified count and period have passed since the model was last built. Although dbt checks for new data every time the job runs, `build_after` ensures the model is only rebuilt if enough time has passed and new data is available.| `count` and `period` Specify how often dbt should check for new data. For example, `count: 4, period: hour` means dbt will check every 4 hours.   Note that for every `freshness` config, you're required to either set values for both `count` and `period`, or set `freshness: null`.| `updates_on` Optional. Determines when upstream data changes should trigger a job build. Use the following values:  - `any`: The model will build once *any* direct upstream node has new data since the last build. Faster and may increase spend.  - `all`: The model will only build when *all* direct upstream nodes have new data since the last build. Less spend and more requirements. | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Default[​](#default "Direct link to Default")

Default for the `build_after` key is:

```
build_after:
  count: 0
  period: minute
  updates_on: any
```

This means that by default, the model will be built every time a scheduled job runs for any amount of new data.

## Examples[​](#examples "Direct link to Examples")

The following examples show how to configure models to run less frequently, more frequently, or on a custom frequency.

You can configure the `freshness` YAML to skip models during the build process *unless* new data is available *and* a specified time interval has passed.

### Less frequent[​](#less-frequent "Direct link to Less frequent")

You can build a model that runs less frequently (which reduces spend) by configuring the model to only build no more often than every X amount of time, as long as as it has new data.

Add the `freshness` configuration to the model with `count: 4` and `period: hour`:

```
models:
  - name: stg_wizards
    config:
      freshness:
        build_after:
          count: 4
          period: hour
          updates_on: all
  - name: stg_worlds
    config:
      freshness:
        build_after:
          count: 4
          period: hour
          updates_on: all
```

When the state-aware orchestration job triggers, dbt checks for two things:

* Whether new source data is available on all upstream models
* Whether the models `stg_wizards` and `stg_worlds` were built more than 4 hours ago

When *both* conditions are met, dbt builds the model. In this case, the `updates_on: all` config is set. If the `raw.wizards` source has new data, but `stg_wizards` and `stg_worlds` were last built 3 hours ago, then nothing would be built.

If `updates_on: any` had been set in the previous example, then when `raw.wizards` source has new data, dbt would build the model unless it had been built within the last 4 hours.

### More frequent[​](#more-frequent "Direct link to More frequent")

If you want to build a model that runs more frequently (which might increase spend), you can configure the model to build as soon as *any* dependency has new data instead of waiting for all dependencies.

Add the `build_after` freshness configuration to the model with `count: 1` and `period: hour`:

```
models:
  - name: stg_wizards
    config:
      freshness:
        build_after:
          count: 1
          period: hour
          updates_on: any
  - name: stg_worlds
    config:
      freshness:
        build_after:
          count: 1
          period: hour
          updates_on: any
```

When the state-aware orchestration job runs, dbt checks two things:

* If new source data is available on at least one upstream model.
* If `stg_wizards` or `stg_worlds` wasn’t built in the last hour.

If *both* conditions are met, dbt rebuilds the model. This also means if either model (`stg_wizards` *or* `stg_worlds`) has new data, dbt rebuilds the model. If neither model has new data, nothing will be built.

In this example, because `updates_on: any` is set in, even if only the `raw.wizards` source has new data and only `stg_wizards` was built in the last hour (while `stg_worlds` hasn’t been updated), dbt will still build the model because it only needs one source update and one eligible (stale) model.

### Custom frequency[​](#custom-frequency "Direct link to Custom frequency")

You can also use custom logic with `build_after` to set different frequencies for different days, or to skip builds during a specific period (for example, on a weekend).

If you want to build every hour on just weekdays (Monday to Friday), you can use Jinja expressions in your YAML and SQL files by using [Python functions](https://docs.python.org/3/library/datetime.html#datetime.date.weekday) such as `weekday()` where Monday is `0` and Sunday is `6`. For example:

* Project file* Config block

dbt\_project.yml

```
+freshness:
  build_after:
    # wait at least 48 hours before building again, if Saturday or Sunday
    # otherwise, wait at least 1 hour before building again
    count: "{{ 48 if modules.datetime.datetime.today().weekday() in (5, 6) else 1 }}"
    period: hour
    updates_on: any
```

models/<filename>.sql

```
{{
    config(
      freshness={
        "build_after": {
        "count": 48 if modules.datetime.datetime.today().weekday() in (5, 6) else 1,
        "period": "hour",
        "updates_on": "any"
        }
      }
    )
}}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Model configurations](https://docs.getdbt.com/reference/model-configs)[Next

batch\_size](https://docs.getdbt.com/reference/resource-configs/batch-size)

* [Definition](#definition)* [Default](#default)* [Examples](#examples)
      + [Less frequent](#less-frequent)+ [More frequent](#more-frequent)+ [Custom frequency](#custom-frequency)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/freshness.md)
