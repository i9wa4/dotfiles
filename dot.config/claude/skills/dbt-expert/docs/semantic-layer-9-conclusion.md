---
title: "Best practices | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-9-conclusion"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* [How we build our metrics](https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-1-intro)* Best practices

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-build-our-metrics%2Fsemantic-layer-9-conclusion+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-build-our-metrics%2Fsemantic-layer-9-conclusion+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-build-our-metrics%2Fsemantic-layer-9-conclusion+so+I+can+ask+questions+about+it.)

On this page

## Putting it all together[​](#putting-it-all-together "Direct link to Putting it all together")

* 📊 We've walked through **creating semantic models and metrics** for basic coverage of a key business area.
* 🔁 In doing so we've looked at how to **refactor a frozen rollup** into a dynamic, flexible new life in the Semantic Layer.

## Best practices[​](#best-practices "Direct link to Best practices")

* ✅ **Prefer normalization** when possible to allow MetricFlow to denormalize dynamically for end users.
* ✅ Use **marts to denormalize** when needed, for instance grouping tables together into richer components, or getting measures on dimensional tables attached to a table with a time spine.
* ✅ When source data is **well normalized** you can **build semantic models on top of staging models**.
* ✅ **Prefer** computing values in **measures and metrics** when possible as opposed to in frozen rollups.
* ❌ **Don't directly refactor the code you have in production**, build in parallel so you can audit the Semantic Layer output and deprecate old marts gracefully.

## Key commands[​](#key-commands "Direct link to Key commands")

* 🔑 Use `dbt parse` to generate a fresh semantic manifest.
* 🔑 Use `dbt sl list dimensions --metrics [metric name]` to check that you're increasing dimensionality as you progress.
* 🔑 Use `dbt sl query [query options]` to preview the output from your metrics as you develop.

## Next steps[​](#next-steps "Direct link to Next steps")

* 🗺️ Use these best practices to map out your team's plan to **incrementally adopt the Semantic Layer**.
* 🤗 Get involved in the community and ask questions, **help craft best practices**, and share your progress in building a Semantic Layer.
* [Validate semantic nodes in CI](https://docs.getdbt.com/docs/deploy/ci-jobs#semantic-validations-in-ci) to ensure code changes made to dbt models don't break these metrics.

The Semantic Layer is the biggest paradigm shift thus far in the young practice of analytics engineering. It's ready to provide value right away, but is most impactful if you move your project towards increasing normalization, and allow MetricFlow to do the denormalization for you with maximum dimensionality.

We will be releasing more resources soon covering implementation of the Semantic Layer in dbt with various integrated BI tools. This is just the beginning, hopefully this guide has given you a path forward for building your data platform in this new era. Refer to [Semantic Layer FAQs](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-faqs) for more information.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Refactor an existing rollup](https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-8-refactor-a-rollup)

* [Putting it all together](#putting-it-all-together)* [Best practices](#best-practices)* [Key commands](#key-commands)* [Next steps](#next-steps)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-build-our-metrics/semantic-layer-9-conclusion.md)
