---
title: "About user access in dbt | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/manage-access/about-user-access"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* Manage access

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fabout-user-access+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fabout-user-access+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fabout-user-access+so+I+can+ask+questions+about+it.)

On this page

"User access" is not "Model access"

This page covers user groups and access, including:

* User licenses, permissions, and group memberships
* Role-based access controls for projects and environments
* Single sign-on, and secure authentication

For model-specific access and their availability across projects, refer to [Model access](https://docs.getdbt.com/docs/mesh/govern/model-access).

You can regulate access to dbt by various measures, including licenses, groups, permissions, and role-based access control (RBAC). To understand the possible approaches to user access to dbt features and functionality, you should first know how we approach users and groups.

## Users[​](#users "Direct link to Users")

Individual users in dbt can be people you [manually invite](https://docs.getdbt.com/docs/cloud/manage-access/invite-users) or grant access via an external identity provider (IdP), such as Microsoft Entra ID, Okta, or Google Workspace.

In either scenario, when you add a user to dbt, they are assigned a [license](#licenses). You assign licenses at the individual user or group levels. When you manually invite a user, you will assign the license in the invitation window.

[![Example of the license dropdown in the user invitation window.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/license-dropdown.png?v=2 "Example of the license dropdown in the user invitation window.")](#)Example of the license dropdown in the user invitation window.

You can edit an existing user's license by navigating to the **Users** section of the **Account settings**, clicking on a user, and clicking **Edit** on the user pane. Delete users from this same window to free up licenses for new users.

[![Example of the user information window in the user directory](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/edit-user.png?v=2 "Example of the user information window in the user directory")](#)Example of the user information window in the user directory

### User passwords[​](#user-passwords "Direct link to User passwords")

By default, new users will be prompted to set a password for their account. All plan tiers support and enforce [multi-factor authentication](https://docs.getdbt.com/docs/cloud/manage-access/mfa) for users with password logins. However, they will still need to configure their password before configuring MFA. Enterprise tier accounts can configure [SSO](#sso-mappings) and advanced authentication measures. Developer and Starter plans only support user passwords with MFA.

User passwords must meet the following criteria:

* Be at least nine characters in length
* Contain at least one uppercase and one lowercase letter
* Contain at least one number 0-9
* Contain at least one special character

## Groups[​](#groups "Direct link to Groups")

Groups in dbt serve much of the same purpose as they do in traditional directory tools — to gather individual users together to make bulk assignments of permissions easier.

The permissions available depends on whether you're on an [Enterprise-tier](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) or [self-service Starter](https://docs.getdbt.com/docs/cloud/manage-access/self-service-permissions) plan.

* Admins use groups in dbt to assign [licenses](#licenses) and [permissions](#permissions).
* The permissions are more granular than licenses, and you only assign them at the group level; *you can’t assign permissions at the user level.*
* Every user in dbt must be assigned to at least one group.

There are three default groups available as soon as you create your dbt account (the person who created the account is added to all three automatically):

* **Owner:** This group is for individuals responsible for the entire account and will give them elevated account admin privileges. You cannot change the permissions.
* **Member:** This group is for the general members of your organization. Default permissions are broad, restricting only access to features that can alter billing or security. By default, dbt adds new users to this group.
* **Everyone:** A general group for all members of your organization. Customize the permissions to fit your organizational needs. By default, dbt adds new users to this group.

Default groups are automatically provisioned for all accounts to simplify the initial set up. We recommend creating your own organizational groups so you can customize the permissions. Once you create your own groups, you can delete the default groups.

### Create new groups [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#create-new-groups- "Direct link to create-new-groups-")

* Create new groups from the **Groups & Licenses** section of the **Account settings**.
* If you use an external IdP for SSO, you can sync those SSO groups to dbt from the **Group details** pane when creating or editing existing groups.

[![Example the new group pane in the account settings.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/new-group.png?v=2 "Example the new group pane in the account settings.")](#)Example the new group pane in the account settings.

important

If a user is assigned licenses and permissions from multiple groups, the group that grants the most access will take precedence. You must assign a permission set to any groups created beyond the three defaults, or users assigned will not have access to features beyond their user profile.

### Group access and permissions[​](#group-access-and-permissions "Direct link to Group access and permissions")

The **Access & Permissions** section of a group is where you can assign users the right level of access based on their role or responsibilities. You decide:

* Projects the group can access
* Roles that the group members are assigned for each
* Environments the group can edit

This setup provides you with the flexibility to determine the level of access users in any given group will have. For example, you might allow one group of analysts to edit jobs in their project, but only let them view related projects, or you could grant admin-level access to a team that owns a specific project while keeping others restricted to read-only.

[![Assign a variety of roles and access permissions to user groups.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/sample-access-policy.png?v=2 "Assign a variety of roles and access permissions to user groups.")](#)Assign a variety of roles and access permissions to user groups.

#### Environment write access[​](#environment-write-access "Direct link to Environment write access")

Some permission sets grant users read-only access to environment settings that can be overridden if you assign them to a group with **Environment write access**. They will then be able to create, edit, and delete environment settings, bypassing the read-only restriction.

In the following example, the `analyst` permission set, which by default has read-only access to jobs, is assigned to the group across all projects; however, the **Environment write access** is set to `All Environments`. This grants all users in this group the ability to create, edit, and delete jobs across all environments and projects.

[![Users assigned environment write access will be able to edit environment settings.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/environment-write.png?v=2 "Users assigned environment write access will be able to edit environment settings.")](#)Users assigned environment write access will be able to edit environment settings.

Only use **Environment write access** settings when you intend to grant users the ability to edit environments. To grant users only the permissions inherent to their set, leave this setting blank (all boxes unchecked).

### SSO mappings [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#sso-mappings- "Direct link to sso-mappings-")

SSO Mappings connect an identity provider (IdP) group membership to a dbt group. When users log into dbt via a supported identity provider, their IdP group memberships sync with dbt. Upon logging in successfully, the user's group memberships (and permissions) will automatically adjust within dbt.

Creating SSO Mappings

While dbt supports mapping multiple IdP groups to a single dbt group, we recommend using a 1:1 mapping to make administration as simple as possible. Use the same names for your dbt groups and your IdP groups.

Create an SSO mapping in the group view:

1. Open an existing group to edit or create a new group.
2. In the **SSO** portion of the group screen, enter the name of the SSO group exactly as it appears in the IdP. If the name is not the same, the users will not be properly placed into the group.
3. In the **Users** section, ensure the **Add all users by default** option is disabled.
4. Save the group configuration. New SSO users will be added to the group upon login, and existing users will be added to the group upon their next login.

[![Example of an SSO group mapped to a dbt group.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/sso-mapping.png?v=2 "Example of an SSO group mapped to a dbt group.")](#)Example of an SSO group mapped to a dbt group.

Refer to [role-based access control](#role-based-access-control) for more information about mapping SSO groups for user assignment to dbt groups.

## Grant access[​](#grant-access "Direct link to Grant access")

dbt users have both a license (assigned to an individual user or by group membership) and permissions (by group membership only) that determine what actions they can take. Licenses are account-wide, and permissions provide more granular access or restrictions to specific features.

### Licenses[​](#licenses "Direct link to Licenses")

Every user in dbt will have a license assigned. Licenses consume "seats" which impact how your account is [billed](https://docs.getdbt.com/docs/cloud/billing), depending on your [service plan](https://www.getdbt.com/pricing).

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

Developer licenses will make up a majority of the users in your environment and have the highest impact on billing, so it's important to monitor how many you have at any given time.

For more information on these license types, see [Seats & Users](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users)

License types override group permissions

**User license types always override their assigned group permission sets.** For example, a user with a Read-Only license cannot perform administrative actions, even if they belong to an Account Admin group.

This ensures that license restrictions are always enforced, regardless of group membership.

### Permissions[​](#permissions "Direct link to Permissions")

Permissions determine what a developer-licensed user can do in your dbt account. By default, members of the `Owner` and `Member` groups have full access to all areas and features. When you want to restrict access to features, assign users to groups with stricter permission sets. Keep in mind that if a user belongs to multiple groups, the most permissive group will take precedence.

The permissions available depends on whether you're on an [Enterprise, Enterprise+](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions), or [self-service Starter](https://docs.getdbt.com/docs/cloud/manage-access/self-service-permissions) plan. Developer accounts only have a single user, so permissions aren't applicable.

[![Example permissions dropdown while editing an existing group.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/assign-group-permissions.png?v=2 "Example permissions dropdown while editing an existing group.")](#)Example permissions dropdown while editing an existing group.

Some permissions (those that don't grant full access, like admins) allow groups to be "assigned" to specific projects and environments only. Read about [environment-level permissions](https://docs.getdbt.com/docs/cloud/manage-access/environment-permissions-setup) for more information on restricting environment access.

[![Example environment access control for a group with Git admin assigned.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/environment-access-control.png?v=2 "Example environment access control for a group with Git admin assigned.")](#)Example environment access control for a group with Git admin assigned.

## Role-based access control [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[​](#role-based-access-control- "Direct link to role-based-access-control-")

Role-based access control (RBAC) allows you to grant users access to features and functionality based on their group membership. With this method, you can grant users varying access levels to different projects and environments. You can take access and security to the next level by integrating dbt with a third-party identity provider (IdP) to grant users access when they authenticate with your SSO or OAuth service.

There are a few things you need to know before you configure RBAC for SSO users:

* New SSO users join any groups with the **Add all new users by default** option enabled. By default, the `Everyone` and `Member` groups have this option enabled. Disable this option across all groups for the best RBAC experience.
* You must have the appropriate SSO groups configured in the group details SSO section. If the SSO group name does not match *exactly*, users will not be placed in the group correctly.

  [![The Group details SSO section with a group configured.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/sso-window-details.png?v=2 "The Group details SSO section with a group configured.")](#)The Group details SSO section with a group configured.
* dbt Labs recommends that your dbt group names match the IdP group names.

Let's say you have a new employee being onboarded into your organization using [Okta](https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-okta) as the IdP and dbt groups with SSO mappings. In this scenario, users are working on `The Big Project` and a new analyst named `Euclid Ean` is joining the group.

Check out the following example configurations for an idea of how you can implement RBAC for your organization (these examples assume you have already configured [SSO](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview)):

 Okta configuration

You and your IdP team add `Euclid Ean` to your Okta environment and assign them to the `dbt` SSO app via a group called `The Big Project`.

[![The user in the group in Okta.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/okta-group-config.png?v=2 "The user in the group in Okta.")](#)The user in the group in Okta.

Configure the group attribute statements the `dbt` application in Okta. The group statements in the following example are set to the group name exactly (`The Big Project`), but yours will likely be a much broader configuration. Companies often use the same prefix across all dbt groups in their IdP. For example `DBT_GROUP_`

[![Group attributes set in the dbt SAML 2.0 app in Okta.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/group-attributes.png?v=2 "Group attributes set in the dbt SAML 2.0 app in Okta.")](#)Group attributes set in the dbt SAML 2.0 app in Okta.

 dbt configuration

You and your dbt admin team configure the groups in your account's settings:

1. Navigate to the **Account settings** and click **Groups & Licenses** on the left-side menu.
2. Click **Create group** or select an existing group and click **Edit**.
3. Enter the group name in the **SSO** field.
4. Configure the **Access and permissions** fields to your needs. Select a [permission set](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions), the project they can access, and [environment-level access](https://docs.getdbt.com/docs/cloud/manage-access/environment-permissions).

[![The group configuration with SSO field filled out in dbt.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/dbt-cloud-group-config.png?v=2 "The group configuration with SSO field filled out in dbt.")](#)The group configuration with SSO field filled out in dbt.

Euclid is limited to the `Analyst` role, the `Jaffle Shop` project, and the `Development`, `Staging`, and `General` environments of that project. Euclid has no access to the `Production` environment in their role.

 The user journey

Euclid takes the following steps to log in:

1. Access the SSO URL or the dbt app in their Okta account. The URL can be found on the **Single sign-on** configuration page in the **Account settings**.

[![The SSO login URL in the account settings.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/sso-login-url.png?v=2 "The SSO login URL in the account settings.")](#)The SSO login URL in the account settings.

2. Log in with their Okta credentials.

[![The SSO login screen when using Okta as the identity provider.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/sso-login.png?v=2 "The SSO login screen when using Okta as the identity provider.")](#)The SSO login screen when using Okta as the identity provider.

3. Since it's their first time logging in with SSO, Euclid Ean is presented with a message and no option to move forward until they check the email address associated with their Okta account.

[![The screen users see after their first SSO login.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/post-login-screen.png?v=2 "The screen users see after their first SSO login.")](#)The screen users see after their first SSO login.

4. They now open their email and click the link to join dbt Labs.

[![The email the user receives on first SSO login.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/sample-email.png?v=2 "The email the user receives on first SSO login.")](#)The email the user receives on first SSO login.

5. Their email address is now verified. They click **Authenticate with your enterprise login**, which completes the process.

   [![The confirmation that the email address is verified.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/email-verified.png?v=2 "The confirmation that the email address is verified.")](#)The confirmation that the email address is verified.

Euclid is now logged in to their account. They only have access to the `Jaffle Shop` project. Under **Orchestration**, they can configure development credentials.

[![The Orchestration page with the environments.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/orchestration-environments.png?v=2 "The Orchestration page with the environments.")](#)The Orchestration page with the environments.

The `Production` environment is visible, but it is `read-only`, and they have full access in the `Staging` environment.

[![The Production environment landing page with read-only access.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/production-restricted.png?v=2 "The Production environment landing page with read-only access.")](#)The Production environment landing page with read-only access.

[![The Staging environment landing page with full access.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/staging-access.png?v=2 "The Staging environment landing page with full access.")](#)The Staging environment landing page with full access.

With RBAC configured, you now have granular control over user access to features across dbt.

### SCIM license management[​](#scim-license-management "Direct link to SCIM license management")

As part of the SSO configuration for supported IdPs, you can also configure the [System for Cross-Domain Identity Management (SCIM)](https://docs.getdbt.com/docs/cloud/manage-access/scim) settings to add a layer of security to your user lifecycle management. As part of this process, you can integrate user license distribution into the user provisioning process through your IdP. See the [SCIM license management instructions](https://docs.getdbt.com/docs/cloud/manage-access/scim#manage-user-licenses-with-scim) for more information.

## FAQs[​](#faqs "Direct link to FAQs")

 When are IdP group memberships updated for SSO Mapped groups?

Group memberships are updated whenever a user logs into dbt via a supported SSO provider. If you've changed group memberships in your identity provider or dbt, ask your users to log back into dbt to synchronize these group memberships.

 Can I set up SSO without RBAC?

Yes, see the documentation on [Manual Assignment](#manual-assignment) above for more information on using SSO without RBAC.

 Can I configure a user's license type based on IdP attributes?

Yes, see the docs on [managing license types](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users#managing-license-types) for more information.

 Why can't I edit a user's group membership?

Don't try to edit your own user, as this isn't allowed for security reasons. You'll need a different user to make changes to your own user's group membership.

 How do I add or remove users?

Each dbt plan has a base number of Developer and Read-Only licenses. You can add or remove licenses by modifying the number of users in your account settings.

* If you're on an Enterprise or Enterprise+ plan and have the correct [permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions), you can add or remove developers by adjusting your developer user seat count in **Account settings** -> **Users**.
* If you're on a Starter plan and have the correct [permissions](https://docs.getdbt.com/docs/cloud/manage-access/self-service-permissions), you can add or remove developers by making two changes: adjust your developer user seat count AND your developer billing seat count in **Account settings** -> **Users** and then in **Account settings** -> **Billing**.

For detailed steps, refer to [Users and licenses](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users#licenses).

## Learn more[​](#learn-more "Direct link to Learn more")

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

Users and licenses](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users)

* [Users](#users)
  + [User passwords](#user-passwords)* [Groups](#groups)
    + [Create new groups](#create-new-groups-) + [Group access and permissions](#group-access-and-permissions)+ [SSO mappings](#sso-mappings-)* [Grant access](#grant-access)
      + [Licenses](#licenses)+ [Permissions](#permissions)* [Role-based access control](#role-based-access-control-)
        + [SCIM license management](#scim-license-management)* [FAQs](#faqs)* [Learn more](#learn-more)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/manage-access/about-access.md)
