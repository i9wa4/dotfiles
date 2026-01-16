---
title: "About the Discovery API | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * Discovery API

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-api+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-api+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-api+so+I+can+ask+questions+about+it.)

On this page

Every time dbt runs a project, it generates and stores information about the project. The metadata includes details about your project’s models, sources, and other nodes along with their execution results. With the dbt Discovery API, you can query this comprehensive information to gain a better understanding of your DAG and the data it produces.

By leveraging the metadata in dbt, you can create systems for data monitoring and alerting, lineage exploration, and automated reporting. This can help you improve data discovery, data quality, and pipeline operations within your organization.

You can access the Discovery API through [ad hoc queries](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-querying), custom applications, a wide range of [partner ecosystem integrations](https://www.getdbt.com/product/integrations/) (like BI/analytics, catalog and governance, and quality and observability), and by using dbt features like [model timing](https://docs.getdbt.com/docs/deploy/run-visibility#model-timing) and [data health tiles](https://docs.getdbt.com/docs/explore/data-tile).

[![A rich ecosystem for integration ](https://docs.getdbt.com/img/docs/dbt-cloud/discovery-api/discovery-api-figure.png?v=2 "A rich ecosystem for integration ")](#)A rich ecosystem for integration

You can query the dbt metadata:

* At the [environment](https://docs.getdbt.com/docs/environments-in-dbt) level for both the latest state (use the `environment` endpoint) and historical run results (use `modelHistoricalRuns`) of a dbt project in production.
* At the job level for results on a specific dbt job run for a given resource type, like `models` or `test`.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* dbt [multi-tenant](https://docs.getdbt.com/docs/cloud/about-cloud/tenancy#multi-tenant) or [single tenant](https://docs.getdbt.com/docs/cloud/about-cloud/tenancy#single-tenant) account
* You must be on an [Enterprise or Enterprise+ plan](https://www.getdbt.com/pricing/)
* Your projects must be on a dbt [release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) or dbt version 1.0 or later. Refer to [Upgrade dbt version in Cloud](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud) to upgrade.

## What you can use the Discovery API for[​](#what-you-can-use-the-discovery-api-for "Direct link to What you can use the Discovery API for")

Click the following tabs to learn more about the API's use cases, the analysis you can do, and the results you can achieve by integrating with it.

To use the API directly or integrate your tool with it, refer to [Uses case and examples](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-use-cases-and-examples) for detailed information.

* Performance* Quality* Discovery* Governance* Development

Use the API to look at historical information like model build time to determine the health of your dbt projects. Finding inefficiencies in orchestration configurations can help decrease infrastructure costs and improve timeliness. To learn more about how to do this, refer to [Performance](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-use-cases-and-examples#performance).

You can use, for example, the [model timing](https://docs.getdbt.com/docs/deploy/run-visibility#model-timing) tab to help identify and optimize bottlenecks in model builds:

[![Model timing visualization in dbt](https://docs.getdbt.com/img/docs/dbt-cloud/discovery-api/model-timing.png?v=2 "Model timing visualization in dbt")](#)Model timing visualization in dbt

Use the API to determine if the data is accurate and up-to-date by monitoring test failures, source freshness, and run status. Accurate and reliable information is valuable for analytics, decisions, and monitoring to help prevent your organization from making bad decisions. To learn more about this, refer to [Quality](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-use-cases-and-examples#quality).

When used with [webhooks](https://docs.getdbt.com/docs/deploy/webhooks), it can also help with detecting, investigating, and alerting issues.

Use the API to find and understand dbt assets in integrated tools using information like model and metric definitions, and column information. For more details, refer to [Discovery](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-use-cases-and-examples#discovery).

Data producers must manage and organize data for stakeholders, while data consumers need to quickly and confidently analyze data on a large scale to make informed decisions that improve business outcomes and reduce organizational overhead. The API is useful for discovery data experiences in catalogs, analytics, apps, and machine learning (ML) tools. It can help you understand the origin and meaning of datasets for your analysis.

[![Data lineage produced by dbt](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/example-model-details.png?v=2 "Data lineage produced by dbt")](#)Data lineage produced by dbt

Use the API to review who developed the models and who uses them to help establish standard practices for better governance. For more details, refer to [Governance](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-use-cases-and-examples#governance).

Use the API to review dataset changes and uses by examining exposures, lineage, and dependencies. From the investigation, you can learn how to define and build more effective dbt projects. For more details, refer to [Development](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-use-cases-and-examples#development).

[![Use exposures to embed data health tiles in your dashboards to distill trust signals for data consumers.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/data-tile-pass.jpg?v=2 "Use exposures to embed data health tiles in your dashboards to distill trust signals for data consumers.")](#)Use exposures to embed data health tiles in your dashboards to distill trust signals for data consumers.

## Types of project state[​](#types-of-project-state "Direct link to Types of project state")

You can query these two types of [project state](https://docs.getdbt.com/docs/dbt-cloud-apis/project-state) at the environment level:

* **Definition** — The logical state of a dbt project’s [resources](https://docs.getdbt.com/docs/build/projects) that update when the project is changed.
* **Applied** — The output of successful dbt DAG execution that creates or describes the state of the database (for example: `dbt run`, `dbt test`, source freshness, and so on)

These states allow you to easily examine the difference between a model’s definition and its applied state so you can get answers to questions like, did the model run? or did the run fail? Applied models exist as a table/view in the data platform given their most recent successful run.

## Related docs[​](#related-docs "Direct link to Related docs")

* [Use cases and examples for the Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-use-cases-and-examples)
* [Query the Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-querying)
* [Schema](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-job)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

dbt Administrative API](https://docs.getdbt.com/docs/dbt-cloud-apis/admin-cloud-api)[Next

Uses and examples](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-use-cases-and-examples)

* [What you can use the Discovery API for](#what-you-can-use-the-discovery-api-for)* [Types of project state](#types-of-project-state)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-cloud-apis/discovery-api.md)
