---
title: "Project state in dbt | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-cloud-apis/project-state"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api)* Project state in dbt

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fproject-state+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fproject-state+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fproject-state+so+I+can+ask+questions+about+it.)

On this page

dbt provides a stateful way of deploying dbt. Artifacts are accessible programmatically via the [Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-querying) in the metadata platform.

With the implementation of the `environment` endpoint in the Discovery API, we've introduced the idea of multiple states. The Discovery API provides a single API endpoint that returns the latest state of models, sources, and other nodes in the DAG.

A single [deployment environment](https://docs.getdbt.com/docs/environments-in-dbt) should represent the production state of a given dbt project.

There are two states that can be queried in dbt:

* **Applied state** refers to what exists in the data warehouse after a successful `dbt run`. The model build succeeds and now exists as a table in the warehouse.
* **Definition state** depends on what exists in the project given the code defined in it (for example, manifest state), which hasn’t necessarily been executed in the data platform (maybe just the result of `dbt compile`).

## Definition (logical) vs. applied state of dbt nodes[​](#definition-logical-vs-applied-state-of-dbt-nodes "Direct link to Definition (logical) vs. applied state of dbt nodes")

In a dbt project, the state of a node *definition* represents the configuration, transformations, and dependencies defined in the SQL and YAML files. It captures how the node should be processed in relation to other nodes and tables in the data warehouse and may be produced by a `dbt build`, `run`, `parse`, or `compile`. It changes whenever the project code changes.

A node’s *applied state* refers to the node’s actual state after it has been successfully executed in the DAG; for example, models are executed; thus, their state is applied to the data warehouse via `dbt run` or `dbt build`. It changes whenever a node is executed. This state represents the result of the transformations and the actual data stored in the database, which for models can be a table or a view based on the defined logic.

The applied state includes execution info, which contains metadata about how the node arrived in the applied state: the most recent execution (successful or attempted), such as when it began, its status, and how long it took.

Here’s how you’d query and compare the definition vs. applied state of a model using the Discovery API:

```
query Compare($environmentId: Int!, $first: Int!) {
	environment(id: $environmentId) {
		definition {
			models(first: $first) {
				edges {
					node {
						name
						rawCode
					}
				}
			}
		}
		applied {
			models(first: $first) {
				edges {
					node {
						name
						rawCode
						executionInfo {
							executeCompletedAt
						}
					}
				}
			}
		}
	}
}
```

Most Discovery API use cases will favor the *applied state* since it pertains to what has actually been run and can be analyzed.

## Affected states by node type[​](#affected-states-by-node-type "Direct link to Affected states by node type")

The following table shows the states of dbt nodes and how they are affected by the Discovery API.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Node Executed in DAG Created by execution Exists in database Lineage States|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Analysis](https://docs.getdbt.com/docs/build/analyses) No No No Upstream Definition|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Data test](https://docs.getdbt.com/docs/build/data-tests) Yes Yes No Upstream Applied & definition|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Exposure](https://docs.getdbt.com/docs/build/exposures) No No No Upstream Definition|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Group](https://docs.getdbt.com/docs/build/groups) No No No Downstream Definition|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Macro](https://docs.getdbt.com/docs/build/jinja-macros) Yes No No N/A Definition|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Metric](https://docs.getdbt.com/docs/build/metrics-overview) No No No Upstream & downstream Definition|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Model](https://docs.getdbt.com/docs/build/models) Yes Yes Yes Upstream & downstream Applied & definition|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Saved queries](https://docs.getdbt.com/docs/build/saved-queries)   (not in API) N/A N/A N/A N/A N/A|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Seed](https://docs.getdbt.com/docs/build/seeds) Yes Yes Yes Downstream Applied & definition|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Semantic model](https://docs.getdbt.com/docs/build/semantic-models) No No No Upstream & downstream Definition|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Snapshot](https://docs.getdbt.com/docs/build/snapshots) Yes Yes Yes Upstream & downstream Applied & definition|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [Source](https://docs.getdbt.com/docs/build/sources) Yes No Yes Downstream Applied & definition|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | [Unit tests](https://docs.getdbt.com/docs/build/unit-tests) Yes Yes No Downstream Definition | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Caveats about state/metadata updates[​](#caveats-about-statemetadata-updates "Direct link to Caveats about state/metadata updates")

Over time, Cloud Artifacts will provide information to maintain state for features/services in dbt and enable you to access state in dbt and its downstream ecosystem. Cloud Artifacts is currently focused on the latest production state, but this focus will evolve.

Here are some limitations of the state representation in the Discovery API:

* Users must access the default production environment to know the latest state of a project.
* The API gets the definition from the latest manifest generated in a given deployment environment, but that often won’t reflect the latest project code state.
* Compiled code results may be outdated depending on dbt run step order and failures.
* Catalog info can be outdated, or incomplete (in the applied state), based on if/when `docs generate` was last run.
* Source freshness checks can be out of date (in the applied state) depending on when the command was last run, and it’s not included in `build`.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Uses and examples](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-use-cases-and-examples)[Next

Query the Discovery API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-querying)

* [Definition (logical) vs. applied state of dbt nodes](#definition-logical-vs-applied-state-of-dbt-nodes)* [Affected states by node type](#affected-states-by-node-type)* [Caveats about state/metadata updates](#caveats-about-statemetadata-updates)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-cloud-apis/project-state.md)
