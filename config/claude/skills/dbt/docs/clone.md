---
title: "About dbt clone command | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/commands/clone"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [List of commands](https://docs.getdbt.com/category/list-of-commands)* clone

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fclone+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fclone+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fclone+so+I+can+ask+questions+about+it.)

On this page

The `dbt clone` command clones selected nodes from the [specified state](https://docs.getdbt.com/reference/node-selection/syntax#establishing-state) to the target schema(s). This command makes use of the `clone` materialization:

* If your data platform supports zero-copy cloning of tables (Snowflake, Databricks, or BigQuery), and this model exists as a table in the source environment, dbt will create it in your target environment as a clone.
* Otherwise, dbt will create a simple pointer view (`select * from` the source object)
* By default, `dbt clone` will not recreate pre-existing relations in the current target. To override this, use the `--full-refresh` flag.
* You may want to specify a higher number of [threads](https://docs.getdbt.com/docs/running-a-dbt-project/using-threads) to decrease execution time since individual clone statements are independent of one another.

The `clone` command is useful for:

* blue/green continuous deployment (on data warehouses that support zero-copy cloning tables)
* cloning current production state into development schema(s)
* handling incremental models in dbt CI jobs (on data warehouses that support zero-copy cloning tables)
* testing code changes on downstream dependencies in your BI tool

```
# clone all of my models from specified state to my target schema(s)
dbt clone --state path/to/artifacts

# clone one_specific_model of my models from specified state to my target schema(s)
dbt clone --select "one_specific_model" --state path/to/artifacts

# clone all of my models from specified state to my target schema(s) and recreate all pre-existing relations in the current target
dbt clone --state path/to/artifacts --full-refresh

# clone all of my models from specified state to my target schema(s), running up to 50 clone statements in parallel
dbt clone --state path/to/artifacts --threads 50
```

### When to use `dbt clone` instead of [deferral](https://docs.getdbt.com/reference/node-selection/defer)?[​](#when-to-use-dbt-clone-instead-of-deferral "Direct link to when-to-use-dbt-clone-instead-of-deferral")

Unlike deferral, `dbt clone` requires some compute and creation of additional objects in your data warehouse. In many cases, deferral is a cheaper and simpler alternative to `dbt clone`. However, `dbt clone` covers additional use cases where deferral may not be possible.

For example, by creating actual data warehouse objects, `dbt clone` allows you to test out your code changes on downstream dependencies *outside of dbt* (such as a BI tool).

As another example, you could `clone` your modified incremental models as the first step of your dbt CI job to prevent costly `full-refresh` builds for warehouses that support zero-copy cloning.

## Cloning in dbt[​](#cloning-in-dbt "Direct link to Cloning in dbt")

You can clone nodes between states in dbt using the `dbt clone` command. This is available in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) and the [Cloud CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation) and relies on the [`--defer`](https://docs.getdbt.com/reference/node-selection/defer) feature. For more details on defer in dbt, read [Using defer in dbt](https://docs.getdbt.com/docs/cloud/about-cloud-develop-defer).

* **Using Cloud CLI** — The `dbt clone` command in the Cloud CLI automatically includes the `--defer` flag. This means you can use the `dbt clone` command without any additional setup.
* **Using Studio IDE** — To use the `dbt clone` command in the Studio IDE, follow these steps before running the `dbt clone` command:

  + Set up your **Production environment** and have a successful job run.
  + Enable **Defer to production** by toggling the switch in the lower-right corner of the command bar.

    [![Select the 'Defer to production' toggle on the bottom right of the command bar to enable defer in the Studio IDE.](https://docs.getdbt.com/img/docs/dbt-cloud/defer-toggle.png?v=2 "Select the 'Defer to production' toggle on the bottom right of the command bar to enable defer in the Studio IDE.")](#)Select the 'Defer to production' toggle on the bottom right of the command bar to enable defer in the Studio IDE.
  + Run the `dbt clone` command from the command bar.

Check out [this Developer blog post](https://docs.getdbt.com/blog/to-defer-or-to-clone) for more details on best practices when to use `dbt clone` vs. deferral.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

clean](https://docs.getdbt.com/reference/commands/clean)[Next

docs](https://docs.getdbt.com/reference/commands/cmd-docs)

* [When to use `dbt clone` instead of deferral?](#when-to-use-dbt-clone-instead-of-deferral)* [Cloning in dbt](#cloning-in-dbt)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/commands/clone.md)
