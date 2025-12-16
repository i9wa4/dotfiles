---
title: "Tableau | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud-integrations/semantic-layer/tableau"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt integrations](https://docs.getdbt.com/docs/cloud-integrations/overview)* [Semantic Layer integrations](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations)* Tableau

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fsemantic-layer%2Ftableau+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fsemantic-layer%2Ftableau+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fsemantic-layer%2Ftableau+so+I+can+ask+questions+about+it.)

On this page

The Tableau integration allows you to use worksheets to query the Semantic Layer directly and produce your dashboards with trusted data. It provides a live connection to the Semantic Layer through Tableau Desktop or Tableau Server.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You have [configured the Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl) and are using dbt v1.6 or higher.
* You must have [Tableau Desktop](https://www.tableau.com/en-gb/products/desktop) version 2021.1 and greater, Tableau Server, or [Tableau Cloud](https://www.tableau.com/products/cloud-bi).
* Log in to Tableau Desktop (with Cloud or Server credentials) or Tableau Cloud. You can also use a licensed Tableau Server deployment.
* You need your [dbt host](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl#3-view-connection-detail), [Environment ID](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl#set-up-dbt-semantic-layer), and a [service token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens) or a [personal access token](https://docs.getdbt.com/docs/dbt-cloud-apis/user-tokens) to log in. This account should be set up with the Semantic Layer.
* You must have a dbt Starter or Enterprise-tier [account](https://www.getdbt.com/pricing). Suitable for both Multi-tenant and Single-tenant deployment.

📹 Learn about the dbt Semantic Layer with on-demand video courses!

Explore our [dbt Semantic Layer on-demand course](https://learn.getdbt.com/courses/semantic-layer) to learn how to define and query metrics in your dbt project.

Additionally, dive into mini-courses for querying the dbt Semantic Layer in your favorite tools: [Tableau](https://courses.getdbt.com/courses/tableau-querying-the-semantic-layer), [Excel](https://learn.getdbt.com/courses/querying-the-semantic-layer-with-excel), [Hex](https://courses.getdbt.com/courses/hex-querying-the-semantic-layer), and [Mode](https://courses.getdbt.com/courses/mode-querying-the-semantic-layer).

## Installing the connector[​](#installing-the-connector "Direct link to Installing the connector")

The Semantic Layer Tableau connector is available to download directly on [Tableau Exchange](https://exchange.tableau.com/products/1020). The connector is supported in Tableau Desktop, Tableau Server, and Tableau Cloud.

Alternatively, you can follow these steps to install the connector. Note that these steps only apply to Tableau Desktop and Tableau Server. The connector for Tableau Cloud is managed by Tableau.

1. Download the GitHub [connector file](https://github.com/dbt-labs/semantic-layer-tableau-connector/releases/latest/download/dbt_semantic_layer.taco) locally and add it to your default folder:

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Operating system Tableau Desktop Tableau Server|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Windows `C:\Users\\[Windows User]\Documents\My Tableau Repository\Connectors` `C:\Program Files\Tableau\Connectors`| Mac `/Users/[user]/Documents/My Tableau Repository/Connectors` Not applicable|  |  |  | | --- | --- | --- | | Linux `/opt/tableau/connectors` `/opt/tableau/connectors` | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

2. Install the [JDBC driver](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-jdbc) to the folder based on your operating system:
   * Windows: `C:\Program Files\Tableau\Drivers`
   * Mac: `~/Library/Tableau/Drivers` or `/Library/JDBC` or `~/Library/JDBC`
   * Linux:  `/opt/tableau/tableau_driver/jdbc`
3. Open Tableau Desktop or Tableau Server and find the **Semantic Layer by dbt Labs** connector on the left-hand side. You may need to restart these applications for the connector to be available.
4. Connect with your Host, Environment ID, and service or personal token information dbt provides during the [Semantic Layer configuration](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl).
   * In Tableau Server, the authentication screen may show "User" & "Password" instead, in which case the User is the Environment ID and the password is the Service Token.

## Using the integration[​](#using-the-integration "Direct link to Using the integration")

1. **Authentication** — Once you authenticate, the system will direct you to the data source page.
2. **Access all Semantic Layer Objects** — Use the "ALL" data source to access all the metrics, dimensions, and entities configured in your Semantic Layer. Note that the "METRICS\_AND\_DIMENSIONS" data source has been deprecated and replaced by "ALL". Be sure to use a live connection since extracts are not supported at this time.
3. **Access saved queries** — You can optionally access individual [saved queries](https://docs.getdbt.com/docs/build/saved-queries) that you've defined. These will also show up as unique data sources when you log in.
4. **Access worksheet** — From your data source selection, go directly to a worksheet in the bottom left-hand corner.
5. **Query metrics and dimensions** — Then, you'll find all the metrics, dimensions, and entities that are available to query on the left side of your window based on your selection.

Visit the [Tableau documentation](https://help.tableau.com/current/pro/desktop/en-us/gettingstarted_overview.htm) to learn more about how to use Tableau worksheets and dashboards.

### Publish from Tableau Desktop to Tableau Server[​](#publish-from-tableau-desktop-to-tableau-server "Direct link to Publish from Tableau Desktop to Tableau Server")

* **From Desktop to Server** — Like any Tableau workflow, you can publish your workbook from Tableau Desktop to Tableau Server. For step-by-step instructions, visit Tableau's [publishing guide](https://help.tableau.com/current/pro/desktop/en-us/publish_workbooks_share.htm).

## Things to note[​](#things-to-note "Direct link to Things to note")

**Aggregation**

* All metrics are shown as using the "SUM" aggregation type in Tableau's UI, and this cannot be altered using Tableau's interface.
* The Semantic Layer controls the aggregation type in code and it is intentionally fixed. Keep in mind that the underlying aggregation in the Semantic Layer might not be "SUM" ("SUM" is Tableau's default).

**Data sources and display**

* In the "ALL" data source, Tableau surfaces all metrics and dimensions from the Semantic Layer on the left-hand side. Note, that not all metrics and dimensions can be combined. You will receive an error message if a particular dimension cannot be sliced with a metric (or vice versa). You can use saved queries for smaller pieces of data that you want to combine.
* To display available metrics and dimensions, Semantic Layer returns metadata for a fake table with the dimensions and metrics as 'columns' on this table. Because of this, you can't actually query this table for previews or extracts.

**Calculations and querying**

* Certain Table calculations like "Totals" and "Percent Of" may not be accurate when using metrics aggregated in a non-additive way (such as count distinct)
* In any of our Semantic Layer interfaces (not only Tableau), you must include a [time dimension](https://docs.getdbt.com/docs/build/cumulative#limitations) when working with any cumulative metric that has a time window or granularity.
* We can support calculated fields for creating parameter filters or dynamically selecting metrics and dimensions. However, other uses of calculated fields are not supported.
  + *Note: For calculated field use cases that are not currently covered, please reach out to [dbt Support](mailto:support@getdbt.com?subject=dbt Semantic Layer feedback) and share them so we can further understand.*
* When using saved queries that include filters, we will automatically apply any filters that the query has.

## Unsupported functionality[​](#unsupported-functionality "Direct link to Unsupported functionality")

The following Tableau features aren't supported at this time, however, the Semantic Layer may support some of this functionality in a future release:

* Updating the data source page
* Using "Extract" mode to view your data
* Unioning Tables
* Writing Custom SQL / Initial SQL
* Table Extensions
* Cross-Database Joins
* Some functions in Analysis --> Create Calculated Field
* Filtering on a Date Part time dimension for a Cumulative metric type
* Changing your date dimension to use "Week Number"
* Performing joins between tables that the Semantic Layer creates. It handles joins for you, so there's no need to join components in the Semantic Layer. Note, that you *can* join tables from the Semantic Layer to ones outside your data platform.
* The Tableau integration doesn't currently display descriptive labels defined in your `metrics` configuration, meaning custom labels won't be visible when those metrics are imported/queried into Tableau.

## FAQs[​](#faqs "Direct link to FAQs")

I'm receiving an `Failed ALPN` error when trying to connect to the dbt Semantic Layer.

If you're receiving a `Failed ALPN` error when trying to connect the dbt Semantic Layer with the various [data integration tools](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations) (such as Tableau, DBeaver, Datagrip, ADBC, or JDBC), it typically happens when connecting from a computer behind a corporate VPN or Proxy (like Zscaler or Check Point).

The root cause is typically the proxy interfering with the TLS handshake as the Semantic Layer uses gRPC/HTTP2 for connectivity. To resolve this:

* If your proxy supports gRPC/HTTP2 but isn't configured to allow ALPN, adjust its settings accordingly to allow ALPN. Or create an exception for the dbt domain.
* If your proxy does not support gRPC/HTTP2, add an SSL interception exception for the dbt domain in your proxy settings

This should help in successfully establishing the connection without the Failed ALPN error.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Power BI](https://docs.getdbt.com/docs/cloud-integrations/semantic-layer/power-bi)[Next

Available dbt versions](https://docs.getdbt.com/docs/dbt-versions/about-versions)

* [Prerequisites](#prerequisites)* [Installing the connector](#installing-the-connector)* [Using the integration](#using-the-integration)
      + [Publish from Tableau Desktop to Tableau Server](#publish-from-tableau-desktop-to-tableau-server)* [Things to note](#things-to-note)* [Unsupported functionality](#unsupported-functionality)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud-integrations/semantic-layer/tableau.md)
