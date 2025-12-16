---
title: "Developer Blog | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



In April, we released the local [dbt MCP (Model Context Protocol) server](https://docs.getdbt.com/blog/introducing-dbt-mcp-server) as an open source project to connect AI agents and LLMs with direct, governed access to trusted dbt assets. The dbt MCP server provides a [universal, open standard](https://docs.anthropic.com/en/docs/mcp) for bridging AI systems with your structured context that keeps your agents accurate, governed, and trustworthy. Learn more in [About dbt Model Context Protocol](https://docs.getdbt.com/docs/dbt-ai/about-mcp).

Since releasing the local dbt MCP server, the dbt community has been applying it in incredible ways including agentic conversational analytics, data catalog exploration, and dbt project refactoring. However, a key piece of feedback we received from AI engineers was that the local dbt MCP server isn’t easy to deploy or host for multi-tenanted workloads, making it difficult to build applications on top of the dbt MCP server.

This is why we are excited to announce a new way to integrate with dbt MCP: **the remote dbt MCP server**. The remote dbt MCP server doesn’t require installing dependencies or running the dbt MCP server in your infrastructure, making it easier than ever to build and run agents. It is **available today in public beta** for users with dbt Starter, Enterprise, or Enterprise+ plans, ready for you to start building AI-powered applications.

## Introduction to dbt and BigFrames[​](#introduction-to-dbt-and-bigframes "Direct link to Introduction to dbt and BigFrames")

**dbt**: A framework for transforming data in modern data warehouses using modular SQL or Python. dbt enables data teams to develop analytics code collaboratively and efficiently by applying software engineering best practices such as version control, modularity, portability, CI/CD, testing, and documentation. For more information, refer to [What is dbt?](https://docs.getdbt.com/docs/introduction#dbt)

**BigQuery DataFrames (BigFrames)**: An open-source Python library offered by Google. BigFrames scales Python data processing by transpiling common Python data science APIs (pandas and scikit-learn) to BigQuery SQL.

You can read more in the [official BigFrames guide](https://cloud.google.com/bigquery/docs/bigquery-dataframes-introduction) and view the [public BigFrames GitHub repository](https://github.com/googleapis/python-bigquery-dataframes).

By combining dbt with BigFrames via the `dbt-bigquery` adapter (referred to as *"dbt-BigFrames"*), you gain:

* dbt’s modular SQL and Python modeling, dependency management with dbt.ref(), environment configurations, and data testing. With the cloud-based dbt platform, you also get job scheduling and monitoring.
* BigFrames’ ability to execute complex Python transformations (including machine learning) directly in BigQuery.

`dbt-BigFrames` utilizes the **Colab Enterprise notebook executor service** in a GCP project to run Python models. These notebooks execute BigFrames code, which is translated into BigQuery SQL.

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

**The AI revolution is here—but are we ready?**
Across the world, the excitement around AI is undeniable. Discussions on large language models, agentic workflows, and how AI is set to transform every industry abound, yet real-world use cases of AI in production remain few and far between.

A common issue blocking people from moving AI use cases to production is an ability to evaluate the validity of AI responses in a systematic and well governed way.
Moving AI workflows from prototype to production requires rigorous evaluation, and most organizations do not have a framework to ensure AI outputs remain high-quality, trustworthy, and actionable.

## Introduction[​](#introduction "Direct link to Introduction")

Building scalable data pipelines in a fast-growing fintech can feel like fixing a bike while riding it. You must keep insights flowing even as data volumes explode. At Kuda (a Nigerian neo-bank), we faced this problem as our user base surged. Traditional batch ETL (rebuilding entire tables each run) started to buckle; pipelines took hours, and costs ballooned. We needed to keep data fresh without reprocessing everything. Our solution was to leverage dbt’s [incremental models](https://docs.getdbt.com/docs/build/incremental-models), which process only new or changed records. This dramatically cut run times and curbed our BigQuery costs, letting us scale efficiently.

dbt is the standard for creating governed, trustworthy datasets on top of your structured data. [MCP](https://www.anthropic.com/news/model-context-protocol) is showing increasing promise as the standard for providing context to LLMs to allow them to function at a high level in real world, operational scenarios.

Today, we are open sourcing an experimental version of the [dbt MCP server](https://github.com/dbt-labs/dbt-mcp/tree/main). We expect that over the coming years, structured data is going to become heavily integrated into AI workflows and that dbt will play a key role in building and provisioning this data.

As a dbt Cloud admin, you’ve just upgraded to dbt Cloud on the [Enterprise plan](https://www.getdbt.com/pricing) - **congrats**! dbt Cloud has a lot to offer such as [CI/CD](https://docs.getdbt.com/docs/deploy/about-ci), [Orchestration](https://docs.getdbt.com/docs/deploy/deployments), [dbt Explorer](https://docs.getdbt.com/docs/explore/explore-projects), [dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl), [dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro), [Visual Editor](https://docs.getdbt.com/docs/cloud/canvas), [dbt Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot), and so much more. ***But where should you begin?***

We strongly recommend as you start adopting dbt Cloud functionality to make it a priority to set up Single-Sign On (SSO) and Role-Based Access Control (RBAC). This foundational step enables your organization to keep your data pipelines secure, onboard users into dbt Cloud with ease, and optimize cost savings for the long term.

Hi! We’re Christine and Carol, Resident Architects at dbt Labs. Our day-to-day
work is all about helping teams reach their technical and business-driven goals.
Collaborating with a broad spectrum of customers ranging from scrappy startups
to massive enterprises, we’ve gained valuable experience guiding teams to
implement architecture which addresses their major pain points.

The information we’re about to share isn't just from our experiences - we
frequently collaborate with other experts like Taylor Dunlap and Steve Dowling
who have greatly contributed to the amalgamation of this guidance. Their work
lies in being the critical bridge for teams between
implementation and business outcomes, ultimately leading teams to align on a
comprehensive technical vision through identification of problems and solutions.

**Why are we here?**
We help teams with dbt architecture, which encompasses the tools, processes and
configurations used to start developing and deploying with dbt. There’s a lot of
decision making that happens behind the scenes to standardize on these pieces -
much of which is informed by understanding what we want the development workflow
to look like. The focus on having the ***perfect*** workflow often gets teams
stuck in heaps of planning and endless conversations, which slows down or even
stops momentum on development. If you feel this, we’re hoping our guidance will
give you a great sense of comfort in taking steps to unblock development - even
when you don’t have everything figured out yet!

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

👋 Greetings, dbt’ers! It’s Faith & Jerrie, back again to offer tactical advice on *where* to put tests in your pipeline.

In [our first post](https://docs.getdbt.com/blog/test-smarter-not-harder) on refining testing best practices, we developed a prioritized list of data quality concerns. We also documented first steps for debugging each concern. This post will guide you on where specific tests should go in your data pipeline.

*Note that we are constructing this guidance based on how we [structure data at dbt Labs.](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview#guide-structure-overview)* You may use a different modeling approach—that’s okay! Translate our guidance to your data’s shape, and let us know in the comments section what modifications you made.

First, here’s our opinions on where specific tests should go:

* Source tests should be fixable data quality concerns. See the [callout box below](#sources) for what we mean by “fixable”.
* Staging tests should be business-focused anomalies specific to individual tables, such as accepted ranges or ensuring sequential values. In addition to these tests, your staging layer should clean up any nulls, duplicates, or outliers that you can’t fix in your source system. You generally don’t need to test your cleanup efforts.
* Intermediate and marts layer tests should be business-focused anomalies resulting specifically from joins or calculations. You also may consider adding additional primary key and not null tests on columns where it’s especially important to protect the grain.

The [Analytics Development Lifecycle (ADLC)](https://www.getdbt.com/resources/guides/the-analytics-development-lifecycle) is a workflow for improving data maturity and velocity. Testing is a key phase here. Many dbt developers tend to focus on [primary keys and source freshness.](https://www.getdbt.com/blog/building-a-data-quality-framework-with-dbt-and-dbt-cloud) We think there is a more holistic and in-depth path to tread. Testing is a key piece of the ADLC, and it should drive data quality.

In this blog, we’ll walk through a plan to define data quality. This will look like:

* identifying *data hygiene* issues
* identifying *business-focused anomaly* issues
* identifying *stats-focused anomaly* issues

Once we have *defined* data quality, we’ll move on to *prioritize* those concerns. We will:

* think through each concern in terms of the breadth of impact
* decide if each concern should be at error or warning severity

Flying home into Detroit this past week working on this blog post on a plane and saw for the first time, the newly connected deck of the Gordie Howe International [bridge](https://www.freep.com/story/news/local/michigan/detroit/2024/07/24/gordie-howe-bridge-deck-complete-work-moves-to-next-phase/74528258007/) spanning the Detroit River and connecting the U.S. and Canada. The image stuck out because, in one sense, a feature store is a bridge between the clean, consistent datasets and the machine learning models that rely upon this data. But, more interesting than the bridge itself is the massive process of coordination needed to build it. This construction effort — I think — can teach us more about processes and the need for feature stores in machine learning (ML).

Think of the manufacturing materials needed as our data and the building of the bridge as the building of our ML models. There are thousands of engineers and construction workers taking materials from all over the world, pulling only the specific pieces needed for each part of the project. However, to make this project truly work at this scale, we need the warehousing and logistics to ensure that each load of concrete rebar and steel meets the standards for quality and safety needed and is available to the right people at the right time — as even a single fault can have catastrophic consequences or cause serious delays in project success. This warehouse and the associated logistics play the role of the feature store, ensuring that data is delivered consistently where and when it is needed to train and run ML models.

If you haven’t paid attention to the data industry news cycle, you might have missed the recent excitement centered around an open table format called Apache Iceberg™. It’s one of many open table formats like Delta Lake, Hudi, and Hive. These formats are changing the way data is stored and metadata accessed. They are groundbreaking in many ways.

But I have to be honest: **I don’t care**. But not for the reasons you think.

One of the most important things that dbt does is unlock the ability for teams to collaborate on creating and disseminating organizational knowledge.

In the past, this primarily looked like a team working in one dbt Project to create a set of transformed objects in their data platform.

As dbt was adopted by larger organizations and began to drive workloads at a global scale, it became clear that we needed mechanisms to allow teams to operate independently from each other, creating and sharing data models across teams — [dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro).

[Older entries](https://docs.getdbt.com/blog/page/2)
