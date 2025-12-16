---
title: "Apache Iceberg Support | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/mesh/iceberg/apache-iceberg-support"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt Mesh](https://docs.getdbt.com/docs/mesh/about-mesh)* Apache Iceberg

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Ficeberg%2Fapache-iceberg-support+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Ficeberg%2Fapache-iceberg-support+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fmesh%2Ficeberg%2Fapache-iceberg-support+so+I+can+ask+questions+about+it.)

Apache Iceberg is an open standard table format that brings greater portability and interoperability to the data ecosystem. By standardizing how data is stored and accessed, Iceberg enables teams to work across different engines and platforms with confidence. It has many components to it but the main ones that dbt interacts with are:

* **Iceberg Table Format** - an open-source table format. Tables materialized in iceberg table format are stored on a user’s infrastructure, such as a S3 Bucket.
* **Iceberg Data Catalog** - an open-source metadata management system that tracks the schema, partition, and versions of Iceberg tables.
* **Iceberg REST Protocol** (also referred to as Iceberg REST API) is how engines can support and speak to other Iceberg-compatible catalogs.

dbt abstracts the complexity of table formats so teams can focus on delivering reliable, well-modeled data. Our initial integration with Iceberg supports table materializations and catalog integrations, allowing users to define and manage Iceberg tables directly in their dbt projects. To learn more, click on one of the following tiles

[![](https://docs.getdbt.com/img/icons/dbt-icon.svg)

#### Using dbt + Iceberg Catalog overview

dbt support for Apache Iceberg](/docs/mesh/iceberg/about-catalogs)

[![](https://docs.getdbt.com/img/icons/snowflake.svg)

#### Snowflake

Snowflake Iceberg Configurations](/docs/mesh/iceberg/snowflake-iceberg-support)

[![](https://docs.getdbt.com/img/icons/bigquery.svg)

#### BigQuery

BigQuery Iceberg Configurations](/docs/mesh/iceberg/bigquery-iceberg-support)

[![](https://docs.getdbt.com/img/icons/databricks.svg)

#### Databricks

Databricks Iceberg Configurations](/docs/mesh/iceberg/databricks-iceberg-support)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Project dependencies](https://docs.getdbt.com/docs/mesh/govern/project-dependencies)[Next

About Iceberg catalogs](https://docs.getdbt.com/docs/mesh/iceberg/about-catalogs)
