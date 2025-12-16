---
title: "Explore multiple projects | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/explore/explore-multiple-projects"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Explore your data](https://docs.getdbt.com/docs/explore/explore-your-data)* [Discover data with dbt Catalog](https://docs.getdbt.com/docs/explore/explore-projects)* Explore multiple projects

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fexplore-multiple-projects+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fexplore-multiple-projects+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fexplore%2Fexplore-multiple-projects+so+I+can+ask+questions+about+it.)

On this page

View all the projects and public models in your account (where public models are defined) and gain a better understanding of your cross-project resources and how they're used.

On-demand learning

If you enjoy video courses, check out our [dbt Catalog on-demand course](https://learn.getdbt.com/courses/dbt-catalog) and learn how to best explore your dbt project(s)!

The resource-level lineage graph for a project displays the cross-project relationships in the DAG, with a **PRJ** icon indicating whether or not it's a project resource. That icon is located to the left side of the node name.

To view the project-level lineage graph, click the **View lineage** icon in the upper right corner from the main overview page:

* This view displays all the projects in your account and their relationships.
* Viewing an upstream (parent) project displays the downstream (child) projects that depend on it.
* Selecting a model reveals its dependent projects in the lineage.
* Click on an upstream (parent) project to view the other projects that reference it in the **Relationships** tab, showing the number of downstream (child) projects that depend on them.
  + This includes all projects listing the upstream one as a dependency in its `dependencies.yml` file, even without a direct `{{ ref() }}`.
* Selecting a project node from a public model opens its detailed lineage graph if you have the [permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) to do so.

Indirect dependencies

When viewing a project's lineage, Catalog shows only *directly* [referenced](https://docs.getdbt.com/docs/mesh/govern/project-dependencies) public models. It doesn't show [indirect dependencies](https://docs.getdbt.com/faqs/Project_ref/indirectly-reference-upstream-model). If a referenced model in your project depends on another upstream public model, the second-level model won't appear in Catalog, however it will appear in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) lineage view.

[![View your cross-project lineage in a parent project and the other projects that reference it by clicking the 'Relationships' tab.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/cross-project-lineage-parent.png?v=2 "View your cross-project lineage in a parent project and the other projects that reference it by clicking the 'Relationships' tab.")](#)View your cross-project lineage in a parent project and the other projects that reference it by clicking the 'Relationships' tab.

When viewing a downstream (child) project that imports and refs public models from upstream (parent) projects:

* Public models will show up in the lineage graph and you can click on them to view the model details.
* Clicking on a model opens a side panel containing general information about the model, such as the specific dbt project that produces that model, description, package, and more.
* Double-clicking on a model from another project opens the resource-level lineage graph of the parent project, if you have the permissions to do so.

[![View a downstream (child) project that imports and refs public models from the upstream (parent) project.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/cross-project-child.png?v=2 "View a downstream (child) project that imports and refs public models from the upstream (parent) project.")](#)View a downstream (child) project that imports and refs public models from the upstream (parent) project.

## Explore the project-level lineage graph[​](#explore-the-project-level-lineage-graph "Direct link to Explore the project-level lineage graph")

For cross-project collaboration, you can interact with the DAG in all the same ways as described in [Explore your project's lineage](https://docs.getdbt.com/docs/explore/explore-projects#project-lineage) but you can also interact with it at the project level and view the details.

If you have permissions for a project in the account, you can view all public models used across the entire account. However, you can only view full public model details and private models if you have permissions for the specific project where those models are defined.

To view all the projects in your account (displayed as a lineage graph or list view):

* Navigate to the top left section of the **Explore** page, near the navigation bar.
* Hover over the project name and select the account name. This takes you to a account-level lineage graph page, where you can view all the projects in the account, including dependencies and relationships between different projects.
* Click the **List view** icon in the page's upper right corner to see a list view of all the projects in the account.
* The list view page displays a public model list, project list, and a search bar for project searches.
* Click the **Lineage view** icon in the page's upper right corner to view the account-level lineage graph.

[![View a downstream (child) project, which imports and refs public models from upstream (parent) projects.](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/account-level-lineage.gif?v=2 "View a downstream (child) project, which imports and refs public models from upstream (parent) projects.")](#)View a downstream (child) project, which imports and refs public models from upstream (parent) projects.

From the account-level lineage graph, you can:

* Click the **Lineage view** icon (in the graph’s upper right corner) to view the cross-project lineage graph.
* Click the **List view** icon (in the graph’s upper right corner) to view the project list.
  + Select a project from the **Projects** tab to switch to that project’s main **Explore** page.
  + Select a model from the **Public Models** tab to view the [model’s details page](https://docs.getdbt.com/docs/explore/explore-projects#view-resource-details).
  + Perform searches on your projects with the search bar.
* Select a project node in the graph (double-clicking) to switch to that particular project’s lineage graph.

When you select a project node in the graph, a project details panel opens on the graph’s right-hand side where you can:

* View counts of the resources defined in the project.
* View a list of its public models, if any.
* View a list of other projects that uses the project, if any.
* Click **Open Project Lineage** to switch to the project’s lineage graph.
* Click the **Share** icon to copy the project panel link to your clipboard so you can share the graph with someone.

[![Select a downstream (child) project to open the project details panel for resource counts, public models associated, and more. ](https://docs.getdbt.com/img/docs/collaborate/dbt-explorer/multi-project-overview.gif?v=2 "Select a downstream (child) project to open the project details panel for resource counts, public models associated, and more. ")](#)Select a downstream (child) project to open the project details panel for resource counts, public models associated, and more.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Data health signals](https://docs.getdbt.com/docs/explore/data-health-signals)[Next

External metadata ingestion](https://docs.getdbt.com/docs/explore/external-metadata-ingestion)

* [Explore the project-level lineage graph](#explore-the-project-level-lineage-graph)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/explore/explore-multiple-projects.md)
