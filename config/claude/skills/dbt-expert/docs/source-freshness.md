---
title: "Source freshness | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/source-freshness"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [Monitor jobs and alerts](https://docs.getdbt.com/docs/deploy/monitor-jobs)* Source freshness

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fsource-freshness+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fsource-freshness+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fsource-freshness+so+I+can+ask+questions+about+it.)

On this page

dbt provides a helpful interface around dbt's [source data freshness](https://docs.getdbt.com/docs/build/sources#source-data-freshness) calculations. When a dbt job is configured to snapshot source data freshness, dbt will render a user interface showing you the state of the most recent snapshot. This interface is intended to help you determine if your source data freshness is meeting the service level agreement (SLA) that you've defined for your organization.

[![Data Sources in dbt](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/data-sources-next.png?v=2 "Data Sources in dbt")](#)Data Sources in dbt

### Enabling source freshness snapshots[​](#enabling-source-freshness-snapshots "Direct link to Enabling source freshness snapshots")

[`dbt build`](https://docs.getdbt.com/reference/commands/build) does *not* include source freshness checks when building and testing resources in your DAG. Instead, you can use one of these common patterns for defining jobs:

* Add `dbt build` to the run step to run models, tests, and so on.
* Select the **Generate docs on run** checkbox to automatically [generate project docs](https://docs.getdbt.com/docs/explore/build-and-view-your-docs).
* Select the **Run source freshness** checkbox to enable [source freshness](#checkbox) as the first step of the job.

[![Selecting source freshness](https://docs.getdbt.com/img/docs/dbt-cloud/select-source-freshness.png?v=2 "Selecting source freshness")](#)Selecting source freshness

To enable source freshness snapshots, firstly make sure to configure your sources to [snapshot freshness information](https://docs.getdbt.com/docs/build/sources#source-data-freshness). You can add source freshness to the list of commands in the job run steps or enable the checkbox. However, you can expect different outcomes when you configure a job by selecting the **Run source freshness** checkbox compared to adding the command to the run steps.

Review the following options and outcomes:

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
| Options Outcomes|  |  |  |  | | --- | --- | --- | --- | | **Select checkbox**  The **Run source freshness** checkbox in your **Execution Settings** will run `dbt source freshness` as the first step in your job and won't break subsequent steps if it fails. If you wanted your job dedicated *exclusively* to running freshness checks, you still need to include at least one placeholder step, such as `dbt compile`.| **Add as a run step** Add the `dbt source freshness` command to a job anywhere in your list of run steps. However, if your source data is out of date — this step will "fail", and subsequent steps will not run. dbt will trigger email notifications (if configured) based on the end state of this step.    You can create a new job to snapshot source freshness.    If you *do not* want your models to run if your source data is out of date, then it could be a good idea to run `dbt source freshness` as the first step in your job. Otherwise, we recommend adding `dbt source freshness` as the last step in the job, or creating a separate job just for this task. | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

[![Adding a step to snapshot source freshness](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/job-step-source-freshness.png?v=2 "Adding a step to snapshot source freshness")](#)Adding a step to snapshot source freshness

### Source freshness snapshot frequency[​](#source-freshness-snapshot-frequency "Direct link to Source freshness snapshot frequency")

It's important that your freshness jobs run frequently enough to snapshot data latency in accordance with your SLAs. You can imagine that if you have a 1 hour SLA on a particular dataset, snapshotting the freshness of that table once daily would not be appropriate. As a good rule of thumb, you should run your source freshness jobs with at least double the frequency of your lowest SLA. Here's an example table of some reasonable snapshot frequencies given typical SLAs:

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| SLA Snapshot Frequency|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | 1 hour 30 mins|  |  |  |  | | --- | --- | --- | --- | | 1 day 12 hours|  |  | | --- | --- | | 1 week About daily | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Further reading[​](#further-reading "Direct link to Further reading")

* Refer to [Artifacts](https://docs.getdbt.com/docs/deploy/artifacts) for more info on how to create dbt artifacts, share links to the latest documentation, and share source freshness reports with your team.
* Source freshness for Snowflake is calculated using the `LAST_ALTERED` column. Read about the limitations in [Snowflake configs](https://docs.getdbt.com/reference/resource-configs/snowflake-configs#source-freshness-known-limitation).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Retry jobs](https://docs.getdbt.com/docs/deploy/retry-jobs)[Next

Webhooks](https://docs.getdbt.com/docs/deploy/webhooks)

* [Enabling source freshness snapshots](#enabling-source-freshness-snapshots)* [Source freshness snapshot frequency](#source-freshness-snapshot-frequency)* [Further reading](#further-reading)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/source-freshness.md)
