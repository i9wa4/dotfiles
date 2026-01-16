---
title: "Global navigation | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/explore/global-navigation"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Explore your data](https://docs.getdbt.com/docs/explore/explore-your-data)* [Discover data with dbt Catalog](https://docs.getdbt.com/docs/explore/explore-projects)* Global navigation

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fglobal-navigation+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fglobal-navigation+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fglobal-navigation+so+I+can+ask+questions+about+it.)

On this page

Learn how to enable and use global navigation in Catalog to search, explore, and analyze data assets across all your dbt projects and connected metadata sources. Discover cross-project lineage, data discovery, and unified analytics governance.

For enterprise plans, Catalog introduces the ability to widen your search by including dbt resources (models, seeds, snapshots, sources, exposures, and more) across your entire account, and the option to discover external metadata. For Starter plans (single project), you’ll still benefit from the new navigation and search experience within your project.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

To enable global navigation:

* Have a [developer license with Owner](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#role-based-access-control) permissions.
* Navigate to your [account settings](https://docs.getdbt.com/docs/cloud/account-settings) in your dbt account and check the box to **Enable dbt Catalog’s (formerly dbt Explorer) New Navigation**.

## About Global navigation[​](#about-global-navigation "Direct link to About Global navigation")

Global navigation in Catalog lets you search, explore, and analyze data assets across all your dbt projects and connected metadata sources—giving you a unified, account-wide view of your analytics ecosystem. With global navigation, you can:

* Search data assets — expand your search by including dbt resources (models, seeds, snapshots, sources, exposures, and more) across your entire account. This broadens the results returned and gives you greater insight into all the assets across your dbt projects.
  + External metadata ingestion — connect directly to your data warehouse, giving you visibility into tables, views, and other resources that aren't defined in dbt with Catalog.
* Explore lineage — explore an interactive map of data relationships across all your dbt projects. It lets you:
  + View upstream/downstream dependencies for models, sources, and more.
  + Drill into project and column-level lineage, including multi-project (Mesh) links.
  + Filter with "lineage lenses" by resource type, materialization, layer, or run status.
  + Troubleshoot data issues by tracing root causes and downstream impacts.
  + Optimize pipelines by spotting slow, failing, or unused parts of your DAG.
* See recommendations — global navigation offers a project-wide snapshot of dbt health, highlighting actionable tips to enhance your analytics engineering. These insights are automatically generated using dbt metadata and best practices from the project evaluator ruleset.
* View model query history — see how often each dbt model is queried in your warehouse, helping you:
  + Track real usage via successful `SELECT`s (excluding builds/tests)
  + Identify most/least used models for optimization or deprecation
  + Guide investment and maintenance with data-driven insights
* Track downstream exposures — monitor how your dbt models and sources are used by BI tools, apps, ML models, and reports across all connected projects

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

External metadata ingestion](https://docs.getdbt.com/docs/explore/external-metadata-ingestion)[Next

Model performance](https://docs.getdbt.com/docs/explore/model-performance)

* [Prerequisites](#prerequisites)* [About Global navigation](#about-global-navigation)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/explore/explore-global-nav.md)
