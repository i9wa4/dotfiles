---
title: "Data ecosystem | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/tags/data-ecosystem"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



In April, we released the local [dbt MCP (Model Context Protocol) server](https://docs.getdbt.com/blog/introducing-dbt-mcp-server) as an open source project to connect AI agents and LLMs with direct, governed access to trusted dbt assets. The dbt MCP server provides a [universal, open standard](https://docs.anthropic.com/en/docs/mcp) for bridging AI systems with your structured context that keeps your agents accurate, governed, and trustworthy. Learn more in [About dbt Model Context Protocol](https://docs.getdbt.com/docs/dbt-ai/about-mcp).

Since releasing the local dbt MCP server, the dbt community has been applying it in incredible ways including agentic conversational analytics, data catalog exploration, and dbt project refactoring. However, a key piece of feedback we received from AI engineers was that the local dbt MCP server isn’t easy to deploy or host for multi-tenanted workloads, making it difficult to build applications on top of the dbt MCP server.

This is why we are excited to announce a new way to integrate with dbt MCP: **the remote dbt MCP server**. The remote dbt MCP server doesn’t require installing dependencies or running the dbt MCP server in your infrastructure, making it easier than ever to build and run agents. It is **available today in public beta** for users with dbt Starter, Enterprise, or Enterprise+ plans, ready for you to start building AI-powered applications.

Hello, community!

My name is Bruno, and you might have seen me posting dbt content on LinkedIn. If you haven't, let me introduce myself. I started working with dbt more than 3 years ago. At that time, I was very new to the tool, and to understand it a bit better, I started creating some resources to help me with dbt learning. One of them, a dbt cheatsheet, was the starting point for my community journey.

I went from this cheatsheet to creating all different kinds of content, contributing and engaging with the community, until I got the dbt community award two times, and I am very thankful and proud about that.

Since the acquisition of SDF Labs by dbt Labs, I have been waiting for the day that we would see what the result of the fusion of these two companies would be. Spoiler alert: It’s the dbt Fusion engine and it's better than I could have expected.

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

## TL;DR: What You Need to Know[​](#tldr-what-you-need-to-know "Direct link to TL;DR: What You Need to Know")

* dbt’s familiar authoring layer remains unchanged, but the execution engine beneath it is completely new.
* The new engine is called the dbt Fusion engine — rewritten from the ground up in Rust based on technology [from SDF](https://www.getdbt.com/blog/dbt-labs-acquires-sdf-labs). The dbt Fusion engine is substantially faster than dbt Core and has built in [SQL comprehension technology](https://docs.getdbt.com/blog/the-levels-of-sql-comprehension) to power the next generation of analytics engineering workflows.
* The dbt Fusion engine is currently in beta. You can try it today if you use Snowflake — with additional adapters coming starting in early June. Review our [path to general availability](https://docs.getdbt.com/blog/dbt-fusion-engine-path-to-ga) (GA) and [try the quickstart](https://docs.getdbt.com/guides/fusion).
* **You do not need to be a dbt Labs customer to use Fusion - dbt Core users can adopt the dbt Fusion engine today for free in your local environment.**
* You can use Fusion with the [new dbt VS Code extension](https://marketplace.visualstudio.com/items?itemName=dbtLabsInc.dbt), [directly via the CLI](https://docs.getdbt.com/docs/fusion/install-fusion-cli), or [via dbt Studio](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#dbt-fusion-engine).
* This is the beginning of a new era for analytics engineering. For a glimpse into what the Fusion engine is going to enable over the next 1 to 2 years, [read this post](https://getdbt.com/blog/where-we-re-headed-with-the-dbt-fusion-engine).

dbt is the standard for creating governed, trustworthy datasets on top of your structured data. [MCP](https://www.anthropic.com/news/model-context-protocol) is showing increasing promise as the standard for providing context to LLMs to allow them to function at a high level in real world, operational scenarios.

Today, we are open sourcing an experimental version of the [dbt MCP server](https://github.com/dbt-labs/dbt-mcp/tree/main). We expect that over the coming years, structured data is going to become heavily integrated into AI workflows and that dbt will play a key role in building and provisioning this data.

Remember how dbt felt when you had a small project? You pressed enter and stuff just happened immediately? We're bringing that back.

[![Benchmarking tip: always try to get data that's good enough that you don't need to do statistics on it](https://docs.getdbt.com/img/blog/2025-02-19-faster-project-parsing-with-rust/parsing_10k.gif?v=2 "Benchmarking tip: always try to get data that's good enough that you don't need to do statistics on it")](#)Benchmarking tip: always try to get data that's good enough that you don't need to do statistics on it

After a [series of deep dives](https://docs.getdbt.com/blog/the-levels-of-sql-comprehension) into the [guts of SQL comprehension](https://docs.getdbt.com/blog/sql-comprehension-technologies), let's talk about speed a little bit. Specifically, I want to talk about one of the most annoying slowdowns as your project grows: project parsing.

When you're waiting a few seconds or a few minutes for things to start happening after you invoke dbt, it's because parsing isn't finished yet. But Lukas' [SDF demo at last month's webinar](https://www.getdbt.com/resources/webinars/accelerating-dbt-with-sdf) didn't have a big wait, so why not?

You ever wonder what’s *really* going on in your database when you fire off a (perfect, efficient, full-of-insight) SQL query to your database?

OK, probably not 😅. Your personal tastes aside, we’ve been talking a *lot* about SQL Comprehension tools at dbt Labs in the wake of our acquisition of SDF Labs, and think that the community would benefit if we included them in the conversation too! We recently published a [blog that talked about the different levels of SQL Comprehension tools](https://docs.getdbt.com/blog/the-levels-of-sql-comprehension). If you read that, you may have encountered a few new terms you weren’t super familiar with.

In this post, we’ll talk about the technologies that underpin SQL Comprehension tools in more detail. Hopefully, you come away with a deeper understanding of and appreciation for the hard work that your computer does to turn your SQL queries into actionable business insights!

Ever since [dbt Labs acquired SDF Labs last week](https://www.getdbt.com/blog/dbt-labs-acquires-sdf-labs), I've been head-down diving into their technology and making sense of it all. The main thing I knew going in was "SDF understands SQL". It's a nice pithy quote, but the specifics are *fascinating.*

For the next era of Analytics Engineering to be as transformative as the last, dbt needs to move beyond being a [string preprocessor](https://en.wikipedia.org/wiki/Preprocessor) and into fully comprehending SQL. **For the first time, SDF provides the technology necessary to make this possible.** Today we're going to dig into what SQL comprehension actually means, since it's so critical to what comes next.

When my wife and I renovated our home, we chose to take on the role of owner-builder. It was a bold (and mostly naive) decision, but we wanted control over every aspect of the project. What we didn’t realize was just how complex and exhausting managing so many moving parts would be.

[![My wife pondering our sanity](https://docs.getdbt.com/img/blog/2024-12-22-why-i-wish-i-had-a-control-plane-for-my-renovation/control-plane.png?v=2 "My wife pondering our sanity")](#)My wife pondering our sanity

We had to coordinate multiple elements:

* The **architects**, who designed the layout, interior, and exterior.
* The **architectural plans**, which outlined what the house should look like.
* The **builders**, who executed those plans.
* The **inspectors**, **councils**, and **energy raters**, who checked whether everything met the required standards.

## New in dbt: allow Snowflake Python models to access the internet[​](#new-in-dbt-allow-snowflake-python-models-to-access-the-internet "Direct link to New in dbt: allow Snowflake Python models to access the internet")

With dbt 1.8, dbt released support for Snowflake’s [external access integrations](https://docs.snowflake.com/en/developer-guide/external-network-access/external-network-access-overview) further enabling the use of dbt + AI to enrich your data. This allows querying of external APIs within dbt Python models, a functionality that was required for dbt Cloud customer, [EQT AB](https://eqtgroup.com/). Learn about why they needed it and how they helped build the feature and get it shipped!

## Cloud Data Platforms make new things possible; dbt helps you put them into production[​](#cloud-data-platforms-make-new-things-possible-dbt-helps-you-put-them-into-production "Direct link to Cloud Data Platforms make new things possible; dbt helps you put them into production")

The original paradigm shift that enabled dbt to exist and be useful was databases going to the cloud.

All of a sudden it was possible for more people to do better data work as huge blockers became huge opportunities:

* We could now dynamically scale compute on-demand, without upgrading to a larger on-prem database.
* We could now store and query enormous datasets like clickstream data, without pre-aggregating and transforming it.

Today, the next wave of innovation is happening in AI and LLMs, and it's coming to the cloud data platforms dbt practitioners are already using every day. For one example, Snowflake have just released their [Cortex functions](https://docs.snowflake.com/LIMITEDACCESS/cortex-functions) to access LLM-powered tools tuned for running common tasks against your existing datasets. In doing so, there are a new set of opportunities available to us:

note

This blog post was updated on December 18, 2023 to cover the support of MVs on dbt-bigquery
and updates on how to test MVs.

## Introduction[​](#introduction "Direct link to Introduction")

The year was 2020. I was a kitten-only household, and dbt Labs was still Fishtown Analytics. A enterprise customer I was working with, Jetblue, asked me for help running their dbt models every 2 minutes to meet a 5 minute SLA.

After getting over the initial terror, we talked through the use case and soon realized there was a better option. Together with my team, I created [lambda views](https://discourse.getdbt.com/t/how-to-create-near-real-time-models-with-just-dbt-sql/1457) to meet the need.

Flash forward to 2023. I’m writing this as my giant dog snores next to me (don’t worry the cats have multiplied as well). Jetblue has outgrown lambda views due to performance constraints (a view can only be so performant) and we are at another milestone in dbt’s journey to support streaming. What. a. time.

Today we are announcing that we now support Materialized Views in dbt. So, what does that mean?

Whether you are creating your pipelines into dbt for the first time or just adding a new model once in a while, **good documentation and testing should always be a priority** for you and your team. Why do we avoid it like the plague then? Because it’s a hassle having to write down each individual field, its description in layman terms and figure out what tests should be performed to ensure the data is fine and dandy. How can we make this process faster and less painful?

By now, everyone knows the wonders of the GPT models for code generation and pair programming so this shouldn’t come as a surprise. But **ChatGPT really shines** at inferring the context of verbosely named fields from database table schemas. So in this post I am going to help you 10x your documentation and testing speed by using ChatGPT to do most of the leg work for you.

Data Vault 2.0 is a data modeling technique designed to help scale large data warehousing projects. It is a rigid, prescriptive system detailed vigorously in [a book](https://www.amazon.com/Building-Scalable-Data-Warehouse-Vault/dp/0128025107) that has become the bible for this technique.

So why Data Vault? Have you experienced a data warehousing project with 50+ data sources, with 25+ data developers working on the same data platform, or data spanning 5+ years with two or more generations of source systems? If not, it might be hard to initially understand the benefits of Data Vault, and maybe [Kimball modelling](https://docs.getdbt.com/blog/kimball-dimensional-model) is better for you. But if you are in *any* of the situations listed, then this is the article for you!

Different from dbt Cloud CLI

This blog explains how to use the `dbt-cloud-cli` Python library to create a data catalog app with dbt Cloud artifacts. This is different from the [dbt Cloud CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation), a tool that allows you to run dbt commands against your dbt Cloud development environment from your local command line.

dbt Cloud is a hosted service that many organizations use for their dbt deployments. Among other things, it provides an interface for creating and managing deployment jobs. When triggered (e.g., cron schedule, API trigger), the jobs generate various artifacts that contain valuable metadata related to the dbt project and the run results.

dbt Cloud provides a REST API for managing jobs, run artifacts and other dbt Cloud resources. Data/analytics engineers would often write custom scripts for issuing automated calls to the API using tools [cURL](https://curl.se/) or [Python Requests](https://requests.readthedocs.io/en/latest/). In some cases, the engineers would go on and copy/rewrite them between projects that need to interact with the API. Now, they have a bunch of scripts on their hands that they need to maintain and develop further if business requirements change. If only there was a dedicated tool for interacting with the dbt Cloud API that abstracts away the complexities of the API calls behind an easy-to-use interface… Oh wait, there is: [the dbt-cloud-cli](https://github.com/data-mie/dbt-cloud-cli)!

*Special Thanks: Emilie Schario, Matt Winkler*

dbt has done a great job of building an elegant, common interface between data engineers, analytics engineers, and any data-y role, by uniting our work on SQL. This unification of tools and workflows creates interoperability between what would normally be distinct teams within the data organization.

I like to call this interoperability a “baton pass.” Like in a relay race, there are clear handoff points & explicit ownership at all stages of the process. But there’s one baton pass that’s still relatively painful and undefined: the handoff between machine learning (ML) engineers and analytics engineers.

In my experience, the initial collaboration workflow between ML engineering & analytics engineering starts off strong but eventually becomes muddy during the maintenance phase. This eventually leads to projects becoming unusable and forgotten.

In this article, we’ll explore a real-life baton pass between ML engineering and analytics engineering and highlighting where things went wrong.

Having a GitHub pull request template is one of the most important and frequently overlooked aspects of creating an efficient and scalable dbt-centric analytics workflow. Opening a pull request is the final step of your modeling process - a process which typically involves a lot of complex work!

For you, the dbt developer, the pull request (PR for short) serves as a final checkpoint in your modeling process, ensuring that no key elements are missing from your code or project.

Airflow and dbt are often framed as either / or:

You either build SQL transformations using Airflow’s SQL database operators (like [SnowflakeOperator](https://airflow.apache.org/docs/apache-airflow-providers-snowflake/stable/operators/snowflake.html)), or develop them in a dbt project.

You either orchestrate dbt models in Airflow, or you deploy them using dbt Cloud.

In my experience, these are false dichotomies, that sound great as hot takes but don’t really help us do our jobs as data people.
