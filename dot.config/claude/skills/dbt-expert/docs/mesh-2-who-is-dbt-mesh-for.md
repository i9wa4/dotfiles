---
title: "Who is dbt Mesh for? | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-mesh/mesh-2-who-is-dbt-mesh-for"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* [How we build our dbt Mesh projects](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro)* Who is dbt Mesh for?

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-mesh%2Fmesh-2-who-is-dbt-mesh-for+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-mesh%2Fmesh-2-who-is-dbt-mesh-for+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-mesh%2Fmesh-2-who-is-dbt-mesh-for+so+I+can+ask+questions+about+it.)

On this page

Before embarking on a Mesh implementation, it's important to understand if Mesh is the right fit for your team. Here, we outline three common organizational structures to help teams identify whether Mesh might fit your organization's needs.

## The enterprise data mesh[​](#the-enterprise-data-mesh "Direct link to The enterprise data mesh")

Some data teams operate on a global scale. By definition, the team needs to manage, deploy, and distribute data products across a large number of teams. Central IT may own some data products or simply own the platform upon which data products are built. Often, these organizations have “architects” who can advise line-of-business teams on their work while keeping track of what’s happening globally (regarding tooling and the substance of work). This is a lot like how software organizations work beyond a certain scale.

The headcount ratio of domain teams to platform teams in this scenario is roughly ≥10:1. For each member of the central platform team, there might be dozens of members of domain-aligned data teams.

Is Mesh a good fit in this scenario? Absolutely! There is no other way to share data products at scale. One dbt project would not keep up with the global demands of an organization like this.

### Tips and tricks[​](#tips-and-tricks "Direct link to Tips and tricks")

* **Managing shared macros**: Teams operating at this scale will benefit from a separate repository containing a dbt package of reusable utility macros that all other projects will install. This is different from public models, which provide data-as-a-service (a set of “API endpoints”) — this is distributed as a **library**. This package can also standardize imports of other third-party packages, as well as providing wrappers / shims for those macros. This package should have a dedicated team of maintainers — probably the central platform team, or a set of “superusers” from domain-aligned data modeling teams.

tip

To help you get started, check out our [Quickstart with Mesh](https://docs.getdbt.com/guides/mesh-qs) or our online [Mesh course](https://learn.getdbt.com/courses/dbt-mesh) to learn more!

### Adoption challenges[​](#adoption-challenges "Direct link to Adoption challenges")

* Onboarding hundreds of people and dozens of projects is full of friction! The challenges of a scaled, global organization are not to be underestimated. To start the migration, prioritize teams that have strong dbt familiarity and fundamentals. Mesh is an advancement of core dbt deployments, so these teams are likely to have a smoother transition.

  Additionally, prioritize teams that manage strategic data assets that need to be shared widely. This ensures that Mesh will help your teams deliver concrete value quickly.

If this sounds like your organization, Mesh is the architecture you should pursue. ✅

## Hub and spoke[​](#hub-and-spoke "Direct link to Hub and spoke")

Some slightly smaller organizations still operate with a central data team serving several business-aligned analytics teams in a ~5:1 headcount ratio. These central teams look less like an IT function and more like a modern data platform team of analytics engineers. This team provides the majority of the data products to the rest of the org, as well as the infrastructure for downstream analytics teams to spin up their own spoke projects to ensure quality and maintenance of the core platform.

Is Mesh a good fit in this scenario? Almost certainly! If your central data team starts to bottleneck analysts’ work, you need a way for those teams to operate relatively independently while still ensuring the quality of the most used data products. Mesh is designed to solve this exact problem.

### Tips and tricks[​](#tips-and-tricks-1 "Direct link to Tips and tricks")

* **Data products by some, for all:** The spoke teams shouldn’t produce public models. By contrast, development in the hub team project should be slower, more careful, and focus on producing foundational public models shared across domains. We’d recommend giving hub team members access (at least read-only) to downstream projects, which will help with more granular impact analysis within Catalog. If a public model isn’t used in any downstream project or a specific column in that model, the hub team can feel better about removing it. However, they should still utilize the dbt governance features like `deprecation_date` and `version` as appropriate to set expectations. If there is a need for a public model in a spoke project to be shared across multiple projects, consider first whether it could or should be moved to the hub project.
* **Sources:** Spokes should be allowed/encouraged to define and use *domain-specific* data sources. The platform team should not need to worry about, say, `Thinkific` data when building core data marts, but the Training project may need to. *No two sources anywhere in a dbt mesh should point to the same relation object.* If a spoke feels like they need to use a source the hub already uses, the interfaces should change so that the spoke can get what they need from the platform project.
* **Project quality:** More analyst-focused teams will have different skill levels & quality bars. Owning their data means they own the consequences as well. Rather than being accountable for the end-to-end delivery of data assets, the Hub team is an enablement team: their role is to provide guardrails and quality checks, but not to fix all the issues exactly to their liking (and thereby remain a bottleneck).

### Adoption challenges[​](#adoption-challenges-1 "Direct link to Adoption challenges")

There are trade-offs to using this architecture, especially for the hub team managing and maintaining public models. This workflow has intentional friction to reduce the chances of unintentional model changes that break unspoken data contracts. These assurances may come with some sacrifices, such as faster onboarding or more flexible development workflows. Compared to having a single project, where a select few are doing all the development work, this architecture optimizes for slower development from a wider group of people.

If this sounds like your organization, it's very likely that Mesh is a good fit for you. ✅

## Single team monolith[​](#single-team-monolith "Direct link to Single team monolith")

Some organizations operate on an even smaller scale. If your data org is a single small team that controls the end-to-end process of building and maintaining all data products at the organization, Mesh may not be required. The complexity in projects comes from having a wide variety of data sources and stakeholders. However, given the team's size, operating on a single codebase may be the most efficient way to manage data products. Generally, if a team of this size and scope is looking to implement Mesh, it's likely that they are looking for better interface design and/or performance improvements for certain parts of their dbt DAG, and not because they necessarily have an organizational pain point to solve.

*Is Mesh a good fit?* Maybe! There are reasons to separate out parts of a large monolithic project into several to better orchestrate and manage the models. However, if the same people are managing each project, they may find that the overhead of managing multiple projects is not worth the benefits.

If this sounds like your organization, it's worth considering whether Mesh is a good fit for you.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Intro to dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro)[Next

Deciding how to structure your dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-3-structures)

* [The enterprise data mesh](#the-enterprise-data-mesh)
  + [Tips and tricks](#tips-and-tricks)+ [Adoption challenges](#adoption-challenges)* [Hub and spoke](#hub-and-spoke)
    + [Tips and tricks](#tips-and-tricks-1)+ [Adoption challenges](#adoption-challenges-1)* [Single team monolith](#single-team-monolith)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-mesh/mesh-2-who-is-dbt-mesh-for.md)
