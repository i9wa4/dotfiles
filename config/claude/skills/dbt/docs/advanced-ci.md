---
title: "Advanced CI | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/advanced-ci"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [Continuous integration](https://docs.getdbt.com/docs/deploy/about-ci)* Advanced CI

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fadvanced-ci+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fadvanced-ci+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fadvanced-ci+so+I+can+ask+questions+about+it.)

On this page

[Continuous integration workflows](https://docs.getdbt.com/docs/deploy/continuous-integration) help increase the governance and improve the quality of the data. Additionally for these CI jobs, you can use Advanced CI features, such as [compare changes](#compare-changes), that provide details about the changes between what's currently in your production environment and the pull request's latest commit, giving you observability into how data changes are affected by your code changes. By analyzing the data changes that code changes produce, you can ensure you're always shipping trustworthy data products as you're developing.

How to enable this feature

You can opt into Advanced CI in dbt. Please refer to [Account access to Advanced CI features](https://docs.getdbt.com/docs/cloud/account-settings#account-access-to-advanced-ci-features) to learn how enable it in your dbt account.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You have a dbt Enterprise or Enterprise+ account.
* You have [Advanced CI features](https://docs.getdbt.com/docs/cloud/account-settings#account-access-to-advanced-features) enabled.
* You use a supported data platform: BigQuery, Databricks, Postgres, Redshift, or Snowflake. Support for additional data platforms coming soon.

## Compare changes feature[​](#compare-changes "Direct link to Compare changes feature")

For [CI jobs](https://docs.getdbt.com/docs/deploy/ci-jobs) that have the [**dbt compare** option enabled](https://docs.getdbt.com/docs/deploy/ci-jobs#set-up-ci-jobs), dbt compares the changes between the last applied state of the production environment (defaulting to deferral for lower compute costs) and the latest changes from the pull request, whenever a pull request is opened or new commits are pushed.

dbt reports the comparison differences in:

* **dbt** — Shows the changes (if any) to the data's primary keys, rows, and columns in the [Compare tab](https://docs.getdbt.com/docs/deploy/run-visibility#compare-tab) from the [Job run details](https://docs.getdbt.com/docs/deploy/run-visibility#job-run-details) page.
* **The pull request from your Git provider** — Shows a summary of the changes as a Git comment.

[![Example of the Compare tab](https://docs.getdbt.com/img/docs/dbt-cloud/example-ci-compare-changes-tab.png?v=2 "Example of the Compare tab")](#)Example of the Compare tab

### Optimizing comparisons[​](#optimizing-comparisons "Direct link to Optimizing comparisons")

When an [`event_time`](https://docs.getdbt.com/reference/resource-configs/event-time) column is specified on your model, compare changes can optimize comparisons by using only the overlapping timeframe (meaning the timeframe exists in both the CI and production environment), helping you avoid incorrect row-count changes and return results faster.

This is useful in scenarios like:

* **Subset of data in CI** — When CI builds only a [subset of data](https://docs.getdbt.com/best-practices/best-practice-workflows#limit-the-data-processed-when-in-development) (like the most recent 7 days), compare changes would interpret the excluded data as "deleted rows." Configuring `event_time` allows you to avoid this issue by limiting comparisons to the overlapping timeframe, preventing false alerts about data deletions that are just filtered out in CI.
* **Fresher data in CI than in production** — When your CI job includes fresher data than production (because it has run more recently), compare changes would flag the additional rows as "new" data, even though they’re just fresher data in CI. With `event_time` configured, the comparison only includes the shared timeframe and correctly reflects actual changes in the data.

[![event_time ensures the same time-slice of data is accurately compared between your CI and production environments.](https://docs.getdbt.com/img/docs/deploy/apples_to_apples.png?v=2 "event_time ensures the same time-slice of data is accurately compared between your CI and production environments.")](#)event\_time ensures the same time-slice of data is accurately compared between your CI and production environments.

## About the cached data[​](#about-the-cached-data "Direct link to About the cached data")

After [comparing changes](#compare-changes), dbt stores a cache of no more than 100 records for each modified model for preview purposes. By caching this data, you can view the examples of changed data without rerunning the comparison against the data warehouse every time (optimizing for lower compute costs). To display the changes, dbt uses a cached version of a sample of the data records. These data records are queried from the database using the connection configuration (such as user, role, service account, and so on) that's set in the CI job's environment.

You control what data to use. This may include synthetic data if pre-production or development data is heavily regulated or sensitive.

* The selected data is cached on dbt Labs' systems for up to 30 days. No data is retained on dbt Labs' systems beyond this period.
* The cache is encrypted and stored in an Amazon S3 or Azure blob storage in your account’s region.
* dbt Labs will not access cached data from Advanced CI for its benefit and the data is only used to provide services as directed by you.
* Third-party subcontractors, other than storage subcontractors, will not have access to the cached data.

If you access a CI job run that's more than 30 days old, you will not be able to see the comparison results. Instead, a message will appear indicating that the data has expired.

[![Example of message about expired data in the Compare tab](https://docs.getdbt.com/img/docs/deploy/compare-expired.png?v=2 "Example of message about expired data in the Compare tab")](#)Example of message about expired data in the Compare tab

## Connection permissions[​](#connection-permissions "Direct link to Connection permissions")

The compare changes feature uses the same credentials as the CI job, as defined in the CI job’s environment. The dbt administrator must ensure that client CI credentials are appropriately restricted since all customer's account users will be able to view the comparison results and the cached data.

If using dynamic data masking in the data warehouse, the cached data will no longer be dynamically masked in the Advanced CI output, depending on the permissions of the users who view it. dbt Labs recommends limiting user access to unmasked data or considering using synthetic data for the Advanced CI testing functionality.

[![Example of credentials in the user settings](https://docs.getdbt.com/img/docs/deploy/compare-credentials.png?v=2 "Example of credentials in the user settings")](#)Example of credentials in the user settings

## Troubleshooting[​](#troubleshooting "Direct link to Troubleshooting")

 Compare changes CI models need to be on same database host/connection

Compare Changes only works if both CI and production models live on the same database host/connection. Compare Changes runs SQL queries in the current CI job’s environment to compare the CI model (like `ci.dbt_cloud_123.foo`) to the production model (`prod.analytics.foo`).

If the CI job defers to a production job that's on a different database connection or host, then the compare changes feature will not work as expected. This is because the CI environment can't access or query production objects on another host.

In the following example, the CI job can’t access the production model to compare them because they’re on different database hosts:

* The dbt CI job in environment `ci.dbt_cloud_123.foo` that connects to host `abc123.rds.amazonaws.com`
* The dbt production job in environment `prod.analytics.foo` that connects to host `def456.rds.amazonaws.com`

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Continuous integration](https://docs.getdbt.com/docs/deploy/continuous-integration)[Next

Continuous deployment](https://docs.getdbt.com/docs/deploy/continuous-deployment)

* [Prerequisites](#prerequisites)* [Compare changes feature](#compare-changes)
    + [Optimizing comparisons](#optimizing-comparisons)* [About the cached data](#about-the-cached-data)* [Connection permissions](#connection-permissions)* [Troubleshooting](#troubleshooting)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/advanced-ci.md)
