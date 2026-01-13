---
title: "Deploy your metrics | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/use-dbt-semantic-layer/deploy-sl"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Use the dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl)* Deploy metrics

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fdeploy-sl+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fdeploy-sl+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fdeploy-sl+so+I+can+ask+questions+about+it.)

On this page

This section explains how you can perform a job run in your deployment environment in dbt to materialize and deploy your metrics. Currently, the deployment environment is only supported.

1. Once you’ve [defined your semantic models and metrics](https://docs.getdbt.com/guides/sl-snowflake-qs?step=10), commit and merge your metric changes in your dbt project.
2. In dbt, create a new [deployment environment](https://docs.getdbt.com/docs/deploy/deploy-environments#create-a-deployment-environment) or use an existing environment on dbt 1.6 or higher.

   * Note — Deployment environment is currently supported (*development experience coming soon*)
3. To create a new environment, navigate to **Deploy** in the navigation menu, select **Environments**, and then select **Create new environment**.
4. Fill in your deployment credentials with your Snowflake username and password. You can name the schema anything you want. Click **Save** to create your new production environment.
5. [Create a new deploy job](https://docs.getdbt.com/docs/deploy/deploy-jobs#create-and-schedule-jobs) that runs in the environment you just created. Go back to the **Deploy** menu, select **Jobs**, select **Create job**, and click **Deploy job**.
6. Set the job to run a `dbt parse` job to parse your projects and generate a [`semantic_manifest.json` artifact](https://docs.getdbt.com/reference/artifacts/sl-manifest) file. Although running `dbt build` isn't required, you can choose to do so if needed.

   note

   If you are on the dbt Fusion engine, add the `dbt docs generate` command to your job to successfully deploy your metrics.
7. Run the job by clicking the **Run now** button. Monitor the job's progress in real-time through the **Run summary** tab.

   Once the job completes successfully, your dbt project, including the generated documentation, will be fully deployed and available for use in your production environment. If any issues arise, review the logs to diagnose and address any errors.

What’s happening internally?

* Merging the code into your main branch allows dbt to pull those changes and build the definition in the manifest produced by the run.
* Re-running the job in the deployment environment helps materialize the models, which the metrics depend on, in the data platform. It also makes sure that the manifest is up to date.
* The Semantic Layer APIs pull in the most recent manifest and enables your integration to extract metadata from it.

## Next steps[​](#next-steps "Direct link to Next steps")

After you've executed a job and deployed your Semantic Layer:

* [Set up your Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl) in dbt.
* Discover the [available integrations](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations), such as Tableau, Google Sheets, Microsoft Excel, and more.
* Start querying your metrics with the [API query syntax](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-jdbc#querying-the-api-for-metric-metadata).

## Related docs[​](#related-docs "Direct link to Related docs")

* [Optimize querying performance](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-cache) using declarative caching.
* [Validate semantic nodes in CI](https://docs.getdbt.com/docs/deploy/ci-jobs#semantic-validations-in-ci) to ensure code changes made to dbt models don't break these metrics.
* If you haven't already, learn how to [build your metrics and semantic models](https://docs.getdbt.com/docs/build/build-metrics-intro) in your development tool of choice.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Semantic Layer architecture](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-architecture)[Next

Write queries with exports](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports)

* [Next steps](#next-steps)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/use-dbt-semantic-layer/deploy-sl.md)
