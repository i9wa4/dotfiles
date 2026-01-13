---
title: "Best practices for workflows | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/best-practice-workflows"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* Best practices for workflows

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fbest-practice-workflows+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fbest-practice-workflows+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fbest-practice-workflows+so+I+can+ask+questions+about+it.)

On this page

This page contains the collective wisdom of experienced users of dbt on how to best use it in your analytics work. Observing these best practices will help your analytics team work as effectively as possible, while implementing the pro-tips will add some polish to your dbt projects!

## Best practice workflows[​](#best-practice-workflows "Direct link to Best practice workflows")

### Version control your dbt project[​](#version-control-your-dbt-project "Direct link to Version control your dbt project")

All dbt projects should be managed in version control. Git branches should be created to manage development of new features and bug fixes. All code changes should be reviewed by a colleague (or yourself) in a Pull Request prior to merging into your production branch, such as `main`.

Git guide

We've codified our best practices in Git, in our [Git guide](https://github.com/dbt-labs/corp/blob/main/git-guide.md).

### Use separate development and production environments[​](#use-separate-development-and-production-environments "Direct link to Use separate development and production environments")

dbt makes it easy to maintain separate production and development environments through the use of targets within a profile. We recommend using a `dev` target when running dbt from your command line and only running against a `prod` target when running from a production deployment. You can read more [about managing environments here](https://docs.getdbt.com/docs/environments-in-dbt).

### Use a style guide for your project[​](#use-a-style-guide-for-your-project "Direct link to Use a style guide for your project")

SQL styles, field naming conventions, and other rules for your dbt project should be codified, especially on projects where multiple dbt users are writing code.

Our style guide

We've made our [style guide](https://docs.getdbt.com/best-practices/how-we-style/0-how-we-style-our-dbt-projects) public – these can act as a good starting point for your own style guide.

## Best practices in dbt projects[​](#best-practices-in-dbt-projects "Direct link to Best practices in dbt projects")

### Use the ref function[​](#use-the-ref-function "Direct link to Use the ref function")

The [ref](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) function is what makes dbt so powerful! Using the `ref` function allows dbt to infer dependencies, ensuring that models are built in the correct order. It also ensures that your current model selects from upstream tables and views in the same environment that you're working in.
Always use the `ref` function when selecting from another model, rather than using the direct relation reference (e.g. `my_schema.my_table`).

### Limit references to raw data[​](#limit-references-to-raw-data "Direct link to Limit references to raw data")

Your dbt project will depend on raw data stored in your database. Since this data is normally loaded by third parties, the structure of it can change over time – tables and columns may be added, removed, or renamed. When this happens, it is easier to update models if raw data is only referenced in one place.

Using sources for raw data references

We recommend defining your raw data as [sources](https://docs.getdbt.com/docs/build/sources), and selecting from the source rather than using the direct relation reference. Our dbt projects don't contain any direct relation references in any models.

### Rename and recast fields once[​](#rename-and-recast-fields-once "Direct link to Rename and recast fields once")

Raw data is generally stored in a source-conformed structure, that is, following the schema and naming conventions that the source defines. Not only will this structure differ between different sources, it is also likely to differ from the naming conventions you wish to use for analytics.

The first layer of transformations in a dbt project should:

* Select from only one source
* Rename fields and tables to fit the conventions you wish to use within your project, for example, ensuring all timestamps are named `<event>_at`. These conventions should be declared in your project coding conventions (see above).
* Recast fields into the correct data type, for example, changing dates into UTC and prices into dollar amounts.

All subsequent data models should be built on top of these models, reducing the amount of duplicated code.

What happened to base models?

Earlier versions of this documentation recommended implementing “base models” as the first layer of transformation, and gave advice on the SQL within these models. We realized that while the reasons behind this convention were valid, the specific advice around "base models" represented an opinion, so we moved it out of the official documentation.

You can instead find our opinions on [how we structure our dbt projects](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview).

### Break complex models up into smaller pieces[​](#break-complex-models-up-into-smaller-pieces "Direct link to Break complex models up into smaller pieces")

Complex models often include multiple Common Table Expressions (CTEs). In dbt, you can instead separate these CTEs into separate models that build on top of each other. It is often a good idea to break up complex models when:

* A CTE is duplicated across two models. Breaking the CTE into a separate model allows you to reference the model from any number of downstream models, reducing duplicated code.
* A CTE changes the grain of a the data it selects from. It's often useful to test any transformations that change the grain (as in, what one record represents) of your data. Breaking a CTE into a separate model allows you to test this transformation independently of a larger model.
* The SQL in a query contains many lines. Breaking CTEs into separate models can reduce the cognitive load when another dbt user (or your future self) is looking at the code.

### Group your models in directories[​](#group-your-models-in-directories "Direct link to Group your models in directories")

Within your `models/` directory, you can have any number of nested subdirectories. We leverage directories heavily, since using a nested structure within directories makes it easier to:

* Configure groups of models, by specifying configurations in your `dbt_project.yml` file.
* Run subsections of your DAG, by using the [model selection syntax](https://docs.getdbt.com/reference/node-selection/syntax).
* Communicate modeling steps to collaborators
* Create conventions around the allowed upstream dependencies of a model, for example, "models in the `marts` directory can only select from other models in the `marts` directory, or from models in the `staging` directory".

### Add tests to your models[​](#add-tests-to-your-models "Direct link to Add tests to your models")

dbt provides a framework to test assumptions about the results generated by a model. Adding tests to a project helps provide assurance that both:

* your SQL is transforming data in the way you expect, and
* your source data contains the values you expect

Recommended tests

Our [style guide](https://github.com/dbt-labs/corp/blob/main/dbt_style_guide.md) recommends that at a minimum, every model should have a primary key that is tested to ensure it is unique, and not null.

### Consider the information architecture of your data warehouse[​](#consider-the-information-architecture-of-your-data-warehouse "Direct link to Consider the information architecture of your data warehouse")

When a user connects to a data warehouse via a SQL client, they often rely on the names of schemas, relations, and columns, to understand the data they are presented with. To improve the information architecture of a data warehouse, we:

* Use [custom schemas](https://docs.getdbt.com/docs/build/custom-schemas) to separate relations into logical groupings, or hide intermediate models in a separate schema. Generally, these custom schemas align with the directories we use to group our models, and are configured from the `dbt_project.yml` file.
* Use prefixes in table names (for example, `stg_`, `fct_` and `dim_`) to indicate which relations should be queried by end users.

### Choose your materializations wisely[​](#choose-your-materializations-wisely "Direct link to Choose your materializations wisely")

[materialization](https://docs.getdbt.com/docs/build/materializations) determine the way models are built through configuration. As a general rule:

* Views are faster to build, but slower to query compared to tables.
* Incremental models provide the same query performance as tables, are faster to build compared to the table materialization, however they introduce complexity into a project.

We often:

* Use views by default
* Use ephemeral models for lightweight transformations that shouldn't be exposed to end-users
* Use tables for models that are queried by BI tools
* Use tables for models that have multiple descendants
* Use incremental models when the build time for table models exceeds an acceptable threshold

## Pro-tips for workflows[​](#pro-tips-for-workflows "Direct link to Pro-tips for workflows")

### Use the model selection syntax when running locally[​](#use-the-model-selection-syntax-when-running-locally "Direct link to Use the model selection syntax when running locally")

When developing, it often makes sense to only run the model you are actively working on and any downstream models. You can choose which models to run by using the [model selection syntax](https://docs.getdbt.com/reference/node-selection/syntax).

### Run only modified models to test changes ("slim CI")[​](#run-only-modified-models-to-test-changes-slim-ci "Direct link to Run only modified models to test changes (\"slim CI\")")

To merge code changes with confidence, you want to know that those changes will not cause breakages elsewhere in your project. For that reason, we recommend running models and tests in a sandboxed environment, separated from your production data, as an automatic check in your git workflow. (If you use GitHub and dbt, read about [how to set up CI jobs](https://docs.getdbt.com/docs/deploy/ci-jobs).

At the same time, it costs time (and money) to run and test all the models in your project. This inefficiency feels especially painful if your PR only proposes changes to a handful of models.

By comparing to artifacts from a previous production run, dbt can determine which models are modified and build them on top of of their unmodified parents.

```
dbt run -s state:modified+ --defer --state path/to/prod/artifacts
dbt test -s state:modified+ --defer --state path/to/prod/artifacts
```

By comparing to artifacts from a previous production run, dbt can determine model and test result statuses.

* `result:fail`
* `result:error`
* `result:warn`
* `result:success`
* `result:skipped`
* `result:pass`

For smarter reruns, use the `result:<status>` selector instead of manually overriding dbt commands with the models in scope.

```
dbt run --select state:modified+ result:error+ --defer --state path/to/prod/artifacts
```

* Rerun all my erroneous models AND run changes I made concurrently that may relate to the erroneous models for downstream use

```
dbt build --select state:modified+ result:error+ --defer --state path/to/prod/artifacts
```

* Rerun and retest all my erroneous models AND run changes I made concurrently that may relate to the erroneous models for downstream use

```
dbt build --select state:modified+ result:error+ result:fail+ --defer --state path/to/prod/artifacts
```

* Rerun all my erroneous models AND all my failed tests
* Rerun all my erroneous models AND run changes I made concurrently that may relate to the erroneous models for downstream use
* There's a failed test that's unrelated to modified or error nodes(think: source test that needs to refresh a data load in order to pass)

```
dbt test --select result:fail --exclude <example test> --defer --state path/to/prod/artifacts
```

* Rerun all my failed tests and exclude tests that I know will still fail
* This can apply to updates in source data during the "EL" process that need to be rerun after they are refreshed

> Note: If you're using the `--state target/` flag, `result:error` and `result:fail` flags can only be selected concurrently(in the same command) if using the `dbt build` command. `dbt test` will overwrite the `run_results.json` from `dbt run` in a previous command invocation.

Only supported by v1.1 or newer.

By comparing to a `sources.json` artifact from a previous production run to a current `sources.json` artifact, dbt can determine which sources are fresher and run downstream models based on them.

```
# job 1
dbt source freshness # must be run to get previous state
```

Test all my sources that are fresher than the previous run, and run and test all models downstream of them:

```
# job 2
dbt source freshness # must be run again to compare current to previous state
dbt build --select source_status:fresher+ --state path/to/prod/artifacts
```

To learn more, read the docs on [state](https://docs.getdbt.com/reference/node-selection/syntax#about-node-selection).

## Pro-tips for dbt Projects[​](#pro-tips-for-dbt-projects "Direct link to Pro-tips for dbt Projects")

### Limit the data processed when in development[​](#limit-the-data-processed-when-in-development "Direct link to Limit the data processed when in development")

In a development environment, faster run times allow you to iterate your code more quickly. We frequently speed up our runs by using a pattern that limits data based on the [target](https://docs.getdbt.com/reference/dbt-jinja-functions/target) name:

```
select
*
from event_tracking.events
{% if target.name == 'dev' %}
where created_at >= dateadd('day', -3, current_date)
{% endif %}
```

Another option is to use the [environment variable `DBT_CLOUD_INVOCATION_CONTEXT`](https://docs.getdbt.com/docs/build/environment-variables#dbt-platform-context). This environment variable provides metadata about the execution context of dbt. The possible values are `prod`, `dev`, `staging`, and `ci`.

**Example usage**:

```
{% if env_var('DBT_CLOUD_INVOCATION_CONTEXT') != 'prod' %}
```

### Use grants to manage privileges on objects that dbt creates[​](#use-grants-to-manage-privileges-on-objects-that-dbt-creates "Direct link to Use grants to manage privileges on objects that dbt creates")

Use `grants` in [resource configs](https://docs.getdbt.com/reference/resource-configs/grants) to ensure that permissions are applied to the objects created by dbt. By codifying these grant statements, you can version control and repeatably apply these permissions.

### Separate source-centric and business-centric transformations[​](#separate-source-centric-and-business-centric-transformations "Direct link to Separate source-centric and business-centric transformations")

When modeling data, we frequently find there are two stages:

1. Source-centric transformations to transform data from different sources into a consistent structure, for example, re-aliasing and recasting columns, or unioning, joining or deduplicating source data to ensure your model has the correct grain; and
2. Business-centric transformations that transform data into models that represent entities and processes relevant to your business, or implement business definitions in SQL.

We find it most useful to separate these two types of transformations into different models, to make the distinction between source-centric and business-centric logic clear.

### Managing whitespace generated by Jinja[​](#managing-whitespace-generated-by-jinja "Direct link to Managing whitespace generated by Jinja")

If you're using macros or other pieces of Jinja in your models, your compiled SQL (found in the `target/compiled` directory) may contain unwanted whitespace. Check out the [Jinja documentation](http://jinja.pocoo.org/docs/2.10/templates/#whitespace-control) to learn how to control generated whitespace.

## Related docs[​](#related-docs "Direct link to Related docs")

* [Updating our permissioning guidelines: grants as configs in dbt Core v1.2](https://docs.getdbt.com/blog/configuring-grants)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Writing custom generic data tests](https://docs.getdbt.com/best-practices/writing-custom-generic-tests)[Next

Best practices for dbt and Unity Catalog](https://docs.getdbt.com/best-practices/dbt-unity-catalog-best-practices)

* [Best practice workflows](#best-practice-workflows)
  + [Version control your dbt project](#version-control-your-dbt-project)+ [Use separate development and production environments](#use-separate-development-and-production-environments)+ [Use a style guide for your project](#use-a-style-guide-for-your-project)* [Best practices in dbt projects](#best-practices-in-dbt-projects)
    + [Use the ref function](#use-the-ref-function)+ [Limit references to raw data](#limit-references-to-raw-data)+ [Rename and recast fields once](#rename-and-recast-fields-once)+ [Break complex models up into smaller pieces](#break-complex-models-up-into-smaller-pieces)+ [Group your models in directories](#group-your-models-in-directories)+ [Add tests to your models](#add-tests-to-your-models)+ [Consider the information architecture of your data warehouse](#consider-the-information-architecture-of-your-data-warehouse)+ [Choose your materializations wisely](#choose-your-materializations-wisely)* [Pro-tips for workflows](#pro-tips-for-workflows)
      + [Use the model selection syntax when running locally](#use-the-model-selection-syntax-when-running-locally)+ [Run only modified models to test changes ("slim CI")](#run-only-modified-models-to-test-changes-slim-ci)* [Pro-tips for dbt Projects](#pro-tips-for-dbt-projects)
        + [Limit the data processed when in development](#limit-the-data-processed-when-in-development)+ [Use grants to manage privileges on objects that dbt creates](#use-grants-to-manage-privileges-on-objects-that-dbt-creates)+ [Separate source-centric and business-centric transformations](#separate-source-centric-and-business-centric-transformations)+ [Managing whitespace generated by Jinja](#managing-whitespace-generated-by-jinja)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/best-practice-workflows.md)
