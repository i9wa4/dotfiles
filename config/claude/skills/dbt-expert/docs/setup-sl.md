---
title: "Administer the Semantic Layer | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Use the dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl)* Configure

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fsetup-sl+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fsetup-sl+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fuse-dbt-semantic-layer%2Fsetup-sl+so+I+can+ask+questions+about+it.)

On this page

With the dbt Semantic Layer, you can centrally define business metrics, reduce code duplication and inconsistency, create self-service in downstream tools, and more. This topic shows you how to set up credentials and tokens so that other tools can query the Semantic Layer.

Not yet supported in the dbt Fusion engine

Semantic Layer is currently supported in the dbt platform for environments running versions of dbt Core. Support for environments on the dbt Fusion engine is coming soon.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* Have a dbt Starter, Enterprise, or Enterprise+ account. Available on all [tenant configurations](https://docs.getdbt.com/docs/cloud/about-cloud/tenancy).
* Ensure your production and development environments are on a [supported dbt version](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud).
* Use Snowflake, BigQuery, Databricks, Redshift, Postgres, or Trino.
* Create a successful run in the environment where you configure the Semantic Layer.
  + **Note:** Semantic Layer supports querying in Deployment environments; development querying is coming soon.
* Understand [MetricFlow's](https://docs.getdbt.com/docs/build/about-metricflow) key concepts powering the Semantic Layer.
* Note that the Semantic Layer doesn't support using [Single sign-on (SSO)](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview) for [production credentials](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens#permissions-for-service-account-tokens), though SSO is supported for development user accounts.

📹 Learn about the dbt Semantic Layer with on-demand video courses!

Explore our [dbt Semantic Layer on-demand course](https://learn.getdbt.com/courses/semantic-layer) to learn how to define and query metrics in your dbt project.

Additionally, dive into mini-courses for querying the dbt Semantic Layer in your favorite tools: [Tableau](https://courses.getdbt.com/courses/tableau-querying-the-semantic-layer), [Excel](https://learn.getdbt.com/courses/querying-the-semantic-layer-with-excel), [Hex](https://courses.getdbt.com/courses/hex-querying-the-semantic-layer), and [Mode](https://courses.getdbt.com/courses/mode-querying-the-semantic-layer).

## Administer the Semantic Layer[​](#administer-the-semantic-layer "Direct link to Administer the Semantic Layer")

You must be part of the Owner group and have the correct [license](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users) and [permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) to administer the Semantic Layer at the environment and project level.

* Enterprise+ and Enterprise plan:
  + Developer license with Account Admin permissions, or
  + Owner with a Developer license, assigned Project Creator, Database Admin, or Admin permissions.
* Starter plan: Owner with a Developer license.
* Free trial: You are on a free trial of the Starter plan as an Owner, which means you have access to the dbt Semantic Layer.

### 1. Select environment[​](#1-select-environment "Direct link to 1. Select environment")

Select the environment where you want to enable the Semantic Layer:

1. Navigate to **Account settings** in the navigation menu.
2. Under **Settings**, click **Projects** and select the specific project you want to enable the Semantic Layer for.
3. In the **Project details** page, navigate to the **Semantic Layer** section. Select **Configure Semantic Layer**.

[![Semantic Layer section in the 'Project details' page](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/new-sl-configure.png?v=2 "Semantic Layer section in the 'Project details' page")](#)Semantic Layer section in the 'Project details' page

4. In the **Set Up Semantic Layer Configuration** page, select the deployment environment you want for the Semantic Layer and click **Save**. This provides administrators with the flexibility to choose the environment where the Semantic Layer will be enabled.

[![Select the deployment environment to run your Semantic Layer against.](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/sl-select-env.png?v=2 "Select the deployment environment to run your Semantic Layer against.")](#)Select the deployment environment to run your Semantic Layer against.

### 2. Configure credentials and create tokens[​](#2-configure-credentials-and-create-tokens "Direct link to 2. Configure credentials and create tokens")

There are two options for setting up Semantic Layer using API tokens:

* [Add a credential and create service tokens](#add-a-credential-and-create-service-tokens)
* [Configure development credentials and create personal tokens](#configure-development-credentials-and-create-a-personal-token)

#### Add a credential and create service tokens[​](#add-a-credential-and-create-service-tokens "Direct link to Add a credential and create service tokens")

The first option is to use [service tokens](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens) for authentication which are tied to an underlying data platform credential that you configure. The credential configured is used to execute queries that the Semantic Layer issues against your data platform.

This credential controls the physical access to underlying data accessed by the Semantic Layer, and all access policies set in the data platform for this credential will be respected.

|  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Feature Starter plan Enterprise+ and Enterprise plan|  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Service tokens Can create multiple service tokens linked to one credential. Can use multiple credentials and link multiple service tokens to each credential. Note that you cannot link a single service token to more than one credential.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Credentials per project One credential per project. Can [add multiple](#4-add-more-credentials) credentials per project.| Link multiple service tokens to a single credential ✅ ✅ | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

*If you're on a Starter plan and need to add more credentials, consider upgrading to our [Enterprise+ or Enterprise plan](https://www.getdbt.com/contact). All Enterprise users can refer to [Add more credentials](#4-add-more-credentials) for detailed steps on adding multiple credentials.*

##### 1. Select deployment environment[​](#1--select-deployment-environment "Direct link to 1. Select deployment environment")

* After selecting the deployment environment, you should see the **Credentials & service tokens** page.
* Click the **Add Semantic Layer credential** button.

##### 2. Configure credential[​](#2-configure-credential "Direct link to 2. Configure credential")

* In the **1. Add credentials** section, enter the credentials specific to your data platform that you want the Semantic Layer to use.
* Use credentials with minimal privileges. The Semantic Layer requires read access to the schema(s) containing the dbt models used in your semantic models for downstream applications
* Use [Extended Attributes](https://docs.getdbt.com/docs/dbt-cloud-environments#extended-attributes) and [Environment Variables](https://docs.getdbt.com/docs/build/environment-variables) when connecting to the Semantic Layer. If you set a value directly in the Semantic Layer Credentials, it will have a higher priority than Extended Attributes. When using environment variables, the default value for the environment will be used.

  For example, set the warehouse by using `{{env_var('DBT_WAREHOUSE')}}` in your Semantic Layer credentials.

  Similarly, if you set the account value using `{{env_var('DBT_ACCOUNT')}}` in Extended Attributes, dbt will check both the Extended Attributes and the environment variable.

[![Add credentials and map them to a service token. ](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/sl-add-credential.png?v=2 "Add credentials and map them to a service token. ")](#)Add credentials and map them to a service token.

##### 3. Create or link service tokens[​](#3-create-or-link-service-tokens "Direct link to 3. Create or link service tokens")

* If you have permission to create service tokens, you’ll see the [**Map new service token** option](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl#map-service-tokens-to-credentials) after adding the credential. Name the token, set permissions to 'Semantic Layer Only' and 'Metadata Only', and click **Save**.
* Once the token is generated, you won't be able to view this token again, so make sure to record it somewhere safe.
* If you don’t have access to create service tokens, you’ll see a message prompting you to contact your admin to create one for you. Admins can create and link tokens as needed.

[![If you don’t have access to create service tokens, you can create a credential and contact your admin to create one for you.](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/sl-credential-no-service-token.png?v=2 "If you don’t have access to create service tokens, you can create a credential and contact your admin to create one for you.")](#)If you don’t have access to create service tokens, you can create a credential and contact your admin to create one for you.

info

* Starter plans can create multiple service tokens that link to a single underlying credential, but each project can only have one credential.
* All Enterprise plans can [add multiple credentials](#4-add-more-credentials) and map those to service tokens for tailored access.

[Book a free live demo](https://www.getdbt.com/contact) to discover the full potential of dbt Enterprise and higher plans.

#### Configure development credentials and create a personal token[​](#configure-development-credentials-and-create-a-personal-token "Direct link to Configure development credentials and create a personal token")

Using [personal access tokens (PATs)](https://docs.getdbt.com/docs/dbt-cloud-apis/user-tokens) is also a supported authentication method for the dbt Semantic Layer. This enables user-level authentication, reducing the need for sharing tokens between users. When you authenticate using PATs, queries are run using your personal development credentials.

To use PATs in Semantic Layer:

1. Configure your development credentials.
   1. Click your account name at the bottom left-hand menu and go to **Account settings** > **Credentials**.
   2. Select your project.
   3. Click **Edit**.
   4. Go to **Development credentials** and enter your details.
   5. Click **Save**.
2. [Create a personal access token](https://docs.getdbt.com/docs/dbt-cloud-apis/user-tokens). Make sure to copy the token.

You can use the generated PAT as the authentication method for Semantic Layer [APIs](https://docs.getdbt.com/docs/dbt-cloud-apis/sl-api-overview) and [integrations](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations).

### 3. View connection detail[​](#3-view-connection-detail "Direct link to 3. View connection detail")

1. Go back to the **Project details** page for connection details to connect to downstream tools.
2. Copy and share the Environment ID, service or personal token, Host, as well as the service or personal token name to the relevant teams for BI connection setup. If your tool uses the GraphQL API, save the GraphQL API host information instead of the JDBC URL.

   For info on how to connect to other integrations, refer to [Available integrations](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations).

[![After configuring, you'll be provided with the connection details to connect to you downstream tools.](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/sl-configure-example.png?v=2 "After configuring, you'll be provided with the connection details to connect to you downstream tools.")](#)After configuring, you'll be provided with the connection details to connect to you downstream tools.

### 4. Add more credentials [Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#4-add-more-credentials- "Direct link to 4-add-more-credentials-")

All dbt Enterprise plans can optionally add multiple credentials and map them to service tokens, offering more granular control and tailored access for different teams, which can then be shared to relevant teams for BI connection setup. These credentials control the physical access to underlying data accessed by the Semantic Layer.

We recommend configuring credentials and service tokens to reflect your teams and their roles. For example, create tokens or credentials that align with your team's needs, such as providing access to finance-related schemas to the Finance team.

 Considerations for linking credentials

* Admins can link multiple service tokens to a single credential within a project, but each service token can only be linked to one credential per project.
* When you send a request through the APIs, the service token of the linked credential will follow access policies of the underlying view and tables used to build your semantic layer requests.
* Use [Extended Attributes](https://docs.getdbt.com/docs/dbt-cloud-environments#extended-attributes) and [Environment Variables](https://docs.getdbt.com/docs/build/environment-variables) when connecting to the Semantic Layer. If you set a value directly in the Semantic Layer Credentials, it will have a higher priority than Extended Attributes. When using environment variables, the default value for the environment will be used.

  For example, set the warehouse by using `{{env_var('DBT_WAREHOUSE')}}` in your Semantic Layer credentials.

  Similarly, if you set the account value using `{{env_var('DBT_ACCOUNT')}}` in Extended Attributes, dbt will check both the Extended Attributes and the environment variable.

#### 1. Add more credentials[​](#1-add-more-credentials "Direct link to 1. Add more credentials")

* After configuring your environment, on the **Credentials & service tokens** page, click the **Add Semantic Layer credential** button to create multiple credentials and map them to a service token.
* In the **1. Add credentials** section, fill in the data platform's credential fields. We recommend using “read-only” credentials.

  [![Add credentials and map them to a service token. ](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/sl-add-credential.png?v=2 "Add credentials and map them to a service token. ")](#)Add credentials and map them to a service token.

#### 2. Map service tokens to credentials[​](#2-map-service-tokens-to-credentials "Direct link to 2. Map service tokens to credentials")

* In the **2. Map new service token** section, [map a service token to the credential](https://docs.getdbt.com/docs/use-dbt-semantic-layer/setup-sl#map-service-tokens-to-credentials) you configured in the previous step. dbt automatically selects the service token permission set you need (Semantic Layer Only and Metadata Only).
* To add another service token during configuration, click **Add Service Token**.
* You can link more service tokens to the same credential later on in the **Semantic Layer Configuration Details** page. To add another service token to an existing Semantic Layer configuration, click **Add service token** under the **Linked service tokens** section.
* Click **Save** to link the service token to the credential. Remember to copy and save the service token securely, as it won't be viewable again after generation.

[![Use the configuration page to manage multiple credentials or link or unlink service tokens for more granular control.](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/sl-credentials-service-token.png?v=2 "Use the configuration page to manage multiple credentials or link or unlink service tokens for more granular control.")](#)Use the configuration page to manage multiple credentials or link or unlink service tokens for more granular control.

#### 3. Delete credentials[​](#3-delete-credentials "Direct link to 3. Delete credentials")

* To delete a credential, go back to the **Credentials & service tokens** page.
* Under **Linked Service Tokens**, click **Edit** and, select **Delete Credential** to remove a credential.

  When you delete a credential, any service tokens mapped to that credential in the project will no longer work and will break for any end users.

### Delete configuration[​](#delete-configuration "Direct link to Delete configuration")

You can delete the entire Semantic Layer configuration for a project. Note that deleting the Semantic Layer configuration will remove all credentials and unlink all service tokens to the project. It will also cause all queries to the Semantic Layer to fail.

Follow these steps to delete the Semantic Layer configuration for a project:

1. Navigate to the **Project details** page.
2. In the **Semantic Layer** section, select **Delete Semantic Layer**.
3. Confirm the deletion by clicking **Yes, delete semantic layer** in the confirmation pop up.

To re-enable the dbt Semantic Layer setup in the future, you will need to recreate your setup configurations by following the [previous steps](#set-up-dbt-semantic-layer). If your semantic models and metrics are still in your project, no changes are needed. If you've removed them, you'll need to set up the YAML configs again.

[![Delete the Semantic Layer configuration for a project.](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/sl-delete-config.png?v=2 "Delete the Semantic Layer configuration for a project.")](#)Delete the Semantic Layer configuration for a project.

## Additional configuration[​](#additional-configuration "Direct link to Additional configuration")

The following are the additional flexible configurations for Semantic Layer credentials.

### Map service tokens to credentials[​](#map-service-tokens-to-credentials "Direct link to Map service tokens to credentials")

* After configuring your environment, you can map additional service tokens to the same credential if you have the required [permissions](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#permission-sets).
* Go to the **Credentials & service tokens** page and click the **+Add Service Token** button in the **Linked Service Tokens** section.
* Type the service token name and select the permission set you need (Semantic Layer Only and Metadata Only).
* Click **Save** to link the service token to the credential.
* Remember to copy and save the service token securely, as it won't be viewable again after generation.

[![Map additional service tokens to a credential.](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/sl-add-service-token.gif?v=2 "Map additional service tokens to a credential.")](#)Map additional service tokens to a credential.

### Unlink service tokens[​](#unlink-service-tokens "Direct link to Unlink service tokens")

* Unlink a service token from the credential by clicking **Unlink** under the **Linked service tokens** section. If you try to query the Semantic Layer with an unlinked credential, you'll experience an error in your BI tool because no valid token is mapped.

### Manage from service token page[​](#manage-from-service-token-page "Direct link to Manage from service token page")

**View credential from service token**

* View your Semantic Layer credential directly by navigating to the **API tokens** and then **Service tokens** page.
* Select the service token to view the credential it's linked to. This is useful if you want to know which service tokens are mapped to credentials in your project.

#### Create a new service token[​](#create-a-new-service-token "Direct link to Create a new service token")

* From the **Service tokens** page, create a new service token and map it to the credential(s) (assuming the semantic layer permission exists). This is useful if you want to create a new service token and directly map it to a credential in your project.
* Make sure to select the correct permission set for the service token (Semantic Layer Only and Metadata Only).

[![Create a new service token and map credentials directly on the separate 'Service tokens page'.](https://docs.getdbt.com/img/docs/dbt-cloud/semantic-layer/sl-create-service-token-page.png?v=2 "Create a new service token and map credentials directly on the separate 'Service tokens page'.")](#)Create a new service token and map credentials directly on the separate 'Service tokens page'.

## Next steps[​](#next-steps "Direct link to Next steps")

* Now that you've set up your credentials and tokens, start querying your metrics with the [available integrations](https://docs.getdbt.com/docs/cloud-integrations/avail-sl-integrations).
* [Optimize querying performance](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-cache) using declarative caching.
* [Validate semantic nodes in CI](https://docs.getdbt.com/docs/deploy/ci-jobs#semantic-validations-in-ci) to ensure code changes made to dbt models don't break these metrics.
* If you haven't already, learn how to [build you metrics and semantic models](https://docs.getdbt.com/docs/build/build-metrics-intro) in your development tool of choice.
* Learn about commonly asked [Semantic Layer FAQs](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-faqs).

## FAQs[​](#faqs "Direct link to FAQs")

How does caching interact with access controls?

Cached data is stored separately from the underlying models. If metrics are pulled from the cache, we don’t have the security context applied to those tables at query time.

In the future, we plan to clone credentials, identify the minimum access level needed, and apply those permissions to cached tables.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Quickstart with the dbt Semantic Layer and Snowflake](https://docs.getdbt.com/guides/sl-snowflake-qs)[Next

Semantic Layer architecture](https://docs.getdbt.com/docs/use-dbt-semantic-layer/sl-architecture)

* [Prerequisites](#prerequisites)* [Administer the Semantic Layer](#administer-the-semantic-layer)
    + [1. Select environment](#1-select-environment)+ [2. Configure credentials and create tokens](#2-configure-credentials-and-create-tokens)+ [3. View connection detail](#3-view-connection-detail)+ [4. Add more credentials](#4-add-more-credentials-) + [Delete configuration](#delete-configuration)* [Additional configuration](#additional-configuration)
      + [Map service tokens to credentials](#map-service-tokens-to-credentials)+ [Unlink service tokens](#unlink-service-tokens)+ [Manage from service token page](#manage-from-service-token-page)* [Next steps](#next-steps)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/use-dbt-semantic-layer/setup-sl.md)
