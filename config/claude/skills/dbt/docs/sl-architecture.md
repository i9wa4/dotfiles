---
title: "dbt Semantic Layer architecture | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-architecture"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Use the dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl)* [Configure](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl)* Semantic Layer architecture

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fsl-architecture+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fsl-architecture+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fsl-architecture+so+I+can+ask+questions+about+it.)

On this page

The Semantic Layer allows you to define metrics and use various interfaces to query them. The Semantic Layer does the heavy lifting to find where the queried data exists in your data platform and generates the SQL to make the request (including performing joins).

[![This diagram shows how the dbt Semantic Layer works with your data stack.](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/sl-concept.png?v=2 "This diagram shows how the dbt Semantic Layer works with your data stack.")](#)This diagram shows how the dbt Semantic Layer works with your data stack.

[![The diagram displays how your data flows using the dbt Semantic Layer and the variety of integration tools it supports.](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/sl-architecture.jpg?v=2 "The diagram displays how your data flows using the dbt Semantic Layer and the variety of integration tools it supports.")](#)The diagram displays how your data flows using the dbt Semantic Layer and the variety of integration tools it supports.

## Components[​](#components "Direct link to Components")

The Semantic Layer includes the following components:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Components Information dbt Core users Developer plans Starter plans Enterprise-tier plans License|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **[MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow)** MetricFlow in dbt allows users to centrally define their semantic models and metrics with YAML specifications. ✅ ✅ ✅ ✅ [Apache 2.0 license](https://github.com/dbt-labs/metricflow/blob/main/LICENSE)| **dbt Semantic interfaces** A configuration spec for defining metrics, dimensions, how they link to each other, and how to query them. The [dbt-semantic-interfaces](https://github.com/dbt-labs/dbt-semantic-interfaces) is available under Apache 2.0. ❌ ❌ ✅ ✅ Proprietary, Cloud (Starter & Enterprise)|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Service layer** Coordinates query requests and dispatching the relevant metric query to the target query engine. This is provided through dbt and is available to all users on dbt version 1.6 or later. The service layer includes a Gateway service for executing SQL against the data platform. ❌ ❌ ✅ ✅ Proprietary, Cloud (Starter, Enterprise, Enterprise+)|  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | | **[Semantic Layer APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-api-overview)** The interfaces allow users to submit metric queries using GraphQL and JDBC APIs. They also serve as the foundation for building first-class integrations with various tools. ❌ ❌ ✅ ✅ Proprietary, Cloud (Starter, Enterprise, Enterprise+) | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Feature comparison[​](#feature-comparison "Direct link to Feature comparison")

The following table compares the features available in dbt and source available in dbt Core:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Feature MetricFlow Source available Semantic Layer with dbt|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Define metrics and semantic models in dbt using the MetricFlow spec ✅ ✅|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Generate SQL from a set of config files ✅ ✅|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Query metrics and dimensions through the command line interface (CLI) ✅ ✅|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Query dimension, entity, and metric metadata through the CLI ✅ ✅|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Query metrics and dimensions through semantic APIs (ADBC, GQL) ❌ ✅|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Connect to downstream integrations (Tableau, Hex, Mode, Google Sheets, and so on.) ❌ ✅|  |  |  | | --- | --- | --- | | Create and run Exports to save metrics queries as tables in your data platform. ❌ ✅ | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Related docs[​](#related-docs "Direct link to Related docs")

* [Semantic Layer FAQs](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-faqs)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Administer the Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl)[Next

Deploy your metrics](https://docs.getdbt.com/docs/use-dbt-semantic-layer/deploy-sl)

* [Components](#components)* [Feature comparison](#feature-comparison)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/use-dbt-semantic-layer/sl-architecture.md)
