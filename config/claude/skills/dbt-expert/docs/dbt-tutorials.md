---
title: "dbt tutorials | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/tags/dbt-tutorials"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



As a dbt Cloud admin, you’ve just upgraded to dbt Cloud on the [Enterprise plan](https://www.getdbt.com/pricing) - **congrats**! dbt Cloud has a lot to offer such as [CI/CD](https://docs.getdbt.com/docs/deploy/about-ci), [Orchestration](https://docs.getdbt.com/docs/deploy/deployments), [dbt Explorer](https://docs.getdbt.com/docs/explore/explore-projects), [dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl), [dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro), [Visual Editor](https://docs.getdbt.com/docs/cloud/canvas), [dbt Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot), and so much more. ***But where should you begin?***

We strongly recommend as you start adopting dbt Cloud functionality to make it a priority to set up Single-Sign On (SSO) and Role-Based Access Control (RBAC). This foundational step enables your organization to keep your data pipelines secure, onboard users into dbt Cloud with ease, and optimize cost savings for the long term.

dbt Cloud now includes a suite of new features that enable configuring precise and unique connections to data platforms at the environment and user level. These enable more sophisticated setups, like connecting a project to multiple warehouse accounts, first-class support for [staging environments](https://docs.getdbt.com/docs/deploy/deploy-environments#staging-environment), and user-level [overrides for specific dbt versions](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#override-dbt-version). This gives dbt Cloud developers the features they need to tackle more complex tasks, like Write-Audit-Publish (WAP) workflows and safely testing dbt version upgrades. While you still configure a default connection at the project level and per-developer, you now have tools to get more advanced in a secure way. Soon, dbt Cloud will take this even further allowing multiple connections to be set globally and reused with *global connections*.

## Introduction[​](#introduction "Direct link to Introduction")

Most data modeling approaches for customer segmentation are based on a wide table with user attributes. This table only stores the current attributes for each user, and is then loaded into the various SaaS platforms via Reverse ETL tools.

Take for example a Customer Experience (CX) team that uses Salesforce as a CRM. The users will create tickets to ask for assistance, and the CX team will start attending them in the order that they are created. This is a good first approach, but not a data driven one.

An improvement to this would be to prioritize the tickets based on the customer segment, answering our most valuable customers first. An Analytics Engineer can build a segmentation to identify the power users (for example with an RFM approach) and store it in the data warehouse. The Data Engineering team can then export that user attribute to the CRM, allowing the customer experience team to build rules on top of it.

At [Lunar](https://www.lunar.app/), most of our dbt models are sourcing from event-driven architecture. As an example, we have the following models for our `activity_based_interest` folder in our ingestion layer:

* `activity_based_interest_activated.sql`
* `activity_based_interest_deactivated.sql`
* `activity_based_interest_updated.sql`
* `downgrade_interest_level_for_user.sql`
* `set_inactive_interest_rate_after_july_1st_in_bec_for_user.sql`
* `set_inactive_interest_rate_from_july_1st_in_bec_for_user.sql`
* `set_interest_levels_from_june_1st_in_bec_for_user.sql`

This results in a lot of the same columns (e.g. `account_id`) existing in different models, across different layers. This means I end up:

1. Writing/copy-pasting the same documentation over and over again
2. Halfway through, realizing I could improve the wording to make it easier to understand, and go back and update the `.yml` files I already did
3. Realizing I made a syntax error in my `.yml` file, so I go back and fix it
4. Realizing the columns are defined differently with different wording being used in other folders in our dbt project
5. Reconsidering my choice of career and pray that a large language model will steal my job
6. Considering if there’s a better way to be generating documentation used across different models

Dimensional modeling is one of many data modeling techniques that are used by data practitioners to organize and present data for analytics. Other data modeling techniques include Data Vault (DV), Third Normal Form (3NF), and One Big Table (OBT) to name a few.

[![Data modeling techniques on a normalization vs denormalization scale](https://docs.getdbt.com/img/blog/2023-04-18-building-a-kimball-dimensional-model-with-dbt/data-modelling.png?v=2 "Data modeling techniques on a normalization vs denormalization scale")](#)Data modeling techniques on a normalization vs denormalization scale

While the relevance of dimensional modeling [has been debated by data practitioners](https://discourse.getdbt.com/t/is-kimball-dimensional-modeling-still-relevant-in-a-modern-data-warehouse/225/6), it is still one of the most widely adopted data modeling technique for analytics.

Despite its popularity, resources on how to create dimensional models using dbt remain scarce and lack detail. This tutorial aims to solve this by providing the definitive guide to dimensional modeling with dbt.

By the end of this tutorial, you will:

* Understand dimensional modeling concepts
* Set up a mock dbt project and database
* Identify the business process to model
* Identify the fact and dimension tables
* Create the dimension tables
* Create the fact table
* Document the dimensional model relationships
* Consume the dimensional model

For years working in data and analytics engineering roles, I treasured the daily camaraderie sharing a small office space with talented folks using a range of tools - from analysts using SQL and Excel to data scientists working in Python. I always sensed that there was so much we could work on in collaboration with each other - but siloed data and tooling made this much more difficult. The diversity of our tools and languages made the potential for collaboration all the more interesting, since we could have folks with different areas of expertise each bringing their unique spin to the project. But logistically, it just couldn’t be done in a scalable way.

So I couldn’t be more excited about dbt’s polyglot capabilities arriving in dbt Core 1.3. This release brings Python dataframe libraries that are crucial to data scientists and enables general-purpose Python but still uses a shared database for reading and writing data sets. Analytics engineers and data scientists are stronger together, and I can’t wait to work side-by-side in the same repo with all my data scientist friends.

Going polyglot is a major next step in the journey of dbt Core. While it expands possibilities, we also recognize the potential for confusion. When combined in an intentional manner, SQL, dataframes, and Python are also stronger together. Polyglot dbt allows informed practitioners to choose the language that best fits your use case.

In this post, we’ll give you your hands-on experience and seed your imagination with potential applications. We’ll walk you through a [demo](https://github.com/dbt-labs/demo-python-blog) that showcases string parsing - one simple way that Python can be folded into a dbt project.

We’ll also give you the intellectual resources to compare/contrast:

* different dataframe implementations within different data platforms
* dataframes vs. SQL

Finally, we’ll share “gotchas” and best practices we’ve learned so far and invite you to participate in discovering the answers to outstanding questions we are still curious about ourselves.

Based on our early experiences, we recommend that you:

✅ **Do**: Use Python when it is better suited for the job – model training, using predictive models, matrix operations, exploratory data analysis (EDA), Python packages that can assist with complex transformations, and select other cases where Python is a more natural fit for the problem you are trying to solve.

❌ **Don’t**: Use Python where the solution in SQL is just as direct. Although a pure Python dbt project is possible, we’d expect the most impactful projects to be a mixture of SQL and Python.

*Editors note - this post assumes working knowledge of dbt Package development. For an introduction to dbt Packages check out [So You Want to Build a dbt Package](https://docs.getdbt.com/blog/so-you-want-to-build-a-package).*

It’s important to be able to test any dbt Project, but it’s even more important to make sure you have robust testing if you are developing a [dbt Package](https://docs.getdbt.com/docs/build/packages).

I love dbt Packages, because it makes it easy to extend dbt’s functionality and create reusable analytics resources. Even better, we can find and share dbt Packages which others developed, finding great packages in [dbt hub](https://hub.getdbt.com/). However, it is a bit difficult to develop complicated dbt macros, because dbt on top of [Jinja2](https://palletsprojects.com/p/jinja/) is lacking some of the functionality you’d expect for software development - like unit testing.

In this article, I would like to share options for unit testing your dbt Package - first through discussing the commonly used pattern of integration testing and then by showing how we can implement unit tests as part of our testing arsenal.

If you’ve needed to grant access to a dbt model between 2019 and today, there’s a good chance you’ve come across the ["The exact grant statements we use in a dbt project"](https://discourse.getdbt.com/t/the-exact-grant-statements-we-use-in-a-dbt-project/430) post on Discourse. It explained options for covering two complementary abilities:

1. querying relations via the "select" privilege
2. using the schema those relations are within via the "usage" privilege

Set up CI/CD with dbt Cloud

This blog is specifically tailored for dbt Core users. If you're using dbt Cloud and your Git provider doesn't have a native dbt Cloud integration (like BitBucket), follow the [Customizing CI/CD with custom pipelines guide](https://docs.getdbt.com/guides/custom-cicd-pipelines?step=3) to set up CI/CD.

Continuous Integration (CI) sets the system up to test everyone’s pull request before merging. Continuous Deployment (CD) deploys each approved change to production. “Slim CI” refers to running/testing only the changed code, [thereby saving compute](https://discourse.getdbt.com/t/how-we-sped-up-our-ci-runs-by-10x-using-slim-ci/2603). In summary, CI/CD automates dbt pipeline testing and deployment.

[dbt Cloud](https://www.getdbt.com/), a much beloved method of dbt deployment, [supports GitHub- and Gitlab-based CI/CD](https://blog.getdbt.com/adopting-ci-cd-with-dbt-cloud/) out of the box. It doesn’t support Bitbucket, AWS CodeCommit/CodeDeploy, or any number of other services, but you need not give up hope even if you are tethered to an unsupported platform.

Although this article uses Bitbucket Pipelines as the compute service and Bitbucket Downloads as the storage service, this article should serve as a blueprint for creating a dbt-based Slim CI/CD *anywhere*. The idea is always the same:

> *[We would love to have] A maturity curve of an end-to-end dbt implementation for each version of dbt .... There are so many features in dbt now but it'd be great to understand, "what is the minimum set of dbt features/components that need to go into a base-level dbt implementation?...and then what are the things that are extra credit?"*
> -*Will Weld on dbt Community Slack*

One question we hear time and time again is this - what does it look like to progress through the different stages of maturity on a dbt project?

When Will posed this question on Slack, it got me thinking about what it would take to create a framework for dbt project maturity.

February 2024 Update

This blog references dbt Core versions older than v1.0.

It's been a few years since dbt-core turned 1.0! Since then, we've committed to releasing zero breaking changes whenever possible and it's become much easier to upgrade dbt Core versions.

In 2024, we're taking this promise further by:

* Stabilizing interfaces for everyone — adapter maintainers, metadata consumers, and (of course) people writing dbt code everywhere — as discussed in [our November 2023 roadmap update](https://github.com/dbt-labs/dbt-core/blob/main/docs/roadmap/2023-11-dbt-tng.md).
* Introducing [Release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) (formerly known as Versionless) to dbt Cloud. No more manual upgrades and no need for *a second sandbox project* just to try out new features in development. For more details, refer to [Upgrade Core version in Cloud](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud).

We're leaving the rest of this post as is, so we can all remember how it used to be. Enjoy a stroll down memory lane.

Without a command to run them, dbt models and tests are just taking up space in a Git repo.

The specific dbt commands you run in production are the control center for your project. They are the structure that defines your team’s data quality + freshness standards.

February 2024 Update

This blog references dbt Core versions older than v1.0.

It's been a few years since dbt-core turned 1.0! Since then, we've committed to releasing zero breaking changes whenever possible and it's become much easier to upgrade dbt Core versions.

In 2024, we're taking this promise further by:

* Stabilizing interfaces for everyone — adapter maintainers, metadata consumers, and (of course) people writing dbt code everywhere — as discussed in [our November 2023 roadmap update](https://github.com/dbt-labs/dbt-core/blob/main/docs/roadmap/2023-11-dbt-tng.md).
* Introducing [Release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) (formerly known as Versionless) to dbt Cloud. No more manual upgrades and no need for *a second sandbox project* just to try out new features in development. For more details, refer to [Upgrade Core version in Cloud](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud).

We're leaving the rest of this post as is, so we can all remember how it used to be. Enjoy a stroll down memory lane.

As we get closer to dbt v1.0 shipping in December, it's a perfect time to get your installation up to scratch. dbt 1.0 represents the culmination of over five years of development and refinement to the analytics engineering experience - smoothing off sharp edges, speeding up workflows and enabling whole new classes of work.

Even with all the new shinies on offer, upgrading can be daunting – you rely on dbt to power your analytics workflow and can’t afford to change things just to discover that your daily run doesn’t work anymore. I’ve been there. This is the checklist I wish I had when I owned my last company’s dbt project.

Packages are the easiest way for a dbt user to contribute code to the dbt community. This is a belief that I hold close as someone who is a contributor to packages and has helped many partners create their own during my time here at dbt Labs.

The reason is simple: packages, as an inherent part of dbt, follow our principle of being built by and for analytics engineers. They’re easy to install, accessible and at the end of the day, it’s just SQL (with sprinklings of git and jinja). You can either share your package with the community or just use it among your teams at your org.

So I challenge you after reading this article to test out your skillsets, think about the code that you find yourself reusing again and again, and build a package. Packages can be as complex as you would want; it’s just SQL hidden in the mix of reusable macros and expansive testing frameworks. So let’s get started on your journey.

At dbt Labs, as more folks adopt dbt, we have started to see more and more use cases that push the boundaries of our established best practices. This is especially true to those adopting dbt in the enterprise space.

After two years of helping companies from 20-10,000+ employees implement dbt & dbt Cloud, the below is my best attempt to answer the question: “Should I have one repository for my dbt project or many?” Alternative title: “To mono-repo or not to mono-repo, that is the question!”

More up-to-date information available

Since this blog post was first published, many data platforms have added support for [materialized views](https://docs.getdbt.com/blog/announcing-materialized-views), which are a superior way to achieve the goals outlined here. We recommend them over the below approach.

Before I dive into how to create this, I have to say this. **You probably don’t need this**. I, along with my other Fishtown colleagues, have spent countless hours working with clients that ask for near-real-time streaming data. However, when we start digging into the project, it is often realized that the use case is not there. There are a variety of reasons why near real-time streaming is not a good fit. Two key ones are:

1. The source data isn’t updating frequently enough.
2. End users aren’t looking at the data often enough.

So when presented with a near-real-time modeling request, I (and you as well!) have to be cynical.

If you’ve been using dbt for over a year, your project is out-of-date. This is natural.

New functionalities have been released. Warehouses change. Best practices are updated. Over the last year, I and others on the Fishtown Analytics (now dbt Labs!) team have conducted seven audits for clients who have been using dbt for a minimum of 2 months.
