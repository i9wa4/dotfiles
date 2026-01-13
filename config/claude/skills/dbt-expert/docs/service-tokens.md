---
title: "Service account tokens | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [API Access](https://docs.getdbt.com/docs/dbt-cloud-apis/authentication)* Service account tokens

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fservice-tokens+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fservice-tokens+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-cloud-apis%2Fservice-tokens+so+I+can+ask+questions+about+it.)

On this page

Service account tokens enable you to securely authenticate with the dbt API by assigning each token a narrow set of permissions that more precisely manages access to the API. While similar to [personal access tokens](https://docs.getdbt.com/docs/dbt-cloud-apis/user-tokens), service account tokens belong to an account rather than a user.

You can use service account tokens for system-level integrations that do not run on behalf of any one user. Assign any permission sets available in dbt to your service account token, which can vary slightly depending on your plan:

* Enterprise and Enterprise+ plans can apply any permission sets available to service tokens.
* Developer and Starter plans can apply Semantic Layer permissions set to service tokens.
* Legacy Team plans can apply Account Admin, Member, Job Admin, Read-Only, Metadata, and Semantic Layer permissions set to service tokens.

You can assign as many permission sets as needed to one token. For more on permissions sets, see "[Enterprise Permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions)."

## Generate service account tokens[​](#generate-service-account-tokens "Direct link to Generate service account tokens")

You can generate service tokens if you have a Developer [license](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users) and account admin [permissions](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#permission-sets). To create a service token in dbt, follow these steps:

1. From dbt, click on your account name in the left side menu and select **Account settings**.
2. On the left sidebar, click on **Service Tokens**.
3. Click the **+ New Token** button to generate a new token.
4. Once the token is generated, you won't be able to view this token again so make sure to save it somewhere safe.

## Permissions for service account tokens[​](#permissions-for-service-account-tokens "Direct link to Permissions for service account tokens")

You can assign service account tokens to any permission set available in dbt. When you assign a permission set to a token, you will also be able to choose whether to grant those permissions to all projects in the account or to specific projects.

### Team plans using service account tokens[​](#team-plans-using-service-account-tokens "Direct link to Team plans using service account tokens")

The following permissions can be assigned to a service account token on a Team plan. Refer to [Enterprise permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) for more information about these roles.

* Account Admin — Account Admin service tokens have full `read + write` access to an account, so please use them with caution. A Team plan refers to this permission set as an "Owner role."
* Billing Admin
* Job Admin
* Metadata Only
* Member
* Read-only
* Semantic Layer Only

### Enterprise plans using service account tokens[​](#enterprise-plans-using-service-account-tokens "Direct link to Enterprise plans using service account tokens")

Refer to [Enterprise permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) for more information about these roles.

* Account Admin — Account Admin service tokens have full `read + write` access to an account, so please use them with caution.
* Account Viewer
* Admin
* Analyst
* Billing Admin
* Database Admin
* Developer
* Git Admin
* Job Admin
* Job Runner
* Job Viewer
* Manage marketplace apps
* Metadata Only
* Semantic Layer Only
* Security Admin
* Stakeholder
* Team Admin

## Service token update[​](#service-token-update "Direct link to Service token update")

On July 18, 2023, dbt Labs changed how tokens are generated and validated to increase performance. These improvements only apply to tokens created after July 18, 2023.

Old tokens remain valid, but if they are used in high-frequency API invocations, we recommend you rotate them for reduced latency.

To rotate your token:

1. Navigate to **Account settings** and click **Service tokens** on the left side pane.
2. Verify the **Created** date for the token is *on or before* July 18, 2023.
3. Click **+ New Token** on the top right side of the screen. Ensure the new token has the same permissions as the old one.
4. Copy the new token and replace the old one in your systems. Store it in a safe place, as it will not be available again once the creation screen is closed.
5. Delete the old token in dbt by clicking the **trash can icon**. *Only take this action after the new token is in place to avoid service disruptions*.

## FAQs[​](#faqs "Direct link to FAQs")

I'm receiving a 403 error 'Forbidden: Access denied' when using service tokens

All [service token](https://docs.getdbt.com/docs/dbt-cloud-apis/service-tokens) traffic is subject to IP restrictions.

When using a service token, the following 403 response error indicates the IP is not on the allowlist. To resolve this, you should add your third-party integration CIDRs (network addresses) to your allowlist.

The following is an example of the 403 response error:

```
        {
            "status": {
                "code": 403,
                "is_success": False,
                "user_message": ("Forbidden: Access denied"),
                "developer_message": None,
            },
            "data": {
                "account_id": <account_id>,
                "user_id": <user_id>,
                "is_service_token": <boolean describing if it's a service token request>,
                "account_access_denied": True,
            },
        }
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Personal access tokens](https://docs.getdbt.com/docs/dbt-cloud-apis/user-tokens)[Next

dbt Administrative API](https://docs.getdbt.com/docs/dbt-cloud-apis/admin-cloud-api)

* [Generate service account tokens](#generate-service-account-tokens)* [Permissions for service account tokens](#permissions-for-service-account-tokens)
    + [Team plans using service account tokens](#team-plans-using-service-account-tokens)+ [Enterprise plans using service account tokens](#enterprise-plans-using-service-account-tokens)* [Service token update](#service-token-update)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-cloud-apis/service-tokens.md)
