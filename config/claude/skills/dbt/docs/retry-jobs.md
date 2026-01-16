---
title: "Retry your dbt jobs | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/retry-jobs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [Monitor jobs and alerts](https://docs.getdbt.com/docs/deploy/monitor-jobs)* Retry jobs

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fretry-jobs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fretry-jobs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fretry-jobs+so+I+can+ask+questions+about+it.)

On this page

If your dbt job run completed with a status of **Error**, you can rerun it from start or from the point of failure in dbt.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You have a [dbt account](https://www.getdbt.com/signup).
* You must be using [dbt version](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud) 1.6 or newer.
* dbt can successfully parse the project and generate a [manifest](https://docs.getdbt.com/reference/artifacts/manifest-json)
* The most recent run of the job hasn't completed successfully. The latest status of the run is **Error**.
  + The job command that failed in the run must be one that supports the [retry command](https://docs.getdbt.com/reference/commands/retry).

## Rerun an errored job[​](#rerun-an-errored-job "Direct link to Rerun an errored job")

1. Select **Deploy** from the top navigation bar and choose **Run History.**
2. Choose the job run that has errored.
3. In the **Run Summary** tab on the job’s **Run** page, expand the run step that failed. An ❌ denotes the failed step.
4. Examine the error message and determine how to fix it. After you have made your changes, save and commit them to your [Git repo](https://docs.getdbt.com/docs/cloud/git/git-version-control).
5. Return to your job’s **Run** page. In the upper right corner, click **Rerun** and choose **Rerun from start** or **Rerun from failure**.

   If you chose to rerun from the failure point, a **Rerun failed steps** modal opens. The modal lists the run steps that will be invoked: the failed step and any skipped steps. To confirm these run steps, click **Rerun from failure**. The job reruns from the failed command in the previously failed run. A banner at the top of the **Run Summary** tab captures this with the message, "This run resumed execution from last failed step".

[![Example of the Rerun options in dbt](https://docs.getdbt.com/img/docs/deploy/native-retry.gif?v=2 "Example of the Rerun options in dbt")](#)Example of the Rerun options in dbt

## Related content[​](#related-content "Direct link to Related content")

* [Retry a failed run for a job](https://docs.getdbt.com/dbt-cloud/api-v2#/operations/Retry%20Failed%20Job) API endpoint
* [Run visibility](https://docs.getdbt.com/docs/deploy/run-visibility)
* [Jobs](https://docs.getdbt.com/docs/deploy/jobs)
* [Job commands](https://docs.getdbt.com/docs/deploy/job-commands)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Run visibility](https://docs.getdbt.com/docs/deploy/run-visibility)[Next

Source freshness](https://docs.getdbt.com/docs/deploy/source-freshness)

* [Prerequisites](#prerequisites)* [Rerun an errored job](#rerun-an-errored-job)* [Related content](#related-content)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/retry-jobs.md)
