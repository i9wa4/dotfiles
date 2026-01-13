---
title: "About dbt test command | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/commands/test"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [List of commands](https://docs.getdbt.com/category/list-of-commands)* test

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Ftest+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Ftest+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Ftest+so+I+can+ask+questions+about+it.)

`dbt test` runs data tests defined on models, sources, snapshots, and seeds and unit tests defined on SQL models. It expects that you have already created those resources through the appropriate commands.

The tests to run can be selected using the `--select` flag discussed [here](https://docs.getdbt.com/reference/node-selection/syntax).

```
# run data and unit tests
dbt test

# run only data tests
dbt test --select test_type:data

# run only unit tests
dbt test --select test_type:unit

# run tests for one_specific_model
dbt test --select "one_specific_model"

# run tests for all models in package
dbt test --select "some_package.*"

# run only data tests defined singularly
dbt test --select "test_type:singular"

# run only data tests defined generically
dbt test --select "test_type:generic"

# run data tests limited to one_specific_model
dbt test --select "one_specific_model,test_type:data"

# run unit tests limited to one_specific_model
dbt test --select "one_specific_model,test_type:unit"
```

For more information on writing tests, read the [data testing](https://docs.getdbt.com/docs/build/data-tests) and [unit testing](https://docs.getdbt.com/docs/build/unit-tests) documentation.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

source](https://docs.getdbt.com/reference/commands/source)[Next

version](https://docs.getdbt.com/reference/commands/version)
