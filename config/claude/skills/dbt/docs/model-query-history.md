---
title: "Model query history | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/explore/model-query-history"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Explore your data](https://docs.getdbt.com/docs/explore/explore-your-data)* [Discover data with dbt Catalog](https://docs.getdbt.com/docs/explore/explore-projects)* [Model consumption](https://docs.getdbt.com/docs/explore/view-downstream-exposures)* Model query history

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fmodel-query-history+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fmodel-query-history+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fmodel-query-history+so+I+can+ask+questions+about+it.)

On this page

Model query history helps data teams track model usage by analyzing query logs.

Model query history allows you to:

* View the count of consumption queries for a model based on the data warehouse's query logs.
* Provides data teams insight, so they can focus their time and infrastructure spend on the worthwhile used data products.
* Enable analysts to find the most popular models used by other people.

Model query history is powered by a single consumption query of the query log table in your data warehouse aggregated on a daily basis.

 What is a consumption query?

Consumption query is a metric of queries in your dbt project that has used the model in a given time. It filters down to `select` statements only to gauge model consumption and excludes dbt model build and test executions.

So for example, if `model_super_santi` was queried 10 times in the past week, it would count as having 10 consumption queries for that particular time period.

Support for Snowflake (Enterprise tier or higher) and BigQuery

Model query history for Snowflake users is **only available for Enterprise tier or higher**. The feature also supports BigQuery. Additional platforms coming soon.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

To access the features, you should meet the following:

1. You have a dbt account on an [Enterprise-tier plan](https://www.getdbt.com/pricing/). Single-tenant accounts should contact their account representative for setup.
2. You have set up a [production](https://docs.getdbt.com/docs/deploy/deploy-environments#set-as-production-environment) deployment environment for each project you want to explore, with at least one successful job run.
3. You have [admin permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) in dbt to edit project settings or production environment settings.
4. Use Snowflake or BigQuery as your data warehouse and can enable [query history permissions](#snowflake-model-query-history) or work with an admin to do so. Support for additional data platforms coming soon.
   * For Snowflake users: You **must** have a Snowflake Enterprise tier or higher subscription.

## Enable query history in dbt[​](#enable-query-history-in-dbt "Direct link to Enable query history in dbt")

To enable model query history in dbt, follow these steps:

1. Navigate to **Orchestration** and then **Environments**.
2. Select the environment marked **PROD** and click **Settings**.
3. Click **Edit** and scroll to the **Query History** section.
4. Click the **Test Permissions** button to validate the deployment credentials permissions are sufficient to support query history.
5. Click the **Enable query history** box to enable.
6. **Save** your settings.

dbt automatically enables query history for brand new environments. If query history fails to retrieve data, dbt automatically disables it to prevent unintended warehouse costs.

* If the failure is temporary (like a network timeout), dbt may retry.
* If the problem keeps happening (for example, missing permissions), dbt turns off query history so customers don’t waste warehouse compute.

To turn it back on, click **Test Permissions** in **Environment settings**. If the test succeeds, dbt re-enables the environment.

[![Enable query history in your environment settings.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/enable-query-history.png?v=2 "Enable query history in your environment settings.")](#)Enable query history in your environment settings.

## Credential permissions[​](#credential-permissions "Direct link to Credential permissions")

This section explains the permissions and steps you need to enable and view model query history in Catalog.

The model query history feature uses the credentials in your production environment to gather metadata from your data warehouse’s query logs. This means you may need elevated permissions with the warehouse. Before making any changes to your data platform permissions, confirm the configured permissions in dbt:

1. Navigate to **Deploy** and then **Environments**.
2. Select the Environment marked **PROD** and click **Settings**.
3. Look at the information under **Deployment credentials**.
   * Note: Querying query history entails warehouse costs / uses credits.

[![Confirm your deployment credentials in your environment settings page.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/model-query-credentials.jpg?v=2 "Confirm your deployment credentials in your environment settings page.")](#)Confirm your deployment credentials in your environment settings page.

4. Copy or cross reference those credential permissions with the warehouse permissions and grant your user the right permissions.

#### Snowflake model query history[​](#snowflake-model-query-history "Direct link to Snowflake model query history")

Model query history makes use of metadata tables available to [Snowflake Enterprise tier](https://docs.snowflake.com/en/user-guide/intro-editions#enterprise-edition) accounts or higher, `QUERY_HISTORY` and `ACCESS_HISTORY`. The Snowflake user in the production environment must have the `GOVERNANCE_VIEWER` permission to view the data.
Before enabling Model query history, your `ACCOUNTADMIN` must run the following grant statement in Snowflake to ensure for access:

```
GRANT DATABASE ROLE SNOWFLAKE.GOVERNANCE_VIEWER TO ROLE <YOUR_DBT_CLOUD_DEPLOYMENT_ROLE>;
```

Without this grant, model query history won't display any data. For more details, view the snowflake docs [here](https://docs.snowflake.com/en/sql-reference/account-usage#enabling-other-roles-to-use-schemas-in-the-snowflake-database).

#### BigQuery model query history[​](#bigquery-model-query-history "Direct link to BigQuery model query history")

The model query history uses metadata from the [`INFORMATION_SCHEMA.JOBS` view](https://docs.cloud.google.com/bigquery/docs/information-schema-jobs) in BigQuery. To access the metadata, the production environment user must have the correct [IAM role](https://docs.cloud.google.com/bigquery/docs/access-control#bigquery.resourceViewer) or permission to access this data:

* If you use a BigQuery provided role, we recommend `roles/bigquery.resourceViewer`.
* If you use a custom role, ensure it includes the `bigquery.jobs.listAll permission`.

## View query history in Explorer[​](#view-query-history-in-explorer "Direct link to View query history in Explorer")

To enhance your discovery, you can view your model query history in various locations within Catalog:

* [View from Performance charts](#view-from-performance-charts)
* [View from Project lineage](#view-from-project-lineage)
* [View from Model list](#view-from-model-list)

### View from Performance charts[​](#view-from-performance-charts "Direct link to View from Performance charts")

1. Navigate to Catalog by clicking on the **Explore** link in the navigation.
2. In the main **Overview** page, click on **Performance** under the **Project details** section. Scroll down to view the **Most consumed models**.
3. Use the dropdown menu on the right to select the desired time period, with options available for up to the past 3 months.

[![View most consumed models on the 'Performance' page in dbt Catalog.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/most-consumed-models.jpg?v=2 "View most consumed models on the 'Performance' page in dbt Catalog.")](#)View most consumed models on the 'Performance' page in dbt Catalog.

4. Click on a model for more details and go to the **Performance** tab.
5. On the **Performance** tab, scroll down to the **Model performance** section.
6. Select the **Consumption queries** tab to view the consumption queries over a given time for that model.

[![View consumption queries over time for a given model.](https://docs.getdbt.com/img/docs/collaborate/model-consumption-queries.jpg?v=2 "View consumption queries over time for a given model.")](#)View consumption queries over time for a given model.

### View from Project lineage[​](#view-from-project-lineage "Direct link to View from Project lineage")

1. To view your model in your project lineage, go to the main **Overview page** and click on **Project lineage.**
2. In the lower left of your lineage, click on **Lenses** and select **Consumption queries**.

[![View model consumption queries in your lineage using the 'Lenses' feature.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/model-consumption-lenses.jpg?v=2 "View model consumption queries in your lineage using the 'Lenses' feature.")](#)View model consumption queries in your lineage using the 'Lenses' feature.

3. Your lineage should display a small red box above each model, indicating the consumption query number. The number for each model represents the model consumption over the last 30 days.

### View from Model list[​](#view-from-model-list "Direct link to View from Model list")

1. To view a list of models, go to the main **Overview page**.
2. In the left navigation, go to the **Resources** tab and click on **Models** to view the models list.
3. You can view the consumption query count for the models and sort by most or least consumed. The consumption query number for each model represents the consumption over the last 30 days.

[![View models consumption in the 'Models' list page under the 'Consumption' column.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/model-consumption-list.jpg?v=2 "View models consumption in the 'Models' list page under the 'Consumption' column.")](#)View models consumption in the 'Models' list page under the 'Consumption' column.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Data health tile](https://docs.getdbt.com/docs/explore/data-tile)[Next

About dbt Insights](https://docs.getdbt.com/docs/explore/dbt-insights)

* [Prerequisites](#prerequisites)* [Enable query history in dbt](#enable-query-history-in-dbt)* [Credential permissions](#credential-permissions)* [View query history in Explorer](#view-query-history-in-explorer)
        + [View from Performance charts](#view-from-performance-charts)+ [View from Project lineage](#view-from-project-lineage)+ [View from Model list](#view-from-model-list)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/explore/model-query-history.md)
