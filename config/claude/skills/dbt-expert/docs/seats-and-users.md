---
title: "Users and licenses | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Manage access](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access)* User permissions and licenses

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fseats-and-users+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fseats-and-users+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fseats-and-users+so+I+can+ask+questions+about+it.)

On this page

In dbt, *licenses* are used to allocate users to your account.

There are four license types in dbt:

* **Analyst** — Available on [Enterprise and Enterprise+ plans only](https://www.getdbt.com/pricing). Requires developer seat license purchase.
  + User can be granted *any* permission sets.
* **Developer** — User can be granted *any* permission sets.
* **IT** — Available on [Starter, Enterprise, and Enterprise+ plans only](https://www.getdbt.com/pricing). User has Security Admin and Billing Admin [permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions#permission-sets) applied.
  + Can manage users, groups, connections, and licenses, among other permissions.
  + *IT licensed users do not inherit rights from any permission sets*.
  + Every IT licensed user has the same access across the account, regardless of the group permissions assigned.
* **Read-Only** — Available on [Starter, Enterprise, and Enterprise+ plans only](https://www.getdbt.com/pricing).
  + User has read-only permissions applied to all dbt resources.
  + Intended to view the [artifacts](https://docs.getdbt.com/docs/deploy/artifacts) and the [deploy](https://docs.getdbt.com/docs/deploy/deployments) section (jobs, runs, schedules) in a dbt account, but can’t make changes.
  + *Read-only licensed users do not inherit rights from any permission sets*.
  + Every read-only licensed user has the same access across the account, regardless of the group permissions assigned.

The user's assigned license determines the specific capabilities they can access in dbt.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Functionality Developer or Analyst Users  Read-Only Users  IT Users\* |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Use the Studio IDE ✅ ❌ ❌|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Use the dbt CLI ✅ ❌ ❌|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Use Jobs ✅ ❌ ❌|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Manage Account ✅ ❌ ✅|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | API Access ✅ ✅ ❌|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Use [Catalog](https://docs.getdbt.com/docs/explore/explore-projects) ✅ ✅ ❌|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Use [Source Freshness](https://docs.getdbt.com/docs/deploy/source-freshness) ✅ ✅ ❌|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | Use [Docs](https://docs.getdbt.com/docs/explore/build-and-view-your-docs) ✅ ✅ ❌|  |  |  |  | | --- | --- | --- | --- | | Receive [Job notifications](https://docs.getdbt.com/docs/deploy/job-notifications) ✅ ✅ ✅ | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

\*Available on Starter, Enterprise, and Enterprise+ plans only. IT seats are limited to 1 seat per Starter or Enterprise-tier account and don't count toward seat usage.

## Licenses[​](#licenses "Direct link to Licenses")

License types override group permissions

**User license types always override their assigned group permission sets.** For example, a user with a Read-Only license cannot perform administrative actions, even if they belong to an Account Admin group.

This ensures that license restrictions are always enforced, regardless of group membership.

Each dbt plan comes with a base number of Developer, IT, and Read-Only licenses. You can add or remove licenses by modifying the number of users in your account settings.

If you have a Developer plan account and want to add more people to your team, you'll need to upgrade to the Starter plan. Refer to [dbt Pricing Plans](https://www.getdbt.com/pricing/) for more information about licenses available with each plan.

The following tabs detail steps on how to modify your user license count:

* Enterprise-tier plans* Starter plans

If you're on an Enterprise-tier plan and have the correct [permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions), you can add or remove licenses by adjusting your user seat count. Note, an IT license does not count toward seat usage.

* To remove a user, click on your account name in the left side menu, click **Account settings** and select **Users**.

  + Select the user you want to remove, click **Edit**, and then **Delete**.
  + This action cannot be undone. However, you can re-invite the user with the same info if you deleted the user in error.
* To add a user, go to **Account Settings** and select **Users**.

  + Click the [**Invite Users**](https://docs.getdbt.com/docs/cloud/manage-access/invite-users) button.
  + For fine-grained permission configuration, refer to [Role based access control](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#role-based-access-control-).

If you're on a Starter plan and have the correct [permissions](https://docs.getdbt.com/docs/cloud/manage-access/self-service-permissions), you can add or remove developers.

Refer to [Self-service Starter account permissions](https://docs.getdbt.com/docs/cloud/manage-access/self-service-permissions#licenses) for more information on the number of each license type included in the Starter plan.

You'll need to make two changes:

* Adjust your developer user seat count, which manages the users invited to your dbt project.
* Adjust your developer billing seat count, which manages the number of billable seats.

You can add or remove developers by increasing or decreasing the number of users and billable seats in your account settings:

* Adding users* Deleting users

To add a user in dbt, you must be an account owner or have admin privileges.

1. From dbt, click on your account name in the left side menu and select **Account settings**.

[![Navigate to Account settings](https://docs.getdbt.com/img/docs/dbt-cloud/Navigate-to-account-settings.png?v=2 "Navigate to Account settings")](#)Navigate to Account settings

2. In **Account Settings**, select **Billing**.
3. Under **Billing details**, enter the number of developer seats you want and make sure you fill in all the payment details, including the **Billing address** section. Leaving these blank won't allow you to save your changes.
4. Press **Update Payment Information** to save your changes.

[![Navigate to Account settings -> Billing to modify billing seat count](https://docs.getdbt.com/img/docs/dbt-cloud/faq-account-settings-billing.png?v=2 "Navigate to Account settings -> Billing to modify billing seat count")](#)Navigate to Account settings -> Billing to modify billing seat count

Now that you've updated your billing, you can now [invite users](https://docs.getdbt.com/docs/cloud/manage-access/invite-users) to join your dbt account:

Great work! After completing those these steps, your dbt user count and billing count should now be the same.

To delete a user in dbt, you must be an account owner or have admin privileges. If the user has a `developer` license type, this will open up their seat for another user or allow the admins to lower the total number of seats.

1. From dbt, click on your account name in the left side menu and select **Account settings**.

[![Navigate to Account settings](https://docs.getdbt.com/img/docs/dbt-cloud/Navigate-to-account-settings.png?v=2 "Navigate to Account settings")](#)Navigate to Account settings

2. In **Account settings**, select **Users**.
3. Select the user you want to delete, then click **Edit**.
4. Click **Delete** in the bottom left. Click **Confirm Delete** to immediately delete the user without additional password prompts. This action cannot be undone. However, you can re-invite the user with the same information if the deletion was made in error.

[![Deleting a user](https://docs.getdbt.com/img/docs/dbt-cloud/delete_user_20221023.gif?v=2 "Deleting a user")](#)Deleting a user

If you are on a **Starter** plan and you're deleting users to reduce the number of billable seats, follow these steps to lower the license count to avoid being overcharged:

1. In **Account Settings**, select **Billing**.
2. Under **Billing details**, enter the number of developer seats you want and make sure you fill in all the payment details, including the **Billing address** section. If you leave any field blank, you won't be able to save your changes.
3. Click **Update Payment Information** to save your changes.

[![The Billing** page in your **Account settings](https://docs.getdbt.com/img/docs/dbt-cloud/faq-account-settings-billing.png?v=2 "The Billing** page in your **Account settings")](#)The Billing\*\* page in your \*\*Account settings

Great work! After completing these steps, your dbt user count and billing count should now be the same.

## Managing license types[​](#managing-license-types "Direct link to Managing license types")

Licenses can be assigned to users individually or through group membership. To assign a license via group membership, you can manually add a user to a group during the invitation process or assign them to a group after they’ve enrolled in dbt. Alternatively, with [SSO configuration](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview) and [role-based access control](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access#role-based-access-control-) (Enterprise-tier only), users can be automatically assigned to groups. By default, new users in an account are assigned a Developer license.

### Manual configuration[​](#manual-configuration "Direct link to Manual configuration")

To manually assign a specific type of license to a user on your team, navigate to the **Users** page in your **Account settings** and click the **Edit** button for the user you want to manage. From this page, you can select the license type and relevant groups for the user.

**Note:** You will need to have an available license ready to allocate for the user. If your account does not have an available license to allocate, you will need to add more licenses to your plan to complete the license change.

[![Manually assigning licenses](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/license-manual.png?v=2 "Manually assigning licenses")](#)Manually assigning licenses

### Mapped configuration [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#mapped-configuration- "Direct link to mapped-configuration-")

If your account is connected to an Identity Provider (IdP) for [Single Sign On](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview), you can automatically map IdP user groups to specific groups in dbt and assign license types to those groups. To configure license mappings, navigate to the **Account Settings** > **Groups & Licenses** > **License Mappings** page. From here, you can create or edit SSO mappings for both Read-Only and Developer license types.

By default, all new members of a dbt account will be assigned a Developer
license. To assign Read-Only licenses to certain groups of users, create a new
License Mapping for the Read-Only license type and include a comma separated
list of IdP group names that should receive a Read-Only license at sign-in time.

[![Configuring IdP group license mapping](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/license-mapping.png?v=2 "Configuring IdP group license mapping")](#)Configuring IdP group license mapping

Usage notes:

* If a user's IdP groups match both a Developer and Read-Only license type
  mapping, a Developer license type will be assigned
* If a user's IdP groups do not match *any* license type mappings, a Developer
  license will be assigned
* License types are adjusted when users sign into dbt via Single Sign On.
  Changes made to license type mappings will take effect the next time users
  sign in to dbt.
* License type mappings are based on *IdP Groups*, not *dbt groups*, so be
  sure to check group memberships in your identity provider when configuring
  this feature.

## Granular permissioning[​](#granular-permissioning "Direct link to Granular permissioning")

dbt Enterprise-tier plans support role-based access controls for configuring granular in-app permissions. See [access control](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access) for more information on Enterprise permissioning.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

Enterprise permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions)

* [Licenses](#licenses)* [Managing license types](#managing-license-types)
    + [Manual configuration](#manual-configuration)+ [Mapped configuration](#mapped-configuration-)* [Granular permissioning](#granular-permissioning)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/manage-access/cloud-seats-and-users.md)
