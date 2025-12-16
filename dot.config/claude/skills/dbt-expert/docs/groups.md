---
title: "Add groups to your DAG | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/groups"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your DAG](https://docs.getdbt.com/docs/build/models)* Groups

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fgroups+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fgroups+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fgroups+so+I+can+ask+questions+about+it.)

On this page

A group is a collection of nodes within a dbt DAG. Groups are named, and every group has an `owner`. They enable intentional collaboration within and across teams by restricting [access to private](https://docs.getdbt.com/reference/resource-configs/access) models.

Group members may include models, tests, seeds, snapshots, analyses, and metrics. (Not included: sources and exposures.) Each node may belong to only one group.

### Declaring a group[​](#declaring-a-group "Direct link to Declaring a group")

Groups are defined in `.yml` files, nested under a `groups:` key.

#### Centrally defining a group[​](#centrally-defining-a-group "Direct link to Centrally defining a group")

To centrally define a group in your project, there are two options:

* Create one `_groups.yml` file in the root of the `models` directory.
* Create one `_groups.yml` file in the root of a `groups` directory. For this option, you also need to configure [`model-paths`](https://docs.getdbt.com/reference/project-configs/model-paths) in the `dbt_project.yml` file:

  ```
  model-paths: ["models", "groups"]
  ```

### Adding a model to a group[​](#adding-a-model-to-a-group "Direct link to Adding a model to a group")

Use the `group` configuration to add one or more models to a group.

* Project-level* Model-level* In-file

dbt\_project.yml

```
models:
  marts:
    finance:
      +group: finance
```

models/schema.yml

```
models:
  - name: model_name
    config:
      group: finance
```

models/model\_name.sql

```
{{ config(group = 'finance') }}

select ...
```

### Referencing a model in a group[​](#referencing-a-model-in-a-group "Direct link to Referencing a model in a group")

By default, all models within a group have the `protected` [access modifier](https://docs.getdbt.com/reference/resource-configs/access). This means they can be referenced by downstream resources in *any* group in the same project, using the [`ref`](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) function. If a grouped model's `access` property is set to `private`, only resources within its group can reference it.

models/schema.yml

```
models:
  - name: finance_private_model
    config:
      access: private # changed to config in v1.10
      group: finance

  # in a different group!
  - name: marketing_model
    config:
      group: marketing
```

models/marketing\_model.sql

```
select * from {{ ref('finance_private_model') }}
```

```
$ dbt run -s marketing_model
...
dbt.exceptions.DbtReferenceError: Parsing Error
  Node model.jaffle_shop.marketing_model attempted to reference node model.jaffle_shop.finance_private_model,
  which is not allowed because the referenced node is private to the finance group.
```

## Related docs[​](#related-docs "Direct link to Related docs")

* [Model Access](https://docs.getdbt.com/docs/mesh/govern/model-access#groups)
* [Group configuration](https://docs.getdbt.com/reference/resource-configs/group)
* [Group selection](https://docs.getdbt.com/reference/node-selection/methods#group)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Exposures](https://docs.getdbt.com/docs/build/exposures)[Next

Analyses](https://docs.getdbt.com/docs/build/analyses)

* [Declaring a group](#declaring-a-group)* [Adding a model to a group](#adding-a-model-to-a-group)* [Referencing a model in a group](#referencing-a-model-in-a-group)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/groups.md)
