---
title: "Run visibility | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/run-visibility"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [Monitor jobs and alerts](https://docs.getdbt.com/docs/deploy/monitor-jobs)* Run visibility

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Frun-visibility+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Frun-visibility+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Frun-visibility+so+I+can+ask+questions+about+it.)

On this page

You can view the history of your runs and the model timing dashboard to help identify where improvements can be made to jobs.

## Run history[​](#run-history "Direct link to Run history")

The **Run history** dashboard in dbt helps you monitor the health of your dbt project. It provides a detailed overview of all your project's job runs and empowers you with a variety of filters that enable you to focus on specific aspects. You can also use it to review recent runs, find errored runs, and track the progress of runs in progress. You can access it from the top navigation menu by clicking **Deploy** and then **Run history**.

The dashboard displays your full run history, including job name, status, associated environment, job trigger, commit SHA, schema, and timing info.

dbt developers can access their run history for the last 365 days through the dbt user interface (UI) and API.

dbt Labs limits self-service retrieval of run history metadata to 365 days to improve dbt's performance.

[![Run history dashboard allows you to monitor the health of your dbt project and displays jobs, job status, environment, timing, and more.](https://docs.getdbt.com/img/docs/dbt-cloud/deployment/run-history.png?v=2 "Run history dashboard allows you to monitor the health of your dbt project and displays jobs, job status, environment, timing, and more.")](#)Run history dashboard allows you to monitor the health of your dbt project and displays jobs, job status, environment, timing, and more.

## Job run details[​](#job-run-details "Direct link to Job run details")

From the **Run history** dashboard, select a run to view complete details about it. The job run details page displays job trigger, commit SHA, time spent in the scheduler queue, all the run steps and their [logs](#access-logs), [model timing](#model-timing), and more.

Click **Rerun now** to rerun the job immediately.

An example of a completed run with a configuration for a [job completion trigger](https://docs.getdbt.com/docs/deploy/deploy-jobs#trigger-on-job-completion):

[![Example of run details](https://docs.getdbt.com/img/docs/dbt-cloud/deployment/example-job-details.png?v=2 "Example of run details")](#)Example of run details

### Run summary tab[​](#run-summary-tab "Direct link to Run summary tab")

You can view or download in-progress and historical logs for your dbt runs. This makes it easier for the team to debug errors more efficiently.

[![Access logs for run steps](https://docs.getdbt.com/img/docs/dbt-cloud/deployment/access-logs.png?v=2 "Access logs for run steps")](#)Access logs for run steps

### Lineage tab[​](#lineage-tab "Direct link to Lineage tab")

View the lineage graph associated with the job run so you can better understand the dependencies and relationships of the resources in your project. To view a node's metadata directly in [Catalog](https://docs.getdbt.com/docs/explore/explore-projects), select it (double-click) from the graph.

[![Example of accessing dbt Catalog from the Lineage tab](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/explorer-from-lineage.gif?v=2 "Example of accessing dbt Catalog from the Lineage tab")](#)Example of accessing dbt Catalog from the Lineage tab

### Model timing tab [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#model-timing-tab- "Direct link to model-timing-tab-")

The **Model timing** tab displays the composition, order, and time each model takes in a job run. The visualization appears for successful jobs and highlights the top 1% of model durations. This helps you identify bottlenecks in your runs so you can investigate them and potentially make changes to improve their performance.

You can find the dashboard on the [job's run details](#job-run-details).

[![The Model timing tab displays the top 1% of model durations and visualizes model bottlenecks](https://docs.getdbt.com/img/docs/dbt-cloud/model-timing.png?v=2 "The Model timing tab displays the top 1% of model durations and visualizes model bottlenecks")](#)The Model timing tab displays the top 1% of model durations and visualizes model bottlenecks

### Artifacts tab[​](#artifacts-tab "Direct link to Artifacts tab")

This provides a list of the artifacts generated by the job run. The files are saved and available for download.

[![Example of the Artifacts tab](https://docs.getdbt.com/img/docs/dbt-cloud/example-artifacts-tab.png?v=2 "Example of the Artifacts tab")](#)Example of the Artifacts tab

### Compare tab [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#compare-tab- "Direct link to compare-tab-")

The **Compare** tab is shown for [CI job runs](https://docs.getdbt.com/docs/deploy/ci-jobs) with the **Run compare changes** setting enabled. It displays details about [the changes from the comparison dbt performed](https://docs.getdbt.com/docs/deploy/advanced-ci#compare-changes) between what's in your production environment and the pull request. To help you better visualize the differences, dbt highlights changes to your models in red (deletions) and green (inserts).

From the **Modified** section, you can view the following:

* **Overview** — High-level summary about the changes to the models such as the number of primary keys that were added or removed.
* **Primary keys** — Details about the changes to the records.
* **Modified rows** — Details about the modified rows. Click **Show full preview** to display all columns.
* **Columns** — Details about the changes to the columns.

To view the dependencies and relationships of the resources in your project more closely, click **View in Catalog** to launch [Catalog](https://docs.getdbt.com/docs/explore/explore-projects).

[![Example of the Compare tab](https://docs.getdbt.com/img/docs/dbt-cloud/example-ci-compare-changes-tab.png?v=2 "Example of the Compare tab")](#)Example of the Compare tab

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Model notifications](https://docs.getdbt.com/docs/deploy/model-notifications)[Next

Retry jobs](https://docs.getdbt.com/docs/deploy/retry-jobs)

* [Run history](#run-history)* [Job run details](#job-run-details)
    + [Run summary tab](#run-summary-tab)+ [Lineage tab](#lineage-tab)+ [Model timing tab](#model-timing-tab-) + [Artifacts tab](#artifacts-tab)+ [Compare tab](#compare-tab-)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/run-visibility.md)
