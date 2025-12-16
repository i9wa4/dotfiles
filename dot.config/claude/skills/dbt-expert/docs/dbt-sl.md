---
title: "dbt Semantic Layer | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * Use the dbt Semantic Layer

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fdbt-sl+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fdbt-sl+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fdbt-sl+so+I+can+ask+questions+about+it.)

On this page

The dbt Semantic Layer eliminates duplicate coding by allowing data teams to define metrics on top of existing models and automatically handling data joins.

The dbt Semantic Layer, powered by [MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow), simplifies the process of defining and using critical business metrics, like `revenue` in the modeling layer (your dbt project). By centralizing metric definitions, data teams can ensure consistent self-service access to these metrics in downstream data tools and applications.

Moving metric definitions out of the BI layer and into the modeling layer allows data teams to feel confident that different business units are working from the same metric definitions, regardless of their tool of choice. If a metric definition changes in dbt, it’s refreshed everywhere it’s invoked and creates consistency across all applications. To ensure secure access control, the Semantic Layer implements robust [access permissions](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl#set-up-dbt-semantic-layer) mechanisms.

Refer to the [Semantic Layer FAQs](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-faqs) or [Why we need a universal semantic layer](https://www.getdbt.com/blog/universal-semantic-layer/) blog post to learn more.

## Get started with the dbt Semantic Layer[​](#get-started-with-the-dbt-semantic-layer "Direct link to Get started with the dbt Semantic Layer")

To define and query metrics with the dbt Semantic Layer, you must be on a [dbt Starter or Enterprise-tier](https://www.getdbt.com/pricing/) account.  Suitable for both Multi-tenant and Single-tenant accounts. Note: Single-tenant accounts should contact their account representative for necessary setup and enablement.



Not yet supported in the dbt Fusion engine

Semantic Layer is currently supported in the dbt platform for environments running versions of dbt Core. Support for environments on the dbt Fusion engine is coming soon.

This page points to various resources available to help you understand, configure, deploy, and integrate the Semantic Layer. The following sections contain links to specific pages that explain each aspect in detail. Use these links to navigate directly to the information you need, whether you're setting up the Semantic Layer for the first time, deploying metrics, or integrating with downstream tools.

Refer to the following resources to get started with the Semantic Layer:

* [Quickstart with the Semantic Layer](https://docs.getdbt.com/guides/sl-snowflake-qs) — Build and define metrics, set up the Semantic Layer, and query them using our first-class integrations.
* [Build your metrics](https://docs.getdbt.com/docs/build/build-metrics-intro) — Use MetricFlow in dbt to centrally define your metrics.
* [Semantic Layer FAQs](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-faqs) — Discover answers to frequently asked questions about the Semantic Layer, such as availability, integrations, and more.

## Configure the dbt Semantic Layer[​](#configure-the-dbt-semantic-layer "Direct link to Configure the dbt Semantic Layer")

The following resources provide information on how to configure the Semantic Layer:

* [Administer the Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl) — Seamlessly set up the credentials and tokens to start querying the Semantic Layer.
* [Architecture](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-architecture) — Explore the powerful components that make up the Semantic Layer.

## Deploy metrics[​](#deploy-metrics "Direct link to Deploy metrics")

This section provides information on how to deploy the Semantic Layer and materialize your metrics:

* [Deploy your Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/deploy-sl) — Run a dbt job to deploy the Semantic Layer and materialize your metrics.
* [Write queries with exports](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports) — Use exports to write commonly used queries directly within your data platform, on a schedule.
* [Cache common queries](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-cache) — Leverage result caching and declarative caching for common queries to speed up performance and reduce query computation.

## Consume metrics and integrate[​](#consume-metrics-and-integrate "Direct link to Consume metrics and integrate")

Consume metrics and integrate the Semantic Layer with downstream tools and applications:

* [Consume metrics](https://docs.getdbt.com/docs/use-dbt-semantic-layer/consume-metrics) — Query and consume metrics in downstream tools and applications using the Semantic Layer.
* [Available integrations](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations) — Review a wide range of partners you can integrate and query with the Semantic Layer.
* [Semantic Layer APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-api-overview) — Use the Semantic Layer APIs to query metrics in downstream tools for consistent, reliable data metrics.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

Quickstart with the dbt Semantic Layer and Snowflake](https://docs.getdbt.com/guides/sl-snowflake-qs)

* [Get started with the dbt Semantic Layer](#get-started-with-the-dbt-semantic-layer)* [Configure the dbt Semantic Layer](#configure-the-dbt-semantic-layer)* [Deploy metrics](#deploy-metrics)* [Consume metrics and integrate](#consume-metrics-and-integrate)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/use-dbt-semantic-layer/dbt-sl.md)
