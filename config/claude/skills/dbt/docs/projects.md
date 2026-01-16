---
title: "About dbt projects | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/projects"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * Build dbt projects

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fprojects+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fprojects+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fprojects+so+I+can+ask+questions+about+it.)

On this page

A dbt project informs dbt about the context of your project and how to transform your data (build your data sets). By design, dbt enforces the top-level structure of a dbt project such as the `dbt_project.yml` file, the `models` directory, the `snapshots` directory, and so on. Within the directories of the top-level, you can organize your project in any way that meets the needs of your organization and data pipeline.

At a minimum, all a project needs is the `dbt_project.yml` project configuration file. dbt supports a number of different resources, so a project may also include:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Resource Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [models](https://docs.getdbt.com/docs/build/models) Each model lives in a single file and contains logic that either transforms raw data into a dataset that is ready for analytics or, more often, is an intermediate step in such a transformation.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [snapshots](https://docs.getdbt.com/docs/build/snapshots) A way to capture the state of your mutable tables so you can refer to it later.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [seeds](https://docs.getdbt.com/docs/build/seeds) CSV files with static data that you can load into your data platform with dbt.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [data tests](https://docs.getdbt.com/docs/build/data-tests) SQL queries that you can write to test the models and resources in your project.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [macros](https://docs.getdbt.com/docs/build/jinja-macros) Blocks of code that you can reuse multiple times.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [docs](https://docs.getdbt.com/docs/build/documentation) Docs for your project that you can build.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [sources](https://docs.getdbt.com/docs/build/sources) A way to name and describe the data loaded into your warehouse by your Extract and Load tools.|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [exposures](https://docs.getdbt.com/docs/build/exposures) A way to define and describe a downstream use of your project.|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [metrics](https://docs.getdbt.com/docs/build/build-metrics-intro) A way for you to define metrics for your project.|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [groups](https://docs.getdbt.com/docs/build/groups) Groups enable collaborative node organization in restricted collections.|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | [analysis](https://docs.getdbt.com/docs/build/analyses) A way to organize analytical SQL queries in your project such as the general ledger from your QuickBooks.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | [semantic models](https://docs.getdbt.com/docs/build/semantic-models) Semantic models define the foundational data relationships in [MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow) and the [Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl), enabling you to query metrics using a semantic graph.| [saved queries](https://docs.getdbt.com/docs/build/saved-queries) Saved queries organize reusable queries by grouping metrics, dimensions, and filters into nodes visible in the dbt DAG.|  |  | | --- | --- | | [user-defined functions](https://docs.getdbt.com/docs/build/udfs) User-defined functions (UDFs) let you create reusable custom functions in your warehouse, shareable across dbt, BI tools, data science workflows, and more. | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

When building out the structure of your project, you should consider these impacts on your organization's workflow:

* **How would people run dbt commands** — Selecting a path
* **How would people navigate within the project** — Whether as developers in the Studio IDE or stakeholders from the docs
* **How would people configure the models** — Some bulk configurations are easier done at the directory level so people don’t have to remember to do everything in a config block with each new model

## Project configuration[​](#project-configuration "Direct link to Project configuration")

Every dbt project includes a project configuration file called `dbt_project.yml`. It defines the directory of the dbt project and other project configurations.

Edit `dbt_project.yml` to set up common project configurations such as:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| YAML key Value description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [name](https://docs.getdbt.com/reference/project-configs/name) Your project’s name in [snake case](https://en.wikipedia.org/wiki/Snake_case)| [version](https://docs.getdbt.com/reference/project-configs/version) Version of your project|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [require-dbt-version](https://docs.getdbt.com/reference/project-configs/require-dbt-version) Restrict your project to only work with a range of [dbt Core versions](https://docs.getdbt.com/docs/dbt-versions/core)| [profile](https://docs.getdbt.com/reference/project-configs/profile) The profile dbt uses to connect to your data platform|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [model-paths](https://docs.getdbt.com/reference/project-configs/model-paths) Directories to where your model and source files live|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [seed-paths](https://docs.getdbt.com/reference/project-configs/seed-paths) Directories to where your seed files live|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [test-paths](https://docs.getdbt.com/reference/project-configs/test-paths) Directories to where your test files live|  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [analysis-paths](https://docs.getdbt.com/reference/project-configs/analysis-paths) Directories to where your analyses live|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | [macro-paths](https://docs.getdbt.com/reference/project-configs/macro-paths) Directories to where your macros live|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | [snapshot-paths](https://docs.getdbt.com/reference/project-configs/snapshot-paths) Directories to where your snapshots live|  |  |  |  | | --- | --- | --- | --- | | [docs-paths](https://docs.getdbt.com/reference/project-configs/docs-paths) Directories to where your docs blocks live|  |  | | --- | --- | | [vars](https://docs.getdbt.com/docs/build/project-variables) Project variables you want to use for data compilation | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

For complete details on project configurations, see [dbt\_project.yml](https://docs.getdbt.com/reference/dbt_project.yml).

## Project subdirectories[​](#project-subdirectories "Direct link to Project subdirectories")

You can use the Project subdirectory option in dbt to specify a subdirectory in your git repository that dbt should use as the root directory for your project. This is helpful when you have multiple dbt projects in one repository or when you want to organize your dbt project files into subdirectories for easier management.

To use the Project subdirectory option in dbt, follow these steps:

1. Click your account name in the bottom left and select **Your profile**.
2. Under **Projects**, select the project you want to configure as a project subdirectory.
3. Select **Edit** on the lower right-hand corner of the page.
4. In the **Project subdirectory** field, add the name of the subdirectory. For example, if your dbt project files are located in a subdirectory called `<repository>/finance`, you would enter `finance` as the subdirectory.

   * You can also reference nested subdirectories. For example, if your dbt project files are located in `<repository>/teams/finance`, you would enter `teams/finance` as the subdirectory. **Note**: You do not need a leading or trailing `/` in the Project subdirectory field.
5. Click **Save** when you've finished.

After configuring the Project subdirectory option, dbt will use it as the root directory for your dbt project. This means that dbt commands, such as `dbt run` or `dbt test`, will operate on files within the specified subdirectory. If there is no `dbt_project.yml` file in the Project subdirectory, you will be prompted to initialize the dbt project.

Project support in dbt plans

Some [plans](https://www.getdbt.com/pricing) support only one dbt project, while [Enterprise-tier plans](https://www.getdbt.com/contact) allow multiple projects and [cross-project references](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro) with Mesh.

## New projects[​](#new-projects "Direct link to New projects")

You can create new projects and [share them](https://docs.getdbt.com/docs/cloud/git/git-version-control) with other people by making them available on a hosted git repository like GitHub, GitLab, and BitBucket.

After you set up a connection with your data platform, you can [initialize your new project in dbt](https://docs.getdbt.com/guides) and start developing. Or, run [dbt init from the command line](https://docs.getdbt.com/reference/commands/init) to set up your new project.

During project initialization, dbt creates sample model files in your project directory to help you start developing quickly.

## Sample projects[​](#sample-projects "Direct link to Sample projects")

If you want to explore dbt projects more in-depth, you can clone dbt Lab’s [Jaffle shop](https://github.com/dbt-labs/jaffle_shop) on GitHub. It's a runnable project that contains sample configurations and helpful notes.

If you want to see what a mature, production project looks like, check out the [GitLab Data Team public repo](https://gitlab.com/gitlab-data/analytics/-/tree/master/transform/snowflake-dbt).

## Related docs[​](#related-docs "Direct link to Related docs")

* [Best practices: How we structure our dbt projects](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview)
* [Quickstarts for dbt](https://docs.getdbt.com/guides)
* [Quickstart for dbt Core](https://docs.getdbt.com/guides/manual-install)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

* [Project configuration](#project-configuration)* [Project subdirectories](#project-subdirectories)* [New projects](#new-projects)* [Sample projects](#sample-projects)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/projects.md)
