---
title: "Jason Ganz - 7 posts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/jason-ganz"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

Today, we announced the [dbt Fusion engine](https://docs.getdbt.com/blog/dbt-fusion-engine).

Fusion isn't just one thing — it's a set of interconnected components working together to power the next generation of analytics engineering.

This post maps out each piece of the Fusion architecture, explains how they fit together, and clarifies what's available to you whether you're compiling from source, using our pre-built binaries, or developing within a dbt Fusion powered product experience.

From the Rust engine to the VS Code extension, through to new Arrow-based adapters and Apache-licensed foundational technologies, we'll break down exactly what each component does, how each component is licensed (for why, see [Tristan's accompanying post](https://www.getdbt.com/blog/new-code-new-license-understanding-the-new-license-for-the-dbt-fusion-engine)), and how you can start using it and get involved today.

## TL;DR: What You Need to Know[​](#tldr-what-you-need-to-know "Direct link to TL;DR: What You Need to Know")

* dbt’s familiar authoring layer remains unchanged, but the execution engine beneath it is completely new.
* The new engine is called the dbt Fusion engine — rewritten from the ground up in Rust based on technology [from SDF](https://www.getdbt.com/blog/dbt-labs-acquires-sdf-labs). The dbt Fusion engine is substantially faster than dbt Core and has built in [SQL comprehension technology](https://docs.getdbt.com/blog/the-levels-of-sql-comprehension) to power the next generation of analytics engineering workflows.
* The dbt Fusion engine is currently in beta. You can try it today if you use Snowflake — with additional adapters coming starting in early June. Review our [path to general availability](https://docs.getdbt.com/blog/dbt-fusion-engine-path-to-ga) (GA) and [try the quickstart](https://docs.getdbt.com/guides/fusion).
* **You do not need to be a dbt Labs customer to use Fusion - dbt Core users can adopt the dbt Fusion engine today for free in your local environment.**
* You can use Fusion with the [new dbt VS Code extension](https://marketplace.visualstudio.com/items?itemName=dbtLabsInc.dbt), [directly via the CLI](https://docs.getdbt.com/docs/fusion/install-fusion-cli), or [via dbt Studio](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#dbt-fusion-engine).
* This is the beginning of a new era for analytics engineering. For a glimpse into what the Fusion engine is going to enable over the next 1 to 2 years, [read this post](https://getdbt.com/blog/where-we-re-headed-with-the-dbt-fusion-engine).

dbt is the standard for creating governed, trustworthy datasets on top of your structured data. [MCP](https://www.anthropic.com/news/model-context-protocol) is showing increasing promise as the standard for providing context to LLMs to allow them to function at a high level in real world, operational scenarios.

Today, we are open sourcing an experimental version of the [dbt MCP server](https://github.com/dbt-labs/dbt-mcp/tree/main). We expect that over the coming years, structured data is going to become heavily integrated into AI workflows and that dbt will play a key role in building and provisioning this data.

One of the most important things that dbt does is unlock the ability for teams to collaborate on creating and disseminating organizational knowledge.

In the past, this primarily looked like a team working in one dbt Project to create a set of transformed objects in their data platform.

As dbt was adopted by larger organizations and began to drive workloads at a global scale, it became clear that we needed mechanisms to allow teams to operate independently from each other, creating and sharing data models across teams — [dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro).

We’ve all done it: fanned out data during a join to produce duplicate records (sometimes duplicated in multiple).

That time when historical revenue numbers doubled on Monday? Classic fanout.

Could it have been avoided? Yes, very simply: by defining the uniqueness grain for a table with a primary key and enforcing it with a dbt test.

So let’s dive deep into: what primary keys are, which cloud analytics warehouses support them, and how you can test them in your warehouse to enforce uniqueness.

### Why primary keys are important[​](#why-primary-keys-are-important "Direct link to Why primary keys are important")

We all know one of the most fundamental rules in data is that every table should have a primary key. Primary keys are critical for many reasons:

* They ensure that you don’t have duplicate rows in your table
* They help establish relationships to other tables
* They allow you to quickly identify the grain of the table (ex: the `customers` table with a PK of `customer_id` has one row per customer)
* You can test them in dbt, to ensure that your data is complete and unique

Doing analytics is hard. Doing analytics *right* is even harder.

There are a massive number of factors to consider: Is data missing? How do we make this insight discoverable? Why is my database locked? *Are we even asking the right questions?*

Compounding this is the fact that analytics can sometimes feel like a lonely pursuit.

Sure, our data is generally proprietary and therefore we can’t talk much about it. But we certainly **can** share what we’ve learned **about** working with that data.

So let’s all commit to sharing our hard won knowledge with each other—and in doing so pave the path for the next generations of analytics practitioners.
