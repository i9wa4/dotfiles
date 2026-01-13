---
title: "Model performance | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/explore/model-performance"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Explore your data](https://docs.getdbt.com/docs/explore/explore-your-data)* [Discover data with dbt Catalog](https://docs.getdbt.com/docs/explore/explore-projects)* Model performance

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fmodel-performance+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fmodel-performance+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fmodel-performance+so+I+can+ask+questions+about+it.)

On this page

Catalog provides metadata on dbt runs for in-depth model performance and quality analysis. This feature assists in reducing infrastructure costs and saving time for data teams by highlighting where to fine-tune projects and deployments — such as model refactoring or job configuration adjustments.

[![Overview of Performance page navigation.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/explorer-model-performance.gif?v=2 "Overview of Performance page navigation.")](#)Overview of Performance page navigation.

On-demand learning

If you enjoy video courses, check out our [dbt Catalog on-demand course](https://learn.getdbt.com/courses/dbt-catalog) and learn how to best explore your dbt project(s)!

## The Performance overview page[​](#the-performance-overview-page "Direct link to The Performance overview page")

You can pinpoint areas for performance enhancement by using the Performance overview page. This page presents a comprehensive analysis across all project models and displays the longest-running models, those most frequently executed, and the ones with the highest failure rates during runs/tests. Data can be segmented by environment and job type which can offer insights into:

* Most executed models (total count).
* Models with the longest execution time (average duration).
* Models with the most failures, detailing run failures (percentage and count) and test failures (percentage and count).

Each data point links to individual models in Catalog.

[![Example of Performance overview page](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/example-performance-overview-page.png?v=2 "Example of Performance overview page")](#)Example of Performance overview page

You can view historical metadata for up to the past three months. Select the time horizon using the filter, which defaults to a two-week lookback.

[![Example of dropdown](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/ex-2-week-default.png?v=2 "Example of dropdown")](#)Example of dropdown

## The Model performance tab[​](#the-model-performance-tab "Direct link to The Model performance tab")

You can view trends in execution times, counts, and failures by using the Model performance tab for historical performance analysis. Daily execution data includes:

* Average model execution time.
* Model execution counts, including failures/errors (total sum).

Clicking on a data point reveals a table listing all job runs for that day, with each row providing a direct link to the details of a specific run.

[![Example of the Model performance tab](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/example-model-performance-tab.png?v=2 "Example of the Model performance tab")](#)Example of the Model performance tab

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Global navigation](https://docs.getdbt.com/docs/explore/global-navigation)[Next

Project recommendations](https://docs.getdbt.com/docs/explore/project-recommendations)

* [The Performance overview page](#the-performance-overview-page)* [The Model performance tab](#the-model-performance-tab)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/explore/model-performance.md)
