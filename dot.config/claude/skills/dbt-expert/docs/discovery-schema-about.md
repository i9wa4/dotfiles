---
title: "About the Discovery API schema | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-about"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api)* Schema

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-schema-about+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-schema-about+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fdiscovery-schema-about+so+I+can+ask+questions+about+it.)

With the Discovery API, you can query the metadata in dbt to learn more about your dbt deployments and the data they generate. You can analyze the data to make improvements. If you are new to the API, refer to [About the Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api) for an introduction. You might also find the [use cases and examples](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-use-cases-and-examples) helpful.

The Discovery API *schema* provides all the pieces necessary to query and interact with the Discovery API. The most common queries use the `environment` endpoint:

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Environment schema

Query and compare a model’s definition (intended) and its applied (actual) state.](/docs/dbt-cloud-apis/discovery-schema-environment)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Applied schema

Query the actual state of objects and metadata in the warehouse after a `dbt run` or `dbt build`.](/docs/dbt-cloud-apis/discovery-schema-environment-applied)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Definition schema

Query intended state in project code and configuration defined in your dbt project.](/docs/dbt-cloud-apis/discovery-schema-environment-definition)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Model Historical Runs schema

Query information about a model's run history.](/docs/dbt-cloud-apis/discovery-schema-environment-applied-modelHistoricalRuns)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Query the Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-querying)[Next

About the schema](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-schema-about)
