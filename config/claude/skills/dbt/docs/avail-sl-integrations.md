---
title: "Available integrations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt integrations](https://docs.getdbt.com/docs/cloud-integrations/overview)* Semantic Layer integrations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Favail-sl-integrations+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Favail-sl-integrations+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Favail-sl-integrations+so+I+can+ask+questions+about+it.)

There are a number of data applications that seamlessly integrate with the Semantic Layer, powered by MetricFlow, from business intelligence tools to notebooks, spreadsheets, data catalogs, and more. These integrations allow you to query and unlock valuable insights from your data ecosystem.

Use the [Semantic Layer APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-api-overview) to simplify metric queries, optimize your development workflow, and reduce coding. This approach also ensures data governance and consistency for data consumers.

The following tools integrate with the dbt Semantic Layer:

[![](https://docs.getdbt.com/img/icons/pbi.svg)

#### Power BI

Use reports to query the dbt Semantic Layer with Power BI and produce dashboards with trusted data.](/docs/cloud-integrations/semantic-layer/power-bi)

[![](https://docs.getdbt.com/img/icons/tableau-software.svg)

#### Tableau

Learn how to connect to Tableau for querying metrics and collaborating with your team.](/docs/cloud-integrations/semantic-layer/tableau)

[![](https://docs.getdbt.com/img/icons/google-sheets-logo-icon.svg)

#### Google Sheets

Discover how to connect to Google Sheets for querying metrics and collaborating with your team.](/docs/cloud-integrations/semantic-layer/gsheets)

[![](https://docs.getdbt.com/img/icons/excel.svg)

#### Microsoft Excel

Connect to Microsoft Excel to query metrics and collaborate with your team. Available for Excel Desktop or Excel Online.](/docs/cloud-integrations/semantic-layer/excel)

[![](https://docs.getdbt.com/img/icons/dot-ai.svg)

#### Dot

Enable everyone to analyze data with AI in Slack or Teams.](https://docs.getdot.ai/dot/integrations/dbt-semantic-layer)

[![](https://docs.getdbt.com/img/icons/hex.svg)

#### Hex

Check out how to connect, analyze metrics, collaborate, and discover more data possibilities.](https://learn.hex.tech/docs/connect-to-data/data-connections/dbt-integration#dbt-semantic-layer-integration)

[![](https://docs.getdbt.com/img/icons/klipfolio.svg)

#### Klipfolio PowerMetrics

Learn how to connect to a streamlined metrics catalog and deliver metric-centric analytics to business users.](https://support.klipfolio.com/hc/en-us/articles/18164546900759-PowerMetrics-Adding-dbt-Semantic-Layer-metrics)

[![](https://docs.getdbt.com/img/icons/mode.svg)

#### Mode

Discover how to connect, access, and get trustworthy metrics and insights.](https://mode.com/help/articles/supported-databases#dbt-semantic-layer)

[![](https://docs.getdbt.com/img/icons/push.svg)

#### Push.ai

Explore how to connect and use metrics to power reports and insights that drive change.](https://docs.push.ai/data-sources/semantic-layers/dbt)

[![](https://docs.getdbt.com/img/icons/sigma.svg)

#### Sigma (Preview)

Connect Sigma to the dbt Semantic Layer to allow you to leverage your predefined dbt metrics in Sigma workbooks.](https://help.sigmacomputing.com/docs/configure-a-dbt-semantic-layer-integration)

[![](https://docs.getdbt.com/img/icons/steep.svg)

#### Steep

Connect Steep to the dbt Semantic Layer for centralized, scalable analytics.](https://help.steep.app/integrations/dbt-cloud)



Before you connect to these tools, you'll need to first [set up the dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl) and [generate a service token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens) to create **Semantic Layer Only** and **Metadata Only** permissions.

### Custom integration[​](#custom-integration "Direct link to Custom integration")

* All BI tools can use [exports](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports) with the Semantic Layer, even if they don’t have a native integration.
* [Consume metrics](https://docs.getdbt.com/docs/use-dbt-semantic-layer/consume-metrics) and develop custom integrations using different languages and tools, supported through [JDBC](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-jdbc), ADBC, and [GraphQL](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-graphql) APIs, and [Python SDK library](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-python). For more info, check out [our examples on GitHub](https://github.com/dbt-labs/example-semantic-layer-clients/).
* Connect to any tool that supports SQL queries. These tools must meet one of the two criteria:
  + Offers a generic JDBC driver option (such as DataGrip) or
  + Is compatible Arrow Flight SQL JDBC driver version 12.0.0 or higher.

## Related docs[​](#related-docs "Direct link to Related docs")

* [dbt Semantic Layer APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-api-overview) to learn how to integrate and query your metrics in downstream tools.
* [Semantic Layer API query syntax](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-jdbc#querying-the-api-for-metric-metadata)
* [Hex Semantic Layer cells](https://learn.hex.tech/docs/explore-data/cells/data-cells/dbt-metrics-cells) to set up SQL cells in Hex.
* [Resolve 'Failed APN'](https://docs.getdbt.com/faqs/Troubleshooting/sl-alpn-error) error when connecting to the Semantic Layer.
* [Semantic Layer on-demand course](https://learn.getdbt.com/courses/semantic-layer)
* [Semantic Layer FAQs](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-faqs)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Orchestrate exposures](https://docs.getdbt.com/docs/cloud-integrations/orchestrate-exposures)[Next

Available integrations](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations)
