---
title: "Other artifact files | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/artifacts/other-artifacts"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt Artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts)* Other artifacts

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fartifacts%2Fother-artifacts+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fartifacts%2Fother-artifacts+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fartifacts%2Fother-artifacts+so+I+can+ask+questions+about+it.)

On this page

### index.html[​](#indexhtml "Direct link to index.html")

**Produced by:** [`docs generate`](https://docs.getdbt.com/reference/commands/cmd-docs)

This file is the skeleton of the [auto-generated dbt documentation website](https://docs.getdbt.com/docs/explore/build-and-view-your-docs). The contents of the site are populated by the [manifest](https://docs.getdbt.com/reference/artifacts/manifest-json) and [catalog](https://docs.getdbt.com/reference/artifacts/catalog-json).

Note: the source code for `index.json` comes from the [dbt-docs repo](https://github.com/dbt-labs/dbt-docs). Head over there if you want to make a bug report, suggestion, or contribution relating to the documentation site.

### partial\_parse.msgpack[​](#partial_parsemsgpack "Direct link to partial_parse.msgpack")

**Produced by:** [manifest commands](https://docs.getdbt.com/reference/artifacts/manifest-json) + [`parse`](https://docs.getdbt.com/reference/commands/parse)

This file is used to store a compressed representation of files dbt has parsed. If you have [partial parsing](https://docs.getdbt.com/reference/parsing#partial-parsing) enabled, dbt will use this file to identify the files that have changed and avoid re-parsing the rest.

### graph.gpickle[​](#graphgpickle "Direct link to graph.gpickle")

**Produced by:** commands supporting [node selection](https://docs.getdbt.com/reference/node-selection/syntax)

Stores the network representation of the dbt resource DAG.

### graph\_summary.json[​](#graph_summaryjson "Direct link to graph_summary.json")

**Produced by:** [manifest commands](https://docs.getdbt.com/reference/artifacts/manifest-json)

This file is useful for investigating performance issues in dbt Core's graph algorithms.

It is more anonymized and compact than [`manifest.json`](https://docs.getdbt.com/reference/artifacts/manifest-json) and [`graph.gpickle`](#graph.gpickle).

It includes that information at two separate points in time:

1. `linked` — immediately after the graph is linked together, and
2. `with_test_edges` — after test edges have been added.

Each of those points in time contains the `name` and `type` of each node and `succ` contains the keys of its child nodes.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Semantic manifest](https://docs.getdbt.com/reference/artifacts/sl-manifest)[Next

About database permissions](https://docs.getdbt.com/reference/database-permissions/about-database-permissions)

* [index.html](#indexhtml)* [partial\_parse.msgpack](#partial_parsemsgpack)* [graph.gpickle](#graphgpickle)* [graph\_summary.json](#graph_summaryjson)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/artifacts/other-artifacts.md)
