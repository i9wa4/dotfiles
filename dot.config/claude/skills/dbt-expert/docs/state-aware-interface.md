---
title: "Navigating the state-aware interface | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/state-aware-interface"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [State aware](https://docs.getdbt.com/docs/deploy/state-aware-about)* Navigating the interface

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fstate-aware-interface+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fstate-aware-interface+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fstate-aware-interface+so+I+can+ask+questions+about+it.)

On this page

Learn how to navigate the state-aware orchestration interface for better visibility into model builds and cost tracking.

## Models built and reused chart[​](#models-built-and-reused-chart "Direct link to Models built and reused chart")

When you go to your **Account home**, you'll see a chart showing the number of models built and reused, giving you visibility into how state-aware orchestration is optimizing your data builds. This chart helps you to:

* **Track effectiveness of state-aware orchestration** — See how state-aware orchestration reduces unnecessary model rebuilds by only building models when there are changes to the data or code⁠. This chart provides transparency into how the optimization is working across your dbt implementation.
* **Analyze build patterns** — Gain insights into your project's build frequency and identify opportunities for further optimization.

You can also view the number of reused models per project in the **Accounts home** page.

[![Models built and reused chart in Account home](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/account-home-chart.png?v=2 "Models built and reused chart in Account home")](#)Models built and reused chart in Account home

[![View reused models count per project in the Accounts home page](https://docs.getdbt.com/img/docs/deploy/sao-model-reuse.png?v=2 "View reused models count per project in the Accounts home page")](#)View reused models count per project in the Accounts home page

## Model consumption view in jobs[​](#model-consumption-view-in-jobs "Direct link to Model consumption view in jobs")

State-aware jobs provide charts that show information about your job runs, and how many models were built and reused by your job in the past week, in the last 14 days, or in the last 30 days. In the **Overview** section of your job, the following charts are available:

Under the **Runs** tab:

* **Recent runs**
* **Total run duration time**

[![Charts for Recent runs and Total run duration time](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/sao-runs-chart.png?v=2 "Charts for Recent runs and Total run duration time")](#)Charts for Recent runs and Total run duration time

Under the **Models** tab:

* **Models built**
* **Models reused**

[![Charts for Models built and Models reused](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/sao-models-chart.png?v=2 "Charts for Models built and Models reused")](#)Charts for Models built and Models reused

## Logs view of built models[​](#logs-view-of-built-models "Direct link to Logs view of built models")

When running a job, a structured logs view shows which models were built, skipped, or reused.

[![Logs view of built models](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/sao-logs-view.png?v=2 "Logs view of built models")](#)Logs view of built models

1. Each model has an icon indicating its status.
2. The **Reused** tab indicates the total number of reused models.
3. You can use the search bar or filter the logs to show **All**, **Success**, **Warning**, **Failed**, **Running**, **Skipped**, **Reused**, or **Debugged** messages.
4. Detailed log messages are provided to get more context on why models were built, reused, or skipped. These messages are highlighted in the logs.

## Reused tag in the Latest status lens[​](#reused-tag-in-the-latest-status-lens "Direct link to Reused tag in the Latest status lens")

Lineage lenses are interactive visual filters in [dbt Catalog](https://docs.getdbt.com/docs/explore/explore-projects#lenses) that show additional context on your lineage graph to understand how resources are defined or performing. When you apply a lens, tags become visible on the nodes in the lineage graph, indicating the layer value along with coloration based on that value. If you're significantly zoomed out, only the tags and their colors are visible in the graph.

The **Latest status** lens shows the status from the latest execution of the resource in the current environment. When you use this lens to view your lineage, models that were reused from state-aware orchestration are tagged with **Reused**.

[![Latest status lens showing reused models](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/sao-latest-status-lens.png?v=2 "Latest status lens showing reused models")](#)Latest status lens showing reused models

To view your lineage with the **Latest status** lens:

1. From the main menu, go to **Orchestration** > **Runs**.
2. Select your run.
3. Go to the **Lineage** tab.
   The lineage of your project appears.
4. In the **Lenses** field, select **Latest status**.

## Clear cache button[​](#clear-cache-button "Direct link to Clear cache button")

State-aware orchestration uses a cached hash of both code and data state for each model in an environment stored in Redis. When running a job, dbt checks if there are changes in the hash for the model being built between the saved state in Redis and the current state that would be built by the job. If there is a change, dbt builds the model. If there are no changes, dbt reuses the model from the last time it was built.

* To wipe this state clean and start again, clear the cache by going to **Orchestration** > **Environments**. Select your environment and click the **Clear cache** button.
* The **Clear cache** button is only available if you have enabled state-aware orchestration.
* After clearing the cache, the next run rebuilds every model from scratch. Subsequent runs rely on the regenerated cache.

[![Clear cache button](https://docs.getdbt.com/img/docs/dbt-cloud/using-dbt-cloud/sao-clear-cache.png?v=2 "Clear cache button")](#)Clear cache button

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Setting up state-aware](https://docs.getdbt.com/docs/deploy/state-aware-setup)[Next

About jobs](https://docs.getdbt.com/docs/deploy/jobs)

* [Models built and reused chart](#models-built-and-reused-chart)* [Model consumption view in jobs](#model-consumption-view-in-jobs)* [Logs view of built models](#logs-view-of-built-models)* [Reused tag in the Latest status lens](#reused-tag-in-the-latest-status-lens)* [Clear cache button](#clear-cache-button)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/state-aware-interface.md)
