---
title: "Deploy jobs | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/deploy-jobs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [Jobs](https://docs.getdbt.com/docs/deploy/jobs)* Deploy jobs

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fdeploy-jobs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fdeploy-jobs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fdeploy-jobs+so+I+can+ask+questions+about+it.)

On this page

You can use deploy jobs to build production data assets. Deploy jobs make it easy to run dbt commands against a project in your cloud data platform, triggered either by schedule or events. Each job run in dbt will have an entry in the job's run history and a detailed run overview, which provides you with:

* Job trigger type
* Commit SHA
* Environment name
* Sources and documentation info, if applicable
* Job run details, including run timing, [model timing data](https://docs.getdbt.com/docs/deploy/run-visibility#model-timing), and [artifacts](https://docs.getdbt.com/docs/deploy/artifacts)
* Detailed run steps with logs and their run step statuses

You can create a deploy job and configure it to run on [scheduled days and times](#schedule-days), enter a [custom cron schedule](#cron-schedule), or [trigger the job after another job completes](#trigger-on-job-completion).

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You must have a [dbt account](https://www.getdbt.com/signup/) and [Developer seat license](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users).
  + For the [Trigger on job completion](#trigger-on-job-completion) feature, your dbt account must be on the [Starter or an Enterprise-tier](https://www.getdbt.com/pricing/) plan.
* You must have a dbt project connected to a [data platform](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections).
* You must have [access permission](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access) to view, create, modify, or run jobs.
* You must set up a [deployment environment](https://docs.getdbt.com/docs/deploy/deploy-environments).

## Create and schedule jobs[​](#create-and-schedule-jobs "Direct link to Create and schedule jobs")

1. On your deployment environment page, click **Create job** > **Deploy job** to create a new deploy job.
2. Options in the **Job settings** section:
   * **Job name** — Specify the name for the deploy job. For example, `Daily build`.
   * (Optional) **Description** — Provide a description of what the job does (for example, what the job consumes and what the job produces).
   * **Environment** — By default, it’s set to the deployment environment you created the deploy job from.
3. Options in the **Execution settings** section:
   * [**Commands**](https://docs.getdbt.com/docs/deploy/job-commands#built-in-commands) — By default, it includes the `dbt build` command. Click **Add command** to add more [commands](https://docs.getdbt.com/docs/deploy/job-commands) that you want to be invoked when the job runs. During a job run, [built-in commands](https://docs.getdbt.com/docs/deploy/job-commands#built-in-commands) are "chained" together and if one run step fails, the entire job fails with an "Error" status.
   * [**Generate docs on run**](https://docs.getdbt.com/docs/deploy/job-commands#checkbox-commands) — Enable this option if you want to [generate project docs](https://docs.getdbt.com/docs/explore/build-and-view-your-docs) when this deploy job runs. If the step fails, the job can succeed if subsequent steps pass.
   * [**Run source freshness**](https://docs.getdbt.com/docs/deploy/job-commands#checkbox-commands) — Enable this option to invoke the `dbt source freshness` command before running the deploy job. If the step fails, the job can succeed if subsequent steps pass. Refer to [Source freshness](https://docs.getdbt.com/docs/deploy/source-freshness) for more details.
4. Options in the **Triggers** section:
   * **Run on schedule** — Run the deploy job on a set schedule.
     + **Timing** — Specify whether to [schedule](#schedule-days) the deploy job using **Intervals** that run the job every specified number of hours, **Specific hours** that run the job at specific times of day, or **Cron schedule** that run the job specified using [cron syntax](#cron-schedule).
     + **Days of the week** — By default, it’s set to every day when **Intervals** or **Specific hours** is chosen for **Timing**.
   * **Run when another job finishes** — Run the deploy job when another *upstream* deploy [job completes](#trigger-on-job-completion).
     + **Project** — Specify the parent project that has that upstream deploy job.
     + **Job** — Specify the upstream deploy job.
     + **Completes on** — Select the job run status(es) that will [enqueue](https://docs.getdbt.com/docs/deploy/job-scheduler#scheduler-queue) the deploy job.

[![Example of Triggers on the Deploy Job page](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/example-triggers-section.png?v=2 "Example of Triggers on the Deploy Job page")](#)Example of Triggers on the Deploy Job page

5. (Optional) Options in the **Advanced settings** section:

   * **Environment variables** — Define [environment variables](https://docs.getdbt.com/docs/build/environment-variables) to customize the behavior of your project when the deploy job runs.
   * **Target name** — Define the [target name](https://docs.getdbt.com/docs/build/custom-target-names) to customize the behavior of your project when the deploy job runs. Environment variables and target names are often used interchangeably.
   * **Run timeout** — Cancel the deploy job if the run time exceeds the timeout value.
   * **Compare changes against** — By default, it’s set to **No deferral**. Select either **Environment** or **This Job** to let dbt know what it should compare the changes against.

   info

   Older versions of dbt only allow you to defer to a specific job instead of an environment. Deferral to a job compares state against the project code that was run in the deferred job's last successful run. While deferral to an environment is more efficient as dbt will compare against the project representation (which is stored in the `manifest.json`) of the last successful deploy job run that executed in the deferred environment. By considering *all* deploy jobs that run in the deferred environment, dbt will get a more accurate, latest project representation state.

   * **dbt version** — By default, it’s set to inherit the [dbt version](https://docs.getdbt.com/docs/dbt-versions/core) from the environment. dbt Labs strongly recommends that you don't change the default setting. This option to change the version at the job level is useful only when you upgrade a project to the next dbt version; otherwise, mismatched versions between the environment and job can lead to confusing behavior.
   * **Threads** — By default, it’s set to 4 [threads](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles#understanding-threads). Increase the thread count to increase model execution concurrency.

   [![Example of Advanced Settings on the Deploy Job page](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/deploy-job-adv-settings.png?v=2 "Example of Advanced Settings on the Deploy Job page")](#)Example of Advanced Settings on the Deploy Job page

### Schedule days[​](#schedule-days "Direct link to Schedule days")

To set your job's schedule, use the **Run on schedule** option to choose specific days of the week, and select customized hours or intervals.

Under **Timing**, you can either use regular intervals for jobs that need to run frequently throughout the day or customizable hours for jobs that need to run at specific times:

* **Intervals** — Use this option to set how often your job runs, in hours. For example, if you choose **Every 2 hours**, the job will run every 2 hours from midnight UTC. This doesn't mean that it will run at exactly midnight UTC. However, subsequent runs will always be run with the same amount of time between them. For example, if the previous scheduled pipeline ran at 00:04 UTC, the next run will be at 02:04 UTC. This option is useful if you need to run jobs multiple times per day at regular intervals.
* **Specific hours** — Use this option to set specific times when your job should run. You can enter a comma-separated list of hours (in UTC) when you want the job to run. For example, if you set it to `0,12,23,` the job will run at midnight, noon, and 11 PM UTC. Job runs will always be consistent between both hours and days, so if your job runs at 00:05, 12:05, and 23:05 UTC, it will run at these same hours each day. This option is useful if you want your jobs to run at specific times of day and don't need them to run more frequently than once a day.

info

dbt uses [Coordinated Universal Time](https://en.wikipedia.org/wiki/Coordinated_Universal_Time) (UTC) and does not account for translations to your specific timezone or take into consideration daylight savings time. For example:

* 0 means 12am (midnight) UTC
* 12 means 12pm (afternoon) UTC
* 23 means 11pm UTC

### Cron schedule[​](#cron-schedule "Direct link to Cron schedule")

To fully customize the scheduling of your job, choose the **Cron schedule** option and use cron syntax. With this syntax, you can specify the minute, hour, day of the month, month, and day of the week, allowing you to set up complex schedules like running a job on the first Monday of each month.

**Cron frequency**

To enhance performance, job scheduling frequencies vary by dbt plan:

* Developer plans: dbt sets a minimum interval of every 10 minutes for scheduling jobs. This means scheduling jobs to run more frequently, or at less than 10 minute intervals, is not supported.
* Starter, Enterprise, and Enterprise+ plans: No restrictions on job execution frequency.

**Examples**

Use tools such as [crontab.guru](https://crontab.guru/) to generate the correct cron syntax. This tool allows you to input cron snippets and return their plain English translations. The dbt job scheduler supports using `L` to schedule jobs on the last day of the month.

Examples of cron job schedules:

* `0 * * * *`: Every hour, at minute 0.
* `*/5 * * * *`: Every 5 minutes. (Not available on Developer plans)
* `5 4 * * *`: At exactly 4:05 AM UTC.
* `30 */4 * * *`: At minute 30 past every 4th hour (such as 4:30 AM, 8:30 AM, 12:30 PM, and so on, all UTC).
* `0 0 */2 * *`: At 12:00 AM (midnight) UTC every other day.
* `0 0 * * 1`: At midnight UTC every Monday.
* `0 0 L * *`: At 12:00 AM (midnight), on the last day of the month.
* `0 0 L 1,2,3,4,5,6,8,9,10,11,12 *`: At 12:00 AM, on the last day of the month, only in January, February, March, April, May, June, August, September, October, November, and December.
* `0 0 L 7 *`: At 12:00 AM, on the last day of the month, only in July.
* `0 0 L * FRI,SAT`: At 12:00 AM, on the last day of the month, and on Friday and Saturday.
* `0 12 L * *`: At 12:00 PM (afternoon), on the last day of the month.
* `0 7 L * 5`: At 07:00 AM, on the last day of the month, and on Friday.
* `30 14 L * *`: At 02:30 PM, on the last day of the month.

### Trigger on job completion [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#trigger-on-job-completion-- "Direct link to trigger-on-job-completion--")

To *chain* deploy jobs together:

1. In the **Triggers** section, enable the **Run when another job finishes** option.
2. Select the project that has the deploy job you want to run after completion.
3. Specify the upstream (parent) job that, when completed, will trigger your job.
   * You can also use the [Create Job API](https://docs.getdbt.com/dbt-cloud/api-v2#/operations/Create%20Job) to do this.
4. In the **Completes on** option, select the job run status(es) that will [enqueue](https://docs.getdbt.com/docs/deploy/job-scheduler#scheduler-queue) the deploy job.

[![Example of Trigger on job completion on the Deploy job page](https://docs.getdbt.com/img/docs/deploy/deploy-job-completion.jpg?v=2 "Example of Trigger on job completion on the Deploy job page")](#)Example of Trigger on job completion on the Deploy job page

5. You can set up a configuration where an upstream job triggers multiple downstream (child) jobs and jobs in other projects. You must have proper [permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions#project-role-permissions) to the project and job to configure the trigger.

If another job triggers your job to run, you can find a link to the upstream job in the [run details section](https://docs.getdbt.com/docs/deploy/run-visibility#job-run-details).

## Delete a job[​](#delete-a-job "Direct link to Delete a job")

To delete a job or multiple jobs in dbt:

1. Click **Deploy** on the navigation header.
2. Click **Jobs** and select the job you want to delete.
3. Click **Settings** on the top right of the page and then click **Edit**.
4. Scroll to the bottom of the page and click **Delete job** to delete the job.

[![Delete a job](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/delete-job.png?v=2 "Delete a job")](#)Delete a job

5. Confirm your action in the pop-up by clicking **Confirm delete** in the bottom right to delete the job immediately. This action cannot be undone. However, you can create a new job with the same information if the deletion was made in error.
6. Refresh the page, and the deleted job should now be gone. If you want to delete multiple jobs, you'll need to perform these steps for each job.

If you're having any issues, feel free to [contact us](mailto:support@getdbt.com) for additional help.

## Job monitoring[​](#job-monitoring "Direct link to Job monitoring")

On the **Environments** page, there are two sections that provide an overview of the jobs for that environment:

* **In progress** — Lists the currently in progress jobs with information on when the run started
* **Top jobs by models built** — Ranks jobs by the number of models built over a specific time

[![In progress jobs and Top jobs by models built](https://docs.getdbt.com/img/docs/deploy/in-progress-top-jobs.png?v=2 "In progress jobs and Top jobs by models built")](#)In progress jobs and Top jobs by models built

## Job settings history[​](#job-settings-history "Direct link to Job settings history")

You can view historical job settings changes over the last 90 days.

To view the change history:

1. Navigate to **Orchestration** from the main menu and click **Jobs**.
2. Click a **job name**.
3. Click **Settings**.
4. Click **History**.

[![Example of the job settings history.](https://docs.getdbt.com/img/docs/deploy/job-history.png?v=2 "Example of the job settings history.")](#)Example of the job settings history.

## Related docs[​](#related-docs "Direct link to Related docs")

* [Artifacts](https://docs.getdbt.com/docs/deploy/artifacts)
* [Continuous integration (CI) jobs](https://docs.getdbt.com/docs/deploy/ci-jobs)
* [Webhooks](https://docs.getdbt.com/docs/deploy/webhooks)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About jobs](https://docs.getdbt.com/docs/deploy/jobs)[Next

CI jobs](https://docs.getdbt.com/docs/deploy/ci-jobs)

* [Prerequisites](#prerequisites)* [Create and schedule jobs](#create-and-schedule-jobs)
    + [Schedule days](#schedule-days)+ [Cron schedule](#cron-schedule)+ [Trigger on job completion](#trigger-on-job-completion--)* [Delete a job](#delete-a-job)* [Job monitoring](#job-monitoring)* [Job settings history](#job-settings-history)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/deploy-jobs.md)
