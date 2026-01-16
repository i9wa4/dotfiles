---
title: "Analytics craft | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/tags/analytics-craft"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



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

One of the most important things that dbt does is unlock the ability for teams to collaborate on creating and disseminating organizational knowledge.

In the past, this primarily looked like a team working in one dbt Project to create a set of transformed objects in their data platform.

As dbt was adopted by larger organizations and began to drive workloads at a global scale, it became clear that we needed mechanisms to allow teams to operate independently from each other, creating and sharing data models across teams — [dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro).

The [dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl) is founded on the idea that data transformation should be both *flexible*, allowing for on-the-fly aggregations grouped and filtered by definable dimensions and *version-controlled and tested*. Like any other codebase, you should have confidence that your transformations express your organization’s business logic correctly. Historically, you had to choose between these options, but the dbt Semantic Layer brings them together. This has required new paradigms for *how* you express your transformations though.

## New in dbt: allow Snowflake Python models to access the internet[​](#new-in-dbt-allow-snowflake-python-models-to-access-the-internet "Direct link to New in dbt: allow Snowflake Python models to access the internet")

With dbt 1.8, dbt released support for Snowflake’s [external access integrations](https://docs.snowflake.com/en/developer-guide/external-network-access/external-network-access-overview) further enabling the use of dbt + AI to enrich your data. This allows querying of external APIs within dbt Python models, a functionality that was required for dbt Cloud customer, [EQT AB](https://eqtgroup.com/). Learn about why they needed it and how they helped build the feature and get it shipped!

Do you ever have "bad data" dreams? Or am I the only one that has recurring nightmares? 😱

Here's the one I had last night:

It began with a midnight bug hunt. A menacing insect creature has locked my colleagues in a dungeon, and they are pleading for my help to escape . Finding the key is elusive and always seems just beyond my grasp. The stress is palpable, a physical weight on my chest, as I raced against time to unlock them.

Of course I wake up without actually having saved them, but I am relieved nonetheless. And I've had similar nightmares involving a heroic code refactor or the launch of a new model or feature.

Good news: beginning in dbt v1.8, we're introducing a first-class unit testing framework that can handle each of the scenarios from my data nightmares.

Before we dive into the details, let's take a quick look at how we got here.

dbt Cloud now includes a suite of new features that enable configuring precise and unique connections to data platforms at the environment and user level. These enable more sophisticated setups, like connecting a project to multiple warehouse accounts, first-class support for [staging environments](https://docs.getdbt.com/docs/deploy/deploy-environments#staging-environment), and user-level [overrides for specific dbt versions](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#override-dbt-version). This gives dbt Cloud developers the features they need to tackle more complex tasks, like Write-Audit-Publish (WAP) workflows and safely testing dbt version upgrades. While you still configure a default connection at the project level and per-developer, you now have tools to get more advanced in a secure way. Soon, dbt Cloud will take this even further allowing multiple connections to be set globally and reused with *global connections*.

## Cloud Data Platforms make new things possible; dbt helps you put them into production[​](#cloud-data-platforms-make-new-things-possible-dbt-helps-you-put-them-into-production "Direct link to Cloud Data Platforms make new things possible; dbt helps you put them into production")

The original paradigm shift that enabled dbt to exist and be useful was databases going to the cloud.

All of a sudden it was possible for more people to do better data work as huge blockers became huge opportunities:

* We could now dynamically scale compute on-demand, without upgrading to a larger on-prem database.
* We could now store and query enormous datasets like clickstream data, without pre-aggregating and transforming it.

Today, the next wave of innovation is happening in AI and LLMs, and it's coming to the cloud data platforms dbt practitioners are already using every day. For one example, Snowflake have just released their [Cortex functions](https://docs.snowflake.com/LIMITEDACCESS/cortex-functions) to access LLM-powered tools tuned for running common tasks against your existing datasets. In doing so, there are a new set of opportunities available to us:

## What’s in a data platform?[​](#whats-in-a-data-platform "Direct link to What’s in a data platform?")

[Raising a dbt project](https://docs.getdbt.com/blog/how-to-build-a-mature-dbt-project-from-scratch) is hard work. We, as data professionals, have poured ourselves into raising happy healthy data products, and we should be proud of the insights they’ve driven. It certainly wasn’t without its challenges though — we remember the terrible twos, where we worked hard to just get the platform to walk straight. We remember the angsty teenage years where tests kept failing, seemingly just to spite us. A lot of blood, sweat, and tears are shed in the service of clean data!

Once the project could dress and feed itself, we also worked hard to get buy-in from our colleagues who put their trust in our little project. Without deep trust and understanding of what we built, our colleagues who depend on your data (or even those involved in developing it with you — it takes a village after all!) are more likely to be in your DMs with questions than in their BI tools, generating insights.

When our teammates ask about where the data in their reports come from, how fresh it is, or about the right calculation for a metric, what a joy! This means they want to put what we’ve built to good use — the challenge is that, historically, *it hasn’t been all that easy to answer these questions well.* That has often meant a manual, painstaking process of cross checking run logs and your dbt documentation site to get the stakeholder the information they need.

Enter [dbt Explorer](https://www.getdbt.com/product/dbt-explorer)! dbt Explorer centralizes documentation, lineage, and execution metadata to reduce the work required to ship trusted data products faster.

Picture this — you’ve got a massive dbt project, thousands of models chugging along, creating actionable insights for your stakeholders. A ticket comes your way — a model needs to be refactored! "No problem," you think to yourself, "I will simply make that change and test it locally!" You look at your lineage, and realize this model is many layers deep, buried underneath a long chain of tables and views.

“OK,” you think further, “I’ll just run a `dbt build -s +my_changed_model` to make sure I have everything I need built into my dev schema and I can test my changes”. You run the command. You wait. You wait some more. You get some coffee, and completely take yourself out of your dbt development flow state. A lot of time and money down the drain to get to a point where you can *start* your work. That’s no good!

Luckily, dbt’s defer functionality allow you to *only* build what you care about when you need it, and nothing more. This feature helps developers spend less time and money in development, helping ship trusted data products faster. dbt Cloud offers native support for this workflow in development, so you can start deferring without any additional overhead!

Hi all, I’m Kshitij, a senior software engineer on the Core team at dbt Labs.
One of the coolest moments of my career here thus far has been shipping the new `dbt clone` command as part of the dbt-core v1.6 release.

However, one of the questions I’ve received most frequently is guidance around “when” to clone that goes beyond [the documentation on “how” to clone](https://docs.getdbt.com/reference/commands/clone).
In this blog post, I’ll attempt to provide this guidance by answering these FAQs:

1. What is `dbt clone`?
2. How is it different from deferral?
3. Should I defer or should I clone?

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

[Older entries](https://docs.getdbt.com/blog/tags/analytics-craft/page/2)
