---
title: "Account settings in dbt | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/account-settings"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* Account settings

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Faccount-settings+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Faccount-settings+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Faccount-settings+so+I+can+ask+questions+about+it.)

On this page

The following sections describe the different **Account settings** available from your dbt account in the sidebar (under your account name on the lower left-hand side).

[![Example of Account settings from the sidebar](https://docs.getdbt.com/img/docs/dbt-cloud/example-sidebar-account-settings.png?v=2 "Example of Account settings from the sidebar")](#)Example of Account settings from the sidebar

## Git repository caching [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#git-repository-caching- "Direct link to git-repository-caching-")

repo caching enabled by default

Git repository caching is enabled by default for all new Enterprise and Enterprise+ accounts, improving reliability by allowing dbt to use a cached copy of your repo if cloning fails.

See the next section for more details on repo caching, retention, and more.

At the start of every [job](https://docs.getdbt.com/docs/deploy/jobs) run, dbt clones the project's Git repository so it has the latest versions of your project's code and runs `dbt deps` to install your dependencies.

For improved reliability and performance on your job runs, you can enable dbt to keep a cache of the project's Git repository. So, if there's a third-party outage that causes the cloning operation to fail, dbt will instead use the cached copy of the repo so your jobs can continue running as scheduled.

dbt caches your project's Git repo after each successful run and retains it for 8 days if there are no repo updates. It caches all packages regardless of installation method and does not fetch code outside of the job runs.

dbt will use the cached copy of your project's Git repo under these circumstances:

* Outages from third-party services (for example, the [dbt package hub](https://hub.getdbt.com/)).
* Git authentication fails.
* There are syntax errors in the `packages.yml` file. You can set up and use [continuous integration (CI)](https://docs.getdbt.com/docs/deploy/continuous-integration) to find these errors sooner.
* If a package doesn't work with the current dbt version. You can set up and use [continuous integration (CI)](https://docs.getdbt.com/docs/deploy/continuous-integration) to identify this issue sooner.
* Note, Git repository caching should not be used for CI jobs. CI jobs are designed to test the latest code changes in a pull request and ensure your code is up to date. Using a cached copy of the repo in CI jobs could result in stale code being tested.

To use, select the **Enable repository caching** option from your account settings.

[![Example of the Enable repository caching option](https://docs.getdbt.com/img/docs/deploy/account-settings-repository-caching.png?v=2 "Example of the Enable repository caching option")](#)Example of the Enable repository caching option

## Partial parsing[​](#partial-parsing "Direct link to Partial parsing")

At the start of every dbt invocation, dbt reads all the files in your project, extracts information, and constructs an internal manifest containing every object (model, source, macro, and so on). Among other things, it uses the `ref()`, `source()`, and `config()` macro calls within models to set properties, infer dependencies, and construct your project's DAG. When dbt finishes parsing your project, it stores the internal manifest in a file called `partial_parse.msgpack`.

Parsing projects can be time-consuming, especially for large projects with hundreds of models and thousands of files. To reduce the time it takes dbt to parse your project, use the partial parsing feature in dbt for your environment. When enabled, dbt uses the `partial_parse.msgpack` file to determine which files have changed (if any) since the project was last parsed, and then it parses *only* the changed files and the files related to those changes.

Partial parsing in dbt requires dbt version 1.4 or newer. The feature does have some known limitations. Refer to [Known limitations](https://docs.getdbt.com/reference/parsing#known-limitations) to learn more about them.

To use, select the **Enable partial parsing between deployment runs** option from your account settings.

[![Example of the Enable partial parsing between deployment runs option](https://docs.getdbt.com/img/docs/deploy/account-settings-partial-parsing.png?v=2 "Example of the Enable partial parsing between deployment runs option")](#)Example of the Enable partial parsing between deployment runs option

## Account access and enablement[​](#account-access-and-enablement "Direct link to Account access and enablement")

### Enabling dbt Copilot [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#enabling-dbt-copilot- "Direct link to enabling-dbt-copilot-")

[Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot) is an AI-powered assistant fully integrated into your dbt experience and is designed to accelerate your analytics workflows.

To use this feature, your dbt administrator must enable Copilot on your account by selecting the **Enable account access to dbt Copilot features** option from the account settings. For more information, see [Enable dbt Copilot](https://docs.getdbt.com/docs/cloud/enable-dbt-copilot).

### Enabling Advanced CI features [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#enabling-advanced-ci-features- "Direct link to enabling-advanced-ci-features-")

[Advanced CI](https://docs.getdbt.com/docs/deploy/advanced-ci) features, such as [compare changes](https://docs.getdbt.com/docs/deploy/advanced-ci#compare-changes), allow dbt account members to view details about the changes between what's in the production environment and the pull request.

To use Advanced CI features, your dbt account must have access to them. Ask your dbt administrator to enable Advanced CI features on your account, which they can do by choosing the **Enable account access to Advanced CI** option from the account settings.

Once enabled, the **dbt compare** option becomes available in the CI job settings for you to select.

[![The Enable account access to Advanced CI option](https://docs.getdbt.com/img/docs/deploy/account-settings-advanced-ci.png?v=2 "The Enable account access to Advanced CI option")](#)The Enable account access to Advanced CI option

### Enabling dbt Catalog [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing") [Preview](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")[​](#enabling-dbt-catalog-- "Direct link to enabling-dbt-catalog--")

[Catalog](https://docs.getdbt.com/docs/explore/explore-projects) allows you to view your project's resources (for example, models, tests, and metrics), their lineage, and model consumption to gain a better understanding of your project's latest production state.

To enable dbt Catalog, a [developer license with Owner permissions](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#role-based-access-control) is required. Enable Catalog in your account by selecting the **Enable dbt Catalog’s (formerly dbt Explorer) New Navigation** option from your account settings. For more information, see [Catalog overview](https://docs.getdbt.com/docs/explore/explore-projects#catalog-overview).

You can bring [external metadata](https://docs.getdbt.com/docs/explore/external-metadata-ingestion) into Catalog by connecting directly to your warehouse. This enables you to view tables and other assets that aren't defined in dbt. Currently, external metadata ingestion is supported for Snowflake only.

To use external metadata ingestion, you must be an [account admin](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions#account-admin) with permission to edit connections. Enable Catalog in your account by selecting the **Ingest external metadata in dbt Catalog (formerly dbt Explorer)** option from your account settings. For more information, see [Enable external metadata ingestion](https://docs.getdbt.com/docs/explore/external-metadata-ingestion#enable-external-metadata-ingestion).

## Project settings history[​](#project-settings-history "Direct link to Project settings history")

You can view historical project settings changes over the last 90 days.

To view the change history:

1. Click your account name at the bottom of the left-side menu and click **Account settings**.
2. Click **Projects**.
3. Click a **project name**.
4. Click **History**.

[![Example of the project history option. ](https://docs.getdbt.com/img/docs/deploy/project-history.png?v=2 "Example of the project history option. ")](#)Example of the project history option.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About dbt setup](https://docs.getdbt.com/docs/cloud/about-cloud-setup)[Next

Account integrations](https://docs.getdbt.com/docs/cloud/account-integrations)

* [Git repository caching](#git-repository-caching-) * [Partial parsing](#partial-parsing)* [Account access and enablement](#account-access-and-enablement)
      + [Enabling dbt Copilot](#enabling-dbt-copilot-) + [Enabling Advanced CI features](#enabling-advanced-ci-features-) + [Enabling dbt Catalog](#enabling-dbt-catalog--)* [Project settings history](#project-settings-history)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/account-settings.md)
