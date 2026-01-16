---
title: "Project recommendations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/explore/project-recommendations"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Explore your data](https://docs.getdbt.com/docs/explore/explore-your-data)* [Discover data with dbt Catalog](https://docs.getdbt.com/docs/explore/explore-projects)* Project recommendations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fproject-recommendations+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fproject-recommendations+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fproject-recommendations+so+I+can+ask+questions+about+it.)

On this page

Catalog provides recommendations about your project from the `dbt_project_evaluator` [package](https://hub.getdbt.com/dbt-labs/dbt_project_evaluator/latest/) using metadata from the [Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api).

* Catalog also offers a global view, showing all the recommendations across the project for easy sorting and summarizing.
* These recommendations provide insight into how you can create a better-documented, better-tested, and better-built dbt project, creating more trust and less confusion.
* For a seamless and consistent experience, recommendations use `dbt_project_evaluator`'s pre-defined settings and don't import customizations applied to your package or project.

On-demand learning

If you enjoy video courses, check out our [dbt Catalog on-demand course](https://learn.getdbt.com/courses/dbt-catalog) and learn how to best explore your dbt project(s)!

## Recommendations page[​](#recommendations-page "Direct link to Recommendations page")

The Recommendations overview page includes two top-level metrics measuring the test and documentation coverage of the models in your project.

* **Model test coverage** — The percent of models in your project (models not from a package or imported via Mesh) with at least one dbt test configured on them.
* **Model documentation coverage** — The percent of models in your project (models not from a package or imported via Mesh) with a description.

[![Example of the Recommendations overview page with project metrics and the recommendations for all resources in the project](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/example-recommendations-overview.png?v=2 "Example of the Recommendations overview page with project metrics and the recommendations for all resources in the project")](#)Example of the Recommendations overview page with project metrics and the recommendations for all resources in the project

## List of rules[​](#list-of-rules "Direct link to List of rules")

The following table lists the rules currently defined in the `dbt_project_evaluator` [package](https://hub.getdbt.com/dbt-labs/dbt_project_evaluator/latest/).

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Category Name Description Package Docs Link|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Modeling Direct Join to Source Model that joins both a model and source, indicating a missing staging model [GitHub](https://dbt-labs.github.io/dbt-project-evaluator/0.8/rules/modeling/#direct-join-to-source)| Modeling Duplicate Sources More than one source node corresponds to the same data warehouse relation [GitHub](https://dbt-labs.github.io/dbt-project-evaluator/0.8/rules/modeling/#duplicate-sources)| Modeling Multiple Sources Joined Models with more than one source parent, indicating lack of staging models [GitHub](https://dbt-labs.github.io/dbt-project-evaluator/0.8/rules/modeling/#multiple-sources-joined)| Modeling Root Model Models with no parents, indicating potential hardcoded references and need for sources [GitHub](https://dbt-labs.github.io/dbt-project-evaluator/0.8/rules/modeling/#root-models)| Modeling Source Fanout Sources with more than one model child, indicating a need for staging models [GitHub](https://dbt-labs.github.io/dbt-project-evaluator/0.8/rules/modeling/#source-fanout)| Modeling Unused Source Sources that are not referenced by any resource [GitHub](https://dbt-labs.github.io/dbt-project-evaluator/0.8/rules/modeling/#unused-sources)| Performance Exposure Dependent on View Exposures with at least one model parent materialized as a view, indicating potential query performance issues [GitHub](https://dbt-labs.github.io/dbt-project-evaluator/0.8/rules/performance/#exposure-parents-materializations)| Testing Missing Primary Key Test Models with insufficient testing on the grain of the model. [GitHub](https://dbt-labs.github.io/dbt-project-evaluator/0.8/rules/testing/#missing-primary-key-tests)| Documentation Undocumented Models Models without a model-level description [GitHub](https://dbt-labs.github.io/dbt-project-evaluator/0.8/rules/documentation/#undocumented-models)| Documentation Undocumented Source Sources (collections of source tables) without descriptions [GitHub](https://dbt-labs.github.io/dbt-project-evaluator/0.8/rules/documentation/#undocumented-sources)| Documentation Undocumented Source Tables Source tables without descriptions [GitHub](https://dbt-labs.github.io/dbt-project-evaluator/0.8/rules/documentation/#undocumented-source-tables)| Governance Public Model Missing Contract Models with public access that do not have a model contract to ensure the data types [GitHub](https://dbt-labs.github.io/dbt-project-evaluator/0.8/rules/governance/#public-models-without-contracts) | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## The Recommendations tab[​](#the-recommendations-tab "Direct link to The Recommendations tab")

Models, sources, and exposures each also have a **Recommendations** tab on their resource details page, with the specific recommendations that correspond to that resource:

[![Example of the Recommendations tab ](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/example-recommendations-tab.png?v=2 "Example of the Recommendations tab ")](#)Example of the Recommendations tab

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Model performance](https://docs.getdbt.com/docs/explore/model-performance)[Next

dbt Catalog FAQs](https://docs.getdbt.com/docs/explore/dbt-explorer-faqs)

* [Recommendations page](#recommendations-page)* [List of rules](#list-of-rules)* [The Recommendations tab](#the-recommendations-tab)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/explore/project-recommendations.md)
