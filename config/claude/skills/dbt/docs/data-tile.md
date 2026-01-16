---
title: "Data health tile | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/explore/data-tile"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Explore your data](https://docs.getdbt.com/docs/explore/explore-your-data)* [Discover data with dbt Catalog](https://docs.getdbt.com/docs/explore/explore-projects)* [Model consumption](https://docs.getdbt.com/docs/explore/view-downstream-exposures)* Data health tile

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fdata-tile+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fdata-tile+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fdata-tile+so+I+can+ask+questions+about+it.)

On this page

With data health tiles, stakeholders will get an at-a-glance confirmation on whether the data they’re looking at is stale or degraded. It allows teams to immediately go back into Catalog to see more details and investigate issues.

The data health tile:

* Distills [data health signals](https://docs.getdbt.com/docs/explore/data-health-signals) for data consumers.
* Deep links you into Catalog where you can further dive into upstream data issues.
* Provides richer information and makes it easier to debug.
* Revamps the existing, [job-based tiles](#job-based-data-health).

Data health tiles rely on [exposures](https://docs.getdbt.com/docs/build/exposures) to surface data health signals in your dashboards. An exposure defines how specific outputs — like dashboards or reports — depend on your data models. Exposures in dbt can be configured in two ways:

* Manual — Defined [manually](https://docs.getdbt.com/docs/build/exposures#declaring-an-exposure) and explicitly in your project’s YAML files.
* Automatic — Pulled automatically for supported dbt integrations. dbt automatically [creates and visualizes downstream exposures](https://docs.getdbt.com/docs/cloud-integrations/downstream-exposures), removing the need for manual YAML definitions. These downstream exposures are stored in dbt’s metadata system, appear in [Catalog](https://docs.getdbt.com/docs/explore/explore-projects), and behave like manual exposures, however they don’t exist in YAML files.

[![Example of passing Data health tile in your dashboard.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/data-tile-pass.jpg?v=2 "Example of passing Data health tile in your dashboard.")](#)Example of passing Data health tile in your dashboard.

[![Embed data health tiles in your dashboards to distill data health signals for data consumers.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/data-tiles.png?v=2 "Embed data health tiles in your dashboards to distill data health signals for data consumers.")](#)Embed data health tiles in your dashboards to distill data health signals for data consumers.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You must have a dbt account on an [Enterprise-tier plan](https://www.getdbt.com/pricing/).
* You must be an account admin to set up [service tokens](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens#permissions-for-service-account-tokens).
* You must have [develop permissions](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users).
* You have [exposures](https://docs.getdbt.com/docs/build/exposures) defined in your project:
  + If using manual exposures, they must be explicitly defined in your YAML files.
  + If using automatic downstream exposures, ensure your BI tool is [configured](https://docs.getdbt.com/docs/cloud-integrations/downstream-exposures-tableau) with dbt.
* You have [source freshness](https://docs.getdbt.com/docs/deploy/source-freshness) enabled in the job that generates this exposure.
* The exposure used for the data health tile must have the [`type` property](https://docs.getdbt.com/docs/build/exposures#available-properties) set to `dashboard`. Otherwise, you won't be able to view the **Embed data health tile in your dashboard** dropdown in Catalog.

## View exposure in dbt Catalog[​](#view-exposure-in-dbt-catalog "Direct link to View exposure in dbt Catalog")

First, be sure to enable [source freshness](https://docs.getdbt.com/docs/deploy/source-freshness) in the job that generates this exposure.

1. Navigate to Catalog by clicking on the **Explore** link in the navigation.
2. In the main **Overview** page, go to the left navigation.
3. Under the **Resources** tab, click on **Exposures** to view the [exposures](https://docs.getdbt.com/docs/build/exposures) list.
4. Select a dashboard exposure and go to the **General** tab to view the data health information.
5. In this tab, you’ll see:
   * Name of the exposure.
   * Data health status: Data freshness passed, Data quality passed, Data may be stale, Data quality degraded.
   * Resource type (model, source, and so on).
   * Dashboard status: Failure, Pass, Stale.
   * You can also see the last check completed, the last check time, and the last check duration.
6. You can click the **Open Dashboard** button on the upper right to immediately view this in your analytics tool.

[![View an exposure in dbt Catalog.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/data-tile-exposures.jpg?v=2 "View an exposure in dbt Catalog.")](#)View an exposure in dbt Catalog.

## Embed in your dashboard[​](#embed-in-your-dashboard "Direct link to Embed in your dashboard")

Once you’ve navigated to the exposure in Catalog, you’ll need to set up your data health tile and [service token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens). You can embed data health tile to any analytics tool that supports URL or iFrame embedding.

Follow these steps to set up your data health tile:

1. Go to **Account settings** in dbt.
2. Select **API tokens** in the left sidebar and then **Service tokens**.
3. Click on **Create service token** and give it a name.
4. Select the [**Metadata Only**](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens) permission. This token will be used to embed the tile in your dashboard in the later steps.

[![Set up your dashboard status tile and service token to embed a data health tile](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/data-tile-setup.jpg?v=2 "Set up your dashboard status tile and service token to embed a data health tile")](#)Set up your dashboard status tile and service token to embed a data health tile

5. Copy the **Metadata Only** token and save it in a secure location. You'll need it token in the next steps.
6. Navigate back to Catalog and select an exposure.

   tip

   The exposure used for the data health tile must have the [`type` property](https://docs.getdbt.com/docs/build/exposures#available-properties) set to `dashboard`. Otherwise, you won't be able to view the **Embed data health tile in your dashboard** dropdown in Catalog.
7. Below the **Data health** section, expand on the toggle for instructions on how to embed the exposure tile (if you're an account admin with develop permissions).
8. In the expanded toggle, you'll see a text field where you can paste your **Metadata Only token**.

[![Expand the toggle to embed data health tile into your dashboard.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/data-tile-example.jpg?v=2 "Expand the toggle to embed data health tile into your dashboard.")](#)Expand the toggle to embed data health tile into your dashboard.

9. Once you’ve pasted your token, you can select either **URL** or **iFrame** depending on which you need to add to your dashboard.

If your analytics tool supports iFrames, you can embed the dashboard tile within it.

## Examples[​](#examples "Direct link to Examples")

The following examples show how to embed the data health tile in PowerBI, Tableau, and Sigma.

* PowerBI example* Tableau example* Sigma example

You can embed the data health tile iFrame in PowerBI using PowerBI Pro Online, Fabric PowerBI, or PowerBI Desktop.

[![Embed data health tile iFrame in PowerBI](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/power-bi.png?v=2 "Embed data health tile iFrame in PowerBI")](#)Embed data health tile iFrame in PowerBI

Follow these steps to embed the data health tile in PowerBI:

1. Create a dashboard in PowerBI and connect to your database to pull in the data.
2. Create a new PowerBI measure by right-clicking on your **Data**, **More options**, and then **New measure**.

[![Create a new PowerBI measure.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/power-bi-measure.png?v=2 "Create a new PowerBI measure.")](#)Create a new PowerBI measure.

3. Navigate to Catalog, select the exposure, and expand the [**Embed data health into your dashboard**](https://docs.getdbt.com/docs/explore/data-tile#embed-in-your-dashboard) toggle.
4. Go to the **iFrame** tab and copy the iFrame code. Make sure the Metadata Only token is already set up.
5. In PowerBI, paste the iFrame code you copied into your measure calculation window. The iFrame code should look like this:

   ```
   <iframe src='https://1234.metadata.ACCESS_URL/exposure-tile?uniqueId=exposure.EXPOSURE_NAME&environmentType=staging&environmentId=123456789&token=YOUR_METADATA_TOKEN' title='Exposure status tile' height='400'></iframe>
   ```

   [![In the 'Measure tools' tab, replace your values with the iFrame code.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/power-bi-measure-tools.png?v=2 "In the 'Measure tools' tab, replace your values with the iFrame code.")](#)In the 'Measure tools' tab, replace your values with the iFrame code.
6. PowerBI desktop doesn't support HTML rendering by default, so you need to install an HTML component from the PowerBI Visuals Store.
7. To do this, go to **Build visuals** and then **Get more visuals**.
8. Login with your PowerBI account.
9. There are several third-party HTML visuals. The one tested for this guide is [HTML content](https://appsource.microsoft.com/en-us/product/power-bi-visuals/WA200001930?tab=Overview). Install it, but please keep in mind it's a third-party plugin not created or supported by dbt Labs.
10. Drag the metric with the iFrame code into the HTML content widget in PowerBI. This should now display your data health tile.

[![Drag the metric with the iFrame code into the HTML content widget in PowerBI. This should now display your data health tile.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/power-bi-final.png?v=2 "Drag the metric with the iFrame code into the HTML content widget in PowerBI. This should now display your data health tile.")](#)Drag the metric with the iFrame code into the HTML content widget in PowerBI. This should now display your data health tile.

*Refer to [this tutorial](https://www.youtube.com/watch?v=SUm9Hnq8Th8) for additional information on embedding a website into your Power BI report.*

Follow these steps to embed the data health tile in Tableau:

[![Embed data health tile iFrame in Tableau](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/tableau-example.png?v=2 "Embed data health tile iFrame in Tableau")](#)Embed data health tile iFrame in Tableau

1. Create a dashboard in Tableau and connect to your database to pull in the data.
2. Ensure you've copied the URL or iFrame snippet available in Catalog's **Data health** section, under the **Embed data health into your dashboard** toggle.
3. Insert a **Web Page** object.
4. Insert the URL and click **Ok**.

   ```
   https://metadata.ACCESS_URL/exposure-tile?uniqueId=exposure.EXPOSURE_NAME&environmentType=production&environmentId=220370&token=<YOUR_METADATA_TOKEN>
   ```

   *Note, replace the placeholders with your actual values.*
5. You should now see the data health tile embedded in your Tableau dashboard.

Follow these steps to embed the data health tile in Sigma:

[![Embed data health tile in Sigma](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/sigma-example.jpg?v=2 "Embed data health tile in Sigma")](#)Embed data health tile in Sigma

1. Create a dashboard in Sigma and connect to your database to pull in the data.
2. Ensure you've copied the URL or iFrame snippet available in Catalog's **Data health** section, under the **Embed data health into your dashboard** toggle.
3. Add a new embedded UI element in your Sigma Workbook in the following format:

   ```
   https://metadata.ACCESS_URL/exposure-tile?uniqueId=exposure.EXPOSURE_NAME&environmentType=production&environmentId=ENV_ID_NUMBER&token=<YOUR_METADATA_TOKEN>
   ```

   *Note, replace the placeholders with your actual values.*
4. You should now see the data health tile embedded in your Sigma dashboard.

## Job-based data health Legacy[​](#job-based-data-health- "Direct link to job-based-data-health-")

The default experience is the [environment-based data health tile](#view-exposure-in-dbt-explorer) with Catalog.

This section is for legacy job-based data health tiles. If you're using the revamped environment-based exposure tile, refer to the previous section. Expand the following to learn more about the legacy job-based data health tile.

 Job-based data health

In dbt, the [Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api) can power dashboard status tiles, which are job-based. A dashboard status tile is placed on a dashboard (specifically: anywhere you can embed an iFrame) to give insight into the quality and freshness of the data feeding into that dashboard. This is done in dbt [exposures](https://docs.getdbt.com/docs/build/exposures).

#### Functionality[​](#functionality "Direct link to Functionality")

The dashboard status tile looks like this:

[![](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/dashboard-status-tiles/passing-tile.jpeg?v=2)](#)

The data freshness check fails if any sources feeding into the exposure are stale. The data quality check fails if any dbt tests fail. A failure state could look like this:

[![](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/dashboard-status-tiles/failing-tile.jpeg?v=2)](#)

Clicking into **see details** from the Dashboard Status Tile takes you to a landing page where you can learn more about the specific sources, models, and tests feeding into this exposure.

#### Setup[​](#setup "Direct link to Setup")

First, be sure to enable [source freshness](https://docs.getdbt.com/docs/deploy/source-freshness) in the job that generates this exposure.

In order to set up your dashboard status tile, here is what you need:

1. **Metadata Only token.** You can learn how to set up a Metadata-Only token [here](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens).
2. **Exposure name.** You can learn more about how to set up exposures [here](https://docs.getdbt.com/docs/build/exposures).
3. **Job iD.** Remember that you can select your job ID directly from the URL when looking at the relevant job in dbt.

You can insert these three fields into the following iFrame, and then embed it **anywhere that you can embed an iFrame**:

```
<iframe src='https://metadata.YOUR_ACCESS_URL/exposure-tile?name=<exposure_name>&jobId=<job_id>&token=<metadata_only_token>' title='Exposure Status Tile'></iframe>
```

Replace `YOUR_ACCESS_URL` with your region and plan's Access URL

dbt is hosted in multiple regions in the world and each region has a different access URL. Replace `YOUR_ACCESS_URL` with the appropriate [Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan. For example, if your account is hosted in the EMEA region, you would use the following iFrame code:

```
<iframe src='https://metadata.emea.dbt.com/exposure-tile?name=<exposure_name>&jobId=<job_id>&token=<metadata_only_token>' title='Exposure Status Tile'></iframe>
```

#### Embedding with BI tools[​](#embedding-with-bi-tools "Direct link to Embedding with BI tools")

The dashboard status tile should work anywhere you can embed an iFrame. But below are some tactical tips on how to integrate with common BI tools.

* Mode* Looker* Tableau* Sigma

#### Mode[​](#mode "Direct link to Mode")

Mode allows you to directly [edit the HTML](https://mode.com/help/articles/report-layout-and-presentation/#html-editor) of any given report, where you can embed the iFrame.

Note that Mode has also built its own [integration](https://mode.com/get-dbt/) with the dbt Discovery API!

#### Looker[​](#looker "Direct link to Looker")

Looker does not allow you to directly embed HTML and instead requires creating a [custom visualization](https://docs.looker.com/admin-options/platform/visualizations). One way to do this for admins is to:

* Add a [new visualization](https://fishtown.looker.com/admin/visualizations) on the visualization page for Looker admins. You can use [this URL](https://metadata.cloud.getdbt.com/static/looker-viz.js) to configure a Looker visualization powered by the iFrame. It will look like this:

[![Configure a Looker visualization powered by the iFrame](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/dashboard-status-tiles/looker-visualization.jpeg?v=2 "Configure a Looker visualization powered by the iFrame")](#)Configure a Looker visualization powered by the iFrame

* Once you have set up your custom visualization, you can use it on any dashboard! You can configure it with the exposure name, job ID, and token relevant to that dashboard.

[![](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/dashboard-status-tiles/custom-looker.jpeg ?v=2)](#)

#### Tableau[​](#tableau "Direct link to Tableau")

Tableau does not require you to embed an iFrame. You only need to use a Web Page object on your Tableau Dashboard and a URL in the following format:

```
https://metadata.YOUR_ACCESS_URL/exposure-tile?name=<exposure_name>&jobId=<job_id>&token=<metadata_only_token>
```

Replace `YOUR_ACCESS_URL` with your region and plan's Access URL

dbt is hosted in multiple regions in the world and each region has a different access URL. Replace `YOUR_ACCESS_URL` with the appropriate [Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan. For example, if your account is hosted in the North American region, you would use the following code:

```
https://metadata.cloud.getdbt.com/exposure-tile?name=<exposure_name>&jobId=<job_id>&token=<metadata_only_token>
```

[![Configure Tableau by using a Web page object.](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/dashboard-status-tiles/tableau-object.png?v=2 "Configure Tableau by using a Web page object.")](#)Configure Tableau by using a Web page object.

#### Sigma[​](#sigma "Direct link to Sigma")

Sigma does not require you to embed an iFrame. Add a new embedded UI element in your Sigma Workbook in the following format:

```
https://metadata.YOUR_ACCESS_URL/exposure-tile?name=<exposure_name>&jobId=<job_id>&token=<metadata_only_token>
```

Replace `YOUR_ACCESS_URL` with your region and plan's Access URL

dbt is hosted in multiple regions in the world and each region has a different access URL. Replace `YOUR_ACCESS_URL` with the appropriate [Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan. For example, if your account is hosted in the APAC region, you would use the following code:

```
https://metadata.au.dbt.com/exposure-tile?name=<exposure_name>&jobId=<job_id>&token=<metadata_only_token>
```

[![Configure Sigma by using an embedded UI element.](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/dashboard-status-tiles/sigma-embed.gif?v=2 "Configure Sigma by using an embedded UI element.")](#)Configure Sigma by using an embedded UI element.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Visualize downstream exposures](https://docs.getdbt.com/docs/explore/view-downstream-exposures)[Next

Model query history](https://docs.getdbt.com/docs/explore/model-query-history)

* [Prerequisites](#prerequisites)* [View exposure in dbt Catalog](#view-exposure-in-dbt-catalog)* [Embed in your dashboard](#embed-in-your-dashboard)* [Examples](#examples)* [Job-based data health](#job-based-data-health-)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/explore/data-tile.md)
