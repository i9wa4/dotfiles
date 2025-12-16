---
title: "dbt release notes | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-versions/dbt-cloud-release-notes"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * dbt release notes

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fdbt-cloud-release-notes+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fdbt-cloud-release-notes+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Fdbt-cloud-release-notes+so+I+can+ask+questions+about+it.)

On this page

dbt release notes for recent and historical changes. Release notes fall into one of the following categories:

* **New:** New products and features
* **Enhancement:** Performance improvements and feature enhancements
* **Fix:** Bug and security fixes
* **Behavior change:** A change to existing behavior that doesn't fit into the other categories, such as feature deprecations or changes to default settings

Release notes are grouped by month for both multi-tenant and virtual private cloud (VPC) environments.

## December 2025[​](#december-2025 "Direct link to December 2025")

* **Enhancement**: For users in the default region (`US1`) that previously created a dbt account in the past, the dbt VS Code extension now supports registering with OAuth . This makes it easier to register the extension for users who may have forgotten their password or are locked out of their account. For more information, see [Register the extension](https://docs.getdbt.com/docs/install-dbt-extension#register-the-extension).
* **New and enhancements:** The dbt [Studio IDE user interface](https://docs.getdbt.com/docs/cloud/studio-ide/ide-user-interface) has been enhanced to bring more powerful development features to your fingertips:
  + A newly designed toolbar that groups all of your action and project insight tabs for easy access.
  + A dedicated inline **Commands** tab for history and logs.
  + When you upgrade your development environment to the dbt Fusion Engine, the environment includes a new **Problems** tab that gives you live error detection on issues that could block your project from running successfully.

## November 2025[​](#november-2025 "Direct link to November 2025")

* **Behavior change**: [dbt Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot) now requires all input files to use UTF-8 encoding. Files that use other encodings will return an error. If you're working with legacy files that use a different encoding, convert them to UTF-8 before using Copilot.
* **Enhancement**: dbt Copilot now has improved reliability when working with OpenAI. This includes longer timeouts, better retry behavior, and improved handling of reasoning messages for long code generations, resulting in fewer failures and more successful completions.
* **New**: The Snowflake adapter now supports basic table materialization on Iceberg tables registered in a Glue catalog through a [catalog-linked database](https://docs.snowflake.com/en/user-guide/tables-iceberg-catalog-linked-database#label-catalog-linked-db-create). For more information, see [Glue Data Catalog](https://docs.getdbt.com/docs/mesh/iceberg/snowflake-iceberg-support#external-catalogs).
* **New**: You can use the `platform_detection_timeout_seconds` parameter to control how long the Snowflake connector waits when detecting the cloud platform where the connection is being made. For more information, see [Snowflake setup](https://docs.getdbt.com/docs/core/connect-data-platform/snowflake-setup#platform_detection_timeout_seconds).
* **New**: The `cluster_by` configuration is supported in dynamic tables. For more information, see [Dynamic table clustering](https://docs.getdbt.com/reference/resource-configs/snowflake-configs#dynamic-table-clustering).
* **New**: When jobs exceed their configured timeout, the BigQuery adapter sends a cancellation request to the BigQuery job. For more information, see [Connect BigQuery](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-bigquery#job-creation-timeout-seconds).

## October 2025[​](#october-2025 "Direct link to October 2025")

* **New**: The [docs.getdbt.com](http://docs.getdbt.com/) documentation site has introduced an LLM Context menu on all product documentation and guide pages. This menu provides users with quick options to interact with the current page using LLMs. You can can now:
  + Copy the page as raw Markdown — This makes it easier to reference or reuse documentation content.
  + Open the page directly in ChatGPT or Claude — This redirects you to a chat with the LLM and automatically loads a message asking it to read the page, helping you start a conversation with context from the page.

  [![LLM Context menu on documentation pages](https://docs.getdbt.com/img/llm-menu.png?v=2 "LLM Context menu on documentation pages")](#)LLM Context menu on documentation pages
* **Enhancement**: The CodeGenCodeLen feature has been re-introduced to the Studio IDE. This feature was [temporarily](#pre-coalesce) removed in the previous release due to compatibility issues.

### Coalesce 2025 announcements[​](#coalesce-2025-announcements "Direct link to Coalesce 2025 announcements")

The following features are new or enhanced as part of [dbt's Coalesce analytics engineering conference](https://coalesce.getdbt.com/event/21662b38-2c17-4c10-9dd7-964fd652ab44/summary) from October 13-16, 2025:

* **New**: The [dbt MCP server](https://docs.getdbt.com/docs/dbt-ai/about-mcp) is now generally available (GA). For more information on the dbt MCP server and dbt Agents, refer to the [Announcing dbt Agents and the remote dbt MCP Server: Trusted AI for analytics](https://www.getdbt.com/blog/dbt-agents-remote-dbt-mcp-server-trusted-ai-for-analytics) blog post.
* **Private preview**: The [dbt platform (powered by Fusion)](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#dbt-fusion-engine) is now in private preview. If you have any questions, please reach out to your account manager.
  + [About data platform connections](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections) lists all available dbt platform connections on Fusion and the supported authentication methods per connection.
* **New**: Fusion‑specific configuration is now available for BigQuery, Databricks, Redshift, and Snowflake. For more information, see [Connect Fusion to your data platform](https://docs.getdbt.com/docs/fusion/connect-data-platform-fusion/profiles.yml).
* **Alpha**: The `dbt-salesforce` adapter is available via the dbt Fusion Engine CLI. Note that this connection is in the Alpha product stage and is not production-ready. For more information, see [Salesforce Data Cloud setup](https://docs.getdbt.com/docs/fusion/connect-data-platform-fusion/salesforce-data-cloud-setup).
* **Private preview**: [State-aware orchestration](https://docs.getdbt.com/docs/deploy/state-aware-about) is now in private preview!
  + **New**: You can now [enable state-aware orchestration](https://docs.getdbt.com/docs/deploy/state-aware-setup) by selecting **Enable Fusion cost optimization features** in your job settings. Previously, you had to disable **Force node selection** to enable state-aware orchestration.
  + **Private beta**: The [Efficient Testing feature](https://docs.getdbt.com/docs/deploy/state-aware-about#efficient-testing-in-state-aware-orchestration) is now available in private beta. This feature reduces warehouse costs by avoiding redundant data tests and combining multiple tests in a single query.
  + **New**: To improve visibility into state‑aware orchestration and provide better control when you need to reset cached state, the following [UI enhancements](https://docs.getdbt.com/docs/deploy/state-aware-interface) are introduced:
    - **Models built and reused chart** on your **Account home**
    - New charts in the **Overview** section of your job that display **Recent runs**, **Total run duration**, **Models built**, and **Models reused**
    - A new structure to view logs grouped by models, with a **Reused** tab to quickly find reused models
    - **Reused** tag in **Latest status** lineage lens to see reused models in your DAG
    - **Clear cache** button on the **Environments** page to reset cached state when needed
* **New**: [dbt Insights](https://docs.getdbt.com/docs/explore/dbt-insights) is now generally available (GA)!
  + **Private beta**: The [Analyst agent](https://docs.getdbt.com/docs/explore/navigate-dbt-insights#dbt-copilot) is now available in dbt Insights. The Analyst agent is a conversational AI feature where you can ask natural language prompts and receive analysis in real-time. For more information, see [Analyze data with the Analyst agent](https://docs.getdbt.com/docs/cloud/use-dbt-copilot#analyze-data-with-the-analyst-agent).
  + **Beta**: dbt Insights now has a [Query Builder](https://docs.getdbt.com/docs/explore/navigate-dbt-insights#query-builder), where you can build SQL queries against the Semantic Layer without writing SQL code. It guides you in creating queries based on available metrics, dimensions, and entities.
  + **Enhancement**: In [dbt Insights](https://docs.getdbt.com/docs/explore/dbt-insights), projects upgraded to the [dbt Fusion Engine](https://docs.getdbt.com/docs/fusion) get [Language Server Protocol (LSP) features](https://docs.getdbt.com/docs/explore/navigate-dbt-insights#lsp-features) and their compilation running on Fusion.
* **New**: [MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow) is now developed and maintained as part of the [Open Semantic Interchange (OSI)](https://www.snowflake.com/en/blog/open-semantic-interchange-ai-standard/) initiative, and is distributed under the [Apache 2.0 license](https://github.com/dbt-labs/metricflow/blob/main/LICENSE). For more information, see the blog post about [Open sourcing MetricFlow](https://www.getdbt.com/blog/open-source-metricflow-governed-metrics).

### Pre-Coalesce[​](#pre-coalesce "Direct link to Pre-Coalesce")

* **Behavior change**: dbt platform [access URLs](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for accounts in the US multi-tenant (US MT) region are transitioning from `cloud.getdbt.com` to dedicated domains on `dbt.com` (for example, `us1.dbt.com`). Users will be automatically redirected, which means no action is required. EMEA and APAC MT accounts are not impacted by this change and will be updated by the end of November 2025.

  Organizations that use network allow-listing should add `YOUR_ACCESS_URL.dbt.com` to their allow list (for example, if your access URL is `ab123.us1.dbt.com`, add the entire domain `ab123.us1.dbt.com` to your allow list).

  All OAuth, Git, and public API integrations will continue to work with the previous domain. View the updated access URL in dbt platform's **Account settings** page.

  For questions, contact [support@getdbt.com](mailto:support@getdbt.com).
* **Enhancement**:

  + **Fusion MCP tools** — Added Fusion tools that support `compile_sql` and `get_column_lineage` (Fusion-exclusive) for both [Remote](https://docs.getdbt.com/docs/dbt-ai/about-mcp#fusion-tools-remote) and [Local](https://docs.getdbt.com/docs/dbt-ai/about-mcp#fusion-tools-local) usage. Remote Fusion tools defer to your prod environment by default (set with `x-dbt-prod-environment-id`); you can disable deferral with `x-dbt-fusion-disable-defer=true`. Refer to [set up remote MCP](https://docs.getdbt.com/docs/dbt-ai/setup-remote-mcp) for more info.
  + **Local MCP OAuth** — You can now authenticate the local dbt MCP server to the dbt platform with OAuth (supported docs for [Claude](https://docs.getdbt.com/docs/dbt-ai/integrate-mcp-claude), [Cursor](https://docs.getdbt.com/docs/dbt-ai/integrate-mcp-cursor), and [VS Code](https://docs.getdbt.com/docs/dbt-ai/integrate-mcp-vscode)), reducing local secret management and standardizing setup. Refer to [dbt platform authentication](https://docs.getdbt.com/docs/dbt-ai/setup-local-mcp#dbt-platform-authentication) for more information.
* **Behavior change**: The CodeGenCodeLens feature for creating models from your sources with a click of a button has been temporarily removed from the Studio IDE due to compatibility issues. We plan to reintroduce this feature in the near future for both the IDE and the VS Code extension.

## September 2025[​](#september-2025 "Direct link to September 2025")

* **Fix**: Improved how [MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow) handles [offset metrics](https://docs.getdbt.com/docs/build/derived) for more accurate results when querying time-based data. MetricFlow now joins data *after* aggregation when the query grain matches the offset grain. Previously, when querying offset metrics, the offset join was applied *before* aggregation, which could exclude some values from the total time period.

## August 2025[​](#august-2025 "Direct link to August 2025")

* **Fix**: Resolved a bug that caused [saved query](https://docs.getdbt.com/docs/build/saved-queries) exports to fail during `dbt build` with `Unable to get saved_query` errors.
* **New**: The Semantic Layer GraphQL API now has a [`queryRecords`](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-graphql#query-records) endpoint. With this endpoint, you can view the query history both for Insights and Semantic Layer queries.
* **Fix**: Resolved a bug that caused Semantic Layer queries with a trailing whitespace to produce an error. This issue mostly affected [Push.ai](https://docs.push.ai/data-sources/semantic-layers/dbt) users and is fixed now.
* **New**: You can now use [personal access tokens (PATs)](https://docs.getdbt.com/docs/dbt-cloud-apis/user-tokens) to authenticate in the Semantic Layer. This enables user-level authentication and reduces the need for sharing tokens between users. When you authenticate using PATs, queries are run using your personal development credentials. For more information, see [Set up the dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl).

## July 2025[​](#july-2025 "Direct link to July 2025")

* **New**: The [Tableau Cloud](https://www.tableau.com/products/cloud-bi) integration with Semantic Layer is now available. For more information, see [Tableau](https://docs.getdbt.com/docs/cloud-integrations/semantic-layer/tableau).
* **Preview**: The [Semantic Layer Power BI integration](https://docs.getdbt.com/docs/cloud-integrations/semantic-layer/power-bi) is now available in Preview.
* **Enhancement:** You can now use `limit` and `order_by` parameters when creating [saved queries](https://docs.getdbt.com/docs/build/saved-queries).
* **Enhancement:** Users assigned IT [licenses](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users) can now edit and manage [global connections settings](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections#connection-management).
* **New**: Paginated [GraphQL](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-graphql) endpoints for metadata queries in Semantic Layer are now available. This improves integration load times for large manifests. For more information, see [Metadata calls](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-graphql#metadata-calls).

## June 2025[​](#june-2025 "Direct link to June 2025")

* **New**: [System for Cross-Domain Identity Management](https://docs.getdbt.com/docs/cloud/manage-access/scim#scim-configuration-for-entra-id) (SCIM) through Microsoft Entra ID is now GA. Also available on legacy Enterprise plans.
* **Enhancement:** You can now set the [compilation environment](https://docs.getdbt.com/docs/explore/access-dbt-insights#set-jinja-environment) to control how Jinja functions are rendered in dbt Insights.
* **Beta**: The dbt Fusion engine supports the BigQuery adapter in beta.
* **New:** You can now view the history of settings changes for [projects](https://docs.getdbt.com/docs/cloud/account-settings), [environments](https://docs.getdbt.com/docs/dbt-cloud-environments), and [jobs](https://docs.getdbt.com/docs/deploy/deploy-jobs).
* **New:** Added support for the latest version of BigQuery credentials in Semantic Layer and MetricFlow.
* **New:** Snowflake External OAuth is now supported for Semantic Layer queries.
  Snowflake connections that use External OAuth for user credentials can now emit queries for Insights, Cloud CLI, and Studio IDE through the Semantic Layer Gateway. This enables secure, identity-aware access via providers like Okta or Microsoft Entra ID.
* **New:** You can now [download your managed Git repo](https://docs.getdbt.com/docs/cloud/git/managed-repository#download-managed-repository) from the dbt platform.
* **New**: The Semantic Layer now supports Trino as a data platform. For more details, see [Set up the Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl).
* **New**: The dbt Fusion engine supports Databricks in beta.
* **Enhancement**: Group owners can now specify multiple email addresses for model-level notifications, enabling broader team alerts. Previously, only a single email address was supported. Check out the [Configure groups](https://docs.getdbt.com/docs/deploy/model-notifications#configure-groups) section to learn more.
* **New**: The Semantic Layer GraphQL API now has a [`List a saved query`](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-graphql#list-a-saved-query) endpoint.

## May 2025[​](#may-2025 "Direct link to May 2025")

### 2025 dbt Launch Showcase[​](#2025-dbt-launch-showcase "Direct link to 2025 dbt Launch Showcase")

The following features are new or enhanced as part of our [dbt Launch Showcase](https://www.getdbt.com/resources/webinars/2025-dbt-cloud-launch-showcase) on May 28th, 2025:

* **New**: The dbt Fusion engine is the brand new dbt engine re-written from the ground up to provide incredible speed, cost-savings tools, and comprehensive SQL language tools. The dbt Fusion engine is now available in beta for Snowflake users.
  + Read more [about Fusion](https://docs.getdbt.com/docs/fusion).
  + Understand what actions you need to take to get your projects Fusion-ready with the [upgrade guide](https://docs.getdbt.com/docs/dbt-versions/core-upgrade/upgrading-to-fusion).
  + Begin testing today with the [quickstart guide](https://docs.getdbt.com/guides/fusion).
  + Know [where we're headed with the dbt Fusion engine](https://getdbt.com/blog/where-we-re-headed-with-the-dbt-fusion-engine).
* **New**: The dbt VS Code extension is a powerful new tool that brings the speed and productivity of the dbt Fusion engine into your Visual Studio Code editor. This is a free download that will forever change your dbt development workflows. The dbt VS Code extension is now available as beta [alongside Fusion](https://getdbt.com/blog/get-to-know-the-new-dbt-fusion-engine-and-vs-code-extension). Check out the [installation instructions](https://docs.getdbt.com/docs/install-dbt-extension) and read more [about the features](https://docs.getdbt.com/docs/about-dbt-extension) to get started enhancing your dbt workflows today!
* **New**: dbt Explorer is now Catalog! Learn more about the change [here](https://getdbt.com/blog/updated-names-for-dbt-platform-and-features).
  + dbt's Catalog, global navigation provides a search experience that lets you find dbt resources across all your projects, as well as non-dbt resources in Snowflake.
  + External metadata ingestion allows you to connect directly to your data warehouse, giving you visibility into tables, views, and other resources that aren't defined in dbt.
* **New**: [dbt Canvas is now generally available](https://getdbt.com/blog/dbt-canvas-is-ga) (GA). Canvas is the intuitive visual editing tool that enables anyone to create dbt models with an easy to understand drag-and-drop interface. Read more [about Canvas](https://docs.getdbt.com/docs/cloud/canvas) to begin empowering your teams to build more, faster!
* **New**: [State-aware orchestration](https://docs.getdbt.com/docs/deploy/state-aware-about) is now in beta! Every time a new job in Fusion runs, state-aware orchestration automatically determines which models to build by detecting changes in code or data.
* **New**: With Hybrid Projects, your organization can adopt complementary dbt Core and dbt Cloud workflows and seamlessly integrate these workflows by automatically uploading dbt Core artifacts into dbt Cloud. [Hybrid Projects](https://docs.getdbt.com/docs/deploy/hybrid-projects) is now available as a preview to [dbt Enterprise accounts](https://www.getdbt.com/pricing).
* **New**: [System for Cross-Domain Identity Management (SCIM)](https://docs.getdbt.com/docs/cloud/manage-access/scim) through Okta is now GA.
* **New**: dbt now acts as a [Model Context Protocol](https://docs.getdbt.com/docs/dbt-ai/about-mcp) (MCP) server, allowing seamless integration of AI tools with data warehouses through a standardized framework.
* **New**: The [quickstart guide for data analysts](https://docs.getdbt.com/guides/analyze-your-data) is now available. With dbt, data analysts can use built-in, AI-powered tools to build governed data models, explore how they’re built, and run their own analysis.
* **New**: You can view your [usage metering and limiting in dbt Copilot](https://docs.getdbt.com/docs/cloud/billing#dbt-copilot-usage-metering-and-limiting) on the billing page of your dbt Cloud account.
* **New**: You can use Copilot to create a `dbt-styleguide.md` for dbt projects. The generated style guide template includes SQL style guidelines, model organization and naming conventions, model configurations and testing practices, and recommendations to enforce style rules. For more information, see [Copilot style guide](https://docs.getdbt.com/docs/cloud/copilot-styleguide).
* **New**: Copilot chat is an interactive interface within the Studio IDE where you can generate SQL code from natural language prompts and ask analytics-related questions. It integrates contextual understanding of your dbt project and assists in streamlining SQL development. For more information, see [Copilot chat](https://docs.getdbt.com/docs/cloud/copilot-chat-in-studio).
* **New**: Leverage dbt Copilot to generate SQL queries in [Insights](https://docs.getdbt.com/docs/explore/dbt-insights) from natural language prompts, enabling efficient data exploration within a context-aware interface.
* **New**: The dbt platform Cost management dashboard was available as a preview for Snowflake users on Enterprise and Enterprise Plus plans. On November 25, 2025, we retired the cost management dashboard to focus on building a more scalable and integrated cost-insights experience, expected in early 2026.
* **New**: Apache Iceberg catalog integration support is now available on Snowflake and BigQuery! This is essential to making your dbt Mesh interoperable across platforms, built on Iceberg. Read more about [Iceberg](https://docs.getdbt.com/docs/mesh/iceberg/apache-iceberg-support) to begin creating Iceberg tables.
* **Update**: Product renaming and other changes. For more information, refer to [Updated names for dbt platform and features](https://getdbt.com/blog/updated-names-for-dbt-platform-and-features).
   Product names key

  + Canvas (previously Visual Editor)
  + Catalog (previously Explorer)
  + Copilot
  + Cost Management
  + dbt Fusion engine
  + Insights
  + Mesh
  + Orchestrator
  + Studio IDE (previously Cloud IDE)
  + Semantic Layer
  + Pricing plan changes. For more information, refer to [One dbt](https://www.getdbt.com/product/one-dbt).

## April 2025[​](#april-2025 "Direct link to April 2025")

* **Enhancement**: The [Python SDK](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-python) now supports lazy loading for large fields for `dimensions`, `entities`, and `measures` on `Metric` objects. For more information, see [Lazy loading for large fields](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-python#lazy-loading-for-large-fields).
* **Enhancement**: The Semantic Layer now supports SSH tunneling for [Postgres](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-postgresql-alloydb) or [Redshift](https://docs.getdbt.com/docs/cloud/connect-data-platform/connect-redshift) connections. Refer to [Set up the Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl) for more information.
* **Behavior change**: Users assigned the [`job admin` permission set](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions#job-admin) now have access to set up integrations for projects, including the [Tableau](https://docs.getdbt.com/docs/cloud-integrations/downstream-exposures-tableau) integration to populate downstream exposures.

## March 2025[​](#march-2025 "Direct link to March 2025")

* **Behavior change**: As of March 31st, 2025, dbt Core versions 1.0, 1.1, and 1.2 have been deprecated from dbt. They are no longer available to select as versions for dbt projects. Workloads currently on these versions will be automatically upgraded to v1.3, which may cause new failures.
* **Enhancement**: [Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl) users on single-tenant configurations no longer need to contact their account representative to enable this feature. Setup is now self-service and available across all tenant configurations.
* **New**: The Semantic Layer now supports Postgres as a data platform. For more details on how to set up the Semantic Layer for Postgres, see [Set up the Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl).
* **New**: New [environment variable default](https://docs.getdbt.com/docs/build/environment-variables#dbt-cloud-context) `DBT_CLOUD_INVOCATION_CONTEXT`.
* **Enhancement**: Users assigned [read-only licenses](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#licenses) are now able to view the [Deploy](https://docs.getdbt.com/docs/deploy/deployments) section of their dbt account and click into the individual sections but not edit or otherwise make any changes.

#### dbt Developer day[​](#dbt-developer-day "Direct link to dbt Developer day")

The following features are new or enhanced as part of our [dbt Developer day](https://www.getdbt.com/resources/webinars/dbt-developer-day) on March 19th and 20th, 2025:

* **New**: The [`--sample` flag](https://docs.getdbt.com/docs/build/sample-flag), now available for the `run` and `build` commands, helps reduce build times and warehouse costs by running dbt in sample mode. It generates filtered refs and sources using time-based sampling, allowing developers to validate outputs without building entire models.
* **New**: Copilot, an AI-powered assistant, is now generally available in the Cloud IDE for all dbt Enterprise accounts. Check out [Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot) for more information.

#### Also available this month[​](#also-available-this-month "Direct link to Also available this month")

* **New**: Bringing your own [Azure OpenAI key](https://docs.getdbt.com/docs/cloud/enable-dbt-copilot#bringing-your-own-openai-api-key-byok) for [Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot) is now generally available. Your organization can configure Copilot to use your own Azure OpenAI keys, giving you more control over data governance and billing.
* **New**: The Semantic Layer supports Power BI as a [partner integration](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations), available in private beta. To join the private beta, please reach out to your account representative. Check out the [Power BI](https://docs.getdbt.com/docs/cloud-integrations/semantic-layer/power-bi) integration for more information.
* **New**: [dbt release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) are Generally Available. Depending on their plan, customers may select among the Latest, Compatible, or Extended tracks to manage the update cadences for development and deployment environments.
* **New:** The dbt-native integration with Azure DevOps now supports [Entra ID service principals](https://docs.getdbt.com/docs/cloud/git/setup-service-principal). Unlike a services user, which represents a real user object in Entra ID, the service principal is a secure identity associated with your dbt app to access resources in Azure unattended. Please [migrate your service user](https://docs.getdbt.com/docs/cloud/git/setup-service-principal#migrate-to-service-principal) to a service principal for Azure DevOps as soon as possible.

## February 2025[​](#february-2025 "Direct link to February 2025")

* **Enhancement**: The [Python SDK](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-python) added a new timeout parameter to Semantic Layer client and to underlying GraphQL clients to specify timeouts. Set a timeout number or use the `total_timeout` parameter in the global `TimeoutOptions` to control connect, execute, and close timeouts granularly. `ExponentialBackoff.timeout_ms` is now deprecated.
* **New**: The [Azure DevOps](https://docs.getdbt.com/docs/cloud/git/connect-azure-devops) integration for Git now supports [Entra service principal apps](https://docs.getdbt.com/docs/cloud/git/setup-service-principal) on dbt Enterprise accounts. Microsoft is enforcing MFA across user accounts, including service users, which will impact existing app integrations. This is a phased rollout, and dbt Labs recommends [migrating to a service principal](https://docs.getdbt.com/docs/cloud/git/setup-service-principal#migrate-to-service-principal) on existing integrations once the option becomes available in your account.
* **New**: Added the `dbt invocation` command to the [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation). This command allows you to view and manage active invocations, which are long-running sessions in the dbt CLI. For more information, see [dbt invocation](https://docs.getdbt.com/reference/commands/invocation).
* **New**: Users can now switch themes directly from the user menu, available [in Preview](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles#dbt-cloud). We have added support for **Light mode** (default), **Dark mode**, and automatic theme switching based on system preferences. The selected theme is stored in the user profile and will follow users across all devices.
  + Dark mode is currently available on the Developer plan and will be available for all [plans](https://www.getdbt.com/pricing) in the future. We’ll be rolling it out gradually, so stay tuned for updates. For more information, refer to [Change your dbt theme](https://docs.getdbt.com/docs/cloud/about-cloud/change-your-dbt-cloud-theme).
* **Fix**: Semantic Layer errors in the Cloud IDE are now displayed with proper formatting, fixing an issue where newlines appeared broken or difficult to read. This fix ensures error messages are more user-friendly and easier to parse.
* **Fix**: Fixed an issue where [saved queries](https://docs.getdbt.com/docs/build/saved-queries) with no [exports](https://docs.getdbt.com/docs/build/saved-queries#configure-exports) would fail with an `UnboundLocalError`. Previously, attempting to process a saved query without any exports would cause an error due to an undefined relation variable. Exports are optional, and this fix ensures saved queries without exports don't fail.
* **New**: You can now query metric alias in Semantic Layer [GraphQL](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-graphql) and [JDBC](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-jdbc) APIs.
  + For the JDBC API, refer to [Query metric alias](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-jdbc#query-metric-alias) for more information.
  + For the GraphQL API, refer to [Query metric alias](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-graphql#query-metric-alias) for more information.
* **Enhancement**: Added support to automatically refresh access tokens when Snowflake's SSO connection expires. Previously, users would get the following error: `Connection is not available, request timed out after 30000ms` and would have to wait 10 minutes to try again.
* **Enhancement**: The [`dbt_version` format](https://docs.getdbt.com/reference/commands/version#versioning) in dbt Cloud now better aligns with [semantic versioning rules](https://semver.org/). Leading zeroes have been removed from the month and day (`YYYY.M.D+<suffix>`). For example:
  + New format: `2024.10.8+996c6a8`
  + Previous format: `2024.10.08+996c6a8`

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

* [December 2025](#december-2025)* [November 2025](#november-2025)* [October 2025](#october-2025)
      + [Coalesce 2025 announcements](#coalesce-2025-announcements)+ [Pre-Coalesce](#pre-coalesce)* [September 2025](#september-2025)* [August 2025](#august-2025)* [July 2025](#july-2025)* [June 2025](#june-2025)* [May 2025](#may-2025)
                + [2025 dbt Launch Showcase](#2025-dbt-launch-showcase)* [April 2025](#april-2025)* [March 2025](#march-2025)* [February 2025](#february-2025)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-versions/release-notes.md)
