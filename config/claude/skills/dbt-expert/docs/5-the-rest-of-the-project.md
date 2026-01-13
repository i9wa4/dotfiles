---
title: "The rest of the project | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-structure/5-the-rest-of-the-project"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* [How we structure our dbt projects](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview)* The rest of the project

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-structure%2F5-the-rest-of-the-project+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-structure%2F5-the-rest-of-the-project+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-structure%2F5-the-rest-of-the-project+so+I+can+ask+questions+about+it.)

On this page

### Project structure review[​](#project-structure-review "Direct link to Project structure review")

So far we’ve focused on the `models` folder, the primary directory of our dbt project. Next, we’ll zoom out and look at how the rest of our project files and folders fit in with this structure, starting with how we approach YAML configuration files.

```
models
├── intermediate
│   └── finance
│       ├── _int_finance__models.yml
│       └── int_payments_pivoted_to_orders.sql
├── marts
│   ├── finance
│   │   ├── _finance__models.yml
│   │   ├── orders.sql
│   │   └── payments.sql
│   └── marketing
│       ├── _marketing__models.yml
│       └── customers.sql
├── staging
│   ├── jaffle_shop
│   │   ├── _jaffle_shop__docs.md
│   │   ├── _jaffle_shop__models.yml
│   │   ├── _jaffle_shop__sources.yml
│   │   ├── base
│   │   │   ├── base_jaffle_shop__customers.sql
│   │   │   └── base_jaffle_shop__deleted_customers.sql
│   │   ├── stg_jaffle_shop__customers.sql
│   │   └── stg_jaffle_shop__orders.sql
│   └── stripe
│       ├── _stripe__models.yml
│       ├── _stripe__sources.yml
│       └── stg_stripe__payments.sql
└── utilities
    └── all_dates.sql
```

### YAML in-depth[​](#yaml-in-depth "Direct link to YAML in-depth")

When structuring your YAML configuration files in a dbt project, you want to balance centralization and file size to make specific configs as easy to find as possible. It’s important to note that while the top-level YAML files (`dbt_project.yml`, `packages.yml`) need to be specifically named and in specific locations, the files containing your `sources` and `models` dictionaries can be named, located, and organized however you want. It’s the internal contents that matter here. As such, we’ll lay out our primary recommendation, as well as the pros and cons of a popular alternative. Like many other aspects of structuring your dbt project, what’s most important here is consistency, clear intention, and thorough documentation on how and why you do what you do.

* ✅ **Config per folder.** As in the example above, create a `_[directory]__models.yml` per directory in your models folder that configures all the models in that directory. for staging folders, also include a `_[directory]__sources.yml` per directory.
  + The leading underscore ensures your YAML files will be sorted to the top of every folder to make them easy to separate from your models.
  + YAML files don’t need unique names in the way that SQL model files do, but including the directory (instead of simply `_sources.yml` in each folder), means you can fuzzy find the right file more quickly.
  + We’ve recommended several different naming conventions over the years, most recently calling these `schema.yml` files. We’ve simplified to recommend that these simply be labelled based on the YAML dictionary that they contain.
  + If you utilize [doc blocks](https://docs.getdbt.com/docs/build/documentation#using-docs-blocks) in your project, we recommend following the same pattern, and creating a `_[directory]__docs.md` markdown file per directory containing all your doc blocks for that folder of models.
* ❌ **Config per project.** Some people put *all* of their source and model YAML into one file. While you can technically do this, and while it certainly simplifies knowing what file the config you’re looking for will be in (as there is only one file), it makes it much harder to find specific configurations within that file. We recommend balancing those two concerns.
* ⚠️ **Config per model.** On the other end of the spectrum, some people prefer to create one YAML file per model. This presents less of an issue than a single monolith file, as you can quickly search for files, know exactly where specific configurations exist, spot models without configs (and thus without tests) by looking at the file tree, and various other advantages. In our opinion, the extra files, tabs, and windows this requires creating, copying from, pasting to, closing, opening, and managing creates a somewhat slower development experience that outweighs the benefits. Defining config per directory is the most balanced approach for most projects, but if you have compelling reasons to use config per model, there are definitely some great projects that follow this paradigm.
* ✅ **Cascade configs.** Leverage your `dbt_project.yml` to set default configurations at the directory level. Use the well-organized folder structure we’ve created thus far to define the baseline schemas and materializations, and use dbt’s cascading scope priority to define variations to this. For example, as below, define your marts to be materialized as tables by default, define separate schemas for our separate subfolders, and any models that need to use incremental materialization can be defined at the model level.

```
-- dbt_project.yml

models:
  jaffle_shop:
    staging:
      +materialized: view
    intermediate:
      +materialized: ephemeral
    marts:
      +materialized: table
      finance:
        +schema: finance
      marketing:
        +schema: marketing
```

Define your defaults.

One of the many benefits this consistent approach to project structure confers to us is this ability to cascade default behavior. Carefully organizing our folders and defining configuration at that level whenever possible frees us from configuring things like schema and materialization in every single model (not very DRY!) — we only need to configure exceptions to our general rules. Tagging is another area this principle comes into play. Many people new to dbt will rely on tags rather than a rigorous folder structure, and quickly find themselves in a place where every model *requires* a tag. This creates unnecessary complexity. We want to lean on our folders as our primary selectors and grouping mechanism, and use tags to define groups that are *exceptions.* A folder-based selection like \*\*`dbt build --select marts.marketing` is much simpler than trying to tag every marketing-related model, hoping all developers remember to add that tag for new models, and using `dbt build --select tag:marketing`.

#### Defining groups[​](#defining-groups "Direct link to Defining groups")

A group is a collection of nodes within a dbt DAG. Groups enable intentional collaboration within and across teams by restricting [access to private](https://docs.getdbt.com/reference/resource-configs/access) models.

Groups are defined in `.yml` files, nested under a `groups:` key.

For more information about using groups, see [Add groups to your DAG](https://docs.getdbt.com/docs/build/groups).

### How we use the other folders[​](#how-we-use-the-other-folders "Direct link to How we use the other folders")

```
jaffle_shop
├── analyses
├── seeds
│   └── employees.csv
├── macros
│   ├── _macros.yml
│   └── cents_to_dollars.sql
├── snapshots
└── tests
└── assert_positive_value_for_total_amount.sql
```

We’ve focused heavily thus far on the primary area of action in our dbt project, the `models` folder. As you’ve probably observed though, there are several other folders in our project. While these are, by design, very flexible to your needs, we’ll discuss the most common use cases for these other folders to help get you started.

* ✅ `seeds` for lookup tables. The most common use case for seeds is loading lookup tables that are helpful for modeling but don’t exist in any source systems — think mapping zip codes to states, or UTM parameters to marketing campaigns. In this example project we have a small seed that maps our employees to their `customer_id`s, so that we can handle their purchases with special logic.
* ❌ `seeds` for loading source data. Do not use seeds to load data from a source system into your warehouse. If it exists in a system you have access to, you should be loading it with a proper EL tool into the raw data area of your warehouse. dbt is designed to operate on data in the warehouse, not as a data-loading tool.
* ✅ `analyses` for storing auditing queries. The `analyses` folder lets you store any queries you want to use Jinja with and version control, but not build into models in your warehouse. There are limitless possibilities here, but the most common use case when we set up projects at dbt Labs is to keep queries that leverage the [audit helper](https://github.com/dbt-labs/dbt-audit-helper) package. This package is incredibly useful for finding discrepancies in output when migrating logic from another system into dbt.
* ✅ `tests` for testing multiple specific tables simultaneously. As dbt tests have evolved, writing singular tests has become less and less necessary. It's extremely useful for work-shopping test logic, but more often than not you'll find yourself either migrating that logic into your own custom generic tests or discovering a pre-built test that meets your needs from the ever-expanding universe of dbt packages (between the extra tests in [`dbt-utils`](https://github.com/dbt-labs/dbt-utils) and [`dbt-expectations`](https://github.com/calogica/dbt-expectations) almost any situation is covered). One area where singular tests still shine though is flexibly testing things that require a variety of specific models. If you're familiar with the difference between [unit tests](https://en.wikipedia.org/wiki/Unit_testing) [and](https://www.testim.io/blog/unit-test-vs-integration-test/) [integration](https://www.codecademy.com/resources/blog/what-is-integration-testing/) [tests](https://en.wikipedia.org/wiki/Integration_testing) in software engineering, you can think of generic and singular tests in a similar way. If you need to test the results of how several specific models interact or relate to each other, a singular test will likely be the quickest way to nail down your logic.
* ✅ `snapshots` for creating [Type 2 slowly changing dimension](https://en.wikipedia.org/wiki/Slowly_changing_dimension#Type_2:_add_new_row) records from [Type 1](https://en.wikipedia.org/wiki/Slowly_changing_dimension#Type_1:_overwrite) (destructively updated) source data. This is [covered thoroughly in the dbt Docs](https://docs.getdbt.com/docs/build/snapshots), unlike these other folders has a more defined purpose, and is out-of-scope for this guide, but mentioned for completion.
* ✅ `macros` for DRY-ing up transformations you find yourself doing repeatedly. Like snapshots, a full dive into macros is out-of-scope for this guide and well [covered elsewhere](https://docs.getdbt.com/docs/build/jinja-macros), but one important structure-related recommendation is to [write documentation for your macros](https://docs.getdbt.com/faqs/Docs/documenting-macros). We recommend creating a `_macros.yml` and documenting the purpose and arguments for your macros once they’re ready for use.

### Project splitting[​](#project-splitting "Direct link to Project splitting")

One important, growing consideration in the analytics engineering ecosystem is how and when to split a codebase into multiple dbt projects. Currently, our advice for most teams, especially those just starting, is fairly simple: in most cases, we recommend doing so with [Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro)! Mesh allows organizations to handle complexity by connecting several dbt projects rather than relying on one big, monolithic project. This approach is designed to speed up development while maintaining governance.

As breaking up monolithic dbt projects into smaller, connected projects, potentially within a modern mono repo becomes easier, the scenarios we currently advise against may soon become feasible. So watch this space!

* ✅ **Business groups or departments.** Conceptual separations within the project are the primary reason to split up your project. This allows your business domains to own their own data products and still collaborate using Mesh. For more information about Mesh, please refer to our [Mesh FAQs](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-5-faqs).
* ✅ **Data governance.** Structural, organizational needs — such as data governance and security — are one of the few worthwhile reasons to split up a project. If, for instance, you work at a healthcare company with only a small team cleared to access raw data with PII in it, you may need to split out your staging models into their own projects to preserve those policies. In that case, you would import your staging project into the project that builds on those staging models as a [private package](https://docs.getdbt.com/docs/build/packages#private-packages).
* ✅ **Project size.** At a certain point, your project may grow to have simply too many models to present a viable development experience. If you have 1000s of models, it absolutely makes sense to find a way to split up your project.
* ❌ **ML vs Reporting use cases.** Similarly to the point above, splitting a project up based on different use cases, particularly more standard BI versus ML features, is a common idea. We tend to discourage it for the time being. As with the previous point, a foundational goal of implementing dbt is to create a single source of truth in your organization. The features you’re providing to your data science teams should be coming from the same marts and metrics that serve reports on executive dashboards.

## Final considerations[​](#final-considerations "Direct link to Final considerations")

Overall, consistency is more important than any of these specific conventions. As your project grows and your experience with dbt deepens, you will undoubtedly find aspects of the above structure you want to change. While we recommend this approach for the majority of projects, every organization is unique! The only dogmatic advice we’ll put forward here is that when you find aspects of the above structure you wish to change, think intently about your reasoning and document for your team *how* and *why* you are deviating from these conventions. To that end, we highly encourage you to fork this guide and add it to your project’s README, wiki, or docs so you can quickly create and customize those artifacts.

Finally, we emphasize that this guide is a living document! It will certainly change and grow as dbt and dbt Labs evolve. We invite you to join in — discuss, comment, and contribute regarding suggested changes or new elements to cover.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Marts: Business-defined entities](https://docs.getdbt.com/best-practices/how-we-structure/4-marts)[Next

How we style our dbt projects](https://docs.getdbt.com/best-practices/how-we-style/0-how-we-style-our-dbt-projects)

* [Project structure review](#project-structure-review)* [YAML in-depth](#yaml-in-depth)* [How we use the other folders](#how-we-use-the-other-folders)* [Project splitting](#project-splitting)* [Final considerations](#final-considerations)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-structure/5-the-rest-of-the-project.md)
