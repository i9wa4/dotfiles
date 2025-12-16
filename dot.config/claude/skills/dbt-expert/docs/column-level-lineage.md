---
title: "Column-level lineage | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/explore/column-level-lineage"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Explore your data](https://docs.getdbt.com/docs/explore/explore-your-data)* [Discover data with dbt Catalog](https://docs.getdbt.com/docs/explore/explore-projects)* Column-level lineage

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fcolumn-level-lineage+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fcolumn-level-lineage+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fcolumn-level-lineage+so+I+can+ask+questions+about+it.)

On this page

Catalog now offers column-level lineage (CLL) for the resources in your dbt project. Analytics engineers can quickly and easily gain insight into the provenance of their data products at a more granular level. For each column in a resource (model, source, or snapshot) in a dbt project, Catalog provides end-to-end lineage for the data in that column given how it's used.

CLL is available to all dbt Enterprise plans that can use Catalog.

[![Overview of column level lineage](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/example-overview-cll.png?v=2 "Overview of column level lineage")](#)Overview of column level lineage

On-demand learning

If you enjoy video courses, check out our [dbt Catalog on-demand course](https://learn.getdbt.com/courses/dbt-catalog) and learn how to best explore your dbt project(s)!

## Access the column-level lineage[​](#access-the-column-level-lineage "Direct link to Access the column-level lineage")

There is no additional setup required for CLL if your account is on an Enterprise plan that can use Catalog. You can access the CLL by expanding the column card in the **Columns** tab of an Catalog [resource details page](https://docs.getdbt.com/docs/explore/explore-projects#view-resource-details) for a model, source, or snapshot.

dbt updates the lineage in Explorer after each run that's executed in the production or staging environment. At least one job in the production or staging environment must run `dbt docs generate`. Refer to [Generating metadata](https://docs.getdbt.com/docs/explore/explore-projects#generate-metadata) for more details.

[![Example of the Columns tab and where to expand for the CLL](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/example-cll.png?v=2 "Example of the Columns tab and where to expand for the CLL")](#)Example of the Columns tab and where to expand for the CLL

## Column evolution lens[​](#column-lens "Direct link to Column evolution lens")

You can use the column evolution lineage lens to determine when a column is transformed vs. reused (passthrough or rename). The lens helps you distinguish when and how a column is actually changed as it flows through your dbt lineage, informing debugging workflows in particular.

[![Example of the Column evolution lens](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/example-evolution-lens.png?v=2 "Example of the Column evolution lens")](#)Example of the Column evolution lens

### Inherited column descriptions[​](#inherited-column-descriptions "Direct link to Inherited column descriptions")

A reused column, labeled as **Passthrough** or **Rename** in the lineage, automatically inherits its description from the source and upstream model columns. The inheritance goes as far back as possible. As long as the column isn't transformed, you don't need to manually define the description; it'll automatically propagate downstream.

Passthrough and rename columns are clearly labeled and color-coded in the lineage.

In the following `dim_salesforce_accounts` model example (located at the end of the lineage), the description for a column inherited from the `stg_salesforce__accounts` model (located second to the left) indicates its origin. This helps developers quickly identify the original source of the column, making it easier to know where to make documentation changes.

[![Example of lineage with propagated and inherited column descriptions.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/example-prop-inherit.jpg?v=2 "Example of lineage with propagated and inherited column descriptions.")](#)Example of lineage with propagated and inherited column descriptions.

## Column-level lineage use cases[​](#use-cases "Direct link to Column-level lineage use cases")

Learn more about why and how you can use CLL in the following sections.

### Root cause analysis[​](#root-cause-analysis "Direct link to Root cause analysis")

When there is an unexpected breakage in a data pipeline, column-level lineage can be a valuable tool to understand the exact point where the error occurred in the pipeline. For example, a failing data test on a particular column in your dbt model might've stemmed from an untested column upstream. Using CLL can help quickly identify and fix breakages when they happen.

### Impact analysis[​](#impact-analysis "Direct link to Impact analysis")

During development, analytics engineers can use column-level lineage to understand the full scope of the impact of their proposed changes. This knowledge empowers them to create higher-quality pull requests that require fewer edits, as they can anticipate and preempt issues that would've been unchecked without column-level insights.

### Collaboration and efficiency[​](#collaboration-and-efficiency "Direct link to Collaboration and efficiency")

When exploring your data products, navigating column lineage allows analytics engineers and data analysts to more easily navigate and understand the origin and usage of their data, enabling them to make better decisions with higher confidence.

## Caveats[​](#caveats "Direct link to Caveats")

Refer to the following CLL caveats or limitations as you navigate Catalog.

### Column usage[​](#column-usage "Direct link to Column usage")

Column-level lineage reflects the lineage from `select` statements in your models' SQL code. It doesn't reflect other usage like joins and filters.

### SQL parsing[​](#sql-parsing "Direct link to SQL parsing")

Column-level lineage relies on SQL parsing. Errors can occur when parsing fails or a column's origin is unknown (like with JSON unpacking, lateral joins, and so on). In these cases, lineage may be incomplete and dbt will provide a warning about it in the column lineage.

[![Example of warning in the full lineage graph](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/example-parsing-error-pill.png?v=2 "Example of warning in the full lineage graph")](#)Example of warning in the full lineage graph

To review the error details:

1. Click the **Expand** icon in the upper right corner to open the column's lineage graph
2. Select the node to open the column’s details panel

Possible error cases are:

* **Parsing error** — Error occurs when the SQL is ambiguous or too complex for parsing. An example of ambiguous parsing scenarios are *complex* lateral joins.
* **Python error** — Error occurs when a Python model is used within the lineage. Due to the nature of Python models, it's not possible to parse and determine the lineage.
* **Unknown error** — Error occurs when the lineage can't be determined for an unknown reason. An example of this would be if a dbt best practice is not being followed, like using hardcoded table names instead of `ref` statements.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Access from dbt platform](https://docs.getdbt.com/docs/explore/access-from-dbt-cloud)[Next

Data health signals](https://docs.getdbt.com/docs/explore/data-health-signals)

* [Access the column-level lineage](#access-the-column-level-lineage)* [Column evolution lens](#column-lens)
    + [Inherited column descriptions](#inherited-column-descriptions)* [Column-level lineage use cases](#use-cases)
      + [Root cause analysis](#root-cause-analysis)+ [Impact analysis](#impact-analysis)+ [Collaboration and efficiency](#collaboration-and-efficiency)* [Caveats](#caveats)
        + [Column usage](#column-usage)+ [SQL parsing](#sql-parsing)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/explore/column-level-lineage.md)
