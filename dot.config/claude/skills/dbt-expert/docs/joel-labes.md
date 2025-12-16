---
title: "Joel Labes - 8 posts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/joel-labes"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

Today, we announced the [dbt Fusion engine](https://docs.getdbt.com/blog/dbt-fusion-engine).

Fusion isn't just one thing — it's a set of interconnected components working together to power the next generation of analytics engineering.

This post maps out each piece of the Fusion architecture, explains how they fit together, and clarifies what's available to you whether you're compiling from source, using our pre-built binaries, or developing within a dbt Fusion powered product experience.

From the Rust engine to the VS Code extension, through to new Arrow-based adapters and Apache-licensed foundational technologies, we'll break down exactly what each component does, how each component is licensed (for why, see [Tristan's accompanying post](https://www.getdbt.com/blog/new-code-new-license-understanding-the-new-license-for-the-dbt-fusion-engine)), and how you can start using it and get involved today.

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

Remember how dbt felt when you had a small project? You pressed enter and stuff just happened immediately? We're bringing that back.

[![Benchmarking tip: always try to get data that's good enough that you don't need to do statistics on it](https://docs.getdbt.com/img/blog/2025-02-19-faster-project-parsing-with-rust/parsing_10k.gif?v=2 "Benchmarking tip: always try to get data that's good enough that you don't need to do statistics on it")](#)Benchmarking tip: always try to get data that's good enough that you don't need to do statistics on it

After a [series of deep dives](https://docs.getdbt.com/blog/the-levels-of-sql-comprehension) into the [guts of SQL comprehension](https://docs.getdbt.com/blog/sql-comprehension-technologies), let's talk about speed a little bit. Specifically, I want to talk about one of the most annoying slowdowns as your project grows: project parsing.

When you're waiting a few seconds or a few minutes for things to start happening after you invoke dbt, it's because parsing isn't finished yet. But Lukas' [SDF demo at last month's webinar](https://www.getdbt.com/resources/webinars/accelerating-dbt-with-sdf) didn't have a big wait, so why not?

Ever since [dbt Labs acquired SDF Labs last week](https://www.getdbt.com/blog/dbt-labs-acquires-sdf-labs), I've been head-down diving into their technology and making sense of it all. The main thing I knew going in was "SDF understands SQL". It's a nice pithy quote, but the specifics are *fascinating.*

For the next era of Analytics Engineering to be as transformative as the last, dbt needs to move beyond being a [string preprocessor](https://en.wikipedia.org/wiki/Preprocessor) and into fully comprehending SQL. **For the first time, SDF provides the technology necessary to make this possible.** Today we're going to dig into what SQL comprehension actually means, since it's so critical to what comes next.

## Cloud Data Platforms make new things possible; dbt helps you put them into production[​](#cloud-data-platforms-make-new-things-possible-dbt-helps-you-put-them-into-production "Direct link to Cloud Data Platforms make new things possible; dbt helps you put them into production")

The original paradigm shift that enabled dbt to exist and be useful was databases going to the cloud.

All of a sudden it was possible for more people to do better data work as huge blockers became huge opportunities:

* We could now dynamically scale compute on-demand, without upgrading to a larger on-prem database.
* We could now store and query enormous datasets like clickstream data, without pre-aggregating and transforming it.

Today, the next wave of innovation is happening in AI and LLMs, and it's coming to the cloud data platforms dbt practitioners are already using every day. For one example, Snowflake have just released their [Cortex functions](https://docs.snowflake.com/LIMITEDACCESS/cortex-functions) to access LLM-powered tools tuned for running common tasks against your existing datasets. In doing so, there are a new set of opportunities available to us:

You can now specify a Staging environment too!

This blog post was written before dbt Cloud added full support for Staging environments. Now that they exist, you should mark your CI environment as Staging as well. Read more about [Staging environments](https://docs.getdbt.com/docs/deploy/deploy-environments#staging-environment).

The Bottom Line:

You should [split your Jobs](#how) across Environments in dbt Cloud based on their purposes (e.g. Production and Staging/CI) and set one environment as Production. This will improve your CI experience and enable you to use dbt Explorer.

[Environmental segmentation](https://docs.getdbt.com/docs/environments-in-dbt) has always been an important part of the analytics engineering workflow:

* When developing new models you can [process a smaller subset of your data](https://docs.getdbt.com/reference/dbt-jinja-functions/target#use-targetname-to-limit-data-in-dev) by using `target.name` or an environment variable.
* By building your production-grade models into [a different schema and database](https://docs.getdbt.com/docs/build/custom-schemas#managing-environments), you can experiment in peace without being worried that your changes will accidentally impact downstream users.
* Using dedicated credentials for production runs, instead of an analytics engineer's individual dev credentials, ensures that things don't break when that long-tenured employee finally hangs up their IDE.

Historically, dbt Cloud required a separate environment for *Development*, but was otherwise unopinionated in how you configured your account. This mostly just worked – as long as you didn't have anything more complex than a CI job mixed in with a couple of production jobs – because important constructs like deferral in CI and documentation were only ever tied to a single job.

But as companies' dbt deployments have grown more complex, it doesn't make sense to assume that a single job is enough anymore. We need to exchange a job-oriented strategy for a more mature and scalable environment-centric view of the world. To support this, a recent change in dbt Cloud enables project administrators to [mark one of their environments as the Production environment](https://docs.getdbt.com/docs/deploy/deploy-environments#set-as-production-environment-beta), just as has long been possible for the Development environment.

Explicitly separating your Production workloads lets dbt Cloud be smarter with the metadata it creates, and is particularly important for two new features: dbt Explorer and the revised CI workflows.

Once your data warehouse is built out, the vast majority of your data will have come from other SaaS tools, internal databases, or customer data platforms (CDPs). But there’s another unsung hero of the analytics engineering toolkit: the humble spreadsheet.

Spreadsheets are the Swiss army knife of data processing. They can add extra context to otherwise inscrutable application identifiers, be the only source of truth for bespoke processes from other divisions of the business, or act as the translation layer between two otherwise incompatible tools.

Because of spreadsheets’ importance as the glue between many business processes, there are different tools to load them into your data warehouse and each one has its own pros and cons, depending on your specific use case.

February 2024 Update

This blog references dbt Core versions older than v1.0.

It's been a few years since dbt-core turned 1.0! Since then, we've committed to releasing zero breaking changes whenever possible and it's become much easier to upgrade dbt Core versions.

In 2024, we're taking this promise further by:

* Stabilizing interfaces for everyone — adapter maintainers, metadata consumers, and (of course) people writing dbt code everywhere — as discussed in [our November 2023 roadmap update](https://github.com/dbt-labs/dbt-core/blob/main/docs/roadmap/2023-11-dbt-tng.md).
* Introducing [Release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) (formerly known as Versionless) to dbt Cloud. No more manual upgrades and no need for *a second sandbox project* just to try out new features in development. For more details, refer to [Upgrade Core version in Cloud](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud).

We're leaving the rest of this post as is, so we can all remember how it used to be. Enjoy a stroll down memory lane.

As we get closer to dbt v1.0 shipping in December, it's a perfect time to get your installation up to scratch. dbt 1.0 represents the culmination of over five years of development and refinement to the analytics engineering experience - smoothing off sharp edges, speeding up workflows and enabling whole new classes of work.

Even with all the new shinies on offer, upgrading can be daunting – you rely on dbt to power your analytics workflow and can’t afford to change things just to discover that your daily run doesn’t work anymore. I’ve been there. This is the checklist I wish I had when I owned my last company’s dbt project.
