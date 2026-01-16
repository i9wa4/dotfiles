---
title: "About the empty flag | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/empty-flag"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* Optimize development

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fempty-flag+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fempty-flag+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fempty-flag+so+I+can+ask+questions+about+it.)

On this page

note

The `--empty` flag is not currently available for Python models. If the flag is used with a Python model, it will be ignored.

During dbt development, you might want to validate that your models are semantically correct without the time-consuming cost of building the entire model in the data warehouse. The [`run`](https://docs.getdbt.com/reference/commands/run) and [`build`](https://docs.getdbt.com/reference/commands/build) commands support the `--empty` flag for building schema-only dry runs. The `--empty` flag limits the refs and sources to zero rows. dbt will still execute the model SQL against the target data warehouse but will avoid expensive reads of input data. This validates dependencies and ensures your models will build properly.

### Examples[​](#examples "Direct link to Examples")

Run all models in a project while building only the schemas in your development environment:

```
dbt run --empty
```

Run a specific model:

```
dbt run --select path/to/your_model --empty
```

dbt will build and execute the SQL, resulting in an empty schema in the data warehouse.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

The sample flag](https://docs.getdbt.com/docs/build/sample-flag)

* [Examples](#examples)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/empty-flag.md)
