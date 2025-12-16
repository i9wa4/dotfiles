---
title: "GraphQL | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-cloud-apis/sl-graphql"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Semantic Layer APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-api-overview)* GraphQL

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fsl-graphql+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fsl-graphql+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fsl-graphql+so+I+can+ask+questions+about+it.)

On this page

[GraphQL](https://graphql.org/) (GQL) is an open-source query language for APIs. It offers a more efficient and flexible approach compared to traditional RESTful APIs.

With GraphQL, users can request specific data using a single query, reducing the need for many server round trips. This improves performance and minimizes network overhead.

GraphQL has several advantages, such as self-documenting, having a strong typing system, supporting versioning and evolution, enabling rapid development, and having a robust ecosystem. These features make GraphQL a powerful choice for APIs prioritizing flexibility, performance, and developer productivity.

## dbt Semantic Layer GraphQL API[​](#dbt-semantic-layer-graphql-api "Direct link to dbt Semantic Layer GraphQL API")

The Semantic Layer GraphQL API allows you to explore and query metrics and dimensions. Due to its self-documenting nature, you can explore the calls conveniently through a schema explorer.

The schema explorer URLs vary depending on your [deployment region](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses). Use the following table to find the right link for your region:

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Deployment type Schema explorer URL|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | North America multi-tenant <https://semantic-layer.cloud.getdbt.com/api/graphql>| EMEA multi-tenant <https://semantic-layer.emea.dbt.com/api/graphql>| APAC multi-tenant <https://semantic-layer.au.dbt.com/api/graphql>| Single tenant `https://semantic-layer.YOUR_ACCESS_URL/api/graphql`   Replace `YOUR_ACCESS_URL` with your specific account prefix followed by the appropriate Access URL for your region and plan.| Multi-cell `https://YOUR_ACCOUNT_PREFIX.semantic-layer.REGION.dbt.com/api/graphql`   Replace `YOUR_ACCOUNT_PREFIX` with your specific account identifier and `REGION` with your location, which could be `us1.dbt.com`. | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

**Example**

* If your Single tenant access URL is `ABC123.getdbt.com`, your schema explorer URL will be `https://semantic-layer.ABC123.getdbt.com/api/graphql`.

dbt Partners can use the Semantic Layer GraphQL API to build an integration with the Semantic Layer.

Note that the Semantic Layer GraphQL API doesn't support `ref` to call dbt objects. Instead, use the complete qualified table name. If you're using dbt macros at query time to calculate your metrics, you should move those calculations into your Semantic Layer metric definitions as code.

## Requirements to use the GraphQL API[​](#requirements-to-use-the-graphql-api "Direct link to Requirements to use the GraphQL API")

* A dbt project on dbt v1.6 or higher
* Metrics are defined and configured
* A dbt [service token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens) with "Semantic Layer Only” and "Metadata Only" permissions or a [personal access token](https://docs.getdbt.com/docs/dbt-cloud-apis/user-tokens)

## Using the GraphQL API[​](#using-the-graphql-api "Direct link to Using the GraphQL API")

If you're a dbt user or partner with access to dbt and the [Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl), you can [set up](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl) and test this API with data from your own instance by configuring the Semantic Layer and obtaining the right GQL connection parameters described in this document.

Refer to [Get started with the Semantic Layer](https://docs.getdbt.com/guides/sl-snowflake-qs) for more info.

Authentication uses either a dbt [service account token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens) or a [personal access token](https://docs.getdbt.com/docs/dbt-cloud-apis/user-tokens) passed through a header as follows. To explore the schema, you can enter this information in the "header" section.

```
{"Authorization": "Bearer <AUTHENTICATION TOKEN>"}
```

Each GQL request also requires a dbt `environmentId`. The API uses both the service or personal token in the header and `environmentId` for authentication.

### Metadata calls[​](#metadata-calls "Direct link to Metadata calls")

#### Fetch data platform dialect[​](#fetch-data-platform-dialect "Direct link to Fetch data platform dialect")

In some cases in your application, it may be useful to know the dialect or data platform that's internally used for the Semantic Layer connection (such as if you are building `where` filters from a user interface rather than user-inputted SQL).

The GraphQL API has an easy way to fetch this with the following query:

```
{
  environmentInfo(environmentId: BigInt!) {
    dialect
  }
}
```

#### Fetch available metrics[​](#fetch-available-metrics "Direct link to Fetch available metrics")

```
metricsPaginated(
  environmentId: BigInt!
  search: String = null
  groupBy: [GroupByInput!] = null
  pageNum: Int! = 1
  pageSize: Int = null
): MetricResultPage! {
  items: [Metric!]!
  pageNum: Int!
  pageSize: Int
  totalItems: Int!
  totalPages: Int!
}
```

#### Fetch available dimensions for metrics[​](#fetch-available-dimensions-for-metrics "Direct link to Fetch available dimensions for metrics")

```
dimensionsPaginated(
    environmentId: BigInt!
    metrics: [MetricInput!]!
    search: String = null
    pageNum: Int! = 1
    pageSize: Int = null
): DimensionResultPage! {
    items: [Dimension!]!
    pageNum: Int!
    pageSize: Int
    totalItems: Int!
    totalPages: Int!
}
```

#### Fetch available granularities given metrics[​](#fetch-available-granularities-given-metrics "Direct link to Fetch available granularities given metrics")

Note: This call for `queryableGranularities` returns only queryable granularities for metric time - the primary time dimension across all metrics selected.

```
queryableGranularities(
  environmentId: BigInt!
  metrics: [MetricInput!]!
): [TimeGranularity!]!
```

You can also get queryable granularities for all other dimensions using the `dimensions` call:

```
{
  dimensionsPaginated(environmentId: BigInt!, metrics:[{name:"order_total"}]) {
    items {
      name
      queryableGranularities # --> ["DAY", "WEEK", "MONTH", "QUARTER", "YEAR"]
    }
  }
}
```

You can also optionally access it from the metrics endpoint:

```
{
  metricsPaginated(environmentId: BigInt!) {
    items {
      name
      dimensions {
        name
        queryableGranularities
      }
    }
  }
}
```

#### Fetch measures[​](#fetch-measures "Direct link to Fetch measures")

```
{
  measures(environmentId: BigInt!, metrics: [{name:"order_total"}]) {
    name
    aggTimeDimension
  }
}
```

`aggTimeDimension` tells you the name of the dimension that maps to `metric_time` for a given measure. You can also query `measures` from the `metrics` endpoint, which allows you to see what dimensions map to `metric_time` for a given metric:

```
{
  metricsPaginated(environmentId: BigInt!) {
    items {
      measures {
        name
        aggTimeDimension
      }
    }
  }
}
```

#### Fetch entities[​](#fetch-entities "Direct link to Fetch entities")

```
entitiesPaginated(
    environmentId: BigInt!
    metrics: [MetricInput!] = null
    search: String = null
    pageNum: Int! = 1
    pageSize: Int = null
): EntityResultPage! {
    items: [Entity!]!
    pageNum: Int!
    pageSize: Int
    totalItems: Int!
    totalPages: Int!
}
```

#### Fetch entities and dimensions to group metrics[​](#fetch-entities-and-dimensions-to-group-metrics "Direct link to Fetch entities and dimensions to group metrics")

```
groupBysPaginated(
    environmentId: BigInt!
    metrics: [MetricInput!] = null
    search: String = null
    pageNum: Int! = 1
    pageSize: Int = null
): EntityDimensionResultPage! {
    items: [EntityDimension!]!
    pageNum: Int!
    pageSize: Int
    totalItems: Int!
    totalPages: Int!
}
```

#### Metric types[​](#metric-types "Direct link to Metric types")

```
Metric {
  name: String!
  description: String
  type: MetricType!
  typeParams: MetricTypeParams!
  filter: WhereFilter
  dimensions: [Dimension!]!
  queryableGranularities: [TimeGranularity!]!
}
```

```
MetricType = [SIMPLE, RATIO, CUMULATIVE, DERIVED]
```

#### Metric type parameters[​](#metric-type-parameters "Direct link to Metric type parameters")

```
MetricTypeParams {
  measure: MetricInputMeasure
  inputMeasures: [MetricInputMeasure!]!
  numerator: MetricInput
  denominator: MetricInput
  expr: String
  window: MetricTimeWindow
  grainToDate: TimeGranularity
  metrics: [MetricInput!]
}
```

#### Dimension types[​](#dimension-types "Direct link to Dimension types")

```
Dimension {
  name: String!
  description: String
  type: DimensionType!
  typeParams: DimensionTypeParams
  isPartition: Boolean!
  expr: String
  queryableGranularities: [TimeGranularity!]!
}
```

```
DimensionType = [CATEGORICAL, TIME]
```

#### List saved queries[​](#list-saved-queries "Direct link to List saved queries")

List all saved queries for the specified environment:

```
savedQueriesPaginated(
    environmentId: BigInt!
    search: String = null
    pageNum: Int! = 1
    pageSize: Int = null
): SavedQueryResultPage! {
    items: [SavedQuery!]!
    pageNum: Int!
    pageSize: Int
    totalItems: Int!
    totalPages: Int!
}
```

#### List a saved query[​](#list-a-saved-query "Direct link to List a saved query")

List a single saved query using environment ID and query name:

```
{
savedQuery(environmentId: "123", savedQueryName: "query_name") {
  name
  description
  label
  queryParams {
    metrics {
      name
    }
    groupBy {
      name
      grain
      datePart
    }
    where {
      whereSqlTemplate
    }
  }
}
}
```

### Querying[​](#querying "Direct link to Querying")

When querying for data, *either* a `groupBy` *or* a `metrics` selection is required. The following section provides examples of how to query metrics:

* [Create query](#create-metric-query)
* [Fetch query result](#fetch-query-result)

#### Create query[​](#create-query "Direct link to Create query")

```
createQuery(
  environmentId: BigInt!
  metrics: [MetricInput!]!
  groupBy: [GroupByInput!] = null
  limit: Int = null
  where: [WhereInput!] = null
  order: [OrderByInput!] = null
): CreateQueryResult
```

```
MetricInput {
  name: String!
  alias: String!
}

GroupByInput {
  name: String!
  grain: TimeGranularity = null
}

WhereInput {
  sql: String!
}

OrderByinput { # -- pass one and only one of metric or groupBy
  metric: MetricInput = null
  groupBy: GroupByInput = null
  descending: Boolean! = false
}
```

#### Fetch query result[​](#fetch-query-result "Direct link to Fetch query result")

```
query(
  environmentId: BigInt!
  queryId: String!
): QueryResult!
```

The GraphQL API uses a polling process for querying since queries can be long-running in some cases. It works by first creating a query with a mutation, `createQuery, which returns a query ID. This ID is then used to continuously check (poll) for the results and status of your query. The typical flow would look as follows:

1. Kick off a query

```
mutation {
  createQuery(
    environmentId: 123456
    metrics: [{name: "order_total"}]
    groupBy: [{name: "metric_time"}]
  ) {
    queryId  # => Returns 'QueryID_12345678'
  }
}
```

2. Poll for results

```
{
  query(environmentId: 123456, queryId: "QueryID_12345678") {
    sql
    status
    error
    totalPages
    jsonResult
    arrowResult
  }
}
```

3. Keep querying 2. at an appropriate interval until status is `FAILED` or `SUCCESSFUL`

### Output format and pagination[​](#output-format-and-pagination "Direct link to Output format and pagination")

#### Output format[​](#output-format "Direct link to Output format")

By default, the output is in Arrow format. You can switch to JSON format using the following parameter. However, due to performance limitations, we recommend using the JSON parameter for testing and validation. The JSON received is a base64 encoded string. To access it, you can decode it using a base64 decoder. The JSON is created from pandas, which means you can change it back to a dataframe using `pandas.read_json(json, orient="table")`. Or you can work with the data directly using `json["data"]`, and find the table schema using `json["schema"]["fields"]`. Alternatively, you can pass `encoded:false` to the jsonResult field to get a raw JSON string directly.

```
{
  query(environmentId: BigInt!, queryId: Int!, pageNum: Int! = 1) {
    sql
    status
    error
    totalPages
    arrowResult
    jsonResult(orient: PandasJsonOrient! = TABLE, encoded: Boolean! = true)
  }
}
```

The results default to the table but you can change it to any [pandas](https://pandas.pydata.org/pandas-docs/stable/reference/api/pandas.DataFrame.to_json.html) supported value.

#### Pagination[​](#pagination "Direct link to Pagination")

By default, we return 1024 rows per page. If your result set exceeds this, you need to increase the page number using the `pageNum` option.

### Run a Python query[​](#run-a-python-query "Direct link to Run a Python query")

The `arrowResult` in the GraphQL query response is a byte dump, which isn't visually useful. You can convert this byte data into an Arrow table using any Arrow-supported language. Refer to the following Python example explaining how to query and decode the arrow result:

```
import base64
import pyarrow as pa
import time

headers = {"Authorization":"Bearer <token>"}
query_result_request = """
{
  query(environmentId: 70, queryId: "12345678") {
    sql
    status
    error
    arrowResult
  }
}
"""

while True:
  gql_response = requests.post(
    "https://semantic-layer.cloud.getdbt.com/api/graphql",
    json={"query": query_result_request},
    headers=headers,
  )
  if gql_response.json()["data"]["status"] in ["FAILED", "SUCCESSFUL"]:
    break
  # Set an appropriate interval between polling requests
  time.sleep(1)

"""
gql_response.json() =>
{
  "data": {
    "query": {
      "sql": "SELECT\n  ordered_at AS metric_time__day\n  , SUM(order_total) AS order_total\nFROM semantic_layer.orders orders_src_1\nGROUP BY\n  ordered_at",
      "status": "SUCCESSFUL",
      "error": null,
      "arrowResult": "arrow-byte-data"
    }
  }
}
"""

def to_arrow_table(byte_string: str) -> pa.Table:
  """Get a raw base64 string and convert to an Arrow Table."""
  with pa.ipc.open_stream(base64.b64decode(byte_string)) as reader:
    return pa.Table.from_batches(reader, reader.schema)


arrow_table = to_arrow_table(gql_response.json()["data"]["query"]["arrowResult"])

# Perform whatever functionality is available, like convert to a pandas table.
print(arrow_table.to_pandas())
"""
order_total  ordered_at
          3  2023-08-07
        112  2023-08-08
         12  2023-08-09
       5123  2023-08-10
"""
```

### Additional create query examples[​](#additional-create-query-examples "Direct link to Additional create query examples")

The following section provides query examples for the GraphQL API, such as how to query metrics, dimensions, where filters, and more:

* [Query metric alias](#query-metric-alias) — Query with metric alias, which allows you to use simpler or more intuitive names for metrics instead of their full definitions.
* [Query with a time grain](#query-with-a-time-grain) — Fetch multiple metrics with a change in time dimension granularities.
* [Query multiple metrics and multiple dimensions](#query-multiple-metrics-and-multiple-dimensions) — Select common dimensions for multiple metrics.
* [Query a categorical dimension on its own](#query-a-categorical-dimension-on-its-own) — Group by a categorical dimension.
* [Query with a where filter](#query-with-a-where-filter) — Use the `where` parameter to filter on dimensions and entities using parameters.
* [Query with order](#query-with-order) — Query with `orderBy`, accepts basic string that's a Dimension, Metric, or Entity. Defaults to ascending order.
* [Query with limit](#query-with-limit) — Query using a `limit` clause.
* [Query saved queries](#query-saved-queries) — Query using a saved query using the `savedQuery` parameter for frequently used queries.
* [Query with just compiling SQL](#query-with-just-compiling-sql) — Query using a compile keyword using the `compileSql` mutation.
* [Query records](#query-records) — View all the queries made in your project.

#### Query metric alias[​](#query-metric-alias "Direct link to Query metric alias")

```
mutation {
  createQuery(
    environmentId: "123"
    metrics: [{name: "metric_name", alias: "metric_alias"}]
  ) {
    ...
  }
}
```

#### Query with a time grain[​](#query-with-a-time-grain "Direct link to Query with a time grain")

```
mutation {
  createQuery(
    environmentId: "123"
    metrics: [{name: "order_total"}]
    groupBy: [{name: "metric_time", grain: MONTH}]
  ) {
    queryId
  }
}
```

Note that when using granularity in the query, the output of a time dimension with a time grain applied to it always takes the form of a dimension name appended with a double underscore and the granularity level - `{time_dimension_name}__{DAY|WEEK|MONTH|QUARTER|YEAR}`. Even if no granularity is specified, it will also always have a granularity appended to it and will default to the lowest available (usually daily for most data sources). It is encouraged to specify a granularity when using time dimensions so that there won't be any unexpected results with the output data.

#### Query multiple metrics and multiple dimensions[​](#query-multiple-metrics-and-multiple-dimensions "Direct link to Query multiple metrics and multiple dimensions")

```
mutation {
  createQuery(
    environmentId: "123"
    metrics: [{name: "food_order_amount"}, {name: "order_gross_profit"}]
    groupBy: [{name: "metric_time", grain: MONTH}, {name: "customer__customer_type"}]
  ) {
    queryId
  }
}
```

#### Query a categorical dimension on its own[​](#query-a-categorical-dimension-on-its-own "Direct link to Query a categorical dimension on its own")

```
mutation {
  createQuery(
    environmentId: "123"
    groupBy: [{name: "customer__customer_type"}]
  ) {
    queryId
  }
}
```

#### Query with a where filter[​](#query-with-a-where-filter "Direct link to Query with a where filter")

The `where` filter takes a list argument (or a string for a single input). Depending on the object you are filtering, there are a couple of parameters:

* `Dimension()` — Used for any categorical or time dimensions. For example, `Dimension('metric_time').grain('week')` or `Dimension('customer__country')`.
* `Entity()` — Used for entities like primary and foreign keys, such as `Entity('order_id')`.

Note: If you prefer a `where` clause with a more explicit path, you can optionally use `TimeDimension()` to separate categorical dimensions from time ones. The `TimeDimension` input takes the time dimension and optionally the granularity level. `TimeDimension('metric_time', 'month')`.

```
mutation {
  createQuery(
    environmentId: "123"
    metrics:[{name: "order_total"}]
    groupBy:[{name: "customer__customer_type"}, {name: "metric_time", grain: month}]
    where:[{sql: "{{ Dimension('customer__customer_type') }} = 'new'"}, {sql:"{{ Dimension('metric_time').grain('month') }} > '2022-10-01'"}]
    ) {
     queryId
    }
}
```

For both `TimeDimension()`, the grain is only required in the `where` filter if the aggregation time dimensions for the measures and metrics associated with the where filter have different grains.

#### Example[​](#example "Direct link to Example")

For example, consider this semantic model and metric configuration, which contains two metrics that are aggregated across different time grains. This example shows a single semantic model, but the same goes for metrics across more than one semantic model.

```
semantic_model:
  name: my_model_source

defaults:
  agg_time_dimension: created_month
  measures:
    - name: measure_0
      agg: sum
    - name: measure_1
      agg: sum
      agg_time_dimension: order_year
  dimensions:
    - name: created_month
      type: time
      type_params:
        time_granularity: month
    - name: order_year
      type: time
      type_params:
        time_granularity: year

metrics:
  - name: metric_0
    description: A metric with a month grain.
    type: simple
    type_params:
      measure: measure_0
  - name: metric_1
    description: A metric with a year grain.
    type: simple
    type_params:
      measure: measure_1
```

Assuming the user is querying `metric_0` and `metric_1` together, the following are valid or invalid filters:

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Example  Filter |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | ✅   Valid filter `"{{ TimeDimension('metric_time', 'year') }} > '2020-01-01'"`| ❌   Invalid filter `"{{ TimeDimension('metric_time') }} > '2020-01-01'"`    Metrics in the query are defined based on measures with different grains.| ❌   Invalid filter `"{{ TimeDimension('metric_time', 'month') }} > '2020-01-01'"`    `metric_1` is not available at a month grain. | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

#### Multi-hop joins[​](#multi-hop-joins "Direct link to Multi-hop joins")

In cases where you need to query across multiple related tables (multi-hop joins), use the `entity_path` argument to specify the path between related entities. The following are examples of how you can define these joins:

* In this example, you're querying the `location_name` dimension but specifying that it should be joined using the `order_id` field.

  ```
  {{Dimension('location__location_name', entity_path=['order_id'])}}
  ```
* In this example, the `salesforce_account_owner` dimension is joined to the `region` field, with the path going through `salesforce_account`.

  ```
  {{ Dimension('salesforce_account_owner__region',['salesforce_account']) }}
  ```

#### Query with order[​](#query-with-order "Direct link to Query with order")

```
mutation {
  createQuery(
    environmentId: "123"
    metrics: [{name: "order_total"}]
    groupBy: [{name: "metric_time", grain: MONTH}]
    orderBy: [{metric: {name: "order_total"}}, {groupBy: {name: "metric_time", grain: MONTH}, descending:true}]
  ) {
    queryId
  }
}
```

#### Query with limit[​](#query-with-limit "Direct link to Query with limit")

```
mutation {
  createQuery(
    environmentId: "123"
    metrics: [{name:"food_order_amount"}, {name: "order_gross_profit"}]
    groupBy: [{name:"metric_time", grain: MONTH}, {name: "customer__customer_type"}]
    limit: 10
  ) {
    queryId
  }
}
```

#### Query saved queries[​](#query-saved-queries "Direct link to Query saved queries")

This takes the same inputs as the `createQuery` mutation, but includes the field `savedQuery`. You can use this for frequently used queries.

```
mutation {
  createQuery(
    environmentId: "123"
    savedQuery: "new_customer_orders"
  ) {
    queryId
  }
}
```

A note on querying saved queries

When querying [saved queries](https://docs.getdbt.com/docs/build/saved-queries),you can use parameters such as `where`, `limit`, `order`, `compile`, and so on. However, keep in mind that you can't access `metric` or `group_by` parameters in this context. This is because they are predetermined and fixed parameters for saved queries, and you can't change them at query time. If you would like to query more metrics or dimensions, you can build the query using the standard format.

#### Query with just compiling SQL[​](#query-with-just-compiling-sql "Direct link to Query with just compiling SQL")

This takes the same inputs as the `createQuery` mutation.

```
mutation {
  compileSql(
    environmentId: "123"
    metrics: [{name:"food_order_amount"} {name:"order_gross_profit"}]
    groupBy: [{name:"metric_time", grain: MONTH}, {name:"customer__customer_type"}]
  ) {
    sql
  }
}
```

#### Query records[​](#query-records "Direct link to Query records")

Use this endpoint to view all the queries made in your project. This covers both Insights and Semantic Layer queries.

```
{
  queryRecords(
    environmentId:123
  ) {
    items {
      queryId
      status
      startTime
      endTime
      connectionDetails
      sqlDialect
      connectionSchema
      error
      queryDetails {
        ... on SemanticLayerQueryDetails {
          params {
            type
            metrics {
              name
            }
            groupBy {
              name
              grain
            }
            limit
            where {
              sql
            }
            orderBy {
              groupBy {
                name
                grain
              }
              metric {
                name
              }
              descending
            }
            savedQuery
          }
        }
        ... on RawSqlQueryDetails {
          queryStr
          compiledSql
          numCols
          queryDescription
          queryTitle
        }
      }
    }
    totalItems
    pageNum
    pageSize
  }
}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Semantic Layer APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-api-overview)[Next

JDBC](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-jdbc)

* [dbt Semantic Layer GraphQL API](#dbt-semantic-layer-graphql-api)* [Requirements to use the GraphQL API](#requirements-to-use-the-graphql-api)* [Using the GraphQL API](#using-the-graphql-api)
      + [Metadata calls](#metadata-calls)+ [Querying](#querying)+ [Output format and pagination](#output-format-and-pagination)+ [Run a Python query](#run-a-python-query)+ [Additional create query examples](#additional-create-query-examples)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-cloud-apis/sl-graphql.md)
