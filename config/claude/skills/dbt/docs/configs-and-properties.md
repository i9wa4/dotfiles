---
title: "Configurations and properties, what are they? | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/configs-and-properties"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* Configs and properties

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fconfigs-and-properties+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fconfigs-and-properties+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fconfigs-and-properties+so+I+can+ask+questions+about+it.)

Understand the difference between properties and configurations in dbt: properties describe resources, while configurations control how dbt builds them in the warehouse.

Resources in your project—models, snapshots, seeds, tests, and the rest—can have a number of declared *properties*. Resources can also define *configurations* (configs), which are a special kind of property that bring extra abilities. What's the distinction?

* Properties are declared for resources one-by-one in `properties.yml` files. Configs can be defined there, nested under a `config` property. They can also be set one-by-one via a `config()` macro (right within `.sql` files), and for many resources at once in `dbt_project.yml`.
* Because configs can be set in multiple places, they are also applied hierarchically. An individual resource might *inherit* or *override* configs set elsewhere.
* You can select resources based on their config values using the `config:` selection method, but not the values of non-config properties.
* There are slightly different naming conventions for properties and configs depending on the file type. Refer to [naming convention](https://docs.getdbt.com/reference/dbt_project.yml#naming-convention) for more details.

A rule of thumb: properties declare things *about* your project resources; configs go the extra step of telling dbt *how* to build those resources in your warehouse. This is generally true, but not always, so it's always good to check!

For example, you can use resource **properties** to:

* Describe models, snapshots, seed files, and their columns
* Assert "truths" about a model, in the form of [data tests](https://docs.getdbt.com/docs/build/data-tests), e.g. "this `id` column is unique"
* Define official downstream uses of your data models, in the form of [exposures](https://docs.getdbt.com/docs/build/exposures), and assert an exposure's "type"

Whereas you can use **configurations** to:

* Change how a model will be materialized (table, view, incremental, etc)
* Declare where a seed will be created in the database (`<database>.<schema>.<alias>`)
* Declare whether a resource should persist its descriptions as comments in the database
* Apply tags and meta to a resource

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About resource paths](https://docs.getdbt.com/reference/resource-configs/resource-path)[Next

Define configs](https://docs.getdbt.com/reference/define-configs)
