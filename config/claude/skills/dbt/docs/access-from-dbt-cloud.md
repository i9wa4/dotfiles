---
title: "Access Catalog from dbt platform features | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/explore/access-from-dbt-cloud"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Explore your data](https://docs.getdbt.com/docs/explore/explore-your-data)* [Discover data with dbt Catalog](https://docs.getdbt.com/docs/explore/explore-projects)* Access from dbt platform

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Faccess-from-dbt-cloud+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Faccess-from-dbt-cloud+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Faccess-from-dbt-cloud+so+I+can+ask+questions+about+it.)

On this page

Access Catalog from other features and products inside dbt, ensuring you have a seamless experience navigating between resources and lineage in your project.

This page explains how to access Catalog from various dbt features, including the Studio IDE and jobs. While the primary way to navigate to Catalog is through the **Explore** link in the navigation, you can also access it from other dbt features.

### Studio IDE[​](#studio-ide "Direct link to Studio IDE")

You can enhance your project navigation and editing experience by directly accessing resources from the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) to Catalog for model, seed, or snapshot files. This workflow offers a seamless transition between the Studio IDE and Catalog, allowing you to quickly navigate between viewing project metadata and making updates to your models or other resources without switching contexts.

#### Access Catalog from the IDE[​](#access-catalog-from-the-ide "Direct link to Access Catalog from the IDE")

* In your model, seed, or snapshot file, click the **View in Catalog** icon to the right of your file breadcrumb (under the file name tab).
* This opens the model, seed, or snapshot file in a new tab, allowing you to view resources/lineage directly in Catalog.

[![Access dbt Catalog from the IDE by clicking on the 'View in Explorer' icon next to the file breadcrumbs. ](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/explorer-from-ide.jpg?v=2 "Access dbt Catalog from the IDE by clicking on the 'View in Explorer' icon next to the file breadcrumbs. ")](#)Access dbt Catalog from the IDE by clicking on the 'View in Explorer' icon next to the file breadcrumbs.

### Canvas[​](#canvas "Direct link to Canvas")

Seamlessly access Catalog via Canvas to bring your workflow to life with visual editing.

#### Access Catalog from Canvas[​](#access-catalog-from-canvas "Direct link to Access Catalog from Canvas")

Steps here
[Roxi to check with Greg and team and will add images on response]

### Lineage tab in jobs[​](#lineage-tab-in-jobs "Direct link to Lineage tab in jobs")

The **Lineage tab** in dbt jobs displays the lineage associated with the [job run](https://docs.getdbt.com/docs/deploy/jobs). Access Catalog directly from this tab, allowing you understand dependencies/relationships of resources in your project.

#### Access Catalog from the lineage tab[​](#access-catalog-from-the-lineage-tab "Direct link to Access Catalog from the lineage tab")

* From a job, select the **Lineage tab**.
* Double-click the node in the lineage to open a new tab and view its metadata directly in Catalog.

[![Access dbt Catalog from the lineage tab by double-clicking on the lineage node.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/explorer-from-lineage.gif?v=2 "Access dbt Catalog from the lineage tab by double-clicking on the lineage node.")](#)Access dbt Catalog from the lineage tab by double-clicking on the lineage node.

### Model timing tab in jobs [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#model-timing-tab-in-jobs- "Direct link to model-timing-tab-in-jobs-")

The [model timing tab](https://docs.getdbt.com/docs/deploy/run-visibility#model-timing) in dbt jobs displays the composition, order, and time taken by each model in a job run.

Access Catalog directly from the **modeling timing tab**, which helps you investigate resources, diagnose performance bottlenecks, understand dependencies/relationships of slow-running models, and potentially make changes to improve their performance.

#### Access Catalog from the model timing tab[​](#access-catalog-from-the-model-timing-tab "Direct link to Access Catalog from the model timing tab")

* From a job, select the **model timing tab**.
* Hover over a resource and click on **View on Catalog** to view the resource metadata directly in Catalog.

[![Access dbt Catalog from the model timing tab by hovering over the resource and clicking 'View in Explorer'.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/explorer-from-model-timing.jpg?v=2 "Access dbt Catalog from the model timing tab by hovering over the resource and clicking 'View in Explorer'.")](#)Access dbt Catalog from the model timing tab by hovering over the resource and clicking 'View in Explorer'.

### dbt Insights [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#dbt-insights- "Direct link to dbt-insights-")

Access Catalog directly from [Insights](https://docs.getdbt.com/docs/explore/access-dbt-insights) to view the project lineage and project resources with access to tables, columns, metrics, dimensions, and more.

To access Catalog from Insights, click on the **Catalog** icon in the Query console sidebar menu and search for the resource you're interested in.

[![dbt Insights integrated with dbt Catalog](https://docs.getdbt.com/img/docs/dbt-insights/insights-explorer.png?v=2 "dbt Insights integrated with dbt Catalog")](#)dbt Insights integrated with dbt Catalog

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Discover data with Catalog](https://docs.getdbt.com/docs/explore/explore-projects)[Next

Column-level lineage](https://docs.getdbt.com/docs/explore/column-level-lineage)

* [Studio IDE](#studio-ide)* [Canvas](#canvas)* [Lineage tab in jobs](#lineage-tab-in-jobs)* [Model timing tab in jobs](#model-timing-tab-in-jobs-) * [dbt Insights](#dbt-insights-)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/explore/access-from-dbt-cloud.md)
