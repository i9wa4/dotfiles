---
title: "New concepts in the dbt Fusion engine | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/fusion/new-concepts"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt Fusion engine](https://docs.getdbt.com/docs/fusion)* New concepts

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Ffusion%2Fnew-concepts+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Ffusion%2Fnew-concepts+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Ffusion%2Fnew-concepts+so+I+can+ask+questions+about+it.)

On this page

The dbt Fusion Engine [fully comprehends your project's SQL](https://docs.getdbt.com/blog/the-levels-of-sql-comprehension), enabling advanced capabilities like dialect-aware validation and precise column-level lineage.

It can do this because its compilation step is more comprehensive than that of the dbt Core engine. When dbt Core referred to *compilation*, it only meant *rendering* — converting Jinja-templated strings into a SQL query to send to a database.

The dbt Fusion engine can also render Jinja, but then it completes a second phase: producing and validating with *static analysis* a logical plan for every rendered query in the project. This static analysis step is the cornerstone of Fusion's new capabilities.

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Step dbt Core engine dbt Fusion engine|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Render Jinja into SQL ✅ ✅|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Produce and statically analyze logical plan ❌ ✅|  |  |  | | --- | --- | --- | | Run rendered SQL ✅ ✅ | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Rendering strategies[​](#rendering-strategies "Direct link to Rendering strategies")

[![Each dot represents a step in that model's execution (render, analyze, run). The numbers reflect step order across the DAG. JIT steps are green; AOT steps are purple.](https://docs.getdbt.com/img/fusion/annotated_steps.png?v=2 "Each dot represents a step in that model's execution (render, analyze, run). The numbers reflect step order across the DAG. JIT steps are green; AOT steps are purple.")](#)Each dot represents a step in that model's execution (render, analyze, run). The numbers reflect step order across the DAG. JIT steps are green; AOT steps are purple.

 JIT rendering and execution (dbt Core)

[](https://docs.getdbt.com/img/fusion/CoreJitRun.mp4)

dbt Core will *always* use **Just In Time (JIT) rendering**. It renders a model, runs it in the warehouse, then moves on to the next model.

 AOT rendering, analysis and execution (dbt Fusion engine)

[](https://docs.getdbt.com/img/fusion/FusionAotRun.mp4)

The dbt Fusion Engine will *default to* **Ahead of Time (AOT) rendering and analysis**. It renders all models in the project, then produces and statically analyzes every model's logical plan, and only then will it start running models in the warehouse.

By rendering and analyzing all models ahead of time, and only beginning execution once everything is proven to be valid, the dbt Fusion Engine avoids consuming any warehouse resources unnecessarily. By contrast, SQL errors in models run by dbt Core's engine will only be flagged by the database itself during execution.

### Rendering introspective queries[​](#rendering-introspective-queries "Direct link to Rendering introspective queries")

The exception to AOT rendering is an introspective model: a model whose rendered SQL depends on the results of a database query. Models containing macros like `run_query()` or `dbt_utils.get_column_values()` are introspective. Introspection causes issues with ahead-of-time rendering because:

* Most introspective queries are run against the results of an earlier model in the DAG, which may not yet exist in the database during AOT rendering.
* Even if the model does exist in the database, it might be out of date until after the model has been refreshed.

The dbt Fusion Engine switches to **JIT rendering for introspective models**, to ensure it renders them the same way as dbt Core.

Note that macros like `adapter.get_columns_in_relation()` and `dbt_utils.star()` *can* be rendered and analyzed ahead of time, as long as the [`Relations`](https://docs.getdbt.com/reference/dbt-classes#relation) they inspect aren't themselves dynamic. This is because the dbt Fusion Engine populates schemas into memory as part of the compilation process.

## Principles of static analysis[​](#principles-of-static-analysis "Direct link to Principles of static analysis")

The concept of [static analysis](https://en.wikipedia.org/wiki/Static_program_analysis) is meant to guarantee that if a model compiles without error in development, it will also run without compilation errors when deployed. Introspective queries can break this promise by making it possible to modify the rendered query after a model is committed to source control.

The dbt Fusion Engine uses the [`static_analysis`](https://docs.getdbt.com/reference/resource-configs/static-analysis) config to help you control how it performs static analysis for your models.

The dbt Fusion Engine is unique in that it can statically analyze not just a single model in isolation, but every query from one end of your DAG to the other. Even your database can only validate the query in front of it! Concepts like [information flow theory](https://roundup.getdbt.com/i/156064124/beyond-cll-information-flow-theory-and-metadata-propagation) — although not incorporated into the dbt platform [yet](https://www.getdbt.com/blog/where-we-re-headed-with-the-dbt-fusion-engine) — rely on stable inputs and the ability to trace columns DAG-wide.

### Static analysis and introspective queries[​](#static-analysis-and-introspective-queries "Direct link to Static analysis and introspective queries")

When Fusion encounters an introspective query, that model will switch to just-in-time rendering (as described above). Both the introspective model and all of its descendants will also be opted in to JIT static analysis. We refer to JIT static analysis as "unsafe" because it will still capture most SQL errors and prevent execution of an invalid model, but only after upstream models have already been materialized.

This classification is meant to indicate that Fusion can no longer 100% guarantee alignment between what it analyzes and what will be executed. The most common real-world example where unsafe static analysis can cause an issue is a standalone `dbt compile` step (as opposed to the compilation that happens as part of a `dbt run`).

During a `dbt run`, JIT rendering ensures the downstream model's code will be up to date with the current warehouse state, but a standalone compile does not refresh the upstream model. In this scenario Fusion will read from the upstream model as it was last run. This is *probably* fine, but could lead to errors being raised incorrectly (a false positive) or not at all (a false negative).

 Rendering and analyzing without execution

[](https://docs.getdbt.com/img/fusion/FusionJitCompileUnsafe.mp4)

Note that `model_d` is rendered AOT, since it doesn't use introspection, but it still has to wait for `introspective_model_c` to be analyzed.

You will still derive significant benefits from "unsafe" static analysis compared to no static analysis, and we recommend leaving it on unless you notice it causing you problems. Better still, you should consider whether your introspective code could be rewritten in a way that is eligible for AOT rendering and static analysis.

## Recapping the differences between engines[​](#recapping-the-differences-between-engines "Direct link to Recapping the differences between engines")

dbt Core:

* renders all models just-in-time
* never runs static analysis

The dbt Fusion engine:

* renders all models ahead-of-time, unless they use introspective queries
* statically analyzes all models, defaulting to ahead-of-time unless they or their parents were rendered just-in-time, in which case the static analysis step will also happen just-in-time.

## Configuring `static_analysis`[​](#configuring-static_analysis "Direct link to configuring-static_analysis")

Beyond the default behavior described above, you can always modify the way static analysis is applied for specific models in your project. Remember that **a model is only eligible for static analysis if all of its parents are also eligible.**

The [`static_analysis`](https://docs.getdbt.com/reference/resource-configs/static-analysis) config options are:

* `on`: Statically analyze SQL. The default for non-introspective models, depends on AOT rendering.
* `unsafe`: Statically analyze SQL. The default for introspective models. Always uses JIT rendering.
* `off`: Skip SQL analysis on this model and its descendants.

When you disable static analysis, features of the VS Code extension which depend on SQL comprehension will be unavailable.

The best place to configure `static_analysis` is as a config on an individual model or group of models. As a debugging aid, you can also use the [`--static-analysis off` or `--static-analysis unsafe` CLI flags](https://docs.getdbt.com/reference/global-configs/static-analysis-flag) to override all model-level configuration.

Refer to [CLI options](https://docs.getdbt.com/reference/global-configs/command-line-options) and [Configurations and properties](https://docs.getdbt.com/reference/configs-and-properties) to learn more about configs.

### Example configurations[​](#example-configurations "Direct link to Example configurations")

Disable static analysis for all models in a package:

dbt\_project.yml

```
name: jaffle_shop

models:
  jaffle_shop:
    marts:
      +materialized: table

  a_package_with_introspective_queries:
    +static_analysis: off
```

Disable static analysis in YAML:

models/my\_udf\_using\_model.yml

```
models:
  - name: model_with_static_analysis_off
    config:
      static_analysis: off
```

Disable static analysis for a model using a custom UDF:

models/my\_udf\_using\_model.sql

```
{{ config(static_analysis='off') }}

select
  user_id,
  my_cool_udf(ip_address) as cleaned_ip
from {{ ref('my_model') }}
```

### When should I turn static analysis `off`?[​](#when-should-i-turn-static-analysis-off "Direct link to when-should-i-turn-static-analysis-off")

Static analysis may incorrectly fail on valid queries if they contain:

* **syntax or native functions** that the dbt Fusion Engine doesn't recognize. Please [open an issue](https://github.com/dbt-labs/dbt-fusion/issues) in addition to disabling static analysis.
* **user-defined functions** that the dbt Fusion Engine doesn't recognize. You will need to temporarily disable static analysis. Native support for UDF compilation will arrive in a future version - see [dbt-fusion#69](https://github.com/dbt-labs/dbt-fusion/issues/69).
* **dynamic SQL** such as [Snowflake's PIVOT ANY](https://docs.snowflake.com/en/sql-reference/constructs/pivot#dynamic-pivot-on-all-distinct-column-values-automatically) which cannot be statically analyzed. You can disable static analysis, refactor your pivot to use explicit column names, or create a [dynamic pivot in Jinja](https://github.com/dbt-labs/dbt-utils#pivot-source).
* **highly volatile data feeding an introspective query** during a standalone `dbt compile` invocation. Because the `dbt compile` step does not run models, it uses old data or defers to a different environment when running introspective queries. The more frequently the input data changes, the more likely it is for this divergence to cause a compilation error. Consider whether these standalone `dbt compile` commands are necessary before disabling static analysis.

## Examples[​](#examples "Direct link to Examples")

### No introspective models[​](#no-introspective-models "Direct link to No introspective models")

 AOT rendering, analysis and execution

[](https://docs.getdbt.com/img/fusion/FusionAotRun.mp4)

* Fusion renders each model in order.
* Then it statically analyzes each model's logical plan in order.
* Finally, it runs each model's rendered SQL. Nothing is persisted to the database until Fusion has validated the entire project.

### Introspective model with `unsafe` static analysis[​](#introspective-model-with-unsafe-static-analysis "Direct link to introspective-model-with-unsafe-static-analysis")

Imagine we update `model_c` to contain an introspective query (such as `dbt_utils.get_column_values`). We'll say it's querying `model_b`, but the dbt Fusion Engine's response is the same regardless of what the introspection does.

 Unsafe static analysis of introspective models

[](https://docs.getdbt.com/img/fusion/FusionJitRunUnsafe.mp4)

* During parsing, Fusion discovers `model_c`'s introspective query. It switches `model_c` to JIT rendering and opts `model_c+` in to JIT static analysis.
* `model_a` and `model_b` are still eligible for AOT compilation, so Fusion handles them the same as in the introspection-free example above. `model_d` is still eligible for AOT rendering (but not analysis).
* Once `model_b` is run, Fusion renders `model_c`'s SQL (using the just-refreshed data), analyzes it, and runs it. All three steps happen back-to-back.
* `model_d`'s AOT-rendered SQL is analyzed and run.

 Complex DAG with an introspective branch

[](https://docs.getdbt.com/img/fusion/FusionJitRunUnsafeComplexDag.mp4)

As you'd expect, a branching DAG will AOT compile as much as possible before moving on to the JIT components, and will work with multiple `--threads` if they're available. Here, `model_c` can start rendering as soon as `model_b` has finished running, while the AOT-compiled `model_x` and `model_y` run separately:

## More information about Fusion[​](#more-information-about-fusion "Direct link to More information about Fusion")

Fusion marks a significant update to dbt. While many of the workflows you've grown accustomed to remain unchanged, there are a lot of new ideas, and a lot of old ones going away. The following is a list of the full scope of our current release of the Fusion engine, including implementation, installation, deprecations, and limitations:

* [About the dbt Fusion engine](https://docs.getdbt.com/docs/fusion/about-fusion)
* [About the dbt extension](https://docs.getdbt.com/docs/about-dbt-extension)
* [New concepts in Fusion](https://docs.getdbt.com/docs/fusion/new-concepts)
* [Supported features matrix](https://docs.getdbt.com/docs/fusion/supported-features)
* [Installing Fusion CLI](https://docs.getdbt.com/docs/fusion/install-fusion-cli)
* [Installing VS Code extension](https://docs.getdbt.com/docs/install-dbt-extension)
* [Fusion release track](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#dbt-fusion-engine)
* [Quickstart for Fusion](https://docs.getdbt.com/guides/fusion?step=1)
* [Upgrade guide](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-fusion)
* [Fusion licensing](http://www.getdbt.com/licenses-faq)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

* [Rendering strategies](#rendering-strategies)
  + [Rendering introspective queries](#rendering-introspective-queries)* [Principles of static analysis](#principles-of-static-analysis)
    + [Static analysis and introspective queries](#static-analysis-and-introspective-queries)* [Recapping the differences between engines](#recapping-the-differences-between-engines)* [Configuring `static_analysis`](#configuring-static_analysis)
        + [Example configurations](#example-configurations)+ [When should I turn static analysis `off`?](#when-should-i-turn-static-analysis-off)* [Examples](#examples)
          + [No introspective models](#no-introspective-models)+ [Introspective model with `unsafe` static analysis](#introspective-model-with-unsafe-static-analysis)* [More information about Fusion](#more-information-about-fusion)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/fusion/new-concepts.md)
