---
title: "Job scheduler | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/job-scheduler"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* Job scheduler

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fjob-scheduler+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fjob-scheduler+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fjob-scheduler+so+I+can+ask+questions+about+it.)

On this page

The job scheduler is the backbone of running jobs in dbt, bringing power and simplicity to building data pipelines in both continuous integration and production contexts. The scheduler frees teams from having to build and maintain their own infrastructure, and ensures the timeliness and reliability of data transformations.

The scheduler enables both cron-based and event-driven execution of dbt commands in the user’s data platform. Specifically, it handles:

* Cron-based execution of dbt jobs that run on a predetermined cadence
* Event-driven execution of dbt jobs that run based on the completion of another job ([trigger on job completion](https://docs.getdbt.com/docs/deploy/deploy-jobs#trigger-on-job-completion))
* Event-driven execution of dbt CI jobs triggered when a pull request is merged to the branch ([merge jobs](https://docs.getdbt.com/docs/deploy/merge-jobs))
* Event-driven execution of dbt jobs triggered by API
* Event-driven execution of dbt jobs manually triggered by a user to **Run now**

The scheduler handles various tasks including:

* Queuing jobs
* Creating temporary environments to run the dbt commands required for those jobs
* Providing logs for debugging and remediation
* Storing dbt artifacts for direct consumption/ingestion by the Discovery API

The scheduler also:

* Uses [dbt's Git repository caching](https://docs.getdbt.com/docs/cloud/account-settings#git-repository-caching) to protect against third-party outages and improve job run reliability. [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")
* Powers running dbt in staging and production environments, bringing ease and confidence to CI/CD workflows and enabling observability and governance in deploying dbt at scale.
* Uses [Hybrid projects](https://docs.getdbt.com/docs/deploy/hybrid-projects) to upload dbt Core artifacts into dbt for central visibility, cross-project referencing, and easier collaboration. [Beta](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")
* Uses [state-aware orchestration](https://docs.getdbt.com/docs/deploy/state-aware-about) to decide what needs to be rebuilt based on source freshness, model staleness, and code changes. [Beta](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

## Scheduler terms[​](#scheduler-terms "Direct link to Scheduler terms")

Familiarize yourself with these useful terms to help you understand how the job scheduler works.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Term Definition|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Scheduler The dbt engine that powers job execution. The scheduler queues scheduled or API-triggered job runs, prepares an environment to execute job commands in your cloud data platform, and stores and serves logs and artifacts that are byproducts of run execution.| Job A collection of run steps, settings, and a trigger to invoke dbt commands against a project in the user's cloud data platform.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Job queue The job queue acts as a waiting area for job runs when they are scheduled or triggered to run; runs remain in queue until execution begins. More specifically, the Scheduler checks the queue for runs that are due to execute, ensures the run is eligible to start, and then prepares an environment with appropriate settings, credentials, and commands to begin execution. Once execution begins, the run leaves the queue.|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Over-scheduled job A situation when a cron-scheduled job's run duration becomes longer than the frequency of the job’s schedule, resulting in a job queue that will grow faster than the scheduler can process the job’s runs.|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Deactivated job A situation where a job has reached 100 consecutive failing runs.|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Prep time The time dbt takes to create a short-lived environment to execute the job commands in the user's cloud data platform. Prep time varies most significantly at the top of the hour when the dbt Scheduler experiences a lot of run traffic.| Run A single, unique execution of a dbt job.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Run slot Run slots control the number of jobs that can run concurrently. Each running job occupies a run slot for the duration of the run. To view the number of run slots available in your plan, check out the [dbt pricing page](https://www.getdbt.com/pricing).   Starter and Developer plans are limited to one project each. For additional projects or more run slots, consider upgrading to an [Enterprise-tier plan](https://www.getdbt.com/pricing/).| Threads When dbt builds a project's DAG, it tries to parallelize the execution by using threads. The [thread](https://docs.getdbt.com/docs/running-a-dbt-project/using-threads) count is the maximum number of paths through the DAG that dbt can work on simultaneously. The default thread count in a job is 4.| Wait time Amount of time that dbt waits before running a job, either because there are no available slots or because a previous run of the same job is still in progress. | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Scheduler queue[​](#scheduler-queue "Direct link to Scheduler queue")

The scheduler queues a deployment job to be processed when it's triggered to run by a [set schedule](https://docs.getdbt.com/docs/deploy/deploy-jobs#schedule-days), [a job completed](https://docs.getdbt.com/docs/deploy/deploy-jobs#trigger-on-job-completion), an API call, or manual action.

Before the job starts executing, the scheduler checks these conditions to determine if the run can start executing:

* **Is there a run slot that's available on the account for use?** — If all run slots are occupied, the queued run will wait. The wait time is displayed in dbt. If there are long wait times, [upgrading to an Enterprise-tier plan](https://www.getdbt.com/contact/) can provide more run slots and allow for higher job concurrency.
* **Does this same job have a run already in progress?** — The scheduler executes distinct runs of the same dbt job serially to avoid model build collisions. If there's a job already running, the queued job will wait, and the wait time will be displayed in dbt.

If there is an available run slot and there isn't an actively running instance of the job, the scheduler will prepare the job to run in your cloud data platform. This prep involves readying a Kubernetes pod with the right version of dbt installed, setting environment variables, loading data platform credentials, and Git provider authorization, amongst other environment-setting tasks. The time it takes to prepare the job is displayed as **Prep time** in the UI.

[![An overview of a dbt job run](https://docs.getdbt.com/img/docs/dbt-cloud/deployment/deploy-scheduler.png?v=2 "An overview of a dbt job run")](#)An overview of a dbt job run

### Treatment of CI jobs[​](#treatment-of-ci-jobs "Direct link to Treatment of CI jobs")

When compared to deployment jobs, the scheduler behaves differently when handling [continuous integration (CI) jobs](https://docs.getdbt.com/docs/deploy/continuous-integration). It queues a CI job to be processed when it's triggered to run by a Git pull request, and the conditions the scheduler checks to determine if the run can start executing are also different:

* **Will the CI run consume a run slot?** — CI runs don't consume run slots and will never block production runs.
* **Does this same job have a run already in progress?** — CI runs can execute concurrently (in parallel). CI runs build into unique temporary schemas, and CI checks execute in parallel to help increase team productivity. Teammates never have to wait to get a CI check review.

### Treatment of merge jobs[​](#treatment-of-merge-jobs "Direct link to Treatment of merge jobs")

When triggered by a *merged* Git pull request, the scheduler queues a [merge job](https://docs.getdbt.com/docs/deploy/merge-jobs) to be processed.

* **Will the merge job run consume a run slot?** — Yes, merge jobs do consume run slots.
* **Does this same job have a run already in progress?** — A merge job can only have one run in progress at a time. If there are multiple runs queued up, the scheduler will enqueue the most recent run and cancel all the other runs. If there is a run in progress, it will wait until the run completes before queuing the next run.

## Job memory[​](#job-memory "Direct link to Job memory")

In dbt, the setting to provision memory available to a job is defined at the account-level and applies to each job running in the account; the memory limit cannot be customized per job. If a running job reaches its memory limit, the run is terminated with a "memory limit error" message.

Jobs consume a lot of memory in the following situations:

* A high thread count was specified
* Custom dbt macros attempt to load data into memory instead of pushing compute down to the cloud data platform
* Having a job that generates dbt project documentation for a large and complex dbt project.
  + To prevent problems with the job running out of memory, we recommend generating documentation in a separate job that is set aside for that task and removing `dbt docs generate` from all other jobs. This is especially important for large and complex projects.

Refer to [dbt architecture](https://docs.getdbt.com/docs/cloud/about-cloud/architecture) for an architecture diagram and to learn how the data flows.

## Run cancellation for over-scheduled jobs[​](#run-cancellation-for-over-scheduled-jobs "Direct link to Run cancellation for over-scheduled jobs")

Scheduler won't cancel API-triggered jobs

The scheduler will not cancel over-scheduled jobs triggered by the [API](https://docs.getdbt.com/docs/dbt-cloud-apis/overview).

The dbt scheduler prevents too many job runs from clogging the queue by canceling unnecessary ones. If a job takes longer to run than its scheduled frequency, the queue will grow faster than the scheduler can process the runs, leading to an ever-expanding queue with runs that don’t need to be processed (called *over-scheduled jobs*).

The scheduler prevents queue clog by canceling runs that aren't needed, ensuring there is only one run of the job in the queue at any given time. If a newer run is queued, the scheduler cancels any previously queued run for that job and displays an error message.

[![The cancelled runs display an error message explaining why the run was cancelled and recommendations](https://docs.getdbt.com/img/docs/dbt-cloud/deployment/run-error-message.png?v=2 "The cancelled runs display an error message explaining why the run was cancelled and recommendations")](#)The cancelled runs display an error message explaining why the run was cancelled and recommendations

To prevent over-scheduling, users will need to take action by either refactoring the job so it runs faster or modifying its [schedule](https://docs.getdbt.com/docs/deploy/deploy-jobs#schedule-days).

## Deactivation of jobs [Beta](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")[​](#deactivation-of-jobs- "Direct link to deactivation-of-jobs-")

To reduce unnecessary resource consumption and reduce contention for run slots in your account, dbt will deactivate a [deploy job](https://docs.getdbt.com/docs/deploy/deploy-jobs) or a [CI job](https://docs.getdbt.com/docs/deploy/ci-jobs) if it reaches 100 consecutive failing runs. A banner containing this message is displayed when a job is deactivated: "Job has been deactivated due to repeated run failures. To reactivate, verify the job is configured properly and run manually or reenable any trigger". When this happens, scheduled and triggered-to-run jobs will no longer be enqueued.

To reactivate a deactivated job, you can either:

* Update the job's settings to fix the issue and save the job (recommended)
* Perform a manual run by clicking **Run now** on the job's page

## FAQs[​](#faqs "Direct link to FAQs")

I'm receiving a 'This run exceeded your account's run memory limits' error in my failed job

If you're receiving a `This run exceeded your account's run memory limits` error in your failed job, it means that the job exceeded the [memory limits](https://docs.getdbt.com/docs/deploy/job-scheduler#job-memory) set for your account. All dbt accounts have a pod memory of 600Mib and memory limits are on a per run basis. They're typically influenced by the amount of result data that dbt has to ingest and process, which is small but can become bloated unexpectedly by project design choices.

### Common reasons[​](#common-reasons "Direct link to Common reasons")

Some common reasons for higher memory usage are:

* dbt run/build: Macros that capture large result sets from run query may not all be necessary and may be memory inefficient.
* dbt docs generate: Source or model schemas with large numbers of tables (even if those tables aren't all used by dbt) cause the ingest of very large results for catalog queries.

### Resolution[​](#resolution "Direct link to Resolution")

There are various reasons why you could be experiencing this error but they are mostly the outcome of retrieving too much data back into dbt. For example, using the `run_query()` operations or similar macros, or even using database/schemas that have a lot of other non-dbt related tables/views. Try to reduce the amount of data / number of rows retrieved back into dbt by refactoring the SQL in your `run_query()` operation using `group`, `where`, or `limit` clauses. Additionally, you can also use a database/schema with fewer non-dbt related tables/views.

Video example

As an additional resource, check out [this example video](https://www.youtube.com/watch?v=sTqzNaFXiZ8), which demonstrates how to refactor the sample code by reducing the number of rows returned.

If you've tried the earlier suggestions and are still experiencing failed job runs with this error about hitting the memory limits of your account, please [reach out to support](mailto:support@getdbt.com). We're happy to help!

### Additional resources[​](#additional-resources "Direct link to Additional resources")

* [Blog post on how we shaved 90 mins off](https://docs.getdbt.com/blog/how-we-shaved-90-minutes-off-model)

## Related docs[​](#related-docs "Direct link to Related docs")

* [dbt architecture](https://docs.getdbt.com/docs/cloud/about-cloud/architecture#dbt-cloud-features-architecture)
* [Job commands](https://docs.getdbt.com/docs/deploy/job-commands)
* [Job notifications](https://docs.getdbt.com/docs/deploy/job-notifications)
* [Webhooks](https://docs.getdbt.com/docs/deploy/webhooks)
* [dbt continuous integration](https://docs.getdbt.com/docs/deploy/continuous-integration)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)[Next

Deployment environments](https://docs.getdbt.com/docs/deploy/deploy-environments)

* [Scheduler terms](#scheduler-terms)* [Scheduler queue](#scheduler-queue)
    + [Treatment of CI jobs](#treatment-of-ci-jobs)+ [Treatment of merge jobs](#treatment-of-merge-jobs)* [Job memory](#job-memory)* [Run cancellation for over-scheduled jobs](#run-cancellation-for-over-scheduled-jobs)* [Deactivation of jobs](#deactivation-of-jobs-) * [FAQs](#faqs)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/job-scheduler.md)
