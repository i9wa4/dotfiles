---
title: "Migrate from dbt-spark to dbt-databricks | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/migrate-from-spark-to-databricks"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fmigrate-from-spark-to-databricks+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fmigrate-from-spark-to-databricks+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fmigrate-from-spark-to-databricks+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

Migration

dbt Core

dbt platform

Intermediate

Menu

## Introduction[​](#introduction "Direct link to Introduction")

You can migrate your projects from using the `dbt-spark` adapter to using the [dbt-databricks adapter](https://github.com/databricks/dbt-databricks). In collaboration with dbt Labs, Databricks built this adapter using dbt-spark as the foundation and added some critical improvements. With it, you get an easier set up — requiring only three inputs for authentication — and more features such as support for [Unity Catalog](https://www.databricks.com/product/unity-catalog).

### Prerequisite[​](#prerequisite "Direct link to Prerequisite")

* For dbt, you need administrative (admin) privileges to migrate dbt projects.

### Simpler authentication[​](#simpler-authentication "Direct link to Simpler authentication")

Previously, you had to provide a `cluster` or `endpoint` ID which was hard to parse from the `http_path` that you were given. Now, it doesn't matter if you're using a cluster or an SQL endpoint because the [dbt-databricks setup](https://docs.getdbt.com/docs/core/connect-data-platform/databricks-setup) requires the *same* inputs for both. All you need to provide is:

* hostname of the Databricks workspace
* HTTP path of the Databricks SQL warehouse or cluster
* appropriate credentials

### Better defaults[​](#better-defaults "Direct link to Better defaults")

The `dbt-databricks` adapter provides better defaults than `dbt-spark` does. The defaults help optimize your workflow so you can get the fast performance and cost-effectiveness of Databricks. They are:

* The dbt models use the [Delta](https://docs.databricks.com/delta/index.html) table format. You can remove any declared configurations of `file_format = 'delta'` since they're now redundant.
* Accelerate your expensive queries with the [Photon engine](https://docs.databricks.com/runtime/photon.html).
* The `incremental_strategy` config is set to `merge`.

With dbt-spark, however, the default for `incremental_strategy` is `append`. If you want to continue using `incremental_strategy=append`, you must set this config specifically on your incremental models. If you already specified `incremental_strategy=merge` on your incremental models, you don't need to change anything when moving to dbt-databricks; but, you can keep your models clean (tidy) by removing the config since it's redundant. Read [About incremental\_strategy](https://docs.getdbt.com/docs/build/incremental-strategy) to learn more.

For more information on defaults, see [Caveats](https://docs.getdbt.com/docs/core/connect-data-platform/databricks-setup#caveats).

### Pure Python[​](#pure-python "Direct link to Pure Python")

If you use dbt Core, you no longer have to download an independent driver to interact with Databricks. The connection information is all embedded in a pure-Python library called `databricks-sql-connector`.

## Migrate your dbt projects in dbt[​](#migrate-your-dbt-projects-in-dbt "Direct link to Migrate your dbt projects in dbt")

You can migrate your projects to the Databricks-specific adapter from the generic Apache Spark adapter. If you're using dbt Core, then skip to Step 4.

The migration to the `dbt-databricks` adapter from `dbt-spark` shouldn't cause any downtime for production jobs. dbt Labs recommends that you schedule the connection change when usage of the IDE is light to avoid disrupting your team.

To update your Databricks connection in dbt:

1. Select **Account Settings** in the main navigation bar.
2. On the **Projects** tab, find the project you want to migrate to the dbt-databricks adapter.
3. Click the hyperlinked Connection for the project.
4. Click **Edit** in the top right corner.
5. Select **Databricks** for the warehouse
6. Enter the:
   1. `hostname`
   2. `http_path`
   3. (optional) catalog name
7. Click **Save**.

Everyone in your organization who uses dbt must refresh the Studio IDE before starting work again. It should refresh in less than a minute.

## Configure your credentials[​](#configure-your-credentials "Direct link to Configure your credentials")

When you update the Databricks connection in dbt, your team will not lose their credentials. This makes migrating easier since it only requires you to delete the Databricks connection and re-add the cluster or endpoint information.

These credentials will not get lost when there's a successful connection to Databricks using the `dbt-spark` ODBC method:

* The credentials you supplied to dbt to connect to your Databricks workspace.
* The personal access tokens your team added in their dbt profile so they can develop in the Studio IDE for a given project.
* The access token you added for each deployment environment so dbt can connect to Databricks during production jobs.

## Migrate dbt projects in dbt Core[​](#migrate-dbt-projects-in-dbt-core "Direct link to Migrate dbt projects in dbt Core")

To migrate your dbt Core projects to the `dbt-databricks` adapter from `dbt-spark`, you:

1. Install the [dbt-databricks adapter](https://github.com/databricks/dbt-databricks) in your environment
2. Update your Databricks connection by modifying your `target` in your `~/.dbt/profiles.yml` file

Anyone who's using your project must also make these changes in their environment.

## Try these examples[​](#try-these-examples "Direct link to Try these examples")

You can use the following examples of the `profiles.yml` file to see the authentication setup with `dbt-spark` compared to the simpler setup with `dbt-databricks` when connecting to an SQL endpoint. A cluster example would look similar.

An example of what authentication looks like with `dbt-spark`:

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: spark
      method: odbc
      driver: '/opt/simba/spark/lib/64/libsparkodbc_sb64.so'
      schema: my_schema
      host: dbc-l33t-nwb.cloud.databricks.com
      endpoint: 8657cad335ae63e3
      token: [my_secret_token]
```

An example of how much simpler authentication is with `dbt-databricks`:

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: databricks
      schema: my_schema
      host:  dbc-l33t-nwb.cloud.databricks.com
      http_path: /sql/1.0/endpoints/8657cad335ae63e3
      token: [my_secret_token]
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
