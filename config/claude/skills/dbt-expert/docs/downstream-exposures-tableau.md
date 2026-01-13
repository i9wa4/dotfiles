---
title: "Set up automatic downstream exposures | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud-integrations/downstream-exposures-tableau"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt integrations](https://docs.getdbt.com/docs/cloud-integrations/overview)* [Visualize and orchestrate exposures](https://docs.getdbt.com/docs/cloud-integrations/downstream-exposures)* Set up automatic exposures

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fdownstream-exposures-tableau+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fdownstream-exposures-tableau+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fdownstream-exposures-tableau+so+I+can+ask+questions+about+it.)

On this page

Set up and automatically populate downstream exposures for supported BI tool integrations, like Tableau. Visualize and orchestrate them through [dbt Catalog](https://docs.getdbt.com/docs/explore/explore-projects) and the [dbt job scheduler](https://docs.getdbt.com/docs/deploy/job-scheduler) for a richer experience.

As a data team, it’s critical that you have context into the downstream use cases and users of your data products. By leveraging automatic downstream [exposures](https://docs.getdbt.com/docs/build/exposures), you can:

* Gain a better understanding of how models are used in downstream analytics, improving governance and decision-making.
* Reduce incidents and optimize workflows by linking upstream models to downstream dependencies.
* Automate exposure tracking for supported BI tools, ensuring lineage is always up to date.
* [Orchestrate exposures](https://docs.getdbt.com/docs/cloud-integrations/orchestrate-exposures) to refresh the underlying data sources during scheduled dbt jobs, improving timeliness and reducing costs. Orchestrating exposures is a way to ensure that your BI tools are updated regularly using the [dbt job scheduler](https://docs.getdbt.com/docs/deploy/job-scheduler). See the [previous page](https://docs.getdbt.com/docs/cloud-integrations/downstream-exposures) for more info.

In dbt, you can configure downstream exposures in two ways:

* Manually — Declared [explicitly](https://docs.getdbt.com/docs/build/exposures#declaring-an-exposure) in your project’s YAML files.
* Automatic — dbt [creates and visualizes downstream exposures](https://docs.getdbt.com/docs/cloud-integrations/downstream-exposures) automatically for supported integrations, removing the need for manual YAML definitions. These downstream exposures are stored in dbt’s metadata system, appear in [Catalog](https://docs.getdbt.com/docs/explore/explore-projects), and behave like manual exposures. However, they don’t exist in YAML files.

Tableau Server

If you're using Tableau Server, you need to add the [dbt IP addresses for your region](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) to your allowlist.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

To configure automatic downstream exposures, you should meet the following:

1. Your environment and jobs are on a supported [dbt release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks).
2. You have a dbt account on the [Enterprise or Enterprise+ plan](https://www.getdbt.com/pricing/).
3. You have set up a [production](https://docs.getdbt.com/docs/deploy/deploy-environments#set-as-production-environment) deployment environment for each project you want to explore, with at least one successful job run.
4. You have [proper permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) to edit dbt project or production environment settings.
5. Use Tableau as your BI tool and enable metadata permissions or work with an admin to do so. Compatible with Tableau Cloud or Tableau Server with the Metadata API enabled.
6. You have configured a [Tableau personal access token (PAT)](https://help.tableau.com/current/server/en-us/security_personal_access_tokens.htm) whose creator has permission to view data sources. The PAT inherits the permissions of its creator, so ensure the Tableau user who created the token has [Connect permissions](https://help.tableau.com/current/api/rest_api/en-us/REST/rest_api_concepts_permissions.htm).

### Considerations[​](#considerations "Direct link to Considerations")

Configuring automatic downstream exposures with Tableau have the following considerations:

* You can only connect to a single Tableau site on the same server.
* If you're using Tableau Server, you need to [allowlist dbt's IP addresses](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your dbt region.
* Tableau dashboards built using custom SQL queries aren't supported.
* Downstream exposures sync automatically *once per day* or when a user updates the selected collections.
* The database fully qualified names (FQNs) in Tableau must match those in the dbt build.

  Tableau's database FQNs (fully qualified names) must match those in the dbt build. To view all expected dependencies in your exposure, the FQNs must match but aren't case-sensitive. For example:

  |  |  |  |  |  |  |  |  |  |
  | --- | --- | --- | --- | --- | --- | --- | --- | --- |
  | Tableau FQN dbt FQN Result |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `analytics.dbt_data_team.my_model` `analytics.dbt_data_team.my_model` ✅ Matches and dependencies will display as expected.|  |  |  | | --- | --- | --- | | `analytics.dbt_data_team.my_model` `prod_analytics.dbt_data_team.my_model` ❌ Doesn't match and not all expected dependencies will display. | | | | | | | | |

  |  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  ||  |  |  |  |  |
  | --- | --- | --- | --- | --- |
  | Loading table... | | | | |

  To troubleshoot this:
  1. In dbt, download the `manifest.json` from the most recent production run that includes the missing dependencies by clicking on the **Artifacts** tab and scrolling to `manifest.json`.
  2. Run the following [GraphiQl](https://help.tableau.com/current/api/metadata_api/en-us/docs/meta_api_start.html#explore-the-metadata-api-schema-using-graphiql) query. Make sure to run the query at `your_tableau_server/metadata/graphiql`, where `your_tableau_server` is the value you provided for the Server URL when [setting up your Tableau integration](https://docs.getdbt.com/docs/cloud-integrations/downstream-exposures-tableau#set-up-in-tableau):

     ```
         query {
           workbooks {
             name
             uri
             id
             luid
             projectLuid
             projectName
             upstreamTables {
               id
               name
               schema
               database {
                 name
                 connectionType
             }
           }
         }
       }
     ```
  3. Compare database FQNs between `manifest.json` and the GraphiQL response. Make sure that `{database}.{schema}.{name}` matches in both.
     The following images are examples of FQNs that *match* in both `manifest.json` and the GraphiQL response and aren't case-sensitive:

  [![manifest.json example with lowercase FQNs.](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/manifest-json-example.png?v=2 "manifest.json example with lowercase FQNs.")](#)manifest.json example with lowercase FQNs.

  [![GraphiQl response example with uppercase FQNs.](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/graphiql-example.png?v=2 "GraphiQl response example with uppercase FQNs.")](#)GraphiQl response example with uppercase FQNs.

  4. If the FQNs don't match, update your Tableau FQNs to match the dbt FQNs.
  5. If you're still experiencing issues, please contact [dbt Support](mailto:support@getdbt.com) and share the results with them.

## Set up downstream exposures[​](#set-up-downstream-exposures "Direct link to Set up downstream exposures")

Set up downstream exposures in [Tableau](#set-up-in-tableau) and [dbt](#set-up-in-dbt-cloud) to ensure that your BI tool's extracts are updated automatically.

### Set up in Tableau[​](#set-up-in-tableau "Direct link to Set up in Tableau")

This section explains the steps to configure the integration in Tableau. A Tableau site admin must complete these steps.

Once configured in both Tableau and [dbt](#set-up-in-dbt-cloud), you can [view downstream exposures](#view-downstream-exposures) in Catalog.

1. Enable [personal access tokens (PATs)](https://help.tableau.com/current/server/en-us/security_personal_access_tokens.htm) for your Tableau account.

   [![Enable PATs for the account in Tableau](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/tableau-enable-pat.jpg?v=2 "Enable PATs for the account in Tableau")](#)Enable PATs for the account in Tableau
2. Create a PAT to add to dbt to pull in Tableau metadata for the downstream exposures. When creating the token, you must have permission to access collections/folders, as the PAT only grants access matching the creator's existing privileges.

   [![Create PATs for the account in Tableau](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/tableau-create-pat.jpg?v=2 "Create PATs for the account in Tableau")](#)Create PATs for the account in Tableau
3. Copy the **Secret** and the **Token name** for use in a later step in dbt. The secret is only displayed once, so store it in a safe location (like a password manager).

   [![Copy the secret and token name to enter them in dbt](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/tableau-copy-token.jpg?v=2 "Copy the secret and token name to enter them in dbt")](#)Copy the secret and token name to enter them in dbt
4. Copy the **Server URL** and **Sitename**. You can find these in the URL while logged into Tableau.

   [![Locate the Server URL and Sitename in Tableau](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/tablueau-serverurl.jpg?v=2 "Locate the Server URL and Sitename in Tableau")](#)Locate the Server URL and Sitename in Tableau

   For example, if the full URL is: `10az.online.tableau.com/#/site/dbtlabspartner/explore`:

   * The **Server URL** is the fully qualified domain name, in this case: `10az.online.tableau.com`
   * The **Sitename** is the path fragment right after `site` in the URL, in this case: `dbtlabspartner`
5. With the following items copied, you are now ready to set up downstream exposures in dbt:

   * ServerURL
   * Sitename
   * Token name
   * Secret

### Set up in dbt[​](#set-up-in-dbt "Direct link to Set up in dbt")

1. In dbt, navigate to the **Dashboard** of the project you want to add the downstream exposure to and then select **Settings**.
2. Under the **Exposures** section, select **Add integration** to add the Tableau connection.

   [![Select Add Integration to add the Tableau connection.](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/cloud-add-integration.jpg?v=2 "Select Add Integration to add the Tableau connection.")](#)Select Add Integration to add the Tableau connection.
3. Enter the details for the exposure connection you collected from Tableau in the [previous step](#set-up-in-tableau) and click **Continue**. Note that all fields are case-sensitive.

   [![Enter the details for the exposure connection.](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/cloud-integration-details.jpg?v=2 "Enter the details for the exposure connection.")](#)Enter the details for the exposure connection.
4. Select the collections you want to include for the downstream exposures and click **Save**.

   [![Select the collections you want to include for the downstream exposures.](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/cloud-select-collections.jpg?v=2 "Select the collections you want to include for the downstream exposures.")](#)Select the collections you want to include for the downstream exposures.

   info

   dbt automatically imports and syncs any workbook within the selected collections. New additions to the collections will appear in the lineage in dbt once per day — after the daily sync and a job run.

   dbt immediately starts a sync when you update the selected collections list, capturing new workbooks and removing irrelevant ones.
5. dbt imports everything in the collection(s) and you can continue to [view them](#view-auto-exposures) in Catalog.

   [![View from the dbt Catalog in your Project lineage view, displayed with the Tableau icon.](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/explorer-lineage2.jpg?v=2 "View from the dbt Catalog in your Project lineage view, displayed with the Tableau icon.")](#)View from the dbt Catalog in your Project lineage view, displayed with the Tableau icon.

## View downstream exposures[​](#view-downstream-exposures "Direct link to View downstream exposures")

After setting up downstream exposures in dbt, you can view them in [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) for a richer experience.

Navigate to Catalog by clicking on the **Explore** link in the navigation. From the **Overview** page, you can view downstream exposures from a couple of places:

* [Exposures menu](#exposures-menu)
* [File tree](#file-tree)
* [Project lineage](#project-lineage)

### Exposures menu[​](#exposures-menu "Direct link to Exposures menu")

View downstream exposures from the **Exposures** menu item under **Resources**. This menu provides a comprehensive list of all the exposures so you can quickly access and manage them. The menu displays the following information:

* **Name**: The name of the exposure.
* **Health**: The [data health signal](https://docs.getdbt.com/docs/explore/data-health-signals) of the exposure.
* **Type**: The type of exposure, such as `dashboard` or `notebook`.
* **Owner**: The owner of the exposure.
* **Owner email**: The email address of the owner of the exposure.
* **Integration**: The BI tool that the exposure is integrated with.
* **Exposure mode**: The type of exposure defined: **Auto** or **Manual**.

[![View from the dbt Catalog under the 'Resources' menu.](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/explorer-view-resources.jpg?v=2 "View from the dbt Catalog under the 'Resources' menu.")](#)View from the dbt Catalog under the 'Resources' menu.

### File tree[​](#file-tree "Direct link to File tree")

Locate directly from within the **File tree** under the **imported\_from\_tableau** sub-folder. This view integrates exposures seamlessly with your project files, making it easy to find and reference them from your project's structure.

[![View from the dbt Catalog under the 'File tree' menu.](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/explorer-view-file-tree.jpg?v=2 "View from the dbt Catalog under the 'File tree' menu.")](#)View from the dbt Catalog under the 'File tree' menu.

### Project lineage[​](#project-lineage "Direct link to Project lineage")

From the **Project lineage** view, which visualizes the dependencies and relationships in your project. Exposures are represented with the Tableau icon, offering an intuitive way to see how they fit into your project's overall data flow.

[![View from the dbt Catalog in your Project lineage view, displayed with the Tableau icon.](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/explorer-lineage2.jpg?v=2 "View from the dbt Catalog in your Project lineage view, displayed with the Tableau icon.")](#)View from the dbt Catalog in your Project lineage view, displayed with the Tableau icon.

[![View from the dbt Catalog in your Project lineage view, displayed with the Tableau icon.](https://docs.getdbt.com/img/docs/cloud-integrations/auto-exposures/explorer-lineage.jpg?v=2 "View from the dbt Catalog in your Project lineage view, displayed with the Tableau icon.")](#)View from the dbt Catalog in your Project lineage view, displayed with the Tableau icon.

## Orchestrate exposures [Beta](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles "Go to https://docs.getdbt.com/docs/dbt-versions/product-lifecycles")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#orchestrate-exposures- "Direct link to orchestrate-exposures-")

[Orchestrate exposures](https://docs.getdbt.com/docs/cloud-integrations/orchestrate-exposures) using the dbt [Cloud job scheduler](https://docs.getdbt.com/docs/deploy/job-scheduler) to proactively refresh the underlying data sources (extracts) that power your Tableau Workbooks.

* Orchestrating exposures with a `dbt build` job ensures that downstream exposures, like Tableau extracts, are updated regularly and automatically.
* You can control the frequency of these refreshes by configuring environment variables.

To set up and proactively run exposures with the dbt job scheduler, refer to [Orchestrate exposures](https://docs.getdbt.com/docs/cloud-integrations/orchestrate-exposures).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Visualize and orchestrate downstream exposures](https://docs.getdbt.com/docs/cloud-integrations/downstream-exposures)[Next

Orchestrate exposures](https://docs.getdbt.com/docs/cloud-integrations/orchestrate-exposures)

* [Prerequisites](#prerequisites)
  + [Considerations](#considerations)* [Set up downstream exposures](#set-up-downstream-exposures)
    + [Set up in Tableau](#set-up-in-tableau)+ [Set up in dbt](#set-up-in-dbt)* [View downstream exposures](#view-downstream-exposures)
      + [Exposures menu](#exposures-menu)+ [File tree](#file-tree)+ [Project lineage](#project-lineage)* [Orchestrate exposures](#orchestrate-exposures-)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud-integrations/downstream-exposures-tableau.md)
