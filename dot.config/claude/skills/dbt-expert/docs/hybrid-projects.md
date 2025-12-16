---
title: "About Hybrid projects | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/hybrid-projects"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* Hybrid projects

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fhybrid-projects+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fhybrid-projects+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fhybrid-projects+so+I+can+ask+questions+about+it.)

On this page

With Hybrid projects, your organization can adopt complementary dbt Core and dbt workflows (where some teams deploy projects in dbt Core and others in dbt) and seamlessly integrate these workflows by automatically uploading dbt Core [artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts) into dbt.

Available in public preview

Hybrid projects is available in public preview to [dbt Enterprise accounts](https://www.getdbt.com/pricing).

dbt Core users can seamlessly upload [artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts) like [run results.json](https://docs.getdbt.com/reference/artifacts/run-results-json), [manifest.json](https://docs.getdbt.com/reference/artifacts/manifest-json), [catalog.json](https://docs.getdbt.com/reference/artifacts/catalog-json), [sources.json](https://docs.getdbt.com/reference/artifacts/sources-json), and so on — into dbt after executing a run in the dbt Core command line interface (CLI), which helps:

* Collaborate with dbt + dbt Core users by enabling them to visualize and perform [cross-project references](https://docs.getdbt.com/docs/mesh/govern/project-dependencies#how-to-write-cross-project-ref) to dbt models that live in Core projects.
* (Coming soon) New users interested in the [Canvas](https://docs.getdbt.com/docs/cloud/canvas) can build off of dbt models already created by a central data team in dbt Core rather than having to start from scratch.
* dbt Core and dbt users can navigate to [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) and view their models and assets. To view Catalog, you must have a [read-only seat](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users).

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

To upload artifacts, make sure you meet these prerequisites:

* Your organization is on a [dbt Enterprise+ plan](https://www.getdbt.com/pricing)
* You're on [dbt's release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) and your dbt Core project is on dbt v1.10 or higher
* [Configured](https://docs.getdbt.com/docs/deploy/hybrid-setup#connect-project-in-dbt-cloud) a hybrid project in dbt.
* Updated your existing dbt Core project with latest changes and [configured it with model access](https://docs.getdbt.com/docs/deploy/hybrid-setup#make-dbt-core-models-public):
  + Ensure models that you want to share with other dbt projects use `access: public` in their model configuration. This makes the models more discoverable and shareable
  + Learn more about [access modifier](https://docs.getdbt.com/docs/mesh/govern/model-access#access-modifiers) and how to set the [`access` config](https://docs.getdbt.com/reference/resource-configs/access)
* Update [dbt permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) to create a new project in dbt

**Note:** Uploading artifacts doesn't count against dbt run slots.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Webhooks](https://docs.getdbt.com/docs/deploy/webhooks)[Next

Hybrid setup](https://docs.getdbt.com/docs/deploy/hybrid-setup)

* [Prerequisites](#prerequisites)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/hybrid-projects.md)
