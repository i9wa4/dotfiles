---
title: "Intro to the dbt Semantic Layer | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-1-intro"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* How we build our metrics

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-build-our-metrics%2Fsemantic-layer-1-intro+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-build-our-metrics%2Fsemantic-layer-1-intro+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-build-our-metrics%2Fsemantic-layer-1-intro+so+I+can+ask+questions+about+it.)

On this page

Flying cars, hoverboards, and true self-service analytics: this is the future we were promised. The first two might still be a few years out, but real self-service analytics is here today. With dbt's Semantic Layer, you can resolve the tension between accuracy and flexibility that has hampered analytics tools for years, empowering everybody in your organization to explore a shared reality of metrics. Best of all for analytics engineers, building with these new tools will significantly [DRY](https://docs.getdbt.com/terms/dry) up and simplify your codebase. As you'll see, the deep interaction between your dbt models and the Semantic Layer make your dbt project the ideal place to craft your metrics.

## Learning goals[​](#learning-goals "Direct link to Learning goals")

* ❓ Understand the **purpose and capabilities** of the **Semantic Layer**, particularly MetricFlow as the engine that powers it.
* 🧱 Familiarity with the core components of MetricFlow — **semantic models and metrics** — and how they work together.
* 🔁 Know how to **refactor** dbt models for the Semantic Layer.
* 🏅 Aware of **best practices** to take maximum advantage of the Semantic Layer.

## Guide structure overview[​](#guide-structure-overview "Direct link to Guide structure overview")

1. Getting **setup** in your dbt project.
2. Building a **semantic model** and its fundamental parts: **entities, dimensions, and measures**.
3. Building a **metric**.
4. Defining **advanced metrics**: `ratio` and `derived` types.
5. **File and folder structure**: establishing a system for naming things.
6. **Refactoring** marts and roll-ups for the Semantic Layer.
7. Review **best practices**.

If you're ready to ship your users more power and flexibility with less code, let's dive in!

info

MetricFlow is the engine for defining metrics in dbt and one of the key components of the [Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl). It handles SQL query construction and defines the specification for dbt semantic models and metrics.

To fully experience the Semantic Layer, including the ability to query dbt metrics via external integrations, you'll need a [dbt Starter, Enterprise, or Enterprise+ accounts](https://www.getdbt.com/pricing/). Refer to [Semantic Layer FAQs](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-faqs) for more information.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

Set up the dbt Semantic Layer](https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-2-setup)

* [Learning goals](#learning-goals)* [Guide structure overview](#guide-structure-overview)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-build-our-metrics/semantic-layer-1-intro.md)
