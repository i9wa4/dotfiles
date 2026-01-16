---
title: "Intro to dbt Mesh | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* How we build our dbt Mesh projects

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-mesh%2Fmesh-1-intro+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-mesh%2Fmesh-1-intro+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-mesh%2Fmesh-1-intro+so+I+can+ask+questions+about+it.)

On this page

## What is dbt Mesh?[​](#what-is-dbt-mesh "Direct link to What is dbt Mesh?")

Organizations of all sizes rely upon dbt to manage their data transformations, from small startups to large enterprises. At scale, it can be challenging to coordinate all the organizational and technical requirements demanded by your stakeholders within the scope of a single dbt project.

To date, there also hasn't been a first-class way to effectively manage the dependencies, governance, and workflows between multiple dbt projects.

That's where **Mesh** comes in - empowering data teams to work *independently and collaboratively*; sharing data, code, and best practices without sacrificing security or autonomy.

Mesh is not a single product - it is a pattern enabled by a convergence of several features in dbt:

* **[Cross-project references](https://docs.getdbt.com/docs/mesh/govern/project-dependencies#how-to-write-cross-project-ref)** - this is the foundational feature that enables the multi-project deployments. `{{ ref() }}`s now work across dbt projects on Enterprise and Enterprise+ plans.
* **[Catalog](https://docs.getdbt.com/docs/explore/explore-projects)** - dbt's metadata-powered documentation platform, complete with full, cross-project lineage.
* **Governance** - dbt's governance features allow you to manage access to your dbt models both within and across projects.
  + **[Groups](https://docs.getdbt.com/docs/mesh/govern/model-access#groups)** - With groups, you can organize nodes in your dbt DAG that share a logical connection (for example, by functional area) and assign an owner to the entire group.
  + **[Access](https://docs.getdbt.com/docs/mesh/govern/model-access#access-modifiers)** - access configs allow you to control who can reference models.
  + **[Model Versions](https://docs.getdbt.com/docs/mesh/govern/model-versions)** - when coordinating across projects and teams, we recommend treating your data models as stable APIs. Model versioning is the mechanism to allow graceful adoption and deprecation of models as they evolve.
  + **[Model Contracts](https://docs.getdbt.com/docs/mesh/govern/model-contracts)** - data contracts set explicit expectations on the shape of the data to ensure data changes upstream of dbt or within a project's logic don't break downstream consumers' data products.

## When is the right time to use dbt Mesh?[​](#when-is-the-right-time-to-use-dbt-mesh "Direct link to When is the right time to use dbt Mesh?")

The multi-project architecture helps organizations with mature, complex transformation workflows in dbt increase the flexibility and performance of their dbt projects. If you're already using dbt and your project has started to experience any of the following, you're likely ready to start exploring this paradigm:

* The **number of models** in your project is degrading performance and slowing down development.
* Teams have developed **separate workflows** and need to decouple development from each other.
* Teams are experiencing **communication challenges**, and the reliability of some of your data products has started to deteriorate.
* **Security and governance** requirements are increasing and would benefit from increased isolation.

dbt is designed to coordinate the features above and simplify the complexity to solve for these problems.

If you're just starting your dbt journey, don't worry about building a multi-project architecture right away. You can *incrementally* adopt the features in this guide as you scale. The collection of features work effectively as independent tools. Familiarizing yourself with the tooling and features that make up a multi-project architecture, and how they can apply to your organization will help you make better decisions as you grow.

For additional information, refer to the [Mesh FAQs](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-5-faqs).

## Learning goals[​](#learning-goals "Direct link to Learning goals")

* Understand the **purpose and tradeoffs** of building a multi-project architecture.
* Develop an intuition for various **Mesh patterns** and how to design a multi-project architecture for your organization.
* Establish recommended steps to **incrementally adopt** these patterns in your dbt implementation.

tip

To help you get started, check out our [Quickstart with Mesh](https://docs.getdbt.com/guides/mesh-qs) or our online [Mesh course](https://learn.getdbt.com/courses/dbt-mesh) to learn more!

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Best practices](https://docs.getdbt.com/best-practices/how-we-build-our-metrics/semantic-layer-9-conclusion)[Next

Who is dbt Mesh for?](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-2-who-is-dbt-mesh-for)

* [What is dbt Mesh?](#what-is-dbt-mesh)* [When is the right time to use dbt Mesh?](#when-is-the-right-time-to-use-dbt-mesh)* [Learning goals](#learning-goals)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-mesh/mesh-1-intro.md)
