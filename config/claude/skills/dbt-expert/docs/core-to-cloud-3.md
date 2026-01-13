---
title: "Move from dbt Core to the dbt platform: Optimization tips | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/core-to-cloud-3"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcore-to-cloud-3+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcore-to-cloud-3+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fcore-to-cloud-3+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

Migration

dbt Core

dbt platform

Intermediate

Menu

## Introduction[​](#introduction "Direct link to Introduction")

Moving from dbt Core to dbt streamlines analytics engineering workflows by allowing teams to develop, test, deploy, and explore data products using a single, fully managed software service.

Explore our 3-part-guide series on moving from dbt Core to dbt. The series is ideal for users aiming for streamlined workflows and enhanced analytics:

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

## What you'll learn[​](#what-youll-learn "Direct link to What you'll learn")

You may have already started your move to dbt and are looking for tips to help you optimize your dbt experience. This guide includes tips and caveats for the following areas:

* [Adapters and connections](https://docs.getdbt.com/guides/core-to-cloud-3?step=3)
* [Development tools](https://docs.getdbt.com/guides/core-to-cloud-3?step=4)
* [Orchestration](https://docs.getdbt.com/guides/core-to-cloud-3?step=5)
* [Mesh](https://docs.getdbt.com/guides/core-to-cloud-3?step=6)
* [Semantic Layer](https://docs.getdbt.com/guides/core-to-cloud-3?step=7)
* [Catalog](https://docs.getdbt.com/guides/core-to-cloud-3?step=8)

## Adapters and connections[​](#adapters-and-connections "Direct link to Adapters and connections")

In dbt, you can natively connect to your data platform and test its [connection](https://docs.getdbt.com/docs/connect-adapters) with a click of a button. This is especially useful for users who are new to dbt or are looking to streamline their connection setup. Here are some tips and caveats to consider:

### Tips[​](#tips "Direct link to Tips")

* Manage [dbt versions](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud) and ensure team collaboration with dbt's one-click feature, eliminating the need for manual updates and version discrepancies. Select a [release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) for ongoing updates, to always stay up to date with fixes and (optionally) get early access to new functionality for your dbt project.
* dbt supports a whole host of [cloud providers](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections), including Snowflake, Databricks, BigQuery, Fabric, and Redshift (to name a few).
* Use [Extended Attributes](https://docs.getdbt.com/docs/deploy/deploy-environments#extended-attributes) to set a flexible [profiles.yml](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml) snippet in your dbt environment settings. It gives you more control over environments (both deployment and development) and extends how dbt connects to the data platform within a given environment.
  + For example, if you have a field in your `profiles.yml` that you’d like to add to the dbt adapter user interface, you can use Extended Attributes to set it.

### Caveats[​](#caveats "Direct link to Caveats")

* Not all parameters are available for adapters.
* A project can only use one warehouse type.

## Development tools[​](#development-tools "Direct link to Development tools")

dbt empowers data practitioners to develop in the tool of their choice. It ships with a [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation) (local) or [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) (browser-based) to build, test, run, and version control your dbt projects.

Both development tools are tailored to suit different audiences and preferences within your team. To streamline your team’s workflow, it's important to know who will prefer the Studio IDE and who might lean towards the dbt CLI. This section aims to clarify these preferences.

### Studio IDE[​](#studio-ide "Direct link to Studio IDE")

A web-based interface for building, testing, running, and version-controlling dbt projects. It compiles dbt code into SQL and executes it directly on your database. The Studio IDE makes developing fast and easy for new and seasoned data practitioners to build and test changes.

**Who might prefer the Studio IDE?**

* New dbt users or those transitioning from other tools who appreciate a more guided experience through a browser-based interface.
* Team members focused on speed and convenience for getting started with a new or existing project.
* Individuals who prioritize direct feedback from the Studio IDE, such as seeing unsaved changes.

**Key features**

* The Studio IDE has simplified Git functionality:
  + Create feature branches from the branch configured in the development environment.
  + View saved but not-committed code changes directly in the Studio IDE.
* [Format or lint](https://docs.getdbt.com/docs/cloud/studio-ide/lint-format) your code with `sqlfluff` or `sqlfmt`. This includes support for adding your custom linting rules.
* Allows users to natively [defer to production](https://docs.getdbt.com/docs/cloud/about-cloud-develop-defer#defer-in-dbt-cloud-cli) metadata directly in their development workflows, reducing the number of objects.
* Support running multiple dbt commands at the same time through [safe parallel execution](https://docs.getdbt.com/reference/dbt-commands#parallel-execution), a [feature](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features) available in dbt's infrastructure. In contrast, `dbt-core` *doesn't support* safe parallel execution for multiple invocations in the same process.

The Studio IDE provides a simplified interface that's accessible to all users, regardless of their technical background. However, there are some capabilities that are intentionally not available in the Studio IDE due to its focus on simplicity and ease of use:

* Pre-commit for automated checks before *committing* code is not available (yet).
* Mass-generating files / interacting with the file system are not available.
* Combining/piping commands, such as `dbt run -s (bash command)`, is not available.

### dbt CLI[​](#dbt-cli "Direct link to dbt CLI")

The dbt CLI allows you to run dbt [commands](https://docs.getdbt.com/reference/dbt-commands#available-commands) against your dbt development environment from your local command line. For users who seek full control over their development environment and ideal for those comfortable with the command line.

When moving from dbt Core to dbt, make sure you check the `.gitignore` file contains the [necessary folders](https://docs.getdbt.com/docs/cloud/git/version-control-basics#the-gitignore-file). dbt Core doesn't interact with git so dbt doesn't automatically add or verify entries in the `.gitignore` file. Additionally, if the repository already contains dbt code and doesn't require initialization, dbt won't add any missing entries to the `.gitignore file`.

**Who might prefer the dbt CLI?**

* Data practitioners accustomed to working with a specific set of development tooling.
* Users looking for granular control over their Git workflows (such as pre-commits for automated checks before committing code).
* Data practitioners who need to perform complex operations, like mass file generation or specific command combinations.

**Key features**

* Allows users to run dbt commands against their dbt development environment from their local command line with minimal configuration.
* Allows users to natively [defer to production](https://docs.getdbt.com/docs/cloud/about-cloud-develop-defer#defer-in-dbt-cloud-cli) metadata directly in their development workflows, reducing the number of objects.
* Support running multiple dbt commands at the same time through [safe parallel execution](https://docs.getdbt.com/reference/dbt-commands#parallel-execution), a [feature](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features) available in dbt's infrastructure. In contrast, `dbt-core` *doesn't support* safe parallel execution for multiple invocations in the same process.
* Able to use Visual Studio (VS) Code extensions

## Orchestration[​](#orchestration "Direct link to Orchestration")

dbt provides robust orchestration that enables you to schedule, run, and monitor dbt jobs with ease. Here are some tips and caveats to consider when using dbt's orchestration features:

### Tips[​](#tips-1 "Direct link to Tips")

* Enable [partial parsing](https://docs.getdbt.com/docs/cloud/account-settings#partial-parsing) between jobs in dbt to significantly speed up project parsing by only processing changed files, optimizing performance for large projects.
* [Run multiple CI/CD](https://docs.getdbt.com/docs/deploy/continuous-integration) jobs at the same time which will not block production runs. The Job scheduler automatically cancels stale runs when a newer commit is pushed. This is because each PR will run in its own schema.
* dbt automatically [cancels](https://docs.getdbt.com/docs/deploy/job-scheduler#run-cancellation-for-over-scheduled-jobs) a scheduled run if the existing run is still executing. This prevents unnecessary, duplicative executions.
* Protect you and your data freshness from third-party outages by enabling dbt’s [Git repository caching](https://docs.getdbt.com/docs/cloud/account-settings#git-repository-caching), which keeps a cache of the project's Git repository. [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")
* [Link deploy jobs](https://docs.getdbt.com/docs/deploy/deploy-jobs#trigger-on-job-completion) across dbt projects by configuring your job or using the [Create Job API](https://docs.getdbt.com/dbt-cloud/api-v2#/operations/Create%20Job) to do this. [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")
* [Rerun your jobs](https://docs.getdbt.com/docs/deploy/retry-jobs) from the start or the point of failure if your dbt job run completed with a status of **`Error.`**

### Caveats[​](#caveats-1 "Direct link to Caveats")

* To automate the setup and configuration of your dbt platform, you can store your job configurations as code within a repository:
  + Check out our [Terraform provider.](https://registry.terraform.io/providers/dbt-labs/dbtcloud/latest/docs/resources/job)
  + Alternatively, check out our [jobs-as-code](https://github.com/dbt-labs/dbt-jobs-as-code) repository, which is a tool built to handle dbt jobs as a well-defined YAML file.
* dbt users and external emails can receive notifications if a job fails, succeeds, or is cancelled. To get notifications for warnings, you can create a [webhook subscription](https://docs.getdbt.com/guides/zapier-slack) and post to Slack.

## dbt Mesh[​](#dbt-mesh "Direct link to dbt Mesh")

[Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro) helps organizations with mature, complex transformation workflows in dbt increase the flexibility and performance of their dbt projects. It allows you to make use of multiple interconnected dbt projects instead of a single large, monolithic project.

It enables you to interface and navigate between different projects and models with [cross-project dependencies](https://docs.getdbt.com/docs/mesh/govern/project-dependencies#how-to-write-cross-project-ref), enhancing collaboration and data governance.

Here are some tips and caveats to consider when using Mesh:

### Tips[​](#tips-2 "Direct link to Tips")

* To dynamically resolve [cross-project references](https://docs.getdbt.com/docs/mesh/govern/project-dependencies#how-to-write-cross-project-ref), all developers need to develop with dbt (either with the dbt CLI or Studio IDE). Cross-project references aren't natively supported in dbt Core, except by installing the source code from upstream projects [as packages](https://docs.getdbt.com/docs/build/packages#how-do-i-add-a-package-to-my-project)
* Link models across projects for a modular and scalable approach for your project and teams.
* Manage access to your dbt models both within and across projects using:
  + **[Groups](https://docs.getdbt.com/docs/mesh/govern/model-access#groups)** — Organize nodes in your dbt DAG that share a logical connection and assign an owner to the entire group.
  + **[Model access](https://docs.getdbt.com/docs/mesh/govern/model-access#access-modifiers)** — Control which other models or projects can reference this model.
  + **[Model versions](https://docs.getdbt.com/docs/mesh/govern/model-versions)** — Enable adoption and deprecation of models as they evolve.
  + **[Model contracts](https://docs.getdbt.com/docs/mesh/govern/model-contracts)** — Set clear expectations on the shape of the data to ensure data changes upstream of dbt or within a project's logic don't break downstream consumers' data products.
* Use [dbt-meshify](https://github.com/dbt-labs/dbt-meshify) to accelerate splitting apart your monolith into multiple projects.

### Caveats[​](#caveats-2 "Direct link to Caveats")

* To use cross-project references in dbt, each dbt project must correspond to just one dbt project. We strongly discourage defining multiple projects for the same codebase, even if you're trying to manage access permissions, connect to different data warehouses, or separate production and non-production data. While this was required historically, features like [Staging environments](https://docs.getdbt.com/docs/dbt-cloud-environments#types-of-environments), Environment-level RBAC (*coming soon*), and [Extended attributes](https://docs.getdbt.com/docs/dbt-cloud-environments#extended-attributes) will make it unnecessary.
* Project dependencies are uni-directional, meaning they go in one direction. This means dbt checks for cycles across projects (circular dependencies) and raise errors if any are detected. However, we are considering support to allow projects to depend on each other in both directions in the future, with dbt still checking for node-level cycles while allowing cycles at the project level.
* Everyone in the account can view public model metadata, which helps users find data products more easily. This is separate from who can access the actual data, which is controlled by permissions in the data warehouse. For use cases where even metadata about a reusable data asset is sensitive, we are [considering](https://github.com/dbt-labs/dbt-core/issues/9340) an optional extension of protected models.

Refer to the [Mesh FAQs](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-5-faqs) for more questions.

## dbt Semantic Layer[​](#dbt-semantic-layer "Direct link to dbt Semantic Layer")

Leverage the [Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl), powered by MetricFlow, to create a unified view of your business metrics, ensuring consistency across all analytics tools. Here are some tips and caveats to consider when using Semantic Layer:

### Tips[​](#tips-3 "Direct link to Tips")

* Define semantic models and metrics once in dbt with the [Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl) (powered by MetricFlow). Reuse them across various analytics platforms, reducing redundancy and errors.
* Use the [Semantic Layer APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-api-overview) to query metrics in downstream tools for consistent, reliable data metrics.
* Connect to several data applications, from business intelligence tools to notebooks, spreadsheets, data catalogs, and more, to query your metrics. [Available integrations](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations) include Tableau, Google Sheets, Hex, and more.
* Use [exports](https://docs.getdbt.com/docs/use-dbt-semantic-layer/exports) to write commonly used queries directly within your data platform, on a schedule.

### Caveats[​](#caveats-3 "Direct link to Caveats")

* Semantic Layer currently supports the Deployment environment for querying. Development querying experience coming soon.
* Run queries/semantic layer commands in the dbt CLI, however running queries/semantic layer commands in the Studio IDE isn’t supported *yet.*
* Semantic Layer doesn't support using [Single sign-on (SSO)](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview) for Semantic Layer [production credentials](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens#permissions-for-service-account-tokens), however, SSO is supported for development user accounts.

Refer to the [Semantic Layer FAQs](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-faqs) for more information.

## dbt Catalog[​](#dbt-catalog "Direct link to dbt Catalog")

[Catalog](https://docs.getdbt.com/docs/explore/explore-projects) enhances your ability to discover, understand, and troubleshoot your data assets through rich metadata and lineage visualization. Here are some tips and caveats to consider when using Catalog:

### Tips[​](#tips-4 "Direct link to Tips")

* Use the search and filter capabilities in Catalog to quickly locate models, sources, and tests, streamlining your workflow.
* View all the [different projects](https://docs.getdbt.com/docs/explore/explore-multiple-projects) and public models in the account, where the public models are defined, and how they are used to gain a better understanding of your cross-project resources.
* Use the [Lenses](https://docs.getdbt.com/docs/explore/explore-projects#lenses) feature, which are map-like layers for your DAG, available from your project's lineage graph. Lenses help you further understand your project’s contextual metadata at scale, especially to distinguish a particular model or a subset of models.
* Access column-level lineage (CLL) for the resources in your dbt project. [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")

### Caveats[​](#caveats-4 "Direct link to Caveats")

* There must be at least one successful job run in the production deployment environment for Catalog to populate information.

Familiarize yourself with Catalog’s features to fully leverage its capabilities to avoid missed opportunities for efficiency gains.

Refer to the [Catalog FAQs](https://docs.getdbt.com/docs/explore/dbt-explorer-faqs) for more information.

## What's next?[​](#whats-next "Direct link to What's next?")

Congratulations on making it through the guide 🎉!

We hope you’re equipped with useful insights and tips to help you with your move. Something to note is that moving from dbt Core to dbt isn’t just about evolving your data projects, it's about exploring new levels of collaboration, governance, efficiency, and innovation within your team.

For the next steps, continue exploring our 3-part-guide series on moving from dbt Core to dbt:

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

### Resources[​](#resources "Direct link to Resources")

If you need any additional help or have some questions, use the following resources:

* [dbt Learn courses](https://learn.getdbt.com) for on-demand video learning.
* Our [Support team](https://docs.getdbt.com/docs/dbt-support) is always available to help you troubleshoot your dbt issues.
* Join the [dbt Community](https://community.getdbt.com/) to connect with other dbt users, ask questions, and share best practices.
* Subscribe to the [dbt RSS alerts](https://status.getdbt.com/)
* Enterprise accounts have an account management team available to help troubleshoot solutions and account management assistance. [Book a demo](https://www.getdbt.com/contact) to learn more.
* [How dbt compares with dbt Core](https://www.getdbt.com/product/dbt-core-vs-dbt-cloud) for a detailed comparison of dbt Core and dbt.

For tailored assistance, you can use the following resources:

* Book [expert-led demos](https://www.getdbt.com/resources/dbt-cloud-demos-with-experts) and insights
* Work with the [dbt Labs’ Professional Services](https://www.getdbt.com/dbt-labs/services) team to support your data organization and move.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
