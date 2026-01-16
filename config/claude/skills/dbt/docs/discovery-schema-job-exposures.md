---
title: "Exposures object schema | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-job-exposures"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api)* [Schema](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-about)* [Job](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-job)* Exposures

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-schema-job-exposures+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-schema-job-exposures+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-schema-job-exposures+so+I+can+ask+questions+about+it.)

On this page

The exposures object allows you to query information about all exposures in a given job. To learn more, refer to [Add Exposures to your DAG](https://docs.getdbt.com/docs/build/exposures).

### Arguments[​](#arguments "Direct link to Arguments")

When querying for `exposures`, the following arguments are available.

# Fetching data...

Below we show some illustrative example queries and outline the schema of the exposures object.

### Example query[​](#example-query "Direct link to Example query")

The example below queries information about all exposures in a given job including the owner's name and email, the URL, and information about parent sources and parent models for each exposure.

```
{
  job(id: 123) {
    exposures(jobId: 123) {
      runId
      projectId
      name
      uniqueId
      resourceType
      ownerName
      url
      ownerEmail
      parentsSources {
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
      parentsModels {
        uniqueId
      }
    }
  }
}
```

### Fields[​](#fields "Direct link to Fields")

When querying for `exposures`, the following fields are available:

# Fetching data...

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Exposure](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-job-exposure)[Next

Semantic Layer APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-api-overview)

* [Arguments](#arguments)* [Example query](#example-query)* [Fields](#fields)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-cloud-apis/schema-discovery-job-exposures.mdx)
