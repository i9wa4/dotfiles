---
title: "Set up environment-level permissions | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/manage-access/environment-permissions-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Manage access](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access)* [Environment permissions](https://docs.getdbt.com/docs/cloud/manage-access/environment-permissions)* Set up environment-level permissions

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fenvironment-permissions-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fenvironment-permissions-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fenvironment-permissions-setup+so+I+can+ask+questions+about+it.)

On this page

To set up and configure environment-level permissions, you must have write permissions to the **Groups & Licenses** settings of your dbt account. For more information about roles and permissions, check out [User permissions and licenses](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users).

Environment-level permissions are not the same as account-level [role-based access control (RBAC)](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#role-based-access-control) and are configured separately from those workflows.

## Setup instructions[​](#setup-instructions "Direct link to Setup instructions")

In your dbt account:

1. Click your account name, above your profile icon on the left side panel. Then select **Account settings**.
2. Select **Groups & Licenses**. We recommend deleting the default `Owner`, `Member`, and `Everyone` groups and, instead, assigning users to your organizational groups to avoid granting them unnecessary elevated privileges.

   However, before deleting these groups, ensure that any existing users — including yourself — are reassigned to their appropriate organizational groups. You won’t be able to delete the `Owner` group until *at least* one user is added to another group with the account admin permission set or if there is a user with an IT license. This safety ensures that an account admin is always available to manage group changes.

[![Groups & Licenses page in dbt with the default groups highlighted.](https://docs.getdbt.com/img/docs/dbt-cloud/groups-and-licenses.png?v=2 "Groups & Licenses page in dbt with the default groups highlighted.")](#)Groups & Licenses page in dbt with the default groups highlighted.

3. Create a new or open an existing group. If it's a new group, give it a name, then scroll down to **Access & permissions**. Click **Add permission**.

[![The Access & permissions section with the Add button highlighted.](https://docs.getdbt.com/img/docs/dbt-cloud/add-permissions.png?v=2 "The Access & permissions section with the Add button highlighted.")](#)The Access & permissions section with the Add button highlighted.

4. Select the **Permission set** for the group. Only the following permissions sets can have environment-level permissions configured:

   * Database admin
   * Git admin
   * Team admin
   * Analyst
   * Developer

   Other permission sets are restricted because they have access to everything (for example, Account admin), or limitations prevent them from having write access to environments (for example, Account viewer).

   If you select a permission set that is not supported, the environment permission option will not appear.

[![The view of the permissions box if there is no option for environment permissions.](https://docs.getdbt.com/img/docs/dbt-cloud/no-option.png?v=2 "The view of the permissions box if there is no option for environment permissions.")](#)The view of the permissions box if there is no option for environment permissions.

5. Select the **Environment** for group access. The default is **All environments**, but you can select multiple. If none are selected, the group will have read-only access.

[![A list of available environments with the Staging and General boxes selected.](https://docs.getdbt.com/img/docs/dbt-cloud/environment-options.png?v=2 "A list of available environments with the Staging and General boxes selected.")](#)A list of available environments with the Staging and General boxes selected.

6. Save the Group settings. You're now setup and ready to assign users!

## User experience[​](#user-experience "Direct link to User experience")

Users with permissions to the environment will see all capabilities assigned to their role. The environment-level permissions are `write` or `read-only` access. This feature does not currently support determining which features in the environment are accessible. For more details on what can and can not be done with environment-level permissions, refer to [About environment-permissions](https://docs.getdbt.com/docs/cloud/manage-access/environment-permissions).

For example, here is an overview of the **Jobs** section of the environment page if a user has been granted access:

[![The jobs page with write access and the 'Create job' button visible .](https://docs.getdbt.com/img/docs/dbt-cloud/write-access.png?v=2 "The jobs page with write access and the 'Create job' button visible .")](#)The jobs page with write access and the 'Create job' button visible .

The same page if the user has not been granted environment-level permissions:

[![The jobs page with read-only access and the 'Create job' button is not visible .](https://docs.getdbt.com/img/docs/dbt-cloud/read-only-access.png?v=2 "The jobs page with read-only access and the 'Create job' button is not visible .")](#)The jobs page with read-only access and the 'Create job' button is not visible .

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

* [Setup instructions](#setup-instructions)* [User experience](#user-experience)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/manage-access/environment-permissions-setup.md)
