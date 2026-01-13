---
title: "About state-aware orchestration | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/state-aware-about"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* State aware

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fstate-aware-about+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fstate-aware-about+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fstate-aware-about+so+I+can+ask+questions+about+it.)

On this page

Every time a job runs, state-aware orchestration automatically determines which models to build by detecting changes in code or data.

important

The dbt Fusion Engine is currently available for installation in:

* [Local command line interface (CLI) tools](https://docs.getdbt.com/docs/fusion/install-fusion-cli) [Preview](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")
* [VS Code and Cursor with the dbt extension](https://docs.getdbt.com/docs/install-dbt-extension) [Preview](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")
* [dbt platform environments](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#dbt-fusion-engine) [Private preview](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")

Join the conversation in our Community Slack channel [`#dbt-fusion-engine`](https://getdbt.slack.com/archives/C088YCAB6GH).

Read the [Fusion Diaries](https://github.com/dbt-labs/dbt-fusion/discussions/categories/announcements) for the latest updates.

State-aware orchestration saves you compute costs and reduces runtime because when a job runs, it checks for new records and only builds the models that will change.

[![Fusion powered state-aware orchestration](https://docs.getdbt.com/img/docs/deploy/sao.gif?v=2 "Fusion powered state-aware orchestration")](#)Fusion powered state-aware orchestration

We built dbt's state-aware orchestration on these four core principles:

* **Real-time shared state:** All jobs write to a real-time shared model-level state, allowing dbt to rebuild only changed models regardless of which jobs the model is built in.
* **Model-level queueing:** Jobs queue up at the model-level so you can avoid any 'collisions' and prevent rebuilding models that were just updated by another job.
* **State-aware and state agnostic support:** You can build jobs dynamically (state-aware) or explicitly (state-agnostic). Both approaches update shared state so everything is kept in sync.
* **Sensible defaults:** State-aware orchestration works out-of-the-box (natively), with an optional configuration setting for more advanced controls. For more information, refer to [state-aware advanced configurations](https://docs.getdbt.com/docs/deploy/state-aware-setup#advanced-configurations).

note

State-aware orchestration does not depend on [static analysis](https://docs.getdbt.com/docs/fusion/new-concepts#principles-of-static-analysis) and works even when `static_analysis` is disabled.

## Optimizing builds with state-aware orchestration[​](#optimizing-builds-with-state-aware-orchestration "Direct link to Optimizing builds with state-aware orchestration")

State-aware orchestration uses shared state tracking to determine which models need to be built by detecting changes in code or data every time a job runs. It also supports custom refresh intervals and custom source freshness configurations, so dbt only rebuilds models when they're actually needed.

For example, you can configure your project so that dbt skips rebuilding the dim\_wizards model (and its parents) if they’ve already been refreshed within the last 4 hours, even if the job itself runs more frequently.

Without configuring anything, dbt's state-aware orchestration automatically knows to build your models either when the code has changed or if there’s any new data in a source (or upstream model in the case of [dbt Mesh](https://docs.getdbt.com/docs/mesh/about-mesh)).

## Efficient testing in state-aware orchestration [Private beta](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")[​](#efficient-testing-in-state-aware-orchestration- "Direct link to efficient-testing-in-state-aware-orchestration-")

Private beta feature

State-aware orchestration features in the dbt platform are only available in Fusion, which is in private preview. Contact your account manager to enable Fusion in your account.

Data quality can get degraded in two ways:

* New code changes definitions or introduces edge cases.
* New data, like duplicates or unexpected values, invalidates downstream metrics.

Running dbt’s out-of-the-box [data tests](https://docs.getdbt.com/docs/build/data-tests) (`unique`, `not_null`, `accepted_values`, `relationships`) on every build helps catch data errors before they impact business decisions. Catching these errors often requires having multiple tests on every model and running tests even when not necessary. If nothing relevant has changed, repeated test executions don’t improve coverage and only increase cost.

With Fusion, dbt gains an understanding of the SQL code based on the logical plan for the compiled code. dbt then can determine when a test must run again, or when a prior upstream test result can be reused.

Efficient testing in state-aware orchestration reduces warehouse costs by avoiding redundant data tests and combining multiple tests into one run. This feature includes two optimizations:

* **Test reuse** — Tests are reused in cases where no logic in the code or no new data could have changed the test's outcome.
* **Test aggregation** — When there are multiple tests on a model, dbt combines tests to run as a single query against the warehouse, rather than running separate queries for each test.

### Supported data tests[​](#supported-data-tests "Direct link to Supported data tests")

The following tests can be reused when Efficient testing is enabled:

* [`unique`](https://docs.getdbt.com/reference/resource-properties/data-tests#unique)
* [`not_null`](https://docs.getdbt.com/reference/resource-properties/data-tests#not_null)
* [`accepted_values`](https://docs.getdbt.com/reference/resource-properties/data-tests#accepted_values)

### Enabling Efficient testing[​](#enabling-efficient-testing "Direct link to Enabling Efficient testing")

Before enabling Efficient testing, make sure you have configured [`static_analysis`](https://docs.getdbt.com/docs/fusion/new-concepts#configuring-static_analysis).

To enable Efficient testing:

1. From the main menu, go to **Orchestration** > **Jobs**.
2. Select your job. Go to your job settings and click **Edit**.
3. Under **Enable Fusion cost optimization features**, expand **More options**.
4. Select **Efficient testing**. This feature is disabled by default.
5. Click **Save**.

### Example[​](#example "Direct link to Example")

In the following query, you’re joining an `orders` and a `customers` table:

```
with

orders as (

    select * from {{ ref('orders') }}

),

customers as (

    select * from {{ ref('customers') }}

),

joined as (

    select
        customers.customer_id as customer_id,
        orders.order_id as order_id
    from customers
    left join orders
        on orders.customer_id = customers.customer_id

)

select * from joined
```

* `not_null` test: A `left join` can introduce null values for customers without orders. Even if upstream tests verified `not_null(order_id)` in orders, the join can create null values downstream. dbt must always run a `not_null` test on `order_id` in this joined result.
* `unique` test: If `orders.order_id` and `customers.customer_id` are unique upstream, uniqueness of `order_id` is preserved and the upstream result can be reused.

### Limitation[​](#limitation "Direct link to Limitation")

The following section lists some considerations when using Efficient testing in state-aware-orchestration:

* **Aggregated tests do not support custom configs**. Tests that include the following [custom config options](https://docs.getdbt.com/reference/data-test-configs) will run individually rather than as part of the aggregated batch:

  ```
  config:
    fail_calc: <string>
    limit: <integer>
    severity: error | warn
    error_if: <string>
    warn_if: <string>
    store_failures: true | false
    where: <string>
  ```

## Related docs[​](#related-docs "Direct link to Related docs")

* [State-aware orchestration configuration](https://docs.getdbt.com/docs/deploy/state-aware-setup)
* [Artifacts](https://docs.getdbt.com/docs/deploy/artifacts)
* [Continuous integration (CI) jobs](https://docs.getdbt.com/docs/deploy/ci-jobs)
* [`freshness`](https://docs.getdbt.com/reference/resource-configs/freshness)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Continuous deployment](https://docs.getdbt.com/docs/deploy/continuous-deployment)[Next

About state-aware orchestration](https://docs.getdbt.com/docs/deploy/state-aware-about)

* [Optimizing builds with state-aware orchestration](#optimizing-builds-with-state-aware-orchestration)* [Efficient testing in state-aware orchestration](#efficient-testing-in-state-aware-orchestration-)
    + [Supported data tests](#supported-data-tests)+ [Enabling Efficient testing](#enabling-efficient-testing)+ [Example](#example)+ [Limitation](#limitation)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/state-aware-about.md)
