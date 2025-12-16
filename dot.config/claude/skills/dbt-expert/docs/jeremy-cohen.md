---
title: "Jeremy Cohen - 2 posts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/jeremy-cohen"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

Today, we announced that the dbt Fusion engine is [available in beta](https://getdbt.com/blog/get-to-know-the-new-dbt-fusion-engine-and-vs-code-extension).

* If Fusion works with your project today, great! You're in for a treat 😄
* If it's your first day using dbt, welcome! You should start on Fusion — you're in for a treat too.

Today is Launch Day — the first day of a new era: the Age of Fusion. We expect many teams with existing projects will encounter at least one issue that will prevent them from adopting the dbt Fusion engine in production environments. That's ok!

We're moving quickly to unblock more teams, and we are committing that by the time Fusion reaches General Availability:

* We will support Snowflake, Databricks, BigQuery, Redshift — and likely also Athena, Postgres, Spark, and Trino — with the new [Fusion Adapter pattern](https://docs.getdbt.com/blog/dbt-fusion-engine-components#dbt-fusion-engine-adapters).
* We will have coverage for (basically) all dbt Core functionality. Some things are impractical to replicate outside of Python, or so seldom-used that we'll be more reactive than proactive. On the other hand, many existing dbt Core behaviours will be improved by the unique capabilities of the dbt Fusion engine, such as speed and SQL comprehension. You'll see us talk about this in relevant GitHub issues, many of which we've linked below.
* The source-available `dbt-fusion` repository will contain more total functionality than what is available in dbt Core today. ([Read more about this here](https://docs.getdbt.com/blog/dbt-fusion-engine-components#ways-to-access).)
* The developer experience will be even speedier and more intuitive.

These statements aren't true yet — but you can see where we're headed. That's what betas are for, that's the journey we're going on together, and that's why we want to have you all involved.

If you’ve needed to grant access to a dbt model between 2019 and today, there’s a good chance you’ve come across the ["The exact grant statements we use in a dbt project"](https://discourse.getdbt.com/t/the-exact-grant-statements-we-use-in-a-dbt-project/430) post on Discourse. It explained options for covering two complementary abilities:

1. querying relations via the "select" privilege
2. using the schema those relations are within via the "usage" privilege
