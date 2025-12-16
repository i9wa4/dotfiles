---
title: "Deploy dbt | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/deployments"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * Deploy dbt

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fdeployments+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fdeployments+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fdeployments+so+I+can+ask+questions+about+it.)

Use dbt's capabilities to seamlessly run a dbt job in production or staging environments. Rather than run dbt commands manually from the command line, you can leverage the [dbt's in-app scheduling](https://docs.getdbt.com/docs/deploy/job-scheduler) to automate how and when you execute dbt.

The dbt platform offers the easiest and most reliable way to run your dbt project in production. Effortlessly promote high quality code from development to production and build fresh data assets that your business intelligence tools and end users query to make business decisions. Deploying with dbt lets you:

* Keep production data fresh on a timely basis
* Ensure CI and production pipelines are efficient
* Identify the root cause of failures in deployment environments
* Maintain high-quality code and data in production
* Gain visibility into the [health](https://docs.getdbt.com/docs/explore/data-tile) of deployment jobs, models, and tests
* Uses [exports](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports) to write [saved queries](https://docs.getdbt.com/docs/build/saved-queries) in your data platform for reliable and fast metric reporting
* [Visualize](https://docs.getdbt.com/docs/cloud-integrations/downstream-exposures-tableau) and [orchestrate](https://docs.getdbt.com/docs/cloud-integrations/orchestrate-exposures) downstream exposures to understand how models are used in downstream tools and proactively refresh the underlying data sources during scheduled dbt jobs. [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")
* Use [dbt's Git repository caching](https://docs.getdbt.com/docs/cloud/account-settings#git-repository-caching) to protect against third-party outages and improve job run reliability. [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")
* Use [Hybrid projects](https://docs.getdbt.com/docs/deploy/hybrid-projects) to upload dbt artifacts into the dbt platform for central visibility, cross-project referencing, and easier collaboration. [Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing") Preview

Before continuing, make sure you understand dbt's approach to [deployment environments](https://docs.getdbt.com/docs/deploy/deploy-environments).

Learn how to use dbt's features to help your team ship timely and quality production data more easily.

## Deploy with dbt[​](#deploy-with-dbt "Direct link to Deploy with dbt")

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Job scheduler

The job scheduler is the backbone of running jobs in the dbt platform, bringing power and simplicity to building data pipelines in both continuous integration and production environments.](/docs/deploy/job-scheduler)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Deploy jobs

Create and schedule jobs for the job scheduler to run.

Runs on a schedule, by API, or after another job completes.](/docs/deploy/deploy-jobs)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### State-aware orchestration

Intelligently determines which models to build by detecting changes in code or data at each job run.](/docs/deploy/state-aware-about)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Continuous integration

Set up CI checks so you can build and test any modified code in a staging environment when you open PRs and push new commits to your dbt repository.](/docs/deploy/continuous-integration)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Continuous deployment

Set up merge jobs to ensure the latest code changes are always in production when pull requests are merged to your Git repository.](/docs/deploy/continuous-deployment)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Job commands

Configure which dbt commands to execute when running a dbt job.](/docs/deploy/job-commands)



## Monitor jobs and alerts[​](#monitor-jobs-and-alerts "Direct link to Monitor jobs and alerts")

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Visualize and orchestrate exposures

Learn how to use dbt to automatically generate downstream exposures from dashboards and proactively refresh the underlying data sources during scheduled dbt jobs.](/docs/deploy/orchestrate-exposures)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Artifacts

dbt generates and saves artifacts for your project, which it uses to power features like creating docs for your project and reporting the freshness of your sources.](/docs/deploy/artifacts)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Job notifications

Receive email or Slack channel notifications when a job run succeeds, fails, or is canceled so you can respond quickly and begin remediation if necessary.](/docs/deploy/job-notifications)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Model notifications

Receive email notifications in real time about issues encountered by your models and tests while a job is running.](/docs/deploy/model-notifications)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Run visibility

View the history of your runs and the model timing dashboard to help identify where improvements can be made to the scheduled jobs.](/docs/deploy/run-visibility)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Retry jobs

Rerun your errored jobs from start or the failure point.](/docs/deploy/retry-jobs)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Source freshness

Enable snapshots to capture the freshness of your data sources and configure how frequent these snapshots should be taken. This can help you determine whether your source data freshness is meeting your SLAs.](/docs/deploy/source-freshness)

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Webhooks

Create outbound webhooks to send events about your dbt jobs' statuses to other systems in your organization.](/docs/deploy/webhooks)



## Hybrid projects [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing") Preview[​](#hybrid-projects-- "Direct link to hybrid-projects--")

[![](https://docs.getdbt.com/img/icons/dbt-bit.svg)

#### Hybrid projects

Use Hybrid projects to upload dbt Core artifacts into the dbt platform for central visibility, cross-project referencing, and easier collaboration.](/docs/deploy/hybrid-projects)



## Related docs[​](#related-docs "Direct link to Related docs")

* [Use exports to materialize saved queries](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports)
* [Integrate with other orchestration tools](https://docs.getdbt.com/docs/deploy/deployment-tools)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

Job scheduler](https://docs.getdbt.com/docs/deploy/job-scheduler)
