---
title: "Continuous integration in dbt | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/continuous-integration"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [Continuous integration](https://docs.getdbt.com/docs/deploy/about-ci)* Continuous integration

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fcontinuous-integration+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fcontinuous-integration+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fcontinuous-integration+so+I+can+ask+questions+about+it.)

On this page

To implement a continuous integration (CI) workflow in dbt, you can set up automation that tests code changes by running [CI jobs](https://docs.getdbt.com/docs/deploy/ci-jobs) before merging to production. dbt tracks the state of what’s running in your production environment so, when you run a CI job, only the modified data assets in your pull request (PR) and their downstream dependencies are built and tested in a staging schema. You can also view the status of the CI checks (tests) directly from within the PR; this information is posted to your Git provider as soon as a CI job completes. Additionally, you can enable settings in your Git provider that allow PRs only with successful CI checks to be approved for merging.

[![Workflow of continuous integration in dbt](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/ci-workflow.png?v=2 "Workflow of continuous integration in dbt")](#)Workflow of continuous integration in dbt

Using CI helps:

* Provide increased confidence and assurances that project changes will work as expected in production.
* Reduce the time it takes to push code changes to production, through build and test automation, leading to better business outcomes.
* Allow organizations to make code changes in a standardized and governed way that ensures code quality without sacrificing speed.

## How CI works[​](#how-ci-works "Direct link to How CI works")

When you [set up CI jobs](https://docs.getdbt.com/docs/deploy/ci-jobs#set-up-ci-jobs), dbt listens for a notification from your Git provider indicating that a new PR has been opened or updated with new commits. When dbt receives one of these notifications, it enqueues a new run of the CI job.

dbt builds and tests models, semantic models, metrics, and saved queries affected by the code change in a temporary schema, unique to the PR. This process ensures that the code builds without error and that it matches the expectations as defined by the project's dbt tests. The unique schema name follows the naming convention `dbt_cloud_pr_<job_id>_<pr_id>` (for example, `dbt_cloud_pr_1862_1704`) and can be found in the run details for the given run, as shown in the following image:

[![Viewing the temporary schema name for a run triggered by a PR](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/using_ci_dbt_cloud.png?v=2 "Viewing the temporary schema name for a run triggered by a PR")](#)Viewing the temporary schema name for a run triggered by a PR

When the CI run completes, you can view the run status directly from within the pull request. dbt updates the pull request in GitHub, GitLab, or Azure DevOps with a status message indicating the results of the run. The status message states whether the models and tests ran successfully or not.

dbt deletes the temporary schema from your data warehouse when you close or merge the pull request. If your project has schema customization using the [generate\_schema\_name](https://docs.getdbt.com/docs/build/custom-schemas#how-does-dbt-generate-a-models-schema-name) macro, dbt might not drop the temporary schema from your data warehouse. For more information, refer to [Troubleshooting](https://docs.getdbt.com/docs/deploy/ci-jobs#troubleshooting).

## Availability of features by Git provider[​](#availability-of-features-by-git-provider "Direct link to Availability of features by Git provider")

* If your git provider has a [native dbt integration](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud), you can seamlessly set up [continuous integration (CI)](https://docs.getdbt.com/docs/deploy/ci-jobs) jobs directly within dbt.
* For providers without native integration, you can still use the [Git clone method](https://docs.getdbt.com/docs/cloud/git/import-a-project-by-git-url) to import your git URL and leverage the [dbt Administrative API](https://docs.getdbt.com/docs/dbt-cloud-apis/admin-cloud-api) to trigger a CI job to run.

The following table outlines the available integration options and their corresponding capabilities.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **Git provider** **Native dbt integration** **Automated CI job** **Git clone** **Information** **Supported plans**|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Azure DevOps](https://docs.getdbt.com/docs/cloud/git/connect-azure-devops)  ✅ ✅ ✅ Organizations on the Starter and Developer plans can connect to Azure DevOps using a deploy key. Note, you won’t be able to configure automated CI jobs but you can still develop. Enterprise, Enterprise+|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [GitHub](https://docs.getdbt.com/docs/cloud/git/connect-github)  ✅ ✅ All dbt plans| [GitLab](https://docs.getdbt.com/docs/cloud/git/connect-gitlab)  ✅ ✅ ✅ All dbt plans| All other git providers using [Git clone](https://docs.getdbt.com/docs/cloud/git/import-a-project-by-git-url) ([BitBucket](https://docs.getdbt.com/docs/cloud/git/import-a-project-by-git-url#bitbucket), [AWS CodeCommit](https://docs.getdbt.com/docs/cloud/git/import-a-project-by-git-url#aws-codecommit), and others) ❌ ❌ ✅ Refer to the [Customizing CI/CD with custom pipelines](https://docs.getdbt.com/guides/custom-cicd-pipelines?step=1) guide to set up continuous integration and continuous deployment (CI/CD).  | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Differences between CI jobs and other deployment jobs[​](#differences-between-ci-jobs-and-other-deployment-jobs "Direct link to Differences between CI jobs and other deployment jobs")

The [dbt scheduler](https://docs.getdbt.com/docs/deploy/job-scheduler) executes CI jobs differently from other deployment jobs in these important ways:

* [**Concurrent CI checks**](#concurrent-ci-checks) — CI runs triggered by the same dbt CI job execute concurrently (in parallel), when appropriate.
* [**Smart cancellation of stale builds**](#smart-cancellation-of-stale-builds) — Automatically cancels stale, in-flight CI runs when there are new commits to the PR.
* [**Run slot treatment**](#run-slot-treatment) — CI runs don't consume a run slot.
* [**SQL linting**](#sql-linting) — When enabled, automatically lints all SQL files in your project as a run step before your CI job builds.

### Concurrent CI checks [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#concurrent-ci-checks- "Direct link to concurrent-ci-checks-")

When you have teammates collaborating on the same dbt project creating pull requests on the same dbt repository, the same CI job will get triggered. Since each run builds into a dedicated, temporary schema that’s tied to the pull request, dbt can safely execute CI runs *concurrently* instead of *sequentially* (differing from what is done with deployment dbt jobs). Because no one needs to wait for one CI run to finish before another one can start, with concurrent CI checks, your whole team can test and integrate dbt code faster.

The following describes the conditions when CI checks are run concurrently and when they’re not:

* CI runs with different PR numbers execute concurrently.
* CI runs with the *same* PR number and *different* commit SHAs execute serially because they’re building into the same schema. dbt will run the latest commit and cancel any older, stale commits. For details, refer to [Smart cancellation of stale builds](#smart-cancellation).
* CI runs with the same PR number and same commit SHA, originating from different dbt projects will execute jobs concurrently. This can happen when two CI jobs are set up in different dbt projects that share the same dbt repository.

### Smart cancellation of stale builds [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#smart-cancellation-of-stale-builds- "Direct link to smart-cancellation-of-stale-builds-")

When you push a new commit to a PR, dbt enqueues a new CI run for the latest commit and cancels any CI run that is (now) stale and still in flight. This can happen when you’re pushing new commits while a CI build is still in process and not yet done. By cancelling runs in a safe and deliberate way, dbt helps improve productivity and reduce data platform spend on wasteful CI runs.

[![Example of an automatically canceled run](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/example-smart-cancel-job.png?v=2 "Example of an automatically canceled run")](#)Example of an automatically canceled run

### Run slot treatment [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#run-slot-treatment- "Direct link to run-slot-treatment-")

CI runs don't consume run slots. This guarantees a CI check will never block a production run.

### SQL linting [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#sql-linting- "Direct link to sql-linting-")

Available on [dbt release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) and dbt Starter or Enterprise-tier accounts.

When [enabled for your CI job](https://docs.getdbt.com/docs/deploy/ci-jobs#set-up-ci-jobs), dbt invokes [SQLFluff](https://sqlfluff.com/) which is a modular and configurable SQL linter that warns you of complex functions, syntax, formatting, and compilation errors.

By default, SQL linting lints all the changed SQL files in your project (compared to the last deferred production state). Note that [snapshots](https://docs.getdbt.com/docs/build/snapshots) can be defined in YAML *and* `.sql` files, but its SQL isn't lintable and can cause errors during linting. To prevent SQLFluff from linting snapshot files, add the snapshots directory to your `.sqlfluffignore` file (for example `snapshots/`). Refer to [snapshot linting](https://docs.getdbt.com/docs/cloud/studio-ide/lint-format#snapshot-linting) for more information.

If the linter runs into errors, you can specify whether dbt should stop running the job on error or continue running it on error. When failing jobs, it helps reduce compute costs by avoiding builds for pull requests that don't meet your SQL code quality CI check.

#### To configure SQLFluff linting:[​](#to-configure-sqlfluff-linting "Direct link to To configure SQLFluff linting:")

You can optionally configure SQLFluff linting rules to override default linting behavior.

* Use [SQLFluff Configuration Files](https://docs.sqlfluff.com/en/stable/configuration/setting_configuration.html#configuration-files) to override the default linting behavior in dbt.
* Create a `.sqlfluff` configuration file in your project, add your linting rules to it, and dbt will use them when linting.
  + When configuring, you can use `dbt` as the templater (for example, `templater = dbt`)
  + If you’re using the Studio IDE, dbt CLI, or any other editor, refer to [Customize linting](https://docs.getdbt.com/docs/cloud/studio-ide/lint-format#customize-linting) for guidance on how to add the dbt-specific (or dbtonic) linting rules we use for own project.
* For complete details, refer to [Custom Usage](https://docs.sqlfluff.com/en/stable/gettingstarted.html#custom-usage) in the SQLFluff documentation.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About continuous integration](https://docs.getdbt.com/docs/deploy/about-ci)[Next

Advanced CI](https://docs.getdbt.com/docs/deploy/advanced-ci)

* [How CI works](#how-ci-works)* [Availability of features by Git provider](#availability-of-features-by-git-provider)* [Differences between CI jobs and other deployment jobs](#differences-between-ci-jobs-and-other-deployment-jobs)
      + [Concurrent CI checks](#concurrent-ci-checks-) + [Smart cancellation of stale builds](#smart-cancellation-of-stale-builds-) + [Run slot treatment](#run-slot-treatment-) + [SQL linting](#sql-linting-)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/continuous-integration.md)
