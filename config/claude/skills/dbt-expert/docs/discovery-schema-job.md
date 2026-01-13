---
title: "Job object schema | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-job"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api)* [Schema](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-about)* Job

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-schema-job+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-schema-job+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-schema-job+so+I+can+ask+questions+about+it.)

On this page

The job object allows you to query information about a particular model based on `jobId` and, optionally, a `runId`.

If you don't provide a `runId`, the API returns information on the latest runId of a job.

The [example query](#example-query) illustrates a few fields you can query in this `job` object. Refer to [Fields](#fields) to see the entire schema, which provides all possible fields you can query.

### Arguments[​](#arguments "Direct link to Arguments")

When querying for `job`, you can use the following arguments.

# Fetching data...

### Example Query[​](#example-query "Direct link to Example Query")

You can use your production job's `id`.

```
query JobQueryExample {
  # Provide runId for looking at specific run, otherwise it defaults to latest run
  job(id: 940) {
    # Get all models from this job's latest run
    models(schema: "analytics") {
      uniqueId
      executionTime
    }

    # Or query a single node
    source(uniqueId: "source.jaffle_shop.snowplow.event") {
      uniqueId
      sourceName
      name
      state
      maxLoadedAt
      criteria {
        warnAfter {
          period
          count
        }
        errorAfter {
          period
          count
        }
      }
      maxLoadedAtTimeAgoInS
    }
  }
}
```

### Fields[​](#fields "Direct link to Fields")

When querying an `job`, you can use the following fields.

# Fetching data...

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

Model](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-job-model)

* [Arguments](#arguments)* [Example Query](#example-query)* [Fields](#fields)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-cloud-apis/schema-discovery-job.mdx)
