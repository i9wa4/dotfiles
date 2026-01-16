---
title: "About dbt models | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/models"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* Build your DAG

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmodels+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmodels+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fmodels+so+I+can+ask+questions+about+it.)

On this page

dbt Core and Cloud are composed of different moving parts working harmoniously. All of them are important to what dbt does — transforming data—the 'T' in ELT. When you execute `dbt run`, you are running a model that will transform your data without that data ever leaving your warehouse.

Models are where your developers spend most of their time within a dbt environment. Models are primarily written as a `select` statement and saved as a `.sql` file. While the definition is straightforward, the complexity of the execution will vary from environment to environment. Models will be written and rewritten as needs evolve and your organization finds new ways to maximize efficiency.

SQL is the language most dbt users will utilize, but it is not the only one for building models. Starting in version 1.3, dbt Core and dbt support Python models. Python models are useful for training or deploying data science models, complex transformations, or where a specific Python package meets a need — such as using the `dateutil` library to parse dates.

### Models and modern workflows[​](#models-and-modern-workflows "Direct link to Models and modern workflows")

The top level of a dbt workflow is the project. A project is a directory of a `.yml` file (the project configuration) and either `.sql` or `.py` files (the models). The project file tells dbt the project context, and the models let dbt know how to build a specific data set. For more details on projects, refer to [About dbt projects](https://docs.getdbt.com/docs/build/projects).

Your organization may need only a few models, but more likely you’ll need a complex structure of nested models to transform the required data. A model is a single file containing a final `select` statement, and a project can have multiple models, and models can even reference each other. Add to that, numerous projects and the level of effort required for transforming complex data sets can improve drastically compared to older methods.

Learn more about models in [SQL models](https://docs.getdbt.com/docs/build/sql-models) and [Python models](https://docs.getdbt.com/docs/build/python-models) pages. If you'd like to begin with a bit of practice, visit our [Getting Started Guide](https://docs.getdbt.com/guides) for instructions on setting up the Jaffle\_Shop sample data so you can get hands-on with the power of dbt.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

SQL models](https://docs.getdbt.com/docs/build/sql-models)

* [Models and modern workflows](#models-and-modern-workflows)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/models.md)
