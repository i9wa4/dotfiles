---
title: "Implementing your mesh plan | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-mesh/mesh-4-implementation"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* [How we build our dbt Mesh projects](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-1-intro)* Implementing your mesh plan

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-mesh%2Fmesh-4-implementation+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-mesh%2Fmesh-4-implementation+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-mesh%2Fmesh-4-implementation+so+I+can+ask+questions+about+it.)

On this page

### Where should your mesh journey start?[​](#where-should-your-mesh-journey-start "Direct link to Where should your mesh journey start?")

Moving to a Mesh represents a meaningful change in development and deployment architecture. Before any sufficiently complex software refactor or migration, it's important to ask, 'Why might this not work?' The two most common reasons we've seen stem from

1. Lack of buy-in that a Mesh is the right long-term architecture
2. Lack of alignment on a well-scoped starting point

Creating alignment on your architecture and starting point are major steps in ensuring a successful migration. Deciding on the right starting point will look different for every organization, but there are some heuristics that can help you decide where to start. In all likelihood, your organization already has logical components, and you may already be grouping, building, and deploying your project according to these interfaces.The goal is to define and formalize these organizational interfaces and use these boundaries to split your project apart by domain.

How do you find these organizational interfaces? Here are some steps to get you started:

* **Talk to teams** about what sort of separation naturally exists right now.
  + Are there various domains people are focused on?
  + Are there various sizes, shapes, and sources of data that get handled separately (such as click event data)?
  + Are there people focused on separate levels of transformation, such as landing and staging data or building marts?
  + Is there a single team that is *downstream* of your current dbt project, who could more easily migrate onto Mesh as a consumer?

When attempting to define your project interfaces, you should consider investigating:

* **Your jobs:** Which sets of models are most often built together?
* **Your lineage graph:** How are models connected?
* **Your selectors(defined in `selectors.yml`):** How do people already define resource groups?

Let's go through an example process of taking a monolithing project, using groups and access to define the interfaces, and then splitting it into multiple projects.

tip

To help you get started, check out our [Quickstart with Mesh](https://docs.getdbt.com/guides/mesh-qs) or our online [Mesh course](https://learn.getdbt.com/courses/dbt-mesh) to learn more!

## Defining project interfaces with groups and access[​](#defining-project-interfaces-with-groups-and-access "Direct link to Defining project interfaces with groups and access")

Once you have a sense of some initial groupings, you can first implement **group and access permissions** within a single project.

* First you can create a [group](https://docs.getdbt.com/docs/build/groups) to define the owner of a set of models.

```
# in models/__groups.yml

groups:
  - name: marketing
    owner:
        name: Ben Jaffleck
        email: ben.jaffleck@jaffleshop.com
```

* Then, we can add models to that group using the `group:` key in the model's YAML entry.

```
# in models/marketing/__models.yml

models:
  - name: fct_marketing_model
    config:
      group: marketing # changed to config in v1.10
  - name: stg_marketing_model
    config:
      group: marketing # changed to config in v1.10
```

* Once you've added models to the group, you can **add [access](https://docs.getdbt.com/docs/mesh/govern/model-access) settings to the models** based on their connections between groups, *opting for the most private access that will maintain current functionality*. This means that any model that has *only* relationships to other models in the same group should be `private` , and any model that has cross-group relationships, or is a terminal node in the group DAG should be `protected` so that other parts of the DAG can continue to reference it.

```
# in models/marketing/__models.yml

models:
  - name: fct_marketing_model
    config:
      group: marketing # changed to config in v1.10
      access: protected # changed to config in v1.10
  - name: stg_marketing_model
    config:
      group: marketing # changed to config in v1.10
      access: private # changed to config in v1.10
```

* **Validate these groups by incrementally migrating your jobs** to execute these groups specifically via selection syntax. We would recommend doing this in parallel to your production jobs until you’re sure about them. This will help you feel out if you’ve drawn the lines in the right place.
* If you find yourself **consistently making changes across multiple groups** when you update logic, that’s a sign that **you may want to rethink your groups**.

## Split your projects[​](#split-your-projects "Direct link to Split your projects")

1. **Move your grouped models into a subfolder**. This will include any model in the selected group, it's associated YAML entry, as well as its parent or child resources as appropriate depending on where this group sits in your DAG.
   1. Note that just like in your dbt project, circular references are not allowed! Project B cannot have parents and children in Project A, for example.
2. **Create a new `dbt_project.yml` file** in the subdirectory.
3. **Copy any macros** used by the resources you moved.
4. **Create a new `packages.yml` file** in your subdirectory with the packages that are used by the resources you moved.
5. **Update `{{ ref }}` functions** — For any model that has a cross-project dependency (this may be in the files you moved, or in the files that remain in your project):
   1. Update the `{{ ref() }}` function to have two arguments, where the first is the name of the source project and the second is the name of the model: e.g. `{{ ref('jaffle_shop', 'my_upstream_model') }}`
   2. Update the upstream, cross-project parents’ `access` configs to `public` , ensuring any project can safely `{{ ref() }}` those models.
   3. We *highly* recommend adding a [model contract](https://docs.getdbt.com/docs/mesh/govern/model-contracts) to the upstream models to ensure the data shape is consistent and reliable for your downstream consumers.
6. **Create a `dependencies.yml` file** ([docs](https://docs.getdbt.com/docs/mesh/govern/project-dependencies)) for the downstream project, declaring the upstream project as a dependency.

```
# in dependencies.yml
projects:
  - name: jaffle_shop
```

### Best practices[​](#best-practices "Direct link to Best practices")

* When you’ve **confirmed the right groups**, it's time to split your projects.
  + **Do *one* group at a time**!
  + **Do *not* refactor as you migrate**, however tempting that may be. Focus on getting 1-to-1 parity and log any issues you find in doing the migration for later. Once you’ve fully migrated the project then you can start optimizing it for its new life as part of your mesh.
* Start by splitting your project within the same repository for full git tracking and easy reversion if you need to start from scratch.

## Connecting existing projects[​](#connecting-existing-projects "Direct link to Connecting existing projects")

Some organizations may already be coordinating across multiple dbt projects. Most often this is via:

1. Installing parent projects as dbt packages
2. Using `{{ source() }}` functions to read the outputs of a parent project as inputs to a child project.

This has a few drawbacks:

1. If using packages, each project has to include *all* resources from *all* projects in its manifest, slowing down dbt and the development cycle.
2. If using sources, there are breakages in the lineage, as there's no real connection between the parent and child projects.

The migration steps here are much simpler than splitting up a monolith!

1. If using the `package` method:
   1. In the parent project:
      1. mark all models being referenced downstream as `public` and add a model contract.
   2. In the child project:
      1. Remove the package entry from `packages.yml`
      2. Add the upstream project to your `dependencies.yml`
      3. Update the `{{ ref() }}` functions to models from the upstream project to include the project name argument.
2. If using `source` method:
   1. In the parent project:
      1. mark all models being imported downstream as `public` and add a model contract.
   2. In the child project:
      1. Add the upstream project to your `dependencies.yml`
      2. Replace the `{{ source() }}` functions with cross project `{{ ref() }}` functions.
      3. Remove the unnecessary `source` definitions.

## Additional Resources[​](#additional-resources "Direct link to Additional Resources")

### Our example projects[​](#our-example-projects "Direct link to Our example projects")

We've provided a set of example projects you can use to explore the topics covered here. We've split our [Jaffle Shop](https://github.com/dbt-labs/jaffle-shop) project into 3 separate projects in a multi-repo Mesh. Note that you'll need to leverage dbt to use multi-project architecture, as cross-project references are powered via dbt's APIs.

* **[Platform](https://github.com/dbt-labs/jaffle-shop-mesh-platform)** - containing our centralized staging models.
* **[Marketing](https://github.com/dbt-labs/jaffle-shop-mesh-marketing)** - containing our marketing marts.
* **[Finance](https://github.com/dbt-labs/jaffle-shop-mesh-finance)** - containing our finance marts.

### dbt-meshify[​](#dbt-meshify "Direct link to dbt-meshify")

We recommend using the `dbt-meshify` [command line tool](https://dbt-labs.github.io/dbt-meshify/) to help you do this. This comes with CLI operations to automate most of the above steps.

## Related docs[​](#related-docs "Direct link to Related docs")

* [Quickstart with Mesh](https://docs.getdbt.com/guides/mesh-qs)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Deciding how to structure your dbt Mesh](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-3-structures)[Next

Coordinating model versions](https://docs.getdbt.com/best-practices/how-we-mesh/mesh-6-coordinate-versions)

* [Where should your mesh journey start?](#where-should-your-mesh-journey-start)* [Defining project interfaces with groups and access](#defining-project-interfaces-with-groups-and-access)* [Split your projects](#split-your-projects)
      + [Best practices](#best-practices)* [Connecting existing projects](#connecting-existing-projects)* [Additional Resources](#additional-resources)
          + [Our example projects](#our-example-projects)+ [dbt-meshify](#dbt-meshify)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-mesh/mesh-4-implementation.md)
