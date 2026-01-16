---
title: "Validations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/validation"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your metrics](https://docs.getdbt.com/docs/build/build-metrics-intro)* [About MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow)* Validations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fvalidation+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fvalidation+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fvalidation+so+I+can+ask+questions+about+it.)

On this page

Validations refer to the process of checking whether a system or configuration meets the expected requirements or constraints. In the case of the Semantic Layer, powered by MetricFlow, there are three built-in validations — [parsing](#parsing), [semantic](#semantic), and [data platform](#data-platform).

These validations ensure that configuration files follow the expected schema, the semantic graph doesn't violate any constraints, and semantic definitions in the graph exist in the physical table - providing effective data governance support. These three validation steps occur sequentially and must succeed before proceeding to the next step.

The code that handles validation [can be found here](https://github.com/dbt-labs/dbt-semantic-interfaces/tree/main/dbt_semantic_interfaces/validations) for those who want to dive deeper into this topic.

## Validations command[​](#validations-command "Direct link to Validations command")

You can run validations from dbt or the command line with the following [MetricFlow commands](https://docs.getdbt.com/docs/build/metricflow-commands). In dbt, you need developer credentials to run `dbt sl validate-configs` in the IDE or CLI, and deployment credentials to run it in CI.

```
dbt sl validate # <Constant name="cloud" /> users
mf validate-configs # <Constant name="core" /> users
```

## Parsing[​](#parsing "Direct link to Parsing")

In this validation step, we ensure your config files follow the defined schema for each semantic graph object and can be parsed successfully. It validates the schema for the following core objects:

* Semantic models
* Identifiers
* Measures
* Dimensions
* Metrics

## Semantic syntax[​](#semantic-syntax "Direct link to Semantic syntax")

This syntactic validation step occurs after we've built your semantic graph. The Semantic Layer, powered by MetricFlow, runs a suite of tests to ensure that your semantic graph doesn't violate any constraints. For example, we check to see if measure names are unique, or if metrics referenced in materialization exist. The current semantic rules we check for are:

1. Check those semantic models with measures have a valid time dimension
2. Check that there is only one primary identifier defined in each semantic model
3. Dimension consistency
4. Unique measures in semantic models
5. Measures in metrics are valid
6. Cumulative metrics are configured properly

## Data platform[​](#data-platform "Direct link to Data platform")

This type of validation checks to see if the semantic definitions in your semantic graph exist in the underlying physical table. To test this, we run queries against your data platform to ensure the generated SQL for semantic models, dimensions, and metrics will execute. We run the following checks:

* Measures and dimensions exist
* Underlying tables for data sources exist
* Generated SQL for metrics will execute

You can run semantic validations (against your semantic layer) in a CI job to guarantee any code changes made to dbt models don't break these metrics. For more information, refer to [semantic validation in CI](https://docs.getdbt.com/docs/deploy/ci-jobs#semantic-validations-in-ci).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

MetricFlow commands](https://docs.getdbt.com/docs/build/metricflow-commands)[Next

Semantic models](https://docs.getdbt.com/docs/build/semantic-models)

* [Validations command](#validations-command)* [Parsing](#parsing)* [Semantic syntax](#semantic-syntax)* [Data platform](#data-platform)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/validation.md)
