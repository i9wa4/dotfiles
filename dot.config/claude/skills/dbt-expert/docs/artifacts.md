---
title: "Artifacts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/artifacts"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [Monitor jobs and alerts](https://docs.getdbt.com/docs/deploy/monitor-jobs)* Artifacts

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fartifacts+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fartifacts+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fartifacts+so+I+can+ask+questions+about+it.)

On this page

When running dbt jobs, dbt generates and saves *artifacts*. You can use these artifacts, like `manifest.json`, `catalog.json`, and `sources.json` to power different aspects of the dbt platform, namely: [Catalog](https://docs.getdbt.com/docs/explore/explore-projects), [dbt Docs](https://docs.getdbt.com/docs/explore/build-and-view-your-docs#dbt-docs), and [source freshness reporting](https://docs.getdbt.com/docs/build/sources#source-data-freshness).

## Create dbt Artifacts[​](#create-dbt-artifacts "Direct link to Create dbt Artifacts")

[Catalog](https://docs.getdbt.com/docs/explore/explore-projects#generate-metadata) uses the metadata provided by the [Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api) to display the details about [the state of your project](https://docs.getdbt.com/docs/dbt-cloud-apis/project-state). It uses metadata from your staging and production [deployment environments](https://docs.getdbt.com/docs/deploy/deploy-environments).

Catalog automatically retrieves the metadata updates after each job run in the production or staging deployment environment so it always has the latest results for your project — meaning it's always automatically updated after each job run.

To view a resource, its metadata, and what commands are needed, refer to [generate metadata](https://docs.getdbt.com/docs/explore/explore-projects#generate-metadata) for more details.

 For dbt Docs

The following steps are for legacy dbt Docs only. For the current documentation experience, see [dbt Catalog](https://docs.getdbt.com/docs/explore/explore-projects).

While running any job can produce artifacts, you should only associate one production job with a given project to produce the project's artifacts. You can designate this connection on the **Project details** page. To access this page:

1. From the dbt platform, click on your account name in the left side menu and select **Account settings**.
2. Select your project, and click **Edit** in the lower right.
3. Under **Artifacts**, select the jobs you want to produce documentation and source freshness artifacts for.

[![Configuring Artifacts](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/project-level-artifact-updated.png?v=2 "Configuring Artifacts")](#)Configuring Artifacts

If you don't see your job listed, you might need to edit the job and select **Run source freshness** and **Generate docs on run**.

[![Editing the job to generate artifacts](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/edit-job-generate-artifacts.png?v=2 "Editing the job to generate artifacts")](#)Editing the job to generate artifacts

When you add a production job to a project, dbt updates the content and provides links to the production documentation and source freshness artifacts it generated for that project. You can see these links by clicking **Deploy** in the upper left, selecting **Jobs**, and then selecting the production job. From the job page, you can select a specific run to see how artifacts were updated for that run only.

### Documentation[​](#documentation "Direct link to Documentation")

Navigate to [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) through the **Explore** link to view your project's resources and lineage to gain a better understanding of its latest production state.

To view a resource, its metadata, and what commands are needed, refer to [generate metadata](https://docs.getdbt.com/docs/explore/explore-projects#generate-metadata) for more details.

Both the job's commands and the docs generate step (triggered by the **Generate docs on run** checkbox) must succeed during the job invocation to update the documentation.

 For dbt Docs

When set up, dbt updates the Documentation link in the header tab so it links to documentation for this job. This link always directs you to the latest version of the documentation for your project.

### Source Freshness[​](#source-freshness "Direct link to Source Freshness")

To view the latest source freshness result, refer to [generate metadata](https://docs.getdbt.com/docs/explore/explore-projects#generate-metadata) for more detail. Then navigate to Catalog through the **Explore** link.

 For dbt Docs

Configuring a job for the Source Freshness artifact setting also updates the data source link under **Orchestration** > **Data sources**. The link points to the latest Source Freshness report for the selected job.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Visualize and orchestrate exposures](https://docs.getdbt.com/docs/deploy/orchestrate-exposures)[Next

Job notifications](https://docs.getdbt.com/docs/deploy/job-notifications)

* [Create dbt Artifacts](#create-dbt-artifacts)
  + [Documentation](#documentation)+ [Source Freshness](#source-freshness)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/artifacts.md)
