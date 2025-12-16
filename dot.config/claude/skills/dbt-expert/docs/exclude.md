---
title: "Exclude models from your run | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/node-selection/exclude"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [Node selection](https://docs.getdbt.com/reference/node-selection/syntax)* Exclude

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fnode-selection%2Fexclude+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fnode-selection%2Fexclude+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fnode-selection%2Fexclude+so+I+can+ask+questions+about+it.)

On this page

### Excluding models[​](#excluding-models "Direct link to Excluding models")

dbt provides an `--exclude` flag with the same semantics as `--select`. Models specified with the `--exclude` flag will be removed from the set of models selected with `--select`.

```
dbt run --select "my_package".*+ --exclude "my_package.a_big_model+"    # select all models in my_package and their children except a_big_model and its children
```

Exclude a specific resource by its name or lineage:

```
# test
dbt test --exclude "not_null_orders_order_id"   # test all models except the not_null_orders_order_id test
dbt test --exclude "orders"                     # test all models except tests associated with the orders model

# seed
dbt seed --exclude "account_parent_mappings"    # load all seeds except account_parent_mappings

# snapshot
dbt snapshot --exclude "snap_order_statuses"    # execute all snapshots except snap_order_statuses
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Syntax overview](https://docs.getdbt.com/reference/node-selection/syntax)[Next

Defer](https://docs.getdbt.com/reference/node-selection/defer)

* [Excluding models](#excluding-models)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/node-selection/exclude.md)
