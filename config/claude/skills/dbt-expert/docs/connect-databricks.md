---
title: "Connect Databricks | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-databricks"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Connect your data platforms](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections)* Connect Databricks

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-databricks+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-databricks+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fconnect-data-platform%2Fconnect-databricks+so+I+can+ask+questions+about+it.)

On this page

The dbt-databricks adapter is maintained by the Databricks team. The Databricks team is committed to supporting and improving the adapter over time, so you can be sure the integrated experience will provide the best of dbt and the best of Databricks. Connecting to Databricks via dbt-spark has been deprecated.

## About the dbt-databricks adapter[​](#about-the-dbt-databricks-adapter "Direct link to About the dbt-databricks adapter")

dbt-databricks is compatible with the following versions of dbt Core in dbt with varying degrees of functionality.

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Feature dbt Versions|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | dbt-databricks Available starting with dbt 1.0 in dbt| Unity Catalog Available starting with dbt 1.1|  |  | | --- | --- | | Python models Available starting with dbt 1.3 | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

The dbt-databricks adapter offers:

* **Easier set up**
* **Better defaults:**
  The dbt-databricks adapter is more opinionated, guiding users to an improved experience with less effort. Design choices of this adapter include defaulting to Delta format, using merge for incremental models, and running expensive queries with Photon.
* **Support for Unity Catalog:**
  Unity Catalog allows Databricks users to centrally manage all data assets, simplifying access management and improving search and query performance. Databricks users can now get three-part data hierarchies – catalog, schema, model name – which solves a longstanding friction point in data organization and governance.

To learn how to optimize performance with data platform-specific configurations in dbt, refer to [Databricks-specific configuration](https://docs.getdbt.com/reference/resource-configs/databricks-configs).

To grant users or roles database permissions (access rights and privileges), refer to the [example permissions](https://docs.getdbt.com/reference/database-permissions/databricks-permissions) page.

To set up the Databricks connection, supply the following fields:

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description Examples|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Server Hostname The hostname of the Databricks account to connect to dbc-a2c61234-1234.cloud.databricks.com|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | HTTP Path The HTTP path of the Databricks cluster or SQL warehouse /sql/1.0/warehouses/1a23b4596cd7e8fg|  |  |  | | --- | --- | --- | | Catalog Name of Databricks Catalog (optional) Production | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

[![Configuring a Databricks connection using the dbt-databricks adapter](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/dbt-databricks.png?v=2 "Configuring a Databricks connection using the dbt-databricks adapter")](#)Configuring a Databricks connection using the dbt-databricks adapter

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Connect BigQuery](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-bigquery)[Next

Connect Microsoft Fabric](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-microsoft-fabric)

* [About the dbt-databricks adapter](#about-the-dbt-databricks-adapter)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/connect-data-platform/connect-databricks.md)
