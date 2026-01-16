---
title: "Build your metrics | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/build-metrics-intro"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* Build your metrics

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fbuild-metrics-intro+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fbuild-metrics-intro+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fbuild-metrics-intro+so+I+can+ask+questions+about+it.)

Use MetricFlow in dbt to centrally define your metrics. As a key component of the [Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl), MetricFlow is responsible for SQL query construction and defining specifications for dbt semantic models and metrics. It uses familiar constructs like semantic models and metrics to avoid duplicative coding, optimize your development workflow, ensure data governance for company metrics, and guarantee consistency for data consumers.

[![This diagram shows how the dbt Semantic Layer works with your data stack.](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/sl-concept.png?v=2 "This diagram shows how the dbt Semantic Layer works with your data stack.")](#)This diagram shows how the dbt Semantic Layer works with your data stack.

MetricFlow allows you to:

* Intuitively define metrics in your dbt project
* Develop from your preferred environment, whether that's the [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation), [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio), or [dbt Core](https://docs.getdbt.com/docs/core/installation-overview)
* Use [MetricFlow commands](https://docs.getdbt.com/docs/build/metricflow-commands) to query and test those metrics in your development environment
* Harness the true magic of the universal Semantic Layer and dynamically query these metrics in downstream tools (Available for dbt [Starter, Enterprise, or Enterprise+](https://www.getdbt.com/pricing/) accounts only).

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Quickstart for the dbt Semantic Layer

Use this guide to build and define metrics, set up the dbt Semantic Layer, and query them using downstream tools.](/guides/sl-snowflake-qs)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### About MetricFlow

Understand MetricFlow's core concepts, how to use joins, how to save commonly used queries, and what commands are available.](/docs/build/about-metricflow)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Semantic model

Use semantic models as the basis for defining data. They act as nodes in the semantic graph, with entities connecting them.](/docs/build/semantic-models)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Metrics

Define metrics through the powerful combination of measures, constraints, or functions, effortlessly organized in either YAML files or separate files.](/docs/build/metrics-overview)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Advanced topics

Learn about advanced topics for dbt Semantic Layer and MetricFlow, such as data modeling workflows, and more.](/docs/build/advanced-topics)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### About the dbt Semantic Layer

Introducing the dbt Semantic Layer, the universal process that allows data teams to centrally define and query metrics](/docs/use-dbt-semantic-layer/dbt-sl)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Available integrations

Discover the diverse range of partners that seamlessly integrate with the powerful dbt Semantic Layer, allowing you to query and unlock valuable insights from your data ecosystem.](/docs/cloud-integrations/avail-sl-integrations)



## Related docs[​](#related-docs "Direct link to Related docs")

* [Quickstart guide with the Semantic Layer](https://docs.getdbt.com/guides/sl-snowflake-qs)
* [The Semantic Layer: what's next](https://www.getdbt.com/blog/dbt-semantic-layer-whats-next/) blog
* [Semantic Layer on-demand course](https://learn.getdbt.com/courses/semantic-layer)
* [Semantic Layer FAQs](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-faqs)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

Quickstart with the dbt Semantic Layer and Snowflake](https://docs.getdbt.com/guides/sl-snowflake-qs)
