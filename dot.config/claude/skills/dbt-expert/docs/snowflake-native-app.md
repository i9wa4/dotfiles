---
title: "About the dbt Snowflake Native App | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud-integrations/snowflake-native-app"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt integrations](https://docs.getdbt.com/docs/cloud-integrations/overview)* Snowflake Native App

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fsnowflake-native-app+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fsnowflake-native-app+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud-integrations%2Fsnowflake-native-app+so+I+can+ask+questions+about+it.)

On this page

The dbt Snowflake Native App — powered by the Snowflake Native App Framework and Snowpark Container Services — extends your dbt experience into the Snowflake user interface. You'll be able to access these three experiences with your Snowflake login:

* **Catalog** — An embedded version of [Catalog](https://docs.getdbt.com/docs/explore/explore-projects)
* **Ask dbt** — A dbt-assisted chatbot, powered by [Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl), OpenAI, and Snowflake Cortex
* **Orchestration observability** — A view into the [job run history](https://docs.getdbt.com/docs/deploy/run-visibility) and sample code to create Snowflake tasks that trigger [deploy jobs](https://docs.getdbt.com/docs/deploy/deploy-jobs).

These experiences enable you to extend what's been built with dbt to users who have traditionally worked downstream from the dbt project, such as BI analysts and technical stakeholders.

For installation instructions, refer to [Set up the dbt Snowflake Native App](https://docs.getdbt.com/docs/cloud-integrations/set-up-snowflake-native-app).

## Architecture[​](#architecture "Direct link to Architecture")

There are three tools connected to the operation of the dbt Snowflake Native App:

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Tool Description|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Consumer’s Snowflake account The location of where the Native App is installed, powered by Snowpark Container Services.    The Native App makes calls to the dbt APIs and Datadog APIs (for logging) using [Snowflake's external network access](https://docs.snowflake.com/en/developer-guide/external-network-access/external-network-access-overview).   To power the **Ask dbt** chatbot, the Semantic Layer accesses the Cortex LLM to execute queries and generate text based on the prompt. This is configured when the user sets up the Semantic Layer environment.| dbt product Snowflake account The location of where the Native App application package is hosted and then distributed into the consumer account.   The consumer's event table is shared to this account for application monitoring and logging.| Consumer’s dbt account The Native App interacts with the dbt APIs for metadata and processing Semantic Layer queries to power the Native App experiences.     The dbt account also calls the consumer Snowflake account to utilize the warehouse to execute dbt queries for orchestration and the Cortex LLM Arctic to power the **Ask dbt** chatbot. | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

The following diagram provides an illustration of the architecture:

[![Architecture of dbt and Snowflake integration](https://docs.getdbt.com/img/docs/cloud-integrations/architecture-dbt-snowflake-native-app.png?v=2 "Architecture of dbt and Snowflake integration")](#)Architecture of dbt and Snowflake integration

## Access[​](#access "Direct link to Access")

Log in to the dbt Snowflake Native App using your regular Snowflake login authentication method. The Snowflake user must have a corresponding dbt user with a *[developer license](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users)*. Previously, this wasn't a requirement during the feature [Preview](https://docs.getdbt.com/docs/dbt-versions/product-lifecycles#dbt-cloud).

If your Snowflake Native App is already configured, you will be prompted to [link credentials](#link-credentials) the next time you access dbt from the app. This is a one-time process.

## Procurement[​](#procurement "Direct link to Procurement")

The dbt Snowflake Native App is available on the [Snowflake Marketplace](https://app.snowflake.com/marketplace/listing/GZTYZSRT2UA/dbt-labs-dbt). Purchasing it includes access to the Native App and a dbt account that's on the Enterprise-tier plan. Existing dbt Enterprise customers can also access it. If interested, contact your Enterprise account manager.

If you're interested, please [contact us](mailto:sales_snowflake_marketplace@dbtlabs.com) for more information.

## Support[​](#support "Direct link to Support")

If you have any questions about the dbt Snowflake Native App, you may [contact our Support team](mailto:dbt-snowflake-marketplace@dbtlabs.com) for help. Please provide information about your installation of the Native App, including your dbt account ID and Snowflake account identifier.

## Limitations[​](#limitations "Direct link to Limitations")

* The Native app does not support dbt accounts with [IP Restrictions](https://docs.getdbt.com/docs/cloud/secure/ip-restrictions) enabled.

## Link credentials[​](#link-credentials "Direct link to Link credentials")

Every Snowflake user accessing the Native app must also have dbt account access with a [developer or read-only license](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users). Feature access will be dependent on their dbt license type.

For existing accounts with the Snowflake Native App configured, users will be prompted to authenticate with dbt the next time they log in. This is a one-time process if they have a user in dbt. If they don’t have a dbt user, they will be denied access, and an admin will need to [create one](https://docs.getdbt.com/docs/cloud/manage-access/invite-users).

1. When you attempt to access the dbt platform from the Snowflake Native App, you will be prompted to link your account.
2. Click **Link account** and you will be prompted for your dbt credentials.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

* [Architecture](#architecture)* [Access](#access)* [Procurement](#procurement)* [Support](#support)* [Limitations](#limitations)* [Link credentials](#link-credentials)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud-integrations/about-snowflake-native-app.md)
