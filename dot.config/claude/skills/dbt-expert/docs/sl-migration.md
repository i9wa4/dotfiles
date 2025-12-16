---
title: "Legacy dbt Semantic Layer migration guide | dbt Developer Hub"
source_url: "https://docs.getdbt.com/guides/sl-migration"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fsl-migration+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fsl-migration+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fguides%2Fsl-migration+so+I+can+ask+questions+about+it.)

[Back to guides](https://docs.getdbt.com/guides)

Semantic Layer

Migration

Intermediate

Menu

## Introduction[​](#introduction "Direct link to Introduction")

The legacy Semantic Layer will be deprecated in H2 2023. Additionally, the `dbt_metrics` package will not be supported in dbt v1.6 and later. If you are using `dbt_metrics`, you'll need to upgrade your configurations before upgrading to v1.6. This guide is for people who have the legacy dbt Semantic Layer setup and would like to migrate to the new dbt Semantic Layer. The estimated migration time is two weeks.

## Migrate metric configs to the new spec[​](#migrate-metric-configs-to-the-new-spec "Direct link to Migrate metric configs to the new spec")

The metrics specification in dbt Core is changed in v1.6 to support the integration of MetricFlow. It's strongly recommended that you refer to [Build your metrics](https://docs.getdbt.com/docs/build/build-metrics-intro) and before getting started so you understand the core concepts of the Semantic Layer.

dbt Labs recommends completing these steps in a local dev environment (such as the [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation)) instead of the Studio IDE:

1. Create new Semantic Model configs as YAML files in your dbt project.\*
2. Upgrade the metrics configs in your project to the new spec.\*
3. Delete your old metrics file or remove the `.yml` file extension so they're ignored at parse time. Remove the `dbt-metrics` package from your project. Remove any macros that reference `dbt-metrics`, like `metrics.calculate()`. Make sure that any packages you’re using don't have references to the old metrics spec.
4. Install the [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation) to run MetricFlow commands and define your semantic model configurations.

   * If you're using dbt Core, install the [MetricFlow CLI](https://docs.getdbt.com/docs/build/metricflow-commands) with `python -m pip install "dbt-metricflow[your_adapter_name]"`. For example:

   ```
   python -m pip install "dbt-metricflow[snowflake]"
   ```

   **Note** - MetricFlow commands aren't yet supported in the Studio IDE at this time.
5. Run `dbt parse`. This parses your project and creates a `semantic_manifest.json` file in your target directory. MetricFlow needs this file to query metrics. If you make changes to your configs, you will need to parse your project again.
6. Run `mf list metrics` to view the metrics in your project.
7. Test querying a metric by running `mf query --metrics <metric_name> --group-by <dimensions_name>`. For example:

   ```
   mf query --metrics revenue --group-by metric_time
   ```
8. Run `mf validate-configs` to run semantic and warehouse validations. This ensures your configs are valid and the underlying objects exist in your warehouse.
9. Push these changes to a new branch in your repo.

`ref` not supported

The dbt Semantic Layer API doesn't support `ref` to call dbt objects. This is currently due to differences in architecture between the legacy Semantic Layer and the re-released Semantic Layer. Instead, use the complete qualified table name. If you're using dbt macros at query time to calculate your metrics, you should move those calculations into your Semantic Layer metric definitions as code.

\**To make this process easier, dbt Labs provides a [custom migration tool](https://github.com/dbt-labs/dbt-converter) that automates these steps for you. You can find installation instructions in the [README](https://github.com/dbt-labs/dbt-converter/blob/master/README.md). Derived metrics aren’t supported in the migration tool, and will have to be migrated manually.*

## Audit metric values after the migration[​](#audit-metric-values-after-the-migration "Direct link to Audit metric values after the migration")

You might need to audit metric values during the migration to ensure that the historical values of key business metrics are the same.

1. In the CLI, query the metric(s) and dimensions you want to test and include the `--explain` option. For example:

   ```
   mf query --metrics orders,revenue --group-by metric_time__month,customer_type --explain
   ```
2. Use SQL MetricFlow to create a temporary model in your project, like `tmp_orders_revenue audit.sql`. You will use this temporary model to compare against your legacy metrics.
3. If you haven’t already done so, create a model using `metrics.calculate()` for the metrics you want to compare against. For example:

   ```
   select *
   from {{ metrics.calculate(
   [metric('orders)',
   metric('revenue)'],
       grain='week',
       dimensions=['metric_time', 'customer_type'],
   ) }}
   ```
4. Run the [dbt-audit](https://github.com/dbt-labs/dbt-audit-helper) helper on both models to compare the metric values.

## Setup the Semantic Layer in a new environment[​](#setup-the-semantic-layer-in-a-new-environment "Direct link to Setup the Semantic Layer in a new environment")

This step is only relevant to users who want the legacy and new semantic layer to run in parallel for a short time. This will let you recreate content in downstream tools like Hex and Mode with minimal downtime. If you do not need to recreate assets in these tools skip to step 5.

1. Create a new deployment environment in dbt and set the dbt version to 1.6 or higher.
2. Select **Only run on a custom branch** and point to the branch that has the updated metric definition.
3. Set the deployment schema to a temporary migration schema, such as `tmp_sl_migration`. Optional, you can create a new database for the migration.
4. Create a job to parse your project, such as `dbt parse`, and run it. Make sure this job succeeds. There needs to be a successful job in your environment in order to set up the semantic layer.
5. Select **Account Settings** -> **Projects** -> **Project details** and choose **Configure the Semantic Layer**.
6. Under **Environment**, select the deployment environment you created in the previous step. Save your configuration.
7. In the **Project details** page, click **Generate service token** and grant it **Semantic Layer Only** and **Metadata Only** permissions. Save this token securely. You will need it to connect to the semantic layer.

At this point, both the new semantic layer and the old semantic layer will be running. The new semantic layer will be pointing at your migration branch with the updated metrics definitions.

## Update connection in downstream integrations[​](#update-connection-in-downstream-integrations "Direct link to Update connection in downstream integrations")

Now that your Semantic Layer is set up, you will need to update any downstream integrations that used the legacy Semantic Layer.

### Migration guide for Hex[​](#migration-guide-for-hex "Direct link to Migration guide for Hex")

To learn more about integrating with Hex, check out their [documentation](https://learn.hex.tech/docs/connect-to-data/data-connections/dbt-integration#dbt-semantic-layer-integration) for more info. Additionally, refer to [Semantic Layer cells](https://learn.hex.tech/docs/logic-cell-types/transform-cells/dbt-metrics-cells) to set up SQL cells in Hex.

1. Set up a new connection for the Semantic Layer for your account. Something to note is that your legacy connection will still work.
2. Re-create the dashboards or reports that use the legacy Semantic Layer.
3. For specific SQL syntax details, refer to [Querying the API for metric metadata](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-jdbc#querying-the-api-for-metric-metadata) to query metrics using the API.

   * **Note** — You will need to update your connection to your production environment once you merge your changes to main. Currently, this connection will be pointing at the semantic layer migration environment

### Migration guide for Mode[​](#migration-guide-for-mode "Direct link to Migration guide for Mode")

1. Set up a new connection for the semantic layer for your account. Follow [Mode's docs to setup your connection](https://mode.com/help/articles/supported-databases/#dbt-semantic-layer).
2. Re-create the dashboards or reports that use the legacy Semantic Layer.
3. For specific SQL syntax details, refer to [Querying the API for metric metadata](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-jdbc#querying-the-api-for-metric-metadata) to query metrics using the API.

## Merge your metrics migration branch to main, and upgrade your production environment to 1.6.[​](#merge-your-metrics-migration-branch-to-main-and-upgrade-your-production-environment-to-16 "Direct link to Merge your metrics migration branch to main, and upgrade your production environment to 1.6.")

1. Upgrade your production environment to 1.6 or higher.

   * **Note** — The old metrics definitions are no longer valid so your dbt jobs will not pass.
2. Merge your updated metrics definitions to main. **At this point the legacy semantic layer will no longer work.**

If you created a new environment in [Step 3](#step-3-setup-the-semantic-layer-in-a-new-environment):

3. Update your Environment in **Account Settings** -> **Project Details** -> **Edit Semantic Layer Configuration** to point to your production environment
4. Delete your migration environment. Be sure to update your connection details in any downstream tools to account for the environment change.

### Related docs[​](#related-docs "Direct link to Related docs")

* [Quickstart guide with the Semantic Layer](https://docs.getdbt.com/guides/sl-snowflake-qs)
* [Semantic Layer FAQs](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-faqs)
* [dbt metrics converter](https://github.com/dbt-labs/dbt-converter)
* [Why we're deprecating the dbt\_metrics package](https://docs.getdbt.com/blog/deprecating-dbt-metrics) blog post
* [Semantic Layer API query syntax](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-jdbc#querying-the-api-for-metric-metadata)
* [Semantic Layer on-demand course](https://learn.getdbt.com/courses/semantic-layer)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0
