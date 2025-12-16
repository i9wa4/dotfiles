---
title: "Set up SCIM | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/manage-access/scim"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Manage access](https://docs.getdbt.com/docs/cloud/manage-access/about-user-access)* [Single sign-on and Oauth](https://docs.getdbt.com/docs/cloud/manage-access/sso-overview)* Set up SCIM

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fscim+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fscim+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fmanage-access%2Fscim+so+I+can+ask+questions+about+it.)

On this page

The System for Cross-Domain Identity Management (SCIM) makes user data more secure and simplifies the admin and end-user lifecycle experience by automating user identities and groups. You can create or disable user identities in your Identity Provider (IdP), and SCIM will automatically make those changes in near real-time downstream in dbt.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

To configure SCIM in your dbt environment:

* You must be on an [Enterprise or Enterprise+ plan](https://www.getdbt.com/pricing).
* You must use Okta or Entra ID as your SSO provider and have it connected in the dbt platform.
* You must have permissions to configure the account settings in [dbt](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) and change application settings in [Okta](https://help.okta.com/en-us/content/topics/security/administrators-admin-comparison.htm).
* If you have IP restrictions enabled, you must add [Okta's IPs](https://help.okta.com/en-us/content/topics/security/ip-address-allow-listing.htm) to your allowlist.

### Supported features[​](#supported-features "Direct link to Supported features")

The currently available supported features for SCIM are:

* User provisioning and de-provisioning
* User profile updates
* Group creation and management
* Importing groups and users

When users are managed by SCIM, functionality like applying default groups and inviting users manually will be disabled by default.

When users are provisioned, the following attributes are supported

* Username
* Family name
* Given name

The following IdPs are supported in the dbt UI:

* [Okta](#scim-configuration-for-okta)
* [Entra ID](#scim-configuration-for-entra-id)

If your IdP isn’t on the list, it can be supported using dbt [APIs](https://docs.getdbt.com/dbt-cloud/api-v3#/operations/Retrieve%20SCIM%20configuration).

## Set up dbt[​](#set-up-dbt "Direct link to Set up dbt")

To retrieve the necessary dbt configurations for use in Okta or Entra ID:

1. Navigate to your dbt **Account settings**.
2. Select **Single sign-on** from the left-side menu.
3. Scroll to the bottom of your SSO configuration settings and click **Enable SCIM**.

   [![SCIM enabled in the configuration settings.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/enable-scim.png?v=2 "SCIM enabled in the configuration settings.")](#)SCIM enabled in the configuration settings.
4. Record the **SCIM base URL** field for use in a later step.
5. Click **Create SCIM token**.

   note

   To follow best practices, you should regularly rotate your SCIM tokens. To do so, follow these same instructions you did to create a new one. To avoid service disruptions, remember to replace your token in your IdP before deleting the old token in dbt.
6. In the pop-up window, give the token a name that will make it easily identifiable. Click **Save**.

   [![Give your token and identifier.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/name-scim-token.png?v=2 "Give your token and identifier.")](#)Give your token and identifier.
7. Copy the token and record it securely, as *it will not be available again after you close the window*. You must create a new token if you lose the current one.

   [![Give your token and identifier.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/copy-scim-token.png?v=2 "Give your token and identifier.")](#)Give your token and identifier.
8. (Optional) Manual updates are turned off by default for all SCIM-managed entities, including the ability to invite new users manually. This ensures SCIM-managed entities stay in sync with the IdP, and we recommend keeping this setting disabled.

   * However, if you need to make manual updates (like update group membership for a SCIM-managed group), you can enable this setting by clicking **Allow manual updates**.

   [![Enabling manual updates in SCIM settings.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/scim-manual-updates.png?v=2 "Enabling manual updates in SCIM settings.")](#)Enabling manual updates in SCIM settings.

## SCIM configuration for Okta[​](#scim-configuration-for-okta "Direct link to SCIM configuration for Okta")

Please complete the [setup SSO with Okta](https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-okta) steps before configuring SCIM settings.

### Set up Okta[​](#set-up-okta "Direct link to Set up Okta")

1. Log in to your Okta account and locate the app configured for the dbt SSO integration.
2. Navigate to the **General** tab and ensure **Enable SCIM provisioning** is checked or the **Provisioning** tab will not be displayed.

   [![Enable SCIM provisioning in Okta.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/scim-provisioned.png?v=2 "Enable SCIM provisioning in Okta.")](#)Enable SCIM provisioning in Okta.
3. Open the **Provisioning** tab and select **Integration**.
4. Paste the [**SCIM base URL** from dbt](#set-up-dbt-cloud) to the first field, then enter your preferred **Unique identifier field for users** — we recommend `userName`.
5. Click the checkboxes for the following **Supported provisioning actions**:

   * Push New Users
   * Push Profile Updates
   * Push Groups
   * Import New Users and Profile Updates (Optional for users created before SSO/SCIM setup)
6. From the **Authentication mode** dropdown, select **HTTP Header**.
7. In the **Authorization** section, paste the token from dbt into the **Bearer** field.

   [![The completed SCIM configuration in the Okta app.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/scim-okta-config.png?v=2 "The completed SCIM configuration in the Okta app.")](#)The completed SCIM configuration in the Okta app.
8. Ensure that the following provisioning actions are selected:

   * Create users
   * Update user attributes
   * Deactivate users

   [![Ensure the users are properly provisioned with these settings.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/provisioning-actions.png?v=2 "Ensure the users are properly provisioned with these settings.")](#)Ensure the users are properly provisioned with these settings.
9. Test the connection and click **Save** once completed.

You've now configured SCIM for the Okta SSO integration in dbt.

### SCIM username format[​](#scim-username-format "Direct link to SCIM username format")

SCIM requires the username to be in the email address format. If your Okta configurations map the `Username` field to a different attribute, SCIM user provisioning will fail. To get around this without altering your user profiles, set your Okta app config to `Email`:

1. Open the SAML app created for the dbt integration.
2. In the **Sign on** tab, click **Edit** in the **Settings** pane.
3. Set the **Application username format** field to **Email**.
4. Click **Save**.

### Existing Okta integrations[​](#existing-okta-integrations "Direct link to Existing Okta integrations")

If you are adding SCIM to an existing Okta integration in dbt (as opposed to setting up SCIM and SSO concurrently for the first time), there is some functionality you should be aware of:

* Users and groups already synced to dbt will become SCIM-managed once you complete the SCIM configuration.
* (Recommended) Import and manage existing dbt groups and users with Okta's **Import Groups** and **Import Users** features. Update the groups in your IdP with the same naming convention used for dbt groups. New users, groups, and changes to existing profiles will be automatically imported into dbt.
  + Ensure the **Import users and profile updates** and **Import groups** checkboxes are selected in the **Provisioning settings** tab in the Okta SCIM configuration.
  + Use **Import Users** to sync all users from dbt, including previously deleted users, if you need to re-provision those users.
  + Read more about this feature in the [Okta documentation](https://help.okta.com/en-us/content/topics/users-groups-profiles/usgp-import-groups-app-provisioning.htm).

## SCIM configuration for Entra ID[​](#scim-configuration-for-entra-id "Direct link to SCIM configuration for Entra ID")

Please complete the [setup SSO with Entra ID](https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-microsoft-entra-id) steps before configuring SCIM settings.

### Set up Entra ID[​](#set-up-entra-id "Direct link to Set up Entra ID")

1. Log in to your Azure account and open the **Entra ID** configurations.
2. From the sidebar, under **Manage**, click **Enterprise Applications**.
3. Click **New Application** and select the option to **Create your own application**.

   [![Create your own application.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/create-your-own.png?v=2 "Create your own application.")](#)Create your own application.
4. Give your app a unique name and ensure the **Integrate any other application you don't find in the gallery (Non-gallery)** field is selected. Ignore any prompts for existing apps. Click **Create**.

   [![Give your app a unique name.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/create-application.png?v=2 "Give your app a unique name.")](#)Give your app a unique name.
5. From the application **Overview** screen, click **Provision User Accounts**.

   [![The 'Provision user accounts' option.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/provision-user-accounts.png?v=2 "The 'Provision user accounts' option.")](#)The 'Provision user accounts' option.
6. From the **Create configuration** section, click **Connect your application**
7. Fill out the form with the information from your dbt account:
   * The **Tenant URL** in Entra ID is your **SCIM based URL** from dbt
   * The **Secret token** in Entra ID is your *SCIM token*\* from dbt
8. Click **Test connection** and click **Create** once complete.

   [![Configure the app and test the connection.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/provisioning-config.png?v=2 "Configure the app and test the connection.")](#)Configure the app and test the connection.

### Attribute mapping[​](#attribute-mapping "Direct link to Attribute mapping")

To map the attributes that will sync with dbt:

1. From the enteprise app **Overview** screen sidebar menu, click **Provisioning**.

   [![The Provisioning option on the sidebar.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/provisioning.png?v=2 "The Provisioning option on the sidebar.")](#)The Provisioning option on the sidebar.
2. From under **Manage**, again click **Provisioning**.
3. Expand the **Mappings** section and click **Provision Microsoft Entra ID users**.

   [![Provision the Entra ID users.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/provision-entra-users.png?v=2 "Provision the Entra ID users.")](#)Provision the Entra ID users.
4. Click the box for **Show advanced options** and then click **Edit attribute list for customappsso**.

   [![Click to edit the customappsso attributes.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/customappsso-attributes.png?v=2 "Click to edit the customappsso attributes.")](#)Click to edit the customappsso attributes.
5. Scroll to the bottom of the **Edit attribute list** window and find an empty field where you can add a new entry with the following fields:
   * **Name:** `emails[type eq "work"].primary`
   * **Type:** `Boolean`
   * **Required:** True

   [![Add the new field to the entry list.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/customappsso-entry.png?v=2 "Add the new field to the entry list.")](#)Add the new field to the entry list.
6. Mark all of the fields listed in Step 10 below as `Required`.

   [![Mark the fields as required.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/mark-as-required.png?v=2 "Mark the fields as required.")](#)Mark the fields as required.
7. Click **Save**
8. Back on the **Attribute mapping** window, click **Add new mapping** and complete fields with the following:
   * **Mapping type:** `none`
   * **Default value if null (optional):** `True`
   * **Target attribute:** `emails[type eq "work"].primary`
   * **Match objects using this attribute:** `No`
   * **Matching precedence:** *Leave blank*
   * **Apply this mapping:** `Always`
9. Click **Ok**

   [![Edit the attribute as shown.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/edit-attribute.png?v=2 "Edit the attribute as shown.")](#)Edit the attribute as shown.
10. Make sure the following mappings are in place and delete any others:
    * **UserName:** `userPrincipalName`
    * **active:** `Switch([IsSoftDeleted], , "False", "True", "True", "False")`
    * **emails[type eq "work"].value:** `userPrincipalName`
    * **name.givenName:** `givenName`
    * **name.familyName:** `surname`
    * **externalid:** `mailNickname`
    * **emails[type eq "work"].primary**

    [![Edit the attributes so they match the list as shown.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/attribute-list.png?v=2 "Edit the attributes so they match the list as shown.")](#)Edit the attributes so they match the list as shown.
11. Click **Save**.

You can now begin assigning users to your SCIM app in Entra ID!

## Assign users to SCIM app[​](#assign-users-to-scim-app "Direct link to Assign users to SCIM app")

The following steps go over how to assign users/groups to the SCIM app. Refer to Microsoft's [official instructions for assigning users or groups to an Enterprise App in Entra ID](https://learn.microsoft.com/en-us/azure/databricks/admin/users-groups/scim/aad#step-3-assign-users-and-groups-to-the-application) to learn more. Although the article is written for Databricks, the steps are identical.

1. Navigate to Enterprise applications and select the SCIM app.
2. Go to **Manage** > **Provisioning**.
3. To synchronize Microsoft Entra ID users and groups to dbt, click the **Start provisioning** button.

   [![Start provisioning to synchronize users and groups.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/scim-entraid-start-provision.png?v=2 "Start provisioning to synchronize users and groups.")](#)Start provisioning to synchronize users and groups.
4. Navigate back to the SCIM app's overview page and go to **Manage** > **Users and groups**.
5. Click **Add user/group** and select the users and groups.

   [![Add user/group.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/scim-entraid-add-users.png?v=2 "Add user/group.")](#)Add user/group.
6. Click the **Assign** button.
7. Wait a few minutes. In the dbt platform, confirm the users and groups exist in your dbt account.
   * Users and groups that you add and assign will automatically be provisioned to your dbt account when Microsoft Entra ID schedules the next sync.
   * By enabling provisioning, you immediately trigger the initial Microsoft Entra ID sync. Subsequent syncs are triggered every 20-40 minutes, depending on the number of users and groups in the application. Refer to Microsoft Entra ID's [Provisioning tips](https://learn.microsoft.com/en-us/azure/databricks/admin/users-groups/scim/aad#provisioning-tips) documentation for more information.
   * You can also prompt a manual provisioning outside of the cycle by clicking **Restart provisioning**.

   [![Prompt manual provisioning.](https://docs.getdbt.com/img/docs/dbt-cloud/dbt-cloud-enterprise/access-control/scim-entraid-manual.png?v=2 "Prompt manual provisioning.")](#)Prompt manual provisioning.

## Manage user licenses with SCIM[​](#manage-user-licenses-with-scim "Direct link to Manage user licenses with SCIM")

You can manage user license assignments via SCIM with a user attribute in your IdP environment. This ensures accurate license assignment as users are provisioned in the IdP and onboarded into your dbt account.

Analyst license assignment

The `Analyst` license is only available for select plans. Assigning an `Analyst` license via SCIM will result in a user update error if that license type is not available for your dbt account.

To use license management via SCIM, enable the feature under the **SCIM** section in the **Single sign-on** settings. This setting will enforce license type for a user based on their SCIM attribute and disable the license mapping and manual configuration set up in dbt.

[![Enable SCIM managed user license distribution.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/scim-managed-licenses.png?v=2 "Enable SCIM managed user license distribution.")](#)Enable SCIM managed user license distribution.

*We recommend that you complete the setup instructions for your identity provider prior to enabling this toggle in your dbt account. Once enabled, any existing license mappings in dbt platform will be ignored. SCIM license mapping is currently only supported for Okta.*

The recommended steps for migrating to SCIM license mapping are as follows:

1. Set up SCIM but keep the toggle disabled so existing license mappings continue to work as expected.
2. Configure license attributes in your Identity Provider (IdP).
3. Test that SCIM attributes are being used to set license type in dbt platform.
4. Enable the toggle to ignore existing license mappings so that SCIM is the source-of-truth for assigning licenses to users.

### Add license type attribute for Okta[​](#add-license-type-attribute-for-okta "Direct link to Add license type attribute for Okta")

To add the attribute for license types to your Okta environment:

1. From your Okta application, navigate to the **Provisioning** tab, scroll down to **Attribute Mappings**, and click **Go to Profile Editor**.
2. Click **Add Attribute**.
3. Configure the attribute fields as follows (the casing should match for the values of each):

   * **Date type:** `string`
   * **Display name:** `License Type`
   * **Variable name:** `licenseType`
   * **External name:** `licenseType`
   * **External namespace:** `urn:ietf:params:scim:schemas:extension:dbtLabs:2.0:User`
   * **Description:** An arbitrary string of your choosing.
   * **Enum:** Check the box for **Define enumerated list of values**
   * **Attribute members:** Add the initial attribute and then click **Add another** until each license type is defined. We recommend adding all of the values even if you don't use them today, so they'll be available in the future.

     |  |  |  |  |  |  |  |  |  |  |
     | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
     | Display name Value|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | **IT** `it`| **Analyst** `analyst`| **Developer** `developer`| **Read Only** `read_only` | | | | | | | | | |

     |  |  |  |  |  |
     | --- | --- | --- | --- | --- |
     ||  |  |  |  |  |
     | --- | --- | --- | --- | --- |
     | Loading table... | | | | |
   * **Attribute type:** Personal

   [![Enter the fields as they appear in the image. Ensure the cases match.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/scim-license-attributes.png?v=2 "Enter the fields as they appear in the image. Ensure the cases match.")](#)Enter the fields as they appear in the image. Ensure the cases match.
4. **Save** the attribute mapping.
5. Users can now have license types set in their profiles and when they are being provisioned.

   [![Set the license type for the user in their Okta profile.](https://docs.getdbt.com/img/docs/dbt-cloud/access-control/scim-license-provisioning.png?v=2 "Set the license type for the user in their Okta profile.")](#)Set the license type for the user in their Okta profile.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Set up SSO with Microsoft Entra ID](https://docs.getdbt.com/docs/cloud/manage-access/set-up-sso-microsoft-entra-id)[Next

Set up Snowflake OAuth](https://docs.getdbt.com/docs/cloud/manage-access/set-up-snowflake-oauth)

* [Prerequisites](#prerequisites)
  + [Supported features](#supported-features)* [Set up dbt](#set-up-dbt)* [SCIM configuration for Okta](#scim-configuration-for-okta)
      + [Set up Okta](#set-up-okta)+ [SCIM username format](#scim-username-format)+ [Existing Okta integrations](#existing-okta-integrations)* [SCIM configuration for Entra ID](#scim-configuration-for-entra-id)
        + [Set up Entra ID](#set-up-entra-id)+ [Attribute mapping](#attribute-mapping)* [Assign users to SCIM app](#assign-users-to-scim-app)* [Manage user licenses with SCIM](#manage-user-licenses-with-scim)
            + [Add license type attribute for Okta](#add-license-type-attribute-for-okta)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/manage-access/scim.md)
