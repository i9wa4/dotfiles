---
title: "Continuous deployment in dbt | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/continuous-deployment"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* Continuous deployment

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fcontinuous-deployment+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fcontinuous-deployment+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fcontinuous-deployment+so+I+can+ask+questions+about+it.)

On this page

To help you improve data transformations and ship data products faster, you can run [merge jobs](https://docs.getdbt.com/docs/deploy/merge-jobs) to implement a continuous deployment (CD) workflow in dbt. Merge jobs can automatically build modified models whenever a pull request (PR) merges, making sure the latest code changes are in production. You don't have to wait for the next scheduled job to run to get the latest updates.

[![Workflow of continuous deployment in dbt](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/cd-workflow.png?v=2 "Workflow of continuous deployment in dbt")](#)Workflow of continuous deployment in dbt

You can also implement continuous integration (CI) in dbt, which can help further to reduce the time it takes to push changes to production and improve code quality. To learn more, refer to [Continuous integration in dbt](https://docs.getdbt.com/docs/deploy/continuous-integration).

## How merge jobs work[​](#how-merge-jobs-work "Direct link to How merge jobs work")

When you set up merge jobs, dbt listens for notifications from your [Git provider](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud) indicating that a PR has been merged. When dbt receives one of these notifications, it enqueues a new run of the merge job.

You can set up merge jobs to perform one of the following when a PR merges:

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| Command to run  Usage description|  |  |  |  | | --- | --- | --- | --- | | `dbt build --select state:modified+` (Default) Build the modified data with every merge.   dbt builds only the changed data models and anything downstream of it, similar to CI jobs. This helps reduce computing costs and ensures that the latest code changes are always pushed to production.| `dbt compile` Refresh the applied state for performant (the slimmest) CI job runs.   dbt generates the executable SQL (from the source model, test, and analysis files) but does not run it. This ensures the changes are reflected in the manifest for the next time a CI job is run and keeps track of only the relevant changes. | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Advanced CI](https://docs.getdbt.com/docs/deploy/advanced-ci)[Next

About state-aware orchestration](https://docs.getdbt.com/docs/deploy/state-aware-about)

* [How merge jobs work](#how-merge-jobs-work)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/continuous-deployment.md)
