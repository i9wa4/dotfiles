---
title: "Jobs in the dbt platform | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/jobs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* Jobs

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fjobs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fjobs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fjobs+so+I+can+ask+questions+about+it.)

These are the available job types in dbt:

* [Deploy jobs](https://docs.getdbt.com/docs/deploy/deploy-jobs) — Build production data assets. Runs on a schedule, by API, or after another job completes.
* [Continuous integration (CI) jobs](https://docs.getdbt.com/docs/deploy/continuous-integration) — Test and validate code changes before merging. Triggered by commit to a PR or by API.
* [Merge jobs](https://docs.getdbt.com/docs/deploy/merge-jobs) — Deploy merged changes into production. Runs after a successful PR merge or by API.
* [State-aware jobs](https://docs.getdbt.com/docs/deploy/state-aware-about) — Intelligently decide what needs to be rebuilt based on source freshness, code, or upstream data changes. Rebuild models only if they are older than the specified interval.

The following comparison table describes the behaviors of the different job types:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **Deploy jobs** **CI jobs** **Merge jobs** **State-aware jobs**|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Purpose Builds production data assets. Builds and tests new code before merging changes into production. Build merged changes into production or update state for deferral. Trigger model builds and job runs only when source data is updated.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Trigger types Triggered by a schedule, API, or the successful completion of another job. Triggered by a commit to a PR or by API. Triggered by a successful merge into the environment's branch or by API. Triggered when code, sources, or upstream data changes and at custom refresh intervals and for custom source freshness configurations|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Destination Builds into a production database and schema. Builds into a staging database and ephemeral schema, lived for the lifetime of the PR. Builds into a production database and schema. Builds into a production database and schema.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Execution mode Runs execute sequentially, so as to not have collisions on the underlying DAG. Runs execute in parallel to promote team velocity. Runs execute sequentially, so as to not have collisions on the underlying DAG. |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Efficiency run savings Detects over-scheduled jobs and cancels unnecessary runs to avoid queue clog. Cancels existing runs when a newer commit is pushed to avoid redundant work. N/A Runs jobs and build models *only* when source data is updated or if models are older than what you specified in the project refresh interval| State comparison Only sometimes needs to detect state. Almost always needs to compare state against the production environment to build on modified code and its dependents. Almost always needs to compare state against the production environment to build on modified code and its dependents. |  |  |  |  |  | | --- | --- | --- | --- | --- | | Job run duration Limit is 24 hours. Limit is 24 hours. Limit is 24 hours. Limit is 24 hours. | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

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

Navigating the interface](https://docs.getdbt.com/docs/deploy/state-aware-interface)[Next

Deploy jobs](https://docs.getdbt.com/docs/deploy/deploy-jobs)
