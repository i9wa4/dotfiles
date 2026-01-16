---
title: "Query the Discovery API | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-querying"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api)* Query the Discovery API

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-querying+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-querying+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-querying+so+I+can+ask+questions+about+it.)

On this page

The Discovery API supports ad-hoc queries and integrations. If you are new to the API, refer to [About the Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api) for an introduction.

Use the Discovery API to evaluate data pipeline health and project state across runs or at a moment in time. dbt Labs provide a default [GraphQL explorer](https://metadata.cloud.getdbt.com/graphql) for this API, enabling you to run queries and browse the schema. However, you can also use any GraphQL client of your choice to query the API.

Since GraphQL describes the data in the API, the schema displayed in the GraphQL explorer accurately represents the graph and fields available to query.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* dbt [multi-tenant](https://docs.getdbt.com/docs/cloud/about-cloud/tenancy#multi-tenant) or [single tenant](https://docs.getdbt.com/docs/cloud/about-cloud/tenancy#single-tenant) account
* You must be on an [Enterprise or Enterprise+ plan](https://www.getdbt.com/pricing/)
* Your projects must be on a dbt [release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) or dbt version 1.0 or later. Refer to [Upgrade dbt version in Cloud](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud) to upgrade.

## Authorization[​](#authorization "Direct link to Authorization")

Currently, authorization of requests takes place [using a service token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens). dbt admin users can generate a Metadata Only service token that is authorized to execute a specific query against the Discovery API.

Once you've created a token, you can use it in the Authorization header of requests to the dbt Discovery API. Be sure to include the Token prefix in the Authorization header, or the request will fail with a `401 Unauthorized` error. Note that `Bearer` can be used instead of `Token` in the Authorization header. Both syntaxes are equivalent.

## Access the Discovery API[​](#access-the-discovery-api "Direct link to Access the Discovery API")

1. Create a [service account token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens) to authorize requests. dbt Admin users can generate a *Metadata Only* service token, which can be used to execute a specific query against the Discovery API to authorize requests.
2. Find the API URL to use from the [Discovery API endpoints](#discovery-api-endpoints) table.
3. For specific query points, refer to the [schema documentation](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-job).

## Run queries using HTTP requests[​](#run-queries-using-http-requests "Direct link to Run queries using HTTP requests")

You can run queries by sending a `POST` request to the Discovery API, making sure to replace:

* `YOUR_API_URL` with the appropriate [Discovery API endpoint](#discovery-api-endpoints) for your region and plan.
* `YOUR_TOKEN` in the Authorization header with your actual API token. Be sure to include the Token prefix.
* `QUERY_BODY` with a GraphQL query, for example `{ "query": "<query text>", "variables": "<variables in json>" }`
* `VARIABLES` with a dictionary of your GraphQL query variables, such as a job ID or a filter.
* `ENDPOINT` with the endpoint you're querying, such as environment.

  ```
  curl 'YOUR_API_URL' \
    -H 'Authorization: Token <YOUR_TOKEN>' \
    -H 'Content-Type: application/json'
    -X POST
    --data QUERY_BODY
  ```

Python example:

```
response = requests.post(
    'YOUR_API_URL',
    headers={"authorization": "Bearer "+YOUR_TOKEN, "content-type": "application/json"},
    json={"query": QUERY_BODY, "variables": VARIABLES}
)

metadata = response.json()['data'][ENDPOINT]
```

Every query will require an environment ID or job ID. You can get the ID from a dbt URL or using the Admin API.

There are several illustrative example queries on this page. For more examples, refer to [Use cases and examples for the Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-use-cases-and-examples).

## Discovery API endpoints[​](#discovery-api-endpoints "Direct link to Discovery API endpoints")

The following are the endpoints for accessing the Discovery API. Use the one that's appropriate for your region and plan.

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Deployment type Discovery API URL|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | North America multi-tenant <https://metadata.cloud.getdbt.com/graphql>| EMEA multi-tenant <https://metadata.emea.dbt.com/graphql>| APAC multi-tenant <https://metadata.au.dbt.com/graphql>| Multi-cell `https://YOUR_ACCOUNT_PREFIX.metadata.REGION.dbt.com/graphql`   Replace `YOUR_ACCOUNT_PREFIX` with your specific account identifier and `REGION` with your location, which could be `us1.dbt.com`.| Single-tenant `https://metadata.YOUR_ACCESS_URL/graphql`   Replace `YOUR_ACCESS_URL` with your specific account prefix with the appropriate [Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan. | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Reasonable use[​](#reasonable-use "Direct link to Reasonable use")

Discovery (GraphQL) API usage is subject to request rate and response size limits to maintain the performance and stability of the metadata platform and prevent abuse.

Job-level endpoints are subject to query complexity limits. Nested nodes (like parents), code (like rawCode), and catalog columns are considered as most complex. Overly complex queries should be broken up into separate queries with only necessary fields included. dbt Labs recommends using the environment endpoint instead for most use cases to get the latest descriptive and result metadata for a dbt project.

## Retention limits[​](#retention-limits "Direct link to Retention limits")

You can use the Discovery API to query data from the previous two months. For example, if today was April 1st, you could query data back to February 1st.

## Run queries with the GraphQL explorer[​](#run-queries-with-the-graphql-explorer "Direct link to Run queries with the GraphQL explorer")

You can run ad-hoc queries directly in the [GraphQL API explorer](https://metadata.cloud.getdbt.com/graphql) and use the document explorer on the left-hand side to see all possible nodes and fields.

Refer to the [Apollo explorer documentation](https://www.apollographql.com/docs/graphos/explorer/explorer) for setup and authorization information for GraphQL.

1. Access the [GraphQL API explorer](https://metadata.cloud.getdbt.com/graphql) and select fields you want to query.
2. Select **Variables** at the bottom of the explorer and replace any `null` fields with your unique values.
3. [Authenticate](https://www.apollographql.com/docs/graphos/explorer/connecting-authenticating#authentication) using Bearer auth with `YOUR_TOKEN`. Select **Headers** at the bottom of the explorer and select **+New header**.
4. Select **Authorization** in the **header key** dropdown list and enter your Bearer auth token in the **value** field. Remember to include the Token prefix. Your header key should be in this format: `{"Authorization": "Bearer <YOUR_TOKEN>}`.



[![Enter the header key and Bearer auth token values](https://docs.getdbt.com/img/docs/dbt-cloud/discovery-api/graphql_header.jpg?v=2 "Enter the header key and Bearer auth token values")](#)Enter the header key and Bearer auth token values

1. Run your query by clicking the blue query button in the top right of the **Operation** editor (to the right of the query). You should see a successful query response on the right side of the explorer.

[![Run queries using the Apollo Server GraphQL explorer](https://docs.getdbt.com/img/docs/dbt-cloud/discovery-api/graphql.jpg?v=2 "Run queries using the Apollo Server GraphQL explorer")](#)Run queries using the Apollo Server GraphQL explorer

### Fragments[​](#fragments "Direct link to Fragments")

Use the [`... on`](https://www.apollographql.com/docs/react/data/fragments/) notation to query across lineage and retrieve results from specific node types.

```
query ($environmentId: BigInt!, $first: Int!) {
  environment(id: $environmentId) {
    applied {
      models(first: $first, filter: { uniqueIds: "MODEL.PROJECT.MODEL_NAME" }) {
        edges {
          node {
            name
            ancestors(types: [Model, Source, Seed, Snapshot]) {
              ... on ModelAppliedStateNestedNode {
                name
                resourceType
                materializedType
                executionInfo {
                  executeCompletedAt
                }
              }
              ... on SourceAppliedStateNestedNode {
                sourceName
                name
                resourceType
                freshness {
                  maxLoadedAt
                }
              }
              ... on SnapshotAppliedStateNestedNode {
                name
                resourceType
                executionInfo {
                  executeCompletedAt
                }
              }
              ... on SeedAppliedStateNestedNode {
                name
                resourceType
                executionInfo {
                  executeCompletedAt
                }
              }
            }
          }
        }
      }
    }
  }
}
```

### Pagination[​](#pagination "Direct link to Pagination")

Querying large datasets can impact performance on multiple functions in the API pipeline. Pagination eases the burden by returning smaller data sets one page at a time. This is useful for returning a particular portion of the dataset or the entire dataset piece-by-piece to enhance performance. dbt utilizes cursor-based pagination, which makes it easy to return pages of constantly changing data.

Use the `PageInfo` object to return information about the page. The available fields are:

* `startCursor` string type — Corresponds to the first `node` in the `edge`.
* `endCursor` string type — Corresponds to the last `node` in the `edge`.
* `hasNextPage` boolean type — Whether or not there are more `nodes` after the returned results.

There are connection variables available when making the query:

* `first` integer type — Returns the first n `nodes` for each page, up to 500.
* `after` string type — Sets the cursor to retrieve `nodes` after. It's best practice to set the `after` variable with the object ID defined in the `endCursor` of the previous page.

Below is an example that returns the `first` 500 models `after` the specified Object ID in the variables. The `PageInfo` object returns where the object ID where the cursor starts, where it ends, and whether there is a next page.

[![Example of pagination](https://docs.getdbt.com/img/Paginate.png?v=2 "Example of pagination")](#)Example of pagination

Below is a code example of the `PageInfo` object:

```
pageInfo {
  startCursor
  endCursor
  hasNextPage
}
totalCount # Total number of records across all pages
```

### Filters[​](#filters "Direct link to Filters")

Filtering helps to narrow down the results of an API query. If you want to query and return only models and tests that are failing or find models that are taking too long to run, you can fetch execution details such as [`executionTime`](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-job-models#fields), [`runElapsedTime`](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-job-models#fields), or [`status`](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-job-models#fields). This helps data teams monitor the performance of their models, identify bottlenecks, and optimize the overall data pipeline.

Below is an example that filters for results of models that have succeeded on their `lastRunStatus`:

[![Example of filtering](https://docs.getdbt.com/img/Filtering.png?v=2 "Example of filtering")](#)Example of filtering

Below is an example that filters for models that have an error on their last run and tests that have failed:

```
query ModelsAndTests($environmentId: BigInt!, $first: Int!) {
  environment(id: $environmentId) {
    applied {
      models(first: $first, filter: { lastRunStatus: error }) {
        edges {
          node {
            name
            executionInfo {
              lastRunId
            }
          }
        }
      }
      tests(first: $first, filter: { status: "fail" }) {
        edges {
          node {
            name
            executionInfo {
              lastRunId
            }
          }
        }
      }
    }
  }
}
```

## Related content[​](#related-content "Direct link to Related content")

* [Use cases and examples for the Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-use-cases-and-examples)
* [Schema](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-job)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Project state in dbt](https://docs.getdbt.com/docs/dbt-cloud-apis/project-state)[Next

Environment](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-environment)

* [Authorization](#authorization)* [Access the Discovery API](#access-the-discovery-api)* [Run queries using HTTP requests](#run-queries-using-http-requests)* [Discovery API endpoints](#discovery-api-endpoints)* [Reasonable use](#reasonable-use)* [Retention limits](#retention-limits)* [Run queries with the GraphQL explorer](#run-queries-with-the-graphql-explorer)
              + [Fragments](#fragments)+ [Pagination](#pagination)+ [Filters](#filters)* [Related content](#related-content)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-cloud-apis/discovery-querying.md)
