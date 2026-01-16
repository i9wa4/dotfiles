---
title: "Move from dbt Core to the dbt platform: Get started | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/core-to-cloud-1?step=8"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcore-to-cloud-1+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcore-to-cloud-1+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcore-to-cloud-1+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides) Total estimated time: 3-4 hours

Migration

dbt Core

dbt platform

Intermediate

Menu

## Introduction[​](#introduction "Direct link to Introduction")

Moving from dbt Core to dbt streamlines analytics engineering workflows by allowing teams to develop, test, deploy, and explore data products using a single, fully managed software service.

Explore our 3-part-guide series on moving from dbt Core to dbt. This series is ideal for users aiming for streamlined workflows and enhanced analytics:

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guide  Information  Audience |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Move from dbt Core to dbt platform: What you need to know](https://docs.getdbt.com/guides/core-cloud-2) Understand the considerations and methods needed in your move from dbt Core to dbt platform. Team leads   Admins| [Move from dbt Core to dbt platform: Get started](https://docs.getdbt.com/guides/core-to-cloud-1?step=1) Learn the steps needed to move from dbt Core to dbt platform. Developers   Data engineers   Data analysts| [Move from dbt Core to dbt platform: Optimization tips](https://docs.getdbt.com/guides/core-to-cloud-3) Learn how to optimize your dbt experience with common scenarios and useful tips. Everyone | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Why move to the dbt platform?[​](#why-move-to-the-dbt-platform "Direct link to Why move to the dbt platform?")

If your team is using dbt Core today, you could be reading this guide because:

* You’ve realized the burden of maintaining that deployment.
* The person who set it up has since left.
* You’re interested in what dbt could do to better manage the complexity of your dbt deployment, democratize access to more contributors, or improve security and governance practices.

Moving from dbt Core to dbt simplifies workflows by providing a fully managed environment that improves collaboration, security, and orchestration. With dbt, you gain access to features like cross-team collaboration ([dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro)), version management, streamlined CI/CD, [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) for comprehensive insights, and more — making it easier to manage complex dbt deployments and scale your data workflows efficiently.

It's ideal for teams looking to reduce the burden of maintaining their own infrastructure while enhancing governance and productivity. What are dbt and dbt Core?

* dbt is the fastest and most reliable way to deploy dbt. It enables you to develop, test, deploy, and explore data products using a single, fully managed service. It also supports:
  + Development experiences tailored to multiple personas ([Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) or [Cloud CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation))
  + Out-of-the-box [CI/CD workflows](https://docs.getdbt.com/docs/deploy/ci-jobs)
  + The [Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl) for consistent metrics
  + Domain ownership of data with multi-project [dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro) setups
  + [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) for easier data discovery and understanding

Learn more about [dbt features](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features).

* dbt Core is an open-source tool that enables data teams to define and execute data transformations in a cloud data warehouse following analytics engineering best practices. While this can work well for ‘single players’ and small technical teams, all development happens on a command-line interface, and production deployments must be self-hosted and maintained. This requires significant, costly work that adds up over time to maintain and scale.

## What you'll learn[​](#what-youll-learn "Direct link to What you'll learn")

This guide outlines the steps you need to take to move from dbt Core to dbt and highlights the necessary technical changes:

* [Account setup](https://docs.getdbt.com/guides/core-to-cloud-1?step=4): Learn how to create a dbt account, invite team members, and configure it for your team.
* [Data platform setup](https://docs.getdbt.com/guides/core-to-cloud-1?step=5): Find out about connecting your data platform to dbt.
* [Git setup](https://docs.getdbt.com/guides/core-to-cloud-1?step=6): Learn to link your dbt project's Git repository with dbt.
* [Developer setup:](https://docs.getdbt.com/guides/core-to-cloud-1?step=7) Understand the setup needed for developing in dbt.
* [Environment variables](https://docs.getdbt.com/guides/core-to-cloud-1?step=8): Discover how to manage environment variables in dbt, including their priority.
* [Orchestration setup](https://docs.getdbt.com/guides/core-to-cloud-1?step=9): Learn how to prepare your dbt environment and jobs for orchestration.
* [Models configuration](https://docs.getdbt.com/guides/core-to-cloud-1?step=10): Get insights on validating and running your models in dbt, using either the Studio IDE or dbt CLI.
* [What's next?](https://docs.getdbt.com/guides/core-to-cloud-1?step=11): Summarizes key takeaways and introduces what to expect in the following guides.

### Related docs[​](#related-docs "Direct link to Related docs")

* [Learn dbt](https://learn.getdbt.com) on-demand video learning.
* Book [expert-led demos](https://www.getdbt.com/resources/dbt-cloud-demos-with-experts) and insights
* Work with the [dbt Labs’ Professional Services](https://www.getdbt.com/dbt-labs/services) team to support your data organization and migration.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You have an existing dbt Core project connected to a Git repository and data platform supported in [dbt](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections).
* You have a dbt account. **[Don't have one? Start your free trial today](https://www.getdbt.com/signup)**!

## Account setup[​](#account-setup "Direct link to Account setup")

This section outlines the steps to set up your dbt account and configure it for your team.

1. [Create your dbt account](https://www.getdbt.com/signup).
2. Provide user [access](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access) and [invite users](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access) to your dbt account and project.
3. Configure [Single Sign-On (SSO)](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview) or [Role-based access control (RBAC)](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#role-based-access-control) for easy and secure access. [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

   * This removes the need to save passwords and secret environment variables locally.

### Additional configuration[​](#additional-configuration "Direct link to Additional configuration")

Explore these additional configurations for performance and reliability improvements:

1. In **Account settings**, enable [partial parsing](https://docs.getdbt.com/docs/cloud/account-settings#partial-parsing) to only reparse changed files, saving time.
2. In **Account settings**, enable [Git repo caching](https://docs.getdbt.com/docs/cloud/account-settings#git-repository-caching) for job reliability & third-party outage protection. [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

## Data platform setup[​](#data-platform-setup "Direct link to Data platform setup")

This section outlines the considerations and methods to connect your data platform to dbt.

1. In dbt, set up your [data platform connections](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections) and [environment variables](https://docs.getdbt.com/docs/build/environment-variables). dbt can connect with a variety of data platform providers including:

   * [AlloyDB](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-postgresql-alloydb)
   * [Amazon Athena](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-amazon-athena)
   * [Amazon Redshift](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-redshift)
   * [Apache Spark](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-apache-spark)
   * [Azure Synapse Analytics](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-azure-synapse-analytics)
   * [Databricks](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-databricks)
   * [Google BigQuery](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-bigquery)
   * [Microsoft Fabric](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-microsoft-fabric)
   * [PostgreSQL](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-postgresql-alloydb)
   * [Snowflake](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-snowflake)
   * [Starburst or Trino](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-starburst-trino)
   * [Teradata](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-teradata)
2. You can verify your data platform connections by clicking the **Test connection** button in your deployment and development credentials settings.

### Additional configuration[​](#additional-configuration-1 "Direct link to Additional configuration")

Explore these additional configurations to optimize your data platform setup further:

1. Use [OAuth connections](https://docs.getdbt.com/docs/cloud/manage-access/set-up-snowflake-oauth), which enables secure authentication using your data platform’s SSO. [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

## Git setup[​](#git-setup "Direct link to Git setup")

Your existing dbt project source code should live in a Git repository. In this section, you will connect your existing dbt project source code from Git to dbt.

1. Ensure your dbt project is in a Git repository.
2. In **Account settings**, select **Integrations** to [connect your Git repository](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud) to dbt:

   * (**Recommended**) Connect with one of the [native integrations](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud) in dbt (such as GitHub, GitLab, and Azure DevOps).

     This method is preferred for its simplicity, security features (including secure OAuth logins and automated workflows like CI builds on pull requests), and overall ease of use.
   * [Import a Git repository](https://docs.getdbt.com/docs/cloud/git/import-a-project-by-git-url) from any valid Git URL that points to a dbt project.

## Developer setup[​](#developer-setup "Direct link to Developer setup")

This section highlights the development configurations you’ll need for your dbt project. The following categories are covered in this section:

* [dbt environments](https://docs.getdbt.com/guides/core-to-cloud-1?step=7#dbt-cloud-environments)
* [Initial setup steps](https://docs.getdbt.com/guides/core-to-cloud-1?step=7#initial-setup-steps)
* [Additional configuration](https://docs.getdbt.com/guides/core-to-cloud-1?step=7#additional-configuration-2)
* [dbt commands](https://docs.getdbt.com/guides/core-to-cloud-1?step=7#dbt-cloud-commands)

### dbt environments[​](#dbt-environments "Direct link to dbt environments")

The most common data environments are production, staging, and development. The way dbt Core manages [environments](https://docs.getdbt.com/docs/environments-in-dbt) is through `target`, which are different sets of connection details.

[dbt environments](https://docs.getdbt.com/docs/dbt-cloud-environments) go further by:

* Integrating with features such as job scheduling or version control, making it easier to manage the full lifecycle of your dbt projects within a single platform.
* Streamlining the process of switching between development, staging, and production contexts.
* Making it easy to configure environments through the dbt UI instead of manually editing the `profiles.yml` file. You can also [set up](https://docs.getdbt.com/reference/dbt-jinja-functions/target) or [customize](https://docs.getdbt.com/docs/build/custom-target-names) target names in dbt.
* Adding `profiles.yml` attributes to dbt environment settings with [Extended Attributes](https://docs.getdbt.com/docs/dbt-cloud-environments#extended-attributes).
* Using [Git repo caching](https://docs.getdbt.com/docs/cloud/account-settings#git-repository-caching) to protect you from third-party outages, Git auth failures, and more. [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

### Initial setup steps[​](#initial-setup-steps "Direct link to Initial setup steps")

1. **Set up development environment** — Set up your [development](https://docs.getdbt.com/docs/dbt-cloud-environments#create-a-development-environment) environment and [development credentials](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio#access-the-cloud-ide). You’ll need this to access your dbt project and start developing.
2. **dbt Core version** — In your dbt environment, select a [release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) for ongoing dbt version upgrades. If your team plans to use both dbt Core and dbt for developing or deploying your dbt project, you can run `dbt --version` in the command line to find out which version of dbt Core you’re using.

   * When using dbt Core, you need to think about which version you’re using and manage your own upgrades. When using dbt, leverage [release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) so you don’t have to.
3. **Connect to your data platform** — When using dbt, you can [connect to your data platform](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections) directly in the UI.

   * Each environment is roughly equivalent to an entry in your `profiles.yml` file. This means you don't need a `profiles.yml` file in your project.
4. **Development tools** — Set up your development workspace with the [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation) (command line interface or code editor) or [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) (browser-based) to build, test, run, and version control your dbt code in your tool of choice.

   * If you've previously installed dbt Core, the [dbt CLI installation doc](https://docs.getdbt.com/docs/cloud/cloud-cli-installation?install=pip#install-dbt-cloud-cli) has more information on how to install the dbt CLI, create aliases, or uninstall dbt Core for a smooth transition.

### Additional configuration[​](#additional-configuration-2 "Direct link to Additional configuration")

Explore these additional configurations to optimize your developer setup further:

1. **Custom target names** — Using [`custom target.names`](https://docs.getdbt.com/docs/build/custom-target-names) in your dbt projects helps identify different environments (like development, staging, and production). While you can specify the `custom target.name` values in your developer credentials or orchestration setup, we recommend using [environment variables](https://docs.getdbt.com/docs/build/environment-variables) as the preferred method. They offer a clearer way to handle different environments and are better supported by dbt's partial parsing feature, unlike using [`{{ target }}` logic](https://docs.getdbt.com/reference/dbt-jinja-functions/target) which is meant for defining the data warehouse connection.

### dbt commands[​](#dbt-commands "Direct link to dbt commands")

1. Review the [dbt commands](https://docs.getdbt.com/reference/dbt-commands) supported for dbt development. For example, `dbt init` isn’t needed in dbt as you can create a new project directly in dbt.

## Environment variables[​](#environment-variables "Direct link to Environment variables")

This section will help you understand how to set up and manage dbt environment variables for your project. The following categories are covered:

* [Environment variables in dbt](https://docs.getdbt.com/guides/core-to-cloud-1?step=7#environment-variables-in-dbt-cloud)
* [dbt environment variables order of precedence](https://docs.getdbt.com/guides/core-to-cloud-1?step=7#dbt-cloud-environment-variables-order-of-precedence)
* [Set environment variables in dbt](https://docs.getdbt.com/guides/core-to-cloud-1?step=7#set-environment-variables-in-dbt-cloud)

In dbt, you can set [environment variables](https://docs.getdbt.com/docs/build/environment-variables) in the dbt user interface (UI). Read [Set up environment variables](#set-environment-variables-in-dbt-cloud) for more info.

In dbt Core, environment variables, or the [`env_var` function](https://docs.getdbt.com/reference/dbt-jinja-functions/env_var), are defined manually by the developer or within the external application running dbt.

### Environment variables in dbt[​](#environment-variables-in-dbt "Direct link to Environment variables in dbt")

* dbt environment variables must be prefixed with `DBT_` (including `DBT_ENV_CUSTOM_ENV_` or `DBT_ENV_SECRET`).
* If your dbt Core environment variables don’t follow this naming convention, perform a [“find and replace”](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio#dbt-cloud-ide-features) in your project to make sure all references to these environment variables contain the proper naming conventions.
* dbt secures environment variables that enable more flexible configuration of data warehouse connections or git provider integrations, offering additional measures for sensitive values, such as prefixing keys with `DBT_ENV_SECRET`to obscure them in logs and the UI.

[![Setting project level and environment level values](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/project-environment-view.png?v=2 "Setting project level and environment level values")](#)Setting project level and environment level values

### dbt environment variables order of precedence[​](#dbt-environment-variables-order-of-precedence "Direct link to dbt environment variables order of precedence")

Environment variables in dbt are managed with a clear [order of precedence](https://docs.getdbt.com/docs/build/environment-variables#setting-and-overriding-environment-variables), allowing users to define values at four levels (highest to lowest order of precedence):

* The job level (job override) or in the Studio IDE for an individual developer (personal override). *Highest precedence*
* The environment level, which can be overridden by the job level or personal override.
* A project-wide default value, which can be overridden by the environment level, job level, or personal override.
* The optional default argument supplied to the `env_var` Jinja function in the code. *Lowest precedence*

[![Environment variables order of precedence](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/Environment Variables/env-var-precdence.png?v=2 "Environment variables order of precedence")](#)Environment variables order of precedence

### Set environment variables in dbt[​](#set-environment-variables-in-dbt "Direct link to Set environment variables in dbt")

* To set these variables for an entire project or specific environments, navigate to **Deploy** > **Environments** > **Environment variables** tab.
* To set these variables at the job level, navigate to **Deploy** > **Jobs** > **Select your job** > **Settings** > **Advanced settings**.
* To set these variables at the personal override level, navigate to **Profile Settings** > **Credentials** > **Select your project** > **Environment variables**.

## Orchestration setup[​](#orchestration-setup "Direct link to Orchestration setup")

This section outlines the considerations and methods to set up your dbt environments and jobs for orchestration. The following categories are covered in this section:

* [dbt environments](https://docs.getdbt.com/guides/core-to-cloud-1?step=8#dbt-cloud-environments-1)
* [Initial setup steps](https://docs.getdbt.com/guides/core-to-cloud-1?step=8#initial-setup-steps-1)
* [Additional configuration](https://docs.getdbt.com/guides/core-to-cloud-1?step=8#additional-configuration-3)
* [CI/CD setup](https://docs.getdbt.com/guides/core-to-cloud-1?step=8#cicd-setup)

### dbt environments[​](#dbt-environments-1 "Direct link to dbt environments")

To use the [dbt's job scheduler](https://docs.getdbt.com/docs/deploy/job-scheduler), set up one environment as the production environment. This is the [deployment](https://docs.getdbt.com/docs/deploy/deploy-environments) environment. You can set up multiple environments for different stages of your deployment pipeline, such as development, staging/QA, and production.

### Initial setup steps[​](#initial-setup-steps-1 "Direct link to Initial setup steps")

1. **dbt Core version** — In your environment settings, configure dbt with the same dbt Core version.

   * Once your full migration is complete, we recommend upgrading your environments to [release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) to always get the latest features and more. You only need to do this once.
2. **Configure your jobs** — [Create jobs](https://docs.getdbt.com/docs/deploy/deploy-jobs#create-and-schedule-jobs) for scheduled or event-driven dbt jobs. You can use cron execution, manual, pull requests, or trigger on the completion of another job.

   * Note that alongside [jobs in dbt](https://docs.getdbt.com/docs/deploy/jobs), discover other ways to schedule and run your dbt jobs with the help of other tools. Refer to [Integrate with other tools](https://docs.getdbt.com/docs/deploy/deployment-tools) for more information.

### Additional configuration[​](#additional-configuration-3 "Direct link to Additional configuration")

Explore these additional configurations to optimize your dbt orchestration setup further:

1. **Custom target names** — Use environment variables to set a `custom target.name` for every [corresponding dbt job](https://docs.getdbt.com/docs/build/custom-target-names) at the environment level.
2. **dbt commands** — Add any relevant [dbt commands](https://docs.getdbt.com/docs/deploy/job-commands) to execute your dbt jobs runs.
3. **Notifications** — Set up [notifications](https://docs.getdbt.com/docs/deploy/job-notifications) by configuring email and Slack alerts to monitor your jobs.
4. **Monitoring tools** — Use [monitoring tools](https://docs.getdbt.com/docs/deploy/monitor-jobs) like run history, job retries, job chaining, dashboard status tiles, and more for a seamless orchestration experience.
5. **API access** — Create [API auth tokens](https://docs.getdbt.com/docs/dbt-cloud-apis/authentication) and access to [dbt APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/overview) as needed. [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")
6. **Catalog** — If you use [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) and run production jobs with an external orchestrator, ensure your production jobs run `dbt run` or `dbt build` to update and view models and their [metadata](https://docs.getdbt.com/docs/explore/explore-projects#generate-metadata) in Catalog. Running `dbt compile` alone will not update model metadata. In addition, features like column-level lineage also requires catalog metadata produced through running `dbt docs generate`. [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

### CI/CD setup[​](#cicd-setup "Direct link to CI/CD setup")

Building a custom solution to efficiently check code upon pull requests is complicated. With dbt, you can enable [continuous integration / continuous deployment (CI/CD)](https://docs.getdbt.com/docs/deploy/continuous-integration) and configure dbt to run your dbt projects in a temporary schema when new commits are pushed to open pull requests.

[![Workflow of continuous integration in dbt](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/ci-workflow.png?v=2 "Workflow of continuous integration in dbt")](#)Workflow of continuous integration in dbt

This build-on-PR functionality is a great way to catch bugs before deploying to production, and an essential tool for data practitioners.

1. Set up an integration with a native Git application (such as Azure DevOps, GitHub, GitLab) and a CI environment in dbt.
2. Create [a CI/CD job](https://docs.getdbt.com/docs/deploy/ci-jobs) to automate quality checks before code is deployed to production.
3. Run your jobs in a production environment to fully implement CI/CD. Future pull requests will also leverage the last production runs to compare against.

## Model development and discovery[​](#model-development-and-discovery "Direct link to Model development and discovery")

In this section, you’ll be able to validate whether your models run or compile correctly in your development tool of choice: The [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) or [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation).

You’ll want to make sure you set up your [development environment and credentials](https://docs.getdbt.com/docs/dbt-cloud-environments#set-developer-credentials).

1. In your [development tool](https://docs.getdbt.com/docs/cloud/about-develop-dbt) of choice, you can review your dbt project, ensure it's set up correctly, and run some [dbt commands](https://docs.getdbt.com/reference/dbt-commands):

   * Run `dbt compile` to make sure your project compiles correctly.
   * Run a few models in the Studio IDE or dbt CLI to ensure you’re experiencing accurate results in development.
2. Once your first job has successfully run in your production environment, use [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) to view your project's [resources](https://docs.getdbt.com/docs/build/projects) (such as models, tests, and metrics) and their data lineage  to gain a better understanding of its latest production state. [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

## What’s next?[​](#whats-next "Direct link to What’s next?")

Congratulations on completing the first part of your move to dbt 🎉!

You have learned:

* How to set up your dbt account
* How to connect your data platform and Git repository
* How to configure your development, orchestration, and CI/CD environments
* How to set up environment variables and validate your models

For the next steps, you can continue exploring our 3-part-guide series on moving from dbt Core to dbt:

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Guide  Information  Audience |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Move from dbt Core to dbt platform: What you need to know](https://docs.getdbt.com/guides/core-cloud-2) Understand the considerations and methods needed in your move from dbt Core to dbt platform. Team leads   Admins| [Move from dbt Core to dbt platform: Get started](https://docs.getdbt.com/guides/core-to-cloud-1?step=1) Learn the steps needed to move from dbt Core to dbt platform. Developers   Data engineers   Data analysts| [Move from dbt Core to dbt platform: Optimization tips](https://docs.getdbt.com/guides/core-to-cloud-3) Learn how to optimize your dbt experience with common scenarios and useful tips. Everyone | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Why move to the dbt platform?[​](#why-move-to-the-dbt-platform "Direct link to Why move to the dbt platform?")

If your team is using dbt Core today, you could be reading this guide because:

* You’ve realized the burden of maintaining that deployment.
* The person who set it up has since left.
* You’re interested in what dbt could do to better manage the complexity of your dbt deployment, democratize access to more contributors, or improve security and governance practices.

Moving from dbt Core to dbt simplifies workflows by providing a fully managed environment that improves collaboration, security, and orchestration. With dbt, you gain access to features like cross-team collaboration ([dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro)), version management, streamlined CI/CD, [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) for comprehensive insights, and more — making it easier to manage complex dbt deployments and scale your data workflows efficiently.

It's ideal for teams looking to reduce the burden of maintaining their own infrastructure while enhancing governance and productivity.

### Related docs[​](#related-docs-1 "Direct link to Related docs")

* [Learn dbt](https://learn.getdbt.com) video courses for on-demand learning.
* Book [expert-led demos](https://www.getdbt.com/resources/dbt-cloud-demos-with-experts) and insights.
* Work with the [dbt Labs’ Professional Services](https://www.getdbt.com/dbt-labs/services) team to support your data organization and migration.
* [How dbt compares with dbt Core](https://www.getdbt.com/product/dbt-core-vs-dbt-cloud) for a detailed comparison of dbt Core and dbt.
* Subscribe to the [dbt RSS alerts](https://status.getdbt.com/)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
