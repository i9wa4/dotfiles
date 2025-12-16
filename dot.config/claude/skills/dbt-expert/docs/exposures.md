---
title: "Add Exposures to your DAG | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/exposures"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your DAG](https://docs.getdbt.com/docs/build/models)* Exposures

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fexposures+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fexposures+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fexposures+so+I+can+ask+questions+about+it.)

On this page

Exposures make it possible to define and describe a downstream use of your dbt project, such as in a dashboard, application, or data science pipeline. By defining exposures, you can then:

* run, test, and list resources that feed into your exposure
* populate a dedicated page in the auto-generated [documentation](https://docs.getdbt.com/docs/build/documentation) site with context relevant to data consumers

Exposures can be defined in two ways:

* Manual — Declared [explicitly](https://docs.getdbt.com/docs/build/exposures#declaring-an-exposure) in your project’s YAML files.
* Automatic — dbt [creates and visualizes downstream exposures](https://docs.getdbt.com/docs/cloud-integrations/downstream-exposures) automatically for supported integrations, removing the need for manual YAML definitions. These downstream exposures are stored in dbt’s metadata system, appear in [Catalog](https://docs.getdbt.com/docs/explore/explore-projects), and behave like manual exposures. However, they don’t exist in YAML files.

### Declaring an exposure[​](#declaring-an-exposure "Direct link to Declaring an exposure")

Exposures are defined in `.yml` files nested under an `exposures:` key.

The following example shows an exposure definition in a `models/<filename>.yml` file:

models/<filename>.yml

```
exposures:

  - name: weekly_jaffle_metrics
    label: Jaffles by the Week
    type: dashboard
    maturity: high
    url: https://bi.tool/dashboards/1
    description: >
      Did someone say "exponential growth"?

    depends_on:
      - ref('fct_orders')
      - ref('dim_customers')
      - source('gsheets', 'goals')
      - metric('count_orders')

    owner:
      name: Callum McData
      email: data@jaffleshop.com
```

### Available properties[​](#available-properties "Direct link to Available properties")

*Required:*

* **name**: a unique exposure name written in [snake case](https://en.wikipedia.org/wiki/Snake_case)
* **type**: one of `dashboard`, `notebook`, `analysis`, `ml`, `application` (used to organize in docs site)
* **owner**: `name` or `email` required; additional properties allowed

*Expected:*

* **depends\_on**: list of refable nodes, including `metric`, `ref`, and `source`. While possible, it is highly unlikely you will ever need an `exposure` to depend on a `source` directly.

*Optional:*

* **label**: May contain spaces, capital letters, or special characters.
* **url**: Activates and populates the link to **View this exposure** in the upper right corner of the generated documentation site
* **maturity**: Indicates the level of confidence or stability in the exposure. One of `high`, `medium`, or `low`. For example, you could use `high` maturity for a well-established dashboard, widely used and trusted within your organization. Use `low` maturity for a new or experimental analysis.

*General properties (optional)*

* [**description**](https://docs.getdbt.com/reference/resource-properties/description)
* [**tags**](https://docs.getdbt.com/reference/resource-configs/tags)
* [**meta**](https://docs.getdbt.com/reference/resource-configs/meta)
* [**enabled**](https://docs.getdbt.com/reference/resource-configs/enabled) — You can set this property at the exposure level or at the project level in the [`dbt_project.yml`](https://docs.getdbt.com/reference/dbt_project.yml) file.

### Referencing exposures[​](#referencing-exposures "Direct link to Referencing exposures")

Once an exposure is defined, you can run commands that reference it:

```
dbt run -s +exposure:weekly_jaffle_report
dbt test -s +exposure:weekly_jaffle_report
```

When we generate the [Catalog site](https://docs.getdbt.com/docs/explore/explore-projects), you'll see the exposure appear:

[![Exposures has a dedicated section, under the 'Resources' tab in dbt Catalog, which lists each exposure in your project.](https://docs.getdbt.com/img/docs/building-a-dbt-project/dbt-explorer-exposures.jpg?v=2 "Exposures has a dedicated section, under the 'Resources' tab in dbt Catalog, which lists each exposure in your project.")](#)Exposures has a dedicated section, under the 'Resources' tab in dbt Catalog, which lists each exposure in your project.

[![Exposures appear as nodes in the dbt Catalog DAG. It displays an orange 'EXP' indicator within the node. ](https://docs.getdbt.com/img/docs/building-a-dbt-project/dag-exposures.png?v=2 "Exposures appear as nodes in the dbt Catalog DAG. It displays an orange 'EXP' indicator within the node. ")](#)Exposures appear as nodes in the dbt Catalog DAG. It displays an orange 'EXP' indicator within the node.

## Related docs[​](#related-docs "Direct link to Related docs")

* [Exposure properties](https://docs.getdbt.com/reference/exposure-properties)
* [`exposure:` selection method](https://docs.getdbt.com/reference/node-selection/methods#exposure)
* [Data health tiles](https://docs.getdbt.com/docs/explore/data-tile)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Sources](https://docs.getdbt.com/docs/build/sources)[Next

Groups](https://docs.getdbt.com/docs/build/groups)

* [Declaring an exposure](#declaring-an-exposure)* [Available properties](#available-properties)* [Referencing exposures](#referencing-exposures)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/exposures.md)
