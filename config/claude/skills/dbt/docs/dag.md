---
title: "DAG use cases and best practices | dbt Labs"
source_url: "https://docs.getdbt.com/terms/dag"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



[Blog](https://docs.getdbt.com/blog "Blog")

 /

[Learn](https://docs.getdbt.com/blog/category/learn "Learn")

 /

DAG use cases and best practices

# DAG use cases and best practices

![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2Fd307e0a9a7dfa9c7b5f92d288b404955c979eb0c-512x512.jpg%3Ffit%3Dmax%26auto%3Dformat&w=1080&q=75)

[Daniel Poppy](https://docs.getdbt.com/authors/daniel-poppy)

last updated on Nov 04, 2025

A DAG is a **D**irected **A**cyclic **G**raph, a type of graph whose nodes are directionally related to each other and don’t form a directional closed loop. In the practice of analytics engineering, DAGs are often used to visually represent the relationships between your data models.

While the concept of a DAG originated in mathematics and gained popularity in computational work, DAGs have found a home in the modern data world. They offer a great way to visualize data pipelines and [lineage](https://www.getdbt.com/blog/guide-to-data-lineage "lineage"), and they offer an easy way to understand dependencies between [data models](https://www.getdbt.com/product/develop "data models").

## DAG use cases and best practices

DAGs are an effective tool to help you understand relationships between your data models and areas of improvement for your overall [data transformations](https://www.getdbt.com/analytics-engineering/transformation/ "data transformations"), including opportunities for [cost optimization](https://www.getdbt.com/product/cost-optimization "cost optimization").

### Unpacking relationships and data lineage

Can you look at one of your data models today and quickly identify all the upstream and downstream models? If you can’t, that’s probably a good sign to start building or looking at your existing DAG.

### Upstream or downstream?

One of the great things about DAGs is that they are *visual*. You can clearly identify the nodes that connect to each other and follow the lines of directions. When looking at a DAG, you should be able to identify where your data sources are going and where that data is potentially being referenced.

Take this mini-DAG for an example:

![A miniature DAG](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2Fbc7fac1a96e70f12da5e125a08f3bff54adae543-1878x838.png%3Ffit%3Dmax%26auto%3Dformat&w=3840&q=75)

What can you learn from this DAG? Immediately, you may notice a handful of things:

* `stg_users` and `stg_user_groups` models are the parent models for `int_users`
* A join is happening between `stg_users` and `stg_user_groups` to form the `int_users` model
* `stg_orgs` and `int_users` are the parent models for `dim_users`
* `dim_users` is at the end of the DAG and is therefore downstream from a total of four different models

Within 10 seconds of looking at this DAG, you can quickly unpack some of the most important elements about a project: dependencies and data lineage. Obviously, this is a simplified version of DAGs you may see in real life, but the practice of identifying relationships and data flows remains very much the same, regardless of the size of the DAG.

What happens if `stg_user_groups` just up and disappears one day? How would you know which models are potentially impacted by this change? Look at your DAG and understand model dependencies to mitigate downstream impacts with [testing and observability](https://www.getdbt.com/product/test-and-observe "testing and observability").

### Auditing projects

A potentially bold statement, but there is no such thing as a perfect DAG. DAGs are special in-part because they are unique to your business, data, and data models. There’s usually always room for improvement, whether that means making a [CTE](https://www.getdbt.com/blog/guide-to-cte "CTE") into its own view or performing a join earlier upstream, and your DAG can be an effective way to diagnose inefficient data models and relationships.

You can additionally use your DAG to help identify bottlenecks, long-running data models that severely impact the performance of your data pipeline. Bottlenecks can happen for multiple reasons:

* Expensive joins
* Extensive filtering or [use of window functions](https://docs.getdbt.com/blog/how-we-shaved-90-minutes-off-model "use of window functions")
* Complex logic stored in views
* Good old large volumes of data

...to name just a few. Understanding the factors impacting model performance can help you decide on [refactoring approaches](https://learn.getdbt.com/courses/refactoring-sql-for-modularity "refactoring approaches"), [changing model materialization](https://docs.getdbt.com/blog/how-we-shaved-90-minutes-off-model#attempt-2-moving-to-an-incremental-model "changing model materialization")s, replacing multiple joins with [surrogate keys](https://www.getdbt.com/blog/guide-to-surrogate-key "surrogate keys"), or other methods.

![A bad DAG, one that follows non-modular data modeling techniques](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2F03b33d53cc9ffa35ba36407b9af9ea2a8229fac6-1999x1124.png%3Ffit%3Dmax%26auto%3Dformat&w=3840&q=75)

### Modular data modeling best practices

See the DAG above? It follows a more traditional approach to data modeling where new data models are often built from raw sources instead of relying on intermediary and reusable data models. This type of project does not scale with team or data growth, making [data modernization](https://www.getdbt.com/product/data-modernization "data modernization") essential. As a result, analytics engineers tend to aim to have their DAGs not look like this.

Instead, there are some key elements that can help you create a more streamlined DAG and [modular data models](https://www.getdbt.com/analytics-engineering/modular-data-modeling-technique/ "modular data models") that [build trust in data and data teams](https://www.getdbt.com/product/build-trust-in-data-and-data-teams "build trust in data and data teams"):

* Leveraging [staging, intermediate, and mart layers](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview "staging, intermediate, and mart layers") to create layers of distinction between sources and transformed data
* Abstracting code that’s used across multiple models to its own model
* Joining on surrogate keys versus on multiple values

These are only a few examples of some best practices to help you organize your data models, business logic, and DAG.

Is your DAG keeping up with best practices?:  [Instead of manually auditing your DAG for best practices, the dbt project evaluator package can help audit your project and find areas of improvement.](https://github.com/dbt-labs/dbt-project-evaluator)

## dbt and DAGs

The marketing team at dbt Labs would be upset with us if we told you we think dbt actually stood for “dag build tool,” but one of the key elements of dbt is its ability to generate documentation and infer relationships between models. And one of the hallmark features of [dbt Docs](https://docs.getdbt.com/docs/build/documentation "dbt Docs") is the Lineage Graph (DAG) of your dbt project.

Whether you’re using dbt or Core, dbt docs and the Lineage Graph are available to all [dbt developers](https://www.getdbt.com/product/develop "dbt developers"). The Lineage Graph in dbt Docs can show a model or source’s entire lineage, all within a visual frame, providing comprehensive visibility through [dbt Catalog](https://www.getdbt.com/product/dbt-catalog "dbt Catalog"). Clicking within a model, you can view the Lineage Graph and adjust selectors to only show certain models within the DAG. Analyzing the DAG here is a great way to diagnose potential inefficiencies or lack of modularity in your dbt project, helping [analysts](https://www.getdbt.com/product/analyst "analysts") work more effectively.

![The Lineage Graph in dbt Docs](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2F9a24352e6c6fd1bc8f27c8138a174c6868839173-1999x1066.png%3Ffit%3Dmax%26auto%3Dformat&w=3840&q=75)

The DAG is also [available in the dbt IDE](https://www.getdbt.com/blog/on-dags-hierarchies-and-ides/ "available in the dbt IDE"), so you and your team can refer to your lineage while you [build your models](https://www.getdbt.com/product/develop "build your models").

### Leverage exposures

## Conclusion

A Directed acyclic graph (DAG) is a visual representation of your data models and their connection to each other. The key components of a DAG are that nodes (sources/models/exposures) are directionally linked and don’t form acyclic loops. Overall, DAGs are an effective tool for understanding data lineage, dependencies, and areas of improvement in your data models.

*Get started with [dbt today](https://www.getdbt.com/signup/ "dbt today") to start building your own DAG!*

## Further reading

Ready to restructure (or create your first) DAG? Check out some of the resources below to better understand data modularity, data lineage, and how dbt helps bring it all together:

* [Data modeling techniques for more modularity](https://www.getdbt.com/analytics-engineering/modular-data-modeling-technique/ "Data modeling techniques for more modularity")
* [How we structure our dbt projects](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview "How we structure our dbt projects")
* [How to audit your DAG](https://www.youtube.com/watch?v=5W6VrnHVkCA "How to audit your DAG")
* [Refactoring legacy SQL to dbt](https://docs.getdbt.com/guides/refactoring-legacy-sql "Refactoring legacy SQL to dbt")

### VS Code Extension

The free dbt VS Code extension is the best way to develop locally in dbt.

[Install free extension](https://docs.getdbt.com/docs/install-dbt-extension)

##### Share this article

Copy post link

### Latest posts

[![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2F6597b63adeb99714df69a50bcb320620fc4f54d1-1200x678.svg%3Ffit%3Dmax%26auto%3Dformat&w=3840&q=75)](/blog/inside-snowflake-s-ai-roadmap "Inside Snowflake’s AI roadmap")

Insights13 min

### [Inside Snowflake’s AI roadmap](https://docs.getdbt.com/blog/inside-snowflake-s-ai-roadmap)

![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2Fd307e0a9a7dfa9c7b5f92d288b404955c979eb0c-512x512.jpg%3Ffit%3Dmax%26auto%3Dformat&w=1080&q=75)

[Daniel Poppy](https://docs.getdbt.com/authors/daniel-poppy)

on  Dec 15, 2025

[![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2Fe7b6a59e1ed4b7f794c4a5fcd8e6d0ec26f1ddb7-800x452.png%3Ffit%3Dmax%26auto%3Dformat&w=1920&q=75)](/blog/reliable-analytics-dbt-databricks "Scale reliable analytics in the AI era with dbt and Databricks")

Insights12 min

### [Scale reliable analytics in the AI era with dbt and Databricks](https://docs.getdbt.com/blog/reliable-analytics-dbt-databricks)

![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2Fe898458a73031c566ee86ddcb51573e09c3f29c5-619x619.jpg%3Ffit%3Dmax%26auto%3Dformat&w=1920&q=75)

[Ryan Segar](https://docs.getdbt.com/authors/ryan-segar)

on  Dec 11, 2025

[![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2Fc02f56005fc5db9a132eba437a7c50285d08ae0a-800x452.png%3Ffit%3Dmax%26auto%3Dformat&w=1920&q=75)](/blog/bring-structured-context-to-agentic-data-development-with-dbt "Bring structured context to agentic data development with dbt ")

Product18 min

### [Bring structured context to agentic data development with dbt](https://docs.getdbt.com/blog/bring-structured-context-to-agentic-data-development-with-dbt)

[Chakshu Mehta](https://docs.getdbt.com/authors/chakshu-mehta),[Ludwig Sewall](https://docs.getdbt.com/authors/ludwig-sewall),[Sai Maddali](https://docs.getdbt.com/authors/sai-maddali)

on  Dec 10, 2025

The dbt Community

## Join the largest community shaping data

The dbt Community is your gateway to best practices, innovation, and direct collaboration with thousands of data leaders and AI practitioners worldwide. Ask questions, share insights, and build better with the experts.

[Join the Community](https://docs.getdbt.com/community/join-the-community)[Explore the community](https://docs.getdbt.com/community)

100,000+active members

50k+teams using dbt weekly

50+Community meetups
