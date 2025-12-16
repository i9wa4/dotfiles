---
title: "Merge jobs in dbt | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/merge-jobs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [Jobs](https://docs.getdbt.com/docs/deploy/jobs)* Merge jobs

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fmerge-jobs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fmerge-jobs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fmerge-jobs+so+I+can+ask+questions+about+it.)

On this page

You can set up a merge job to implement a continuous deployment (CD) workflow in dbt. The merge job triggers a dbt job to run when someone merges Git pull requests into production. This workflow creates a seamless development experience where changes made in code will automatically update production data. Also, you can use this workflow for running `dbt compile` to update your environment's manifest so subsequent CI job runs are more performant.

By using CD in dbt, you can take advantage of deferral to build only the edited model and any downstream changes. With merge jobs, state will be updated almost instantly, always giving the most up-to-date state information in [Catalog](https://docs.getdbt.com/docs/explore/explore-projects).

Triggering merge jobs in monorepos

If you have a monorepo with several dbt projects, merging a single pull request in one of your projects will trigger jobs for all projects connected to the monorepo. To address this, you can use separate target branches per project (for example, `main-project-a`, `main-project-b`) to separate CI triggers.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You have a dbt account.
* You have set up a [connection with your Git provider](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud). This integration lets dbt run jobs on your behalf for job triggering.
  + If you're using a native [GitLab](https://docs.getdbt.com/docs/cloud/git/connect-gitlab) integration, you need a paid or self-hosted account that includes support for GitLab webhooks and [project access tokens](https://docs.gitlab.com/ee/user/project/settings/project_access_tokens.html). If you're using GitLab Free, merge requests will trigger CI jobs but CI job status updates (success or failure of the job) will not be reported back to GitLab.
* For deferral (which is the default), make sure there has been at least one successful job run in the environment you defer to.

## Set up job trigger on Git merge[​](#set-up-merge-jobs "Direct link to Set up job trigger on Git merge")

1. On your deployment environment page, click **Create job** > **Merge job**.
2. Options in the **Job settings** section:
   * **Job name** — Specify the name for the merge job.
   * **Description** — Provide a description about the job.
   * **Environment** — By default, it’s set to the environment you created the job from.
3. In the **Git trigger** section, the **Run on merge** option is enabled by default. Every time a PR merges (to a base
   branch configured in the environment) in your Git repo, this job will get triggered to run.
4. Options in the **Execution settings** section:
   * **Commands** — By default, it includes the `dbt build --select state:modified+` command. This informs dbt to build only new or changed models and their downstream dependents. Importantly, state comparison can only happen when there is a deferred environment selected to compare state to. Click **Add command** to add more [commands](https://docs.getdbt.com/docs/deploy/job-commands) that you want to be invoked when this job runs.
   * **Compare changes against** — By default, it's set to compare changes against the environment you created the job from. This option allows dbt to check the state of the code in the PR against the code running in the deferred environment, so as to only check the modified code, instead of building the full table or the entire DAG. To change the default settings, you can select **No deferral**, **This job** for self-deferral, or choose a different environment.
5. (optional) Options in the **Advanced settings** section:
   * **Environment variables** — Define [environment variables](https://docs.getdbt.com/docs/build/environment-variables) to customize the behavior of your project when this job runs.
   * **Target name** — Define the [target name](https://docs.getdbt.com/docs/build/custom-target-names). Similar to environment variables, this option lets you customize the behavior of the project.
   * **Run timeout** — Cancel this job if the run time exceeds the timeout value.
   * **dbt version** — By default, it’s set to inherit the [dbt version](https://docs.getdbt.com/docs/dbt-versions/core) from the environment. dbt Labs strongly recommends that you don't change the default setting. This option to change the version at the job level is useful only when you upgrade a project to the next dbt version; otherwise, mismatched versions between the environment and job can lead to confusing behavior.
   * **Threads** — By default, it’s set to 4 [threads](https://docs.getdbt.com/docs/core/connect-data-platform/connection-profiles#understanding-threads). Increase the thread count to increase model execution concurrency.

[![Example of creating a merge job](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/example-create-merge-job.png?v=2 "Example of creating a merge job")](#)Example of creating a merge job

## Verify push events in Git[​](#verify-push-events-in-git "Direct link to Verify push events in Git")

Merge jobs require push events so make sure they've been enabled in your Git provider, especially if you have an already-existing Git integration. However, for a new integration setup, you can skip this check since push events are typically enabled by default.

 GitHub example

The following is a GitHub example of when the push events are already set:

[![Example of the Pushes option enabled in the GitHub settings](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/example-github-push-events.png?v=2 "Example of the Pushes option enabled in the GitHub settings")](#)Example of the Pushes option enabled in the GitHub settings

 GitLab example

The following is a GitLab example of when the push events are already set:

[![Example of the Push events option enabled in the GitLab settings](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/example-gitlab-push-events.png?v=2 "Example of the Push events option enabled in the GitLab settings")](#)Example of the Push events option enabled in the GitLab settings

 Azure DevOps example

The following is an example of creating a new **Code pushed** trigger in Azure DevOps. Create a new service hooks subscription when code pushed events haven't been set:

[![Example of creating a new trigger to push events in Azure Devops](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/example-azuredevops-new-event.png?v=2 "Example of creating a new trigger to push events in Azure Devops")](#)Example of creating a new trigger to push events in Azure Devops

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

CI jobs](https://docs.getdbt.com/docs/deploy/ci-jobs)[Next

Job commands](https://docs.getdbt.com/docs/deploy/job-commands)

* [Prerequisites](#prerequisites)* [Set up job trigger on Git merge](#set-up-merge-jobs)* [Verify push events in Git](#verify-push-events-in-git)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/merge-jobs.md)
