---
title: "Google Sheets | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud-integrations/semantic-layer/gsheets"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt integrations](https://docs.getdbt.com/docs/cloud-integrations/overview)* [Semantic Layer integrations](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations)* Google Sheets

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fsemantic-layer%2Fgsheets+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fsemantic-layer%2Fgsheets+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fsemantic-layer%2Fgsheets+so+I+can+ask+questions+about+it.)

On this page

The Semantic Layer offers a seamless integration with Google Sheets through a custom menu. This add-on allows you to build Semantic Layer queries and return data on your metrics directly within Google Sheets

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You have [configured the Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl) and are using dbt v1.6 or higher.
* You need a Google account with access to Google Sheets and the ability to install Google add-ons.
* You have a [dbt Environment ID](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl#set-up-dbt-semantic-layer).
* You have a [service token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens) or a [personal access token](https://docs.getdbt.com/docs/dbt-cloud-apis/user-tokens) to authenticate with from a dbt account.
* You must have a dbt Starter or Enterprise-tier [account](https://www.getdbt.com/pricing). Suitable for both Multi-tenant and Single-tenant deployment.

If you're using [IP restrictions](https://docs.getdbt.com/docs/cloud/secure/ip-restrictions), ensure you've added [Google’s IP addresses](https://www.gstatic.com/ipranges/goog.txt) to your IP allowlist. Otherwise, the Google Sheets connection will fail.

📹 Learn about the dbt Semantic Layer with on-demand video courses!

Explore our [dbt Semantic Layer on-demand course](https://learn.getdbt.com/courses/semantic-layer) to learn how to define and query metrics in your dbt project.

Additionally, dive into mini-courses for querying the dbt Semantic Layer in your favorite tools: [Tableau](https://courses.getdbt.com/courses/tableau-querying-the-semantic-layer), [Excel](https://learn.getdbt.com/courses/querying-the-semantic-layer-with-excel), [Hex](https://courses.getdbt.com/courses/hex-querying-the-semantic-layer), and [Mode](https://courses.getdbt.com/courses/mode-querying-the-semantic-layer).

## Installing the add-on[​](#installing-the-add-on "Direct link to Installing the add-on")

1. Navigate to the [Semantic Layer for Sheets App](https://gsuite.google.com/marketplace/app/foo/392263010968) to install the add-on. You can also find it in Google Sheets by going to [**Extensions -> Add-on -> Get add-ons**](https://support.google.com/docs/answer/2942256?hl=en&co=GENIE.Platform%3DDesktop&oco=0#zippy=%2Cinstall-add-ons%2Cinstall-an-add-on) and searching for it there.
2. After installing, open the **Extensions** menu and select **Semantic Layer for Sheets**. This will open a custom menu on the right-hand side of your screen.
3. [Find your](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl#set-up-dbt-semantic-layer) **Host** and **Environment ID** in dbt.

   * Navigate to **Account Settings** and select **Projects** on the left sidebar.
   * Select your project and then navigate to the **Semantic Layer** settings. You'll need this to authenticate in Google Sheets in the following step.
   * You can generate your service token by clicking **Generate service token** within the Semantic Layer configuration page or navigating to **API tokens** in dbt. Alternatively, you can also create a personal access token by going to **API tokens** > **Personal tokens**.

     [![Access your Environment ID, Host, and URLs in your dbt Semantic Layer settings. Generate a service token in the Semantic Layer settings or API tokens settings](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/sl-and-gsheets.png?v=2 "Access your Environment ID, Host, and URLs in your dbt Semantic Layer settings. Generate a service token in the Semantic Layer settings or API tokens settings")](#)Access your Environment ID, Host, and URLs in your dbt Semantic Layer settings. Generate a service token in the Semantic Layer settings or API tokens settings
4. In Google Sheets, authenticate with your Host, dbt Environment ID, and service or personal token.
5. Start querying your metrics using the **Query Builder**. For more info on the menu functions, refer to [Query Builder functions](#query-builder-functions). To cancel a query while running, press the "Cancel" button.

When querying your data with Google Sheets:

* It returns the data to the cell you clicked on.* The custom menu operation has a timeout limit of six (6) minutes.* If you're using this extension, make sure you're signed into Chrome with the same Google profile you used to set up the Add-On. Log in with one Google profile at a time as using multiple Google profiles at once might cause issues.* Note that only standard granularities are currently available, custom time granularities aren't currently supported for this integration.

## Query Builder functions[​](#query-builder-functions "Direct link to Query Builder functions")

The Google Sheets **Query Builder** custom menu has the following capabilities:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Menu items Description|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Metrics Search and select metrics.|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Group By Search and select dimensions or entities to group by. Dimensions are grouped by the entity of the semantic model they come from. You may choose dimensions on their own without metrics.|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | Time Range Quickly select time ranges to look at the data, which applies to the main time series for the metrics (metric time), or do more advanced filter using the "Custom" selection.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Where Filter your data. This includes categorical and time filters.|  |  |  |  | | --- | --- | --- | --- | | Order By Return your data order.|  |  | | --- | --- | | Limit Set a limit for the rows of your output. | | | | | | | | | | | | | |

Note: Click the **info** button next to any metric or dimension to see its defined description from your dbt project.

#### Modifying time granularity[​](#modifying-time-granularity "Direct link to Modifying time granularity")

When you select time dimensions in the **Group By** menu, you'll see a list of available time granularities. The lowest granularity is selected by default. Metric time is the default time dimension for grouping your metrics.

info

Note: [Custom time granularities](https://docs.getdbt.com/docs/build/metricflow-time-spine#add-custom-granularities) (like fiscal year) aren't currently supported or accessible in this integration. Only [standard granularities](https://docs.getdbt.com/docs/build/dimensions?dimension=time_gran#time) (like day, week, month, and so on) are available. If you'd like to access custom granularities, consider using the [Semantic Layer APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-api-overview).

#### Filtering data[​](#filtering-data "Direct link to Filtering data")

To use the filter functionality, choose the [dimension](https://docs.getdbt.com/docs/build/dimensions) you want to filter by and select the operation you want to filter on.

* For categorical dimensions, you can type a value into search or select from a populated list.* For entities, you must type the value you are looking for as we do not load all of them given the large number of values.* Continue adding additional filters as needed with AND and OR.* For time dimensions, you can use the time range selector to filter on presets or custom options. The time range selector applies only to the primary time dimension (`metric_time`). For all other time dimensions that aren't `metric_time`, you can use the "Where" option to apply filters.

#### Other settings[​](#other-settings "Direct link to Other settings")

If you would like to just query the data values without the headers, you can optionally select the **Exclude column names** box.

To return your results and keep any previously selected data below it intact, un-select the **Clear trailing rows** box. By default, we'll clear all trailing rows if there's stale data.

[![Run a query in the Query Builder. Use the arrow next to the Query button to select additional settings.](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/query-builder.png?v=2 "Run a query in the Query Builder. Use the arrow next to the Query button to select additional settings.")](#)Run a query in the Query Builder. Use the arrow next to the Query button to select additional settings.

## Using saved selections[​](#using-saved-selections "Direct link to Using saved selections")

Saved selections allow you to save the inputs you've created in the Google Sheets **Query Builder** and easily access them again so you don't have to continuously build common queries from scratch. To create a saved selection:

1. Run a query in the **Query Builder**.- Save the selection by selecting the arrow next to the **Query** button and then select **Query & Save Selection**.- The application saves these selections, allowing you to view and edit them from the hamburger menu under **Saved Selections**.

You can also make these selections private or public. Public selections mean your inputs are available in the menu to everyone on the sheet.
Private selections mean your inputs are only visible to you. Note that anyone added to the sheet can still see the data from these private selections, but they won't be able to interact with the selection in the menu or benefit from the automatic refresh.

### Refreshing selections[​](#refreshing-selections "Direct link to Refreshing selections")

Set your saved selections to automatically refresh every time you load the addon. You can do this by selecting **Refresh on Load** when creating the saved selection. When you access the addon and have saved selections that should refresh, you'll see "Loading..." in the cells that are refreshing.

Public saved selections will refresh for anyone who edits the sheet.

What's the difference between saved selections and saved queries?

* Saved selections are saved components that you can create only when using the application.
* Saved queries, explained in the next section, are code-defined sections of data you create in your dbt project that you can easily access and use for building selections. You can also use the results from a saved query to create a saved selection.

## Using saved queries[​](#using-saved-queries "Direct link to Using saved queries")

Access [saved queries](https://docs.getdbt.com/docs/build/saved-queries), powered by MetricFlow, in Google Sheets to quickly get results from pre-defined sets of data. To access the saved queries in Google Sheets:

1. Open the hamburger menu in Google Sheets.- Navigate to **Saved Queries** to access the ones available to you.- You can also select **Build Selection**, which allows you to explore the existing query. This won't change the original query defined in the code.
     * If you use a `WHERE` filter in a saved query, Google Sheets displays the advanced syntax for this filter.

**Limited use policy disclosure**

The Semantic Layer for Sheet's use and transfer to any other app of information received from Google APIs will adhere to [Google API Services User Data Policy](https://developers.google.com/terms/api-services-user-data-policy), including the Limited Use requirements.

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

Available integrations](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations)[Next

Microsoft Excel](https://docs.getdbt.com/docs/cloud-integrations/semantic-layer/excel)

* [Prerequisites](#prerequisites)* [Installing the add-on](#installing-the-add-on)* [Query Builder functions](#query-builder-functions)* [Using saved selections](#using-saved-selections)
        + [Refreshing selections](#refreshing-selections)* [Using saved queries](#using-saved-queries)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud-integrations/semantic-layer/gsheets.md)
