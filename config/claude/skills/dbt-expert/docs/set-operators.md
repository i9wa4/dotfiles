---
title: "Set operators | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/node-selection/set-operators"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [Node selection](https://docs.getdbt.com/reference/node-selection/syntax)* Set operators

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fnode-selection%2Fset-operators+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fnode-selection%2Fset-operators+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fnode-selection%2Fset-operators+so+I+can+ask+questions+about+it.)

On this page

### Unions[​](#unions "Direct link to Unions")

Providing multiple space-delineated arguments to the `--select` or `--exclude` flags selects
the union of them all. If a resource is included in at least one selector, it will be
included in the final set.

Run snowplow\_sessions, all ancestors of snowplow\_sessions, fct\_orders, and all ancestors of fct\_orders:

```
dbt run --select "+snowplow_sessions +fct_orders"
```

### Intersections[​](#intersections "Direct link to Intersections")

If you separate multiple arguments for `--select` and `--exclude` with commas and no whitespace in between, dbt will select only resources that satisfy *all* arguments.

Run all the common ancestors of snowplow\_sessions and fct\_orders:

```
dbt run --select "+snowplow_sessions,+fct_orders"
```

Run all the common descendents of stg\_invoices and stg\_accounts:

```
dbt run --select "stg_invoices+,stg_accounts+"
```

Run models that are in the marts/finance subdirectory *and* tagged nightly:

```
dbt run --select "marts.finance,tag:nightly"
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Graph operators](https://docs.getdbt.com/reference/node-selection/graph-operators)[Next

Node selector methods](https://docs.getdbt.com/reference/node-selection/methods)

* [Unions](#unions)* [Intersections](#intersections)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/node-selection/set-operators.md)
