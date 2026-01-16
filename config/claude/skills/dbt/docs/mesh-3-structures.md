---
title: "Deciding how to structure your dbt Mesh | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-mesh/mesh-3-structures"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* [How we build our dbt Mesh projects](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro)* Deciding how to structure your dbt Mesh

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-mesh%2Fmesh-3-structures+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-mesh%2Fmesh-3-structures+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-mesh%2Fmesh-3-structures+so+I+can+ask+questions+about+it.)

On this page

## Exploring mesh patterns[​](#exploring-mesh-patterns "Direct link to Exploring mesh patterns")

When adopting a multi-project architecture, where do you draw the lines between projects?

How should you organize data workflows in a world where instead of having a single dbt DAG, you have multiple projects speaking to each other, each comprised of their own DAG?

Adopting the Mesh pattern is not a one-size-fits-all process. In fact, it's the opposite! It's about customizing your project structure to fit *your* team and *your* data. Now you can mold your organizational knowledge graph to your organizational people graph, bringing people and data closer together rather than compromising one for the other.

While there is not a single best way to implement this pattern, there are some common decision points that will be helpful for you to consider.

At a high level, you’ll need to decide:

* Where to draw the lines between your dbt Projects -- i.e. how do you determine where to split your DAG and which models go in which project?
* How to manage your code -- do you want multiple dbt Projects living in the same repository (mono-repo) or do you want to have multiple repos with one repo per project?

tip

To help you get started, check out our [Quickstart with Mesh](https://docs.getdbt.com/guides/mesh-qs) or our online [Mesh course](https://learn.getdbt.com/courses/dbt-mesh) to learn more!

## Define your project interfaces by splitting your DAG[​](#define-your-project-interfaces-by-splitting-your-dag "Direct link to Define your project interfaces by splitting your DAG")

The first (and perhaps most difficult!) decision when migrating to a multi-project architecture is deciding where to draw the line in your DAG to define the interfaces between your projects. Let's explore some language for discussing the design of these patterns.

### Vertical splits[​](#vertical-splits "Direct link to Vertical splits")

Vertical splits separate out layers of transformation in DAG order. Let's look at some examples.

* **Splitting up staging and mart layers** to create a more tightly-controlled, shared set of components that other projects build on but can't edit.
* **Isolating earlier models for security and governance requirements** to separate out and mask PII data so that downstream consumers can't access it is a common use case for a vertical split.
* **Protecting complex or expensive data** to isolate large or complex models that are expensive to run so that they are safe from accidental selection, independently deployable, and easier to debug when they have issues.

[![A simplified dbt DAG with a dotted line representing a vertical split.](https://docs.getdbt.com/img/best-practices/how-we-mesh/vertical_split.png?v=2 "A simplified dbt DAG with a dotted line representing a vertical split.")](#)A simplified dbt DAG with a dotted line representing a vertical split.

### Horizontal splits[​](#horizontal-splits "Direct link to Horizontal splits")

Horizontal splits separate your DAG based on source or domain. These splits are often based around the shape and size of the data and how it's used. Let's consider some possibilities for horizontal splitting.

* **Team consumption patterns.** For example, splitting out the marketing team's data flow into a separate project.
* **Data from different sources.** For example, clickstream event data and transactional ecommerce data may need to be modeled independently of each other.
* **Team workflows.** For example, if two embedded groups operate at different paces, you may want to split the projects up so they can move independently.

[![A simplified dbt DAG with a dotted line representing a horizontal split.](https://docs.getdbt.com/img/best-practices/how-we-mesh/horizontal_split.png?v=2 "A simplified dbt DAG with a dotted line representing a horizontal split.")](#)A simplified dbt DAG with a dotted line representing a horizontal split.

### Combining these strategies[​](#combining-these-strategies "Direct link to Combining these strategies")

* **These are not either/or techniques**. You should consider both types of splits, and combine them in any way that makes sense for your organization.
* **Pick one type of split and focus on that first**. If you have a hub-and-spoke team topology for example, handle breaking out the central platform project before you split the remainder into domains. Then if you need to break those domains up horizontally you can focus on that after the fact.
* **DRY applies to underlying data, not just code.** Regardless of your strategy, you should not be sourcing the same rows and columns into multiple nodes. When working within a mesh pattern it becomes increasingly important that we don't duplicate logic or data.

[![A simplified dbt DAG with two dotted lines representing both a vertical and horizontal split.](https://docs.getdbt.com/img/best-practices/how-we-mesh/combined_splits.png?v=2 "A simplified dbt DAG with two dotted lines representing both a vertical and horizontal split.")](#)A simplified dbt DAG with two dotted lines representing both a vertical and horizontal split.

## Determine your git strategy[​](#determine-your-git-strategy "Direct link to Determine your git strategy")

A multi-project architecture can exist in a single repo (monorepo) or as multiple projects, with each one being in their own repository (multi-repo).

* If you're a **smaller team** looking primarily to speed up and simplify development, a **monorepo** is likely the right choice, but can become unwieldy as the number of projects, models and contributors grow.
* If you’re a **larger team with multiple groups**, and need to decouple projects for security and enablement of different development styles and rhythms, a **multi-repo setup** is your best bet.

## Projects, splits, and teams[​](#projects-splits-and-teams "Direct link to Projects, splits, and teams")

Since the launch of Mesh, the most common pattern we've seen is one where projects are 1:1 aligned to teams, and each project has its own codebase in its own repository. This isn’t a hard-and-fast rule: Some organizations want multiple teams working out of a single repo, and some teams own multiple domains that feel awkward to keep combined.

Users may need to contribute models across multiple projects and this is fine. There will be some friction doing this, versus a single repo, but this is *useful* friction, especially if upstreaming a change from a “spoke” to a “hub.” This should be treated like making an API change, one that the other team will be living with for some time to come. You should be concerned if your teammates find they need to make a coordinated change across multiple projects very frequently (every week), or as a key prerequisite for ~20%+ of their work.

### Cycle detection[​](#cycle-detection "Direct link to Cycle detection")

You can enable bidirectional dependencies across projects so these relationships can go in either direction, meaning that the `jaffle_finance` project can add a new model that depends on any public models produced by the `jaffle_marketing` project, so long as the new dependency doesn't introduce any node-level cycles. dbt checks for cycles across projects and raises errors if any are detected.

When setting up projects that depend on each other, it's important to do so in a stepwise fashion. Each project must run and produce public models before the original producer project can take a dependency on the original consumer project. For example, the order of operations would be as follows for a simple two-project setup:

1. The `project_a` project runs in a deployment environment and produces public models.
2. The `project_b` project adds `project_a` as a dependency.
3. The `project_b` project runs in a deployment environment and produces public models.
4. The `project_a` project adds `project_b` as a dependency.

### Tips and tricks[​](#tips-and-tricks "Direct link to Tips and tricks")

The [implementation](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-4-implementation) page provides more in-depth examples of how to split a monolithic project into multiple projects. Here are some tips to get you started when considering the splitting methods listed above on your own projects:

1. Start by drawing a diagram of your teams doing data work. Map each team to a single dbt project. If you already have an existing monolithic project, and you’re onboarding *net-new teams,* this could be as simple as declaring the existing project as your “hub” and creating new “spoke” sandbox projects for each team.
2. Split off common foundations when you know that multiple downstream teams will require the same data source. Those could be upstreamed into a centralized hub or split off into a separate foundational project. need some splits to facilitate other splits, for example, source staging models in A that are used in both B and C (lack of project cycles).
3. Split again to introduce intentional friction and encapsulate a particular set of models (for example, for external export).
4. Recombine if you have “hot path” subsets of the DAG that you need to deploy with low latency because it powers in-app reporting or operational analytics. It might make sense to have a different dedicated team own these data models (see principle 1), similar to how software services with significantly different performance characteristics often warrant dedicated infrastructure, architecture, and staffing.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Who is dbt Mesh for?](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-2-who-is-dbt-mesh-for)[Next

Implementing your mesh plan](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-4-implementation)

* [Exploring mesh patterns](#exploring-mesh-patterns)* [Define your project interfaces by splitting your DAG](#define-your-project-interfaces-by-splitting-your-dag)
    + [Vertical splits](#vertical-splits)+ [Horizontal splits](#horizontal-splits)+ [Combining these strategies](#combining-these-strategies)* [Determine your git strategy](#determine-your-git-strategy)* [Projects, splits, and teams](#projects-splits-and-teams)
        + [Cycle detection](#cycle-detection)+ [Tips and tricks](#tips-and-tricks)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-mesh/mesh-3-structures.md)
