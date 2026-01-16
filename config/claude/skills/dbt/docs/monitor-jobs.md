---
title: "Monitor jobs and alerts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/monitor-jobs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* Monitor jobs and alerts

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fmonitor-jobs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fmonitor-jobs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fmonitor-jobs+so+I+can+ask+questions+about+it.)

Monitor your dbt jobs to help identify improvement and set up alerts to proactively alert the right people or team.

This portion of our documentation will go over dbt's various capabilities that help you monitor your jobs and set up alerts to ensure seamless orchestration, including:

* [Visualize and orchestrate downstream exposures](https://docs.getdbt.com/docs/deploy/orchestrate-exposures) [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing") — Automatically visualize and orchestrate exposures from dashboards and proactively refresh the underlying data sources during scheduled dbt jobs.
* [Leverage artifacts](https://docs.getdbt.com/docs/deploy/artifacts) — dbt generates and saves artifacts for your project, which it uses to power features like creating docs for your project and reporting freshness of your sources.
* [Job notifications](https://docs.getdbt.com/docs/deploy/job-notifications) — Receive email or Slack notifications when a job run succeeds, encounters warnings, fails, or is canceled.
* [Model notifications](https://docs.getdbt.com/docs/deploy/model-notifications) — Receive email notifications about any issues encountered by your models and tests as soon as they occur while running a job.
* [Retry jobs](https://docs.getdbt.com/docs/deploy/retry-jobs) — Rerun your errored jobs from start or the failure point.
* [Run visibility](https://docs.getdbt.com/docs/deploy/run-visibility) — View your run history to help identify where improvements can be made to scheduled jobs.
* [Source freshness](https://docs.getdbt.com/docs/deploy/source-freshness) — Monitor data governance by enabling snapshots to capture the freshness of your data sources.
* [Webhooks](https://docs.getdbt.com/docs/deploy/webhooks) — Use webhooks to send events about your dbt jobs' statuses to other systems.

To set up and add data health tiles to view data freshness and quality checks in your dashboard, refer to [data health tiles](https://docs.getdbt.com/docs/explore/data-tile).

[![An overview of a dbt job run which contains run summary, job trigger, run duration, and more.](https://docs.getdbt.com/img/docs/dbt-cloud/deployment/deploy-scheduler.png?v=2 "An overview of a dbt job run which contains run summary, job trigger, run duration, and more.")](#)An overview of a dbt job run which contains run summary, job trigger, run duration, and more.

[![Run history dashboard allows you to monitor the health of your dbt project and displays jobs, job status, environment, timing, and more.](https://docs.getdbt.com/img/docs/dbt-cloud/deployment/run-history.png?v=2 "Run history dashboard allows you to monitor the health of your dbt project and displays jobs, job status, environment, timing, and more.")](#)Run history dashboard allows you to monitor the health of your dbt project and displays jobs, job status, environment, timing, and more.

[![Access logs for run steps](https://docs.getdbt.com/img/docs/dbt-cloud/deployment/access-logs.gif?v=2 "Access logs for run steps")](#)Access logs for run steps

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Job commands](https://docs.getdbt.com/docs/deploy/job-commands)[Next

Run visibility](https://docs.getdbt.com/docs/deploy/run-visibility)
