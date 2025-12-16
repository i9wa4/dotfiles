---
title: "Consume metrics from your Semantic Layer | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/use-dbt-semantic-layer/consume-metrics"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Use the dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl)* Consume

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fconsume-metrics+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fconsume-metrics+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fconsume-metrics+so+I+can+ask+questions+about+it.)

On this page

After [deploying](https://docs.getdbt.com/docs/use-dbt-semantic-layer/deploy-sl) your Semantic Layer, the next important (and fun!) step is querying and consuming the metrics you’ve defined. This page links to key resources that guide you through the process of consuming metrics across different integrations, APIs, and tools, using various different [query syntaxes](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-jdbc#querying-the-api-for-metric-metadata).

Once your Semantic Layer is deployed, you can start querying your metrics using a variety of tools and APIs. Here are the main resources to get you started:

### Available integrations[​](#available-integrations "Direct link to Available integrations")

Integrate the Semantic Layer with a variety of business intelligence (BI) tools and data platforms, enabling seamless metric queries within your existing workflows. Explore the following integrations:

* [Available integrations](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations) — Review a wide range of partners such as Tableau, Google Sheets, Microsoft Excel, and more, where you can query your metrics directly from the Semantic Layer.

### Query with APIs[​](#query-with-apis "Direct link to Query with APIs")

To leverage the full power of the Semantic Layer, you can use the Semantic Layer APIs for querying metrics programmatically:

* [Semantic Layer APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-api-overview) — Learn how to use the Semantic Layer APIs to query metrics in downstream tools, ensuring consistent and reliable data metrics.
  + [JDBC API query syntax](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-jdbc#querying-the-api-for-metric-metadata) — Dive into the syntax for querying metrics with the JDBC API, with examples and detailed instructions.
  + [GraphQL API query syntax](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-graphql#querying) — Learn the syntax for querying metrics via the GraphQL API, including examples and detailed instructions.
  + [Python SDK](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-python#usage-examples) — Use the Python SDK library to query metrics programmatically with Python.

### Query during development[​](#query-during-development "Direct link to Query during development")

For developers working within the dbt ecosystem, it’s essential to understand how to query metrics during the development phase using MetricFlow commands:

* [MetricFlow commands](https://docs.getdbt.com/docs/build/metricflow-commands) — Learn how to use MetricFlow commands to query metrics directly during the development process, ensuring your metrics are correctly defined and working as expected.

## Next steps[​](#next-steps "Direct link to Next steps")

After understanding the basics of querying metrics, consider optimizing your setup and ensuring the integrity of your metric definitions:

* [Optimize querying performance](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-cache) — Improve query speed and efficiency by using declarative caching techniques.
* [Validate semantic nodes in CI](https://docs.getdbt.com/docs/deploy/ci-jobs#semantic-validations-in-ci) — Ensure that any changes to dbt models don’t break your metrics by validating semantic nodes in Continuous Integration (CI) jobs.
* [Build your metrics and semantic models](https://docs.getdbt.com/docs/build/build-metrics-intro) — If you haven’t already, learn how to define and build your metrics and semantic models using your preferred development tool.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Cache common queries](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-cache)[Next

Semantic Layer FAQs](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-faqs)

* [Available integrations](#available-integrations)* [Query with APIs](#query-with-apis)* [Query during development](#query-during-development)* [Next steps](#next-steps)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/use-dbt-semantic-layer/consume-metrics.md)
