---
title: "MetricFlow commands | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/metricflow-commands"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your metrics](https://docs.getdbt.com/docs/build/build-metrics-intro)* [About MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow)* MetricFlow commands

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmetricflow-commands+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmetricflow-commands+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmetricflow-commands+so+I+can+ask+questions+about+it.)

On this page

After you define metrics in your dbt project, you can query metrics, dimensions, and dimension values, and validate your configs using the MetricFlow commands.

MetricFlow allows you to define and query metrics in your dbt project in the [dbt](https://docs.getdbt.com/docs/cloud/about-develop-dbt) or [dbt Core](https://docs.getdbt.com/docs/core/installation-overview). To experience the power of the universal [Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl) and dynamically query those metrics in downstream tools, you'll need a dbt [Starter, Enterprise, or Enterprise+](https://www.getdbt.com/pricing/) account.

MetricFlow is compatible with Python versions 3.8, 3.9, 3.10, 3.11, and 3.12.

## MetricFlow[​](#metricflow "Direct link to MetricFlow")

MetricFlow is a dbt package that allows you to define and query metrics in your dbt project. You can use MetricFlow to query metrics in your dbt project in the dbt CLI, Studio IDE, or dbt Core.

Using MetricFlow with dbt means you won't need to manage versioning — your dbt account will automatically manage the versioning.

dbt jobs support the `dbt sl validate` command to [automatically test your semantic nodes](https://docs.getdbt.com/docs/deploy/ci-jobs#semantic-validations-in-ci). You can also add MetricFlow validations with your git provider (such as GitHub Actions) by installing MetricFlow (`python -m pip install metricflow`). This allows you to run MetricFlow commands as part of your continuous integration checks on PRs.

* MetricFlow with the dbt platform* MetricFlow with dbt Core

In dbt, run MetricFlow commands directly in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) or in the [Cloud CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation).

For Cloud CLI users, MetricFlow commands are embedded in the Cloud CLI , which means you can immediately run them once you install the Cloud CLI and don't need to install MetricFlow separately. You don't need to manage versioning because your dbt account will automatically manage the versioning for you.

You can install [MetricFlow](https://github.com/dbt-labs/metricflow#getting-started) from [PyPI](https://pypi.org/project/dbt-metricflow/). You need to use `pip` to install MetricFlow on Windows or Linux operating systems:

1. Create or activate your virtual environment `python -m venv venv`.
2. Run `pip install dbt-metricflow`.

* You can install MetricFlow using PyPI as an extension of your dbt adapter in the command line. To install the adapter, run `python -m pip install "dbt-metricflow[adapter_package_name]"` and add the adapter name at the end of the command. For example, for a Snowflake adapter, run `python -m pip install "dbt-metricflow[dbt-snowflake]"`.

**Note**, you'll need to manage versioning between dbt Core, your adapter, and MetricFlow.

Something to note, MetricFlow `mf` commands return an error if you have a Metafont latex package installed. To run `mf` commands, uninstall the package.

## MetricFlow commands[​](#metricflow-commands "Direct link to MetricFlow commands")

MetricFlow provides the following commands to retrieve metadata and query metrics.

* Commands for the dbt platform* Commands for dbt Core

You can use the `dbt sl` prefix before the command name to execute them in the Studio IDE or Cloud CLI. For example, to list all metrics, run `dbt sl list metrics`.

Cloud CLI users can run `dbt sl --help` in the terminal for a complete list of the MetricFlow commands and flags.

The following table lists the commands compatible with the Studio IDE and Cloud CLI:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Command  Description  Studio IDE Cloud CLI|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`list metrics`](#list-metrics) Lists metrics with dimensions. ✅ ✅|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`list dimensions`](#list) Lists unique dimensions for metrics. ✅ ✅|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`list dimension-values`](#list-dimension-values) List dimensions with metrics. ✅ ✅|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`list entities`](#list-entities) Lists all unique entities. ✅ ✅|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`list saved-queries`](#list-saved-queries) Lists available saved queries. Use the `--show-exports` flag to display each export listed under a saved query or `--show-parameters` to show the full query parameters each saved query uses. ✅ ✅|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`query`](#query) Query metrics, saved queries, and dimensions you want to see in the command line interface. Refer to [query examples](#query-examples) to query metrics and dimensions (such as querying metrics, using the `where` filter, adding an `order`, and more). ✅ ✅|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [`validate`](#validate) Validates semantic model configurations. ✅ ✅|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | [`export`](#export) Runs exports for a singular saved query for testing and generating exports in your development environment. You can also use the `--select` flag to specify particular exports from a saved query. ❌ ✅|  |  |  |  | | --- | --- | --- | --- | | [`export-all`](#export-all) Runs exports for multiple saved queries at once, saving time and effort. ❌ ✅ | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Run dbt parse to reflect metric changes

When you make changes to metrics, make sure to run `dbt parse` at a minimum to update the Semantic Layer. This updates the `semantic_manifest.json` file, reflecting your changes when querying metrics. By running `dbt parse`, you won't need to rebuild all the models.

 How can I query or preview metrics with the dbt CLI?

Check out the following video for a short video demo of how to query or preview metrics with the Cloud CLI:

Use the `mf` prefix before the command name to execute them in dbt Core. For example, to list all metrics, run `mf list metrics`.

* [`list metrics`](#list-metrics) — Lists metrics with dimensions.
* [`list dimensions`](#list) — Lists unique dimensions for metrics.
* [`list dimension-values`](#list-dimension-values) — List dimensions with metrics.
* [`list entities`](#list-entities) — Lists all unique entities.
* [`validate-configs`](#validate-configs) — Validates semantic model configurations.
* [`health-checks`](#health-checks) — Performs data platform health check.
* [`tutorial`](#tutorial) — Dedicated MetricFlow tutorial to help get you started.
* [`query`](#query) — Query metrics and dimensions you want to see in the command line interface. Refer to [query examples](#query-examples) to help you get started.

## List metrics[​](#list-metrics "Direct link to List metrics")

This command lists the metrics with their available dimensions:

```
dbt sl list metrics <metric_name> # In the dbt platform

mf list metrics <metric_name> # In dbt Core

Options:
  --search TEXT          Filter available metrics by this search term
  --show-all-dimensions  Show all dimensions associated with a metric.
  --help                 Show this message and exit.
```

## List dimensions[​](#list-dimensions "Direct link to List dimensions")

This command lists all unique dimensions for a metric or multiple metrics. It displays only common dimensions when querying multiple metrics:

```
dbt sl list dimensions --metrics <metric_name> # In the dbt platform

mf list dimensions --metrics <metric_name> # In dbt Core

Options:
  --metrics SEQUENCE  List dimensions by given metrics (intersection). Ex. --metrics bookings,messages
  --help              Show this message and exit.
```

## List dimension-values[​](#list-dimension-values "Direct link to List dimension-values")

This command lists all dimension values with the corresponding metric:

```
dbt sl list dimension-values --metrics <metric_name> --dimension <dimension_name> # In the dbt platform

mf list dimension-values --metrics <metric_name> --dimension <dimension_name> # In dbt Core

Options:
  --dimension TEXT    Dimension to query values from  [required]
  --metrics SEQUENCE  Metrics that are associated with the dimension
                      [required]
  --end-time TEXT     Optional iso8601 timestamp to constraint the end time of
                      the data (inclusive)
                      *Not available in the dbt platform yet
  --start-time TEXT   Optional iso8601 timestamp to constraint the start time
                      of the data (inclusive)
                      *Not available in in the dbt platform yet
  --help              Show this message and exit.
```

## List entities[​](#list-entities "Direct link to List entities")

This command lists all unique entities:

```
dbt sl list entities --metrics <metric_name> # In the dbt platform

mf list entities --metrics <metric_name> # In dbt Core

Options:
  --metrics SEQUENCE  List entities by given metrics (intersection). Ex. --metrics bookings,messages
  --help              Show this message and exit.
```

## List saved queries[​](#list-saved-queries "Direct link to List saved queries")

This command lists all available saved queries:

```
dbt sl list saved-queries
```

You can also add the `--show-exports` flag (or option) to show each export listed under a saved query:

```
dbt sl list saved-queries --show-exports
```

**Output**

```
dbt sl list saved-queries --show-exports

The list of available saved queries:
- new_customer_orders
  exports:
       - Export(new_customer_orders_table, exportAs=TABLE)
       - Export(new_customer_orders_view, exportAs=VIEW)
       - Export(new_customer_orders, alias=orders, schemas=customer_schema, exportAs=TABLE)
```

## Validate[​](#validate "Direct link to Validate")

The following command performs validations against the defined semantic model configurations.

```
dbt sl validate # For dbt users
mf validate-configs # For dbt Core users

Options:
  --timeout                       # dbt platform only
                                  Optional timeout for data warehouse validation in the dbt platform.
  --dw-timeout INTEGER            # dbt Core only
                                  Optional timeout for data warehouse
                                  validation steps. Default None.
  --skip-dw                       # dbt Core only
                                  Skips the data warehouse validations.
  --show-all                      # dbt Core only
                                  Prints warnings and future errors.
  --verbose-issues                # dbt Core only
                                  Prints extra details about issues.
  --semantic-validation-workers INTEGER  # dbt Core only
                                  Uses specified number of workers for large configs.
  --help                          Show this message and exit.
```

## Health checks[​](#health-checks "Direct link to Health checks")

The following command performs a health check against the data platform you provided in the configs.

Note, in dbt, the `health-checks` command isn't required since it uses dbt's credentials to perform the health check.

```
mf health-checks # In dbt Core
```

## Tutorial[​](#tutorial "Direct link to Tutorial")

Follow the dedicated MetricFlow tutorial to help you get started:

```
mf tutorial # In dbt Core
```

## Query[​](#query "Direct link to Query")

Create a new query with MetricFlow and execute it against your data platform. The query returns the following result:

```
dbt sl query --metrics <metric_name> --group-by <dimension_name> # In the dbt platform
dbt sl query --saved-query <name> # In the dbt platform

mf query --metrics <metric_name> --group-by <dimension_name> # In dbt Core

Options:

  --metrics SEQUENCE       Syntax to query single metrics: --metrics metric_name
                           For example, --metrics bookings
                           To query multiple metrics, use --metrics followed by the metric names, separated by commas without spaces.
                           For example,  --metrics bookings,messages

  --group-by SEQUENCE      Syntax to group by single dimension/entity: --group-by dimension_name
                           For example, --group-by ds
                           For multiple dimensions/entities, use --group-by followed by the dimension/entity names, separated by commas without spaces.
                           For example, --group-by ds,org


  --end-time TEXT          Optional iso8601 timestamp to constraint the end
                           time of the data (inclusive).
                           *Not available in the dbt platform yet

  --start-time TEXT        Optional iso8601 timestamp to constraint the start
                           time of the data (inclusive)
                           *Not available in the dbt platform yet

  --where TEXT             SQL-like where statement provided as a string and wrapped in quotes.
                           All filter items must explicitly reference fields or dimensions that are part of your model.
                           To query a single statement: ---where "{{ Dimension('order_id__revenue') }} > 100"
                           To query multiple statements: --where "{{ Dimension('order_id__revenue') }} > 100" --where "{{ Dimension('user_count') }} < 1000" # make sure to wrap each statement in quotes
                           To add a dimension filter, use the `Dimension()` template wrapper to indicate that the filter item is part of your model.
                           Refer to the FAQ for more info on how to do this using a template wrapper.

  --limit TEXT             Limit the number of rows out using an int or leave
                           blank for no limit. For example: --limit 100

  --order-by SEQUENCE     Specify metrics, dimension, or group bys to order by.
                          Add the `-` prefix to sort query in descending (DESC) order.
                          Leave blank for ascending (ASC) order.
                          For example, to sort metric_time in DESC order: --order-by -metric_time
                          To sort metric_time in ASC order and revenue in DESC order:  --order-by metric_time,-revenue

  --csv FILENAME           Provide filepath for data frame output to csv

 --compile (the dbt platform)          In the query output, show the query that was
 --explain (dbt Core)     executed against the data warehouse


  --show-dataflow-plan     Display dataflow plan in explain output

  --display-plans          Display plans (such as metric dataflow) in the browser

  --decimals INTEGER       Choose the number of decimal places to round for
                           the numerical values

  --show-sql-descriptions  Shows inline descriptions of nodes in displayed SQL

  --help                   Show this message and exit.
```

## Query examples[​](#query-examples "Direct link to Query examples")

This section shares various types of query examples that you can use to query metrics and dimensions. The query examples listed are:

* [Query metrics](#query-metrics)
* [Query dimensions](#query-dimensions)
* [Add `order`/`limit` function](#add-orderlimit)
* [Add `where` clause](#add-where-clause)
* [Filter by time](#filter-by-time)
* [Query saved queries](#query-saved-queries)

### Query metrics[​](#query-metrics "Direct link to Query metrics")

Use the example to query multiple metrics by dimension and return the `order_total` and `users_active` metrics by `metric_time.`

**Query**

```
dbt sl query --metrics order_total,users_active --group-by metric_time # In the dbt platform

mf query --metrics order_total,users_active --group-by metric_time # In dbt Core
```

**Result**

```
✔ Success 🦄 - query completed after 1.24 seconds
| METRIC_TIME   |   ORDER_TOTAL |
|:--------------|---------------:|
| 2017-06-16    |         792.17 |
| 2017-06-17    |         458.35 |
| 2017-06-18    |         490.69 |
| 2017-06-19    |         749.09 |
| 2017-06-20    |         712.51 |
| 2017-06-21    |         541.65 |
```

### Query dimensions[​](#query-dimensions "Direct link to Query dimensions")

You can include multiple dimensions in a query. For example, you can group by the `is_food_order` dimension to confirm if orders were for food or not. Note that when you query a dimension, you need to specify the primary entity for that dimension. In the following example, the primary entity is `order_id`.

**Query**

```
dbt sl query --metrics order_total --group-by order_id__is_food_order # In the dbt platform

mf query --metrics order_total --group-by order_id__is_food_order # In dbt Core
```

**Result**

```
 Success 🦄 - query completed after 1.70 seconds
| METRIC_TIME   | IS_FOOD_ORDER   |   ORDER_TOTAL |
|:--------------|:----------------|---------------:|
| 2017-06-16    | True            |         499.27 |
| 2017-06-16    | False           |         292.90 |
| 2017-06-17    | True            |         431.24 |
| 2017-06-17    | False           |          27.11 |
| 2017-06-18    | True            |         466.45 |
| 2017-06-18    | False           |          24.24 |
| 2017-06-19    | False           |         300.98 |
| 2017-06-19    | True            |         448.11 |
```

### Add order/limit[​](#add-orderlimit "Direct link to Add order/limit")

You can add order and limit functions to filter and present the data in a readable format. The following query limits the data set to 10 records and orders them by `metric_time`, descending. Note that using the `-` prefix will sort the query in descending order. Without the `-` prefix sorts the query in ascending order.

Note that when you query a dimension, you need to specify the primary entity for that dimension. In the following example, the primary entity is `order_id`.

**Query**

```
# In the dbt platform
dbt sl query --metrics order_total --group-by order_id__is_food_order --limit 10 --order-by -metric_time

# In dbt Core
mf query --metrics order_total --group-by order_id__is_food_order --limit 10 --order-by -metric_time
```

**Result**

```
✔ Success 🦄 - query completed after 1.41 seconds
| METRIC_TIME   | IS_FOOD_ORDER   |   ORDER_TOTAL |
|:--------------|:----------------|---------------:|
| 2017-08-31    | True            |         459.90 |
| 2017-08-31    | False           |         327.08 |
| 2017-08-30    | False           |         348.90 |
| 2017-08-30    | True            |         448.18 |
| 2017-08-29    | True            |         479.94 |
| 2017-08-29    | False           |         333.65 |
| 2017-08-28    | False           |         334.73 |
```

### Add where clause[​](#add-where-clause "Direct link to Add where clause")

You can further filter the data set by adding a `where` clause to your query. The following example shows you how to query the `order_total` metric, grouped by `is_food_order` with multiple `where` statements (orders that are food orders and orders from the week starting on or after Feb 1st, 2024).

**Query**

```
# In the dbt platform
dbt sl query --metrics order_total --group-by order_id__is_food_order --where "{{ Dimension('order_id__is_food_order') }} = True" --where "{{ TimeDimension('metric_time', 'week') }} >= '2024-02-01'"

# In dbt Core
mf query --metrics order_total --group-by order_id__is_food_order --where "{{ Dimension('order_id__is_food_order') }} = True" --where "{{ TimeDimension('metric_time', 'week') }} >= '2024-02-01'"
```

Notes:

* The type of dimension changes the syntax you use. So if you have a date field, use `TimeDimension` instead of `Dimension`.
* When you query a dimension, you need to specify the primary entity for that dimension. In the example just shared, the primary entity is `order_id`.

**Result**

```
 ✔ Success 🦄 - query completed after 1.06 seconds
| METRIC_TIME   | IS_FOOD_ORDER   |   ORDER_TOTAL |
|:--------------|:----------------|---------------:|
| 2017-08-31    | True            |         459.90 |
| 2017-08-30    | True            |         448.18 |
| 2017-08-29    | True            |         479.94 |
| 2017-08-28    | True            |         513.48 |
| 2017-08-27    | True            |         568.92 |
| 2017-08-26    | True            |         471.95 |
| 2017-08-25    | True            |         452.93 |
| 2017-08-24    | True            |         384.40 |
| 2017-08-23    | True            |         423.61 |
| 2017-08-22    | True            |         401.91 |
```

### Filter by time[​](#filter-by-time "Direct link to Filter by time")

To filter by time, there are dedicated start and end time options. Using these options to filter by time allows MetricFlow to further optimize query performance by pushing down the where filter when appropriate.

Note that when you query a dimension, you need to specify the primary entity for that dimension. In the following example, the primary entity is `order_id`.

**Query**

```
# In dbt Core
mf query --metrics order_total --group-by order_id__is_food_order --limit 10 --order-by -metric_time --where "is_food_order = True" --start-time '2017-08-22' --end-time '2017-08-27'
```

**Result**

```
✔ Success 🦄 - query completed after 1.53 seconds
| METRIC_TIME   | IS_FOOD_ORDER   |   ORDER_TOTAL |
|:--------------|:----------------|---------------:|
| 2017-08-27    | True            |         568.92 |
| 2017-08-26    | True            |         471.95 |
| 2017-08-25    | True            |         452.93 |
| 2017-08-24    | True            |         384.40 |
| 2017-08-23    | True            |         423.61 |
| 2017-08-22    | True            |         401.91 |
```

### Query saved queries[​](#query-saved-queries "Direct link to Query saved queries")

You can use this for frequently used queries. Replace `<name>` with the name of your [saved query](https://docs.getdbt.com/docs/build/saved-queries).

**Query**

```
dbt sl query --saved-query <name> # In the dbt platform

mf query --saved-query <name> # In dbt Core
```

For example, if you use dbt and have a saved query named `new_customer_orders`, you would run `dbt sl query --saved-query new_customer_orders`.

A note on querying saved queries

When querying [saved queries](https://docs.getdbt.com/docs/build/saved-queries), you can use parameters such as `where`, `limit`, `order`, `compile`, and so on. However, keep in mind that you can't access `metric` or `group_by` parameters in this context. This is because they are predetermined and fixed parameters for saved queries, and you can't change them at query time. If you would like to query more metrics or dimensions, you can build the query using the standard format.

## Additional query examples[​](#additional-query-examples "Direct link to Additional query examples")

The following tabs present additional query examples, like exporting to a CSV. Select the tab that best suits your needs:

* --compile/--explain flag* Export to CSV

Add `--compile` (or `--explain` for dbt Core users) to your query to view the SQL generated by MetricFlow.

**Query**

```
# In the dbt platform
dbt sl query --metrics order_total --group-by metric_time,is_food_order --limit 10 --order-by -metric_time --where "is_food_order = True" --start-time '2017-08-22' --end-time '2017-08-27' --compile

# In dbt Core
mf query --metrics order_total --group-by metric_time,is_food_order --limit 10 --order-by -metric_time --where "is_food_order = True" --start-time '2017-08-22' --end-time '2017-08-27' --explain
```

**Result**

```
✔ Success 🦄 - query completed after 0.28 seconds
🔎 SQL (remove --compile to see data or add --show-dataflow-plan to see the generated dataflow plan):
select
 metric_time
 , is_food_order
 , sum(order_cost) as order_total
from (
 select
   cast(ordered_at as date) as metric_time
   , is_food_order
   , order_cost
 from analytics.js_dbt_sl_demo.orders orders_src_1
 where cast(ordered_at as date) between cast('2017-08-22' as timestamp) and cast('2017-08-27' as timestamp)
) subq_3
where is_food_order = True
group by
 metric_time
 , is_food_order
order by metric_time desc
limit 10
```

Add the `--csv file_name.csv` flag to export the results of your query to a CSV. The `--csv` flag is available in dbt Core only and not supported in dbt.

**Query**

```
# In dbt Core
mf query --metrics order_total --group-by metric_time,is_food_order --limit 10 --order-by -metric_time --where "is_food_order = True" --start-time '2017-08-22' --end-time '2017-08-27' --csv query_example.csv
```

**Result**

```
✔ Success 🦄 - query completed after 0.83 seconds
🖨 Successfully written query output to query_example.csv
```

## Time granularity[​](#time-granularity "Direct link to Time granularity")

Optionally, you can specify the time granularity you want your data to be aggregated at by appending two underscores and the unit of granularity you want to `metric_time`, the global time dimension. You can group the granularity by: `day`, `week`, `month`, `quarter`, and `year`.

Below is an example for querying metric data at a monthly grain:

```
dbt sl query --metrics revenue --group-by metric_time__month # In the dbt platform

mf query --metrics revenue --group-by metric_time__month # In dbt Core
```

## Export[​](#export "Direct link to Export")

Run [exports for a specific saved query](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports#exports-for-single-saved-query). Use this command to test and generate exports in your development environment. You can also use the `--select` flag to specify particular exports from a saved query. Refer to [exports in development](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports#exports-in-development) for more info.

Export is available in dbt.

```
dbt sl export
```

## Export-all[​](#export-all "Direct link to Export-all")

Run [exports for multiple saved queries](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports#exports-for-multiple-saved-queries) at once. This command provides a convenient way to manage and execute exports for several queries simultaneously, saving time and effort. Refer to [exports in development](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports#exports-in-development) for more info.

Export is available in dbt.

```
dbt sl export-all
```

## FAQs[​](#faqs "Direct link to FAQs")

How can I add a dimension filter to a where filter?

To add a dimension filter to a where filter, you have to indicate that the filter item is part of your model and use a template wrapper: `{{Dimension('primary_entity__dimension_name')}}`.

Here's an example query: `dbt sl query --metrics order_total --group-by metric_time --where "{{Dimension('order_id__is_food_order')}} = True"`.

Before using the template wrapper, however, set up your terminal to escape curly braces for the filter template to work.Details

How to set up your terminal to escape curly braces?
To configure your `.zshrc`profile to escape curly braces, you can use the `setopt` command to enable the `BRACECCL` option. This option will cause the shell to treat curly braces as literals and prevent brace expansion. Refer to the following steps to set it up:

1. Open your terminal.
2. Open your `.zshrc` file using a text editor like `nano`, `vim`, or any other text editor you prefer. You can use the following command to open it with `nano`:

```
nano ~/.zshrc
```

3. Add the following line to the file:

```
setopt BRACECCL
```

4. Save and exit the text editor (in `nano`, press Ctrl + O to save, and Ctrl + X to exit).
5. Source your `.zshrc` file to apply the changes:

```
source ~/.zshrc
```

6. After making these changes, your Zsh shell will treat curly braces as literal characters and will not perform brace expansion. This means that you can use curly braces without worrying about unintended expansions.

Keep in mind that modifying your shell configuration files can have an impact on how your shell behaves. If you're not familiar with shell configuration, it's a good idea to make a backup of your `.zshrc` file before making any changes. If you encounter any issues or unexpected behavior, you can revert to the backup.

Why is my query limited to 100 rows in the dbt CLI?

The default `limit` for query issues from the Cloud CLI is 100 rows. We set this default to prevent returning unnecessarily large data sets as the Cloud CLI is typically used to query the dbt Semantic Layer during the development process, not for production reporting or to access large data sets. For most workflows, you only need to return a subset of the data.

However, you can change this limit if needed by setting the `--limit` option in your query. For example, to return 1000 rows, you can run `dbt sl list metrics --limit 1000`.

How can I query multiple metrics, group bys, or where statements?

To query multiple metrics, group bys, or where statements in your command, follow this guidance:

* To query multiple metrics and group bys, use the `--metrics` or `--group-by` syntax followed by the metric or dimension/entity names, separated by commas without spaces:
  + Multiple metrics example: `dbt sl query --metrics accounts_active,users_active`
  + Multiple dimension/entity example: `dbt sl query --metrics accounts_active,users_active --group-by metric_time__week,accounts__plan_tier`
* To query multiple where statements, use the `--where` syntax and wrap the statement in quotes:
  + Multiple where statement example: `dbt sl query --metrics accounts_active,users_active --group-by metric_time__week,accounts__plan_tier --where "metric_time__week >= '2024-02-01'" --where "accounts__plan_tier = 'coco'"`

How can I sort my query in ascending or descending order?

When you query metrics, use `--order-by` to specify metrics or groupings to order by. The `order_by` option applies to metrics, dimensions, and group bys.

Add the `-` prefix to sort your query in descending (DESC) order. Leave blank for ascending (ASC) order:

* For example, to query a metric and sort `metric_time` in descending order, run `dbt sl query --metrics order_total --group-by metric_time --order-by -metric_time`. Note that the `-` prefix in `-metric_time` sorts the query in descending order.
* To query a metric and sort `metric_time` in ascending order and `revenue` in descending order, run `dbt sl query --metrics order_total --order-by metric_time,-revenue`. Note that `metric_time` without a prefix is sorted in ascending order and `-revenue` with a `-` prefix sorts the query in descending order.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

MetricFlow time spine](https://docs.getdbt.com/docs/build/metricflow-time-spine)[Next

Validations](https://docs.getdbt.com/docs/build/validation)

* [MetricFlow](#metricflow)* [MetricFlow commands](#metricflow-commands)* [List metrics](#list-metrics)* [List dimensions](#list-dimensions)* [List dimension-values](#list-dimension-values)* [List entities](#list-entities)* [List saved queries](#list-saved-queries)* [Validate](#validate)* [Health checks](#health-checks)* [Tutorial](#tutorial)* [Query](#query)* [Query examples](#query-examples)
                        + [Query metrics](#query-metrics)+ [Query dimensions](#query-dimensions)+ [Add order/limit](#add-orderlimit)+ [Add where clause](#add-where-clause)+ [Filter by time](#filter-by-time)+ [Query saved queries](#query-saved-queries)* [Additional query examples](#additional-query-examples)* [Time granularity](#time-granularity)* [Export](#export)* [Export-all](#export-all)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/metricflow-commands.md)
