---
title: "Job notifications | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/deploy/job-notifications"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Deploy dbt](https://docs.getdbt.com/docs/deploy/deployments)* [Monitor jobs and alerts](https://docs.getdbt.com/docs/deploy/monitor-jobs)* Job notifications

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fjob-notifications+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fjob-notifications+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdeploy%2Fjob-notifications+so+I+can+ask+questions+about+it.)

On this page

Set up notifications in dbt to receive email or Slack alerts about the status of a job run. You can choose to be notified by one or more of the following job run statuses:

* **Succeeds** option — A job run completed successfully with no warnings or errors.
* **Warns** option — A job run encountered warnings from [data tests](https://docs.getdbt.com/docs/build/data-tests) or [source freshness](https://docs.getdbt.com/docs/deploy/source-freshness) checks (if applicable).
* **Fails** option — A job run failed to complete.
* **Is canceled** option — A job run is canceled.

## Email notifications[​](#email-notifications "Direct link to Email notifications")

You can receive email alerts about jobs by configuring the dbt email notification settings.

### Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* You must be either a *developer user* or an *account admin* to configure email notifications in dbt. For more details, refer to [Users and licenses](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users).
  + As a developer user, you can set up email notifications for yourself.
  + As an account admin, you can set up notifications for yourself and other team members.

### Configure email notifications[​](#configure-email-notifications "Direct link to Configure email notifications")

1. Select your profile icon and then click **Notification settings**.
2. By default, dbt sends notifications to the email address that's in your **User profile** page.

   If you're an account admin, you can choose a different email address to receive notifications:

   1. Under Job notifications, click the **Notification email** dropdown.
   2. Select another address from the list.
      The list includes **Internal Users** with access to the account and **External Emails** that have been added.
   3. To add an external email address, click the **Notification email** dropdown
   4. Click **Add external email**.
   5. Enter the email address, and click Add user.
      After adding an external email, it becomes available for selection in the **Notification email** dropdown list. External emails can be addresses that are outside of your dbt account and also for third-party integrations like [channels in Microsoft Teams](https://support.microsoft.com/en-us/office/tip-send-email-to-a-channel-2c17dbae-acdf-4209-a761-b463bdaaa4ca) and [PagerDuty email integration](https://support.pagerduty.com/docs/email-integration-guide).

      note

      External emails and their notification settings persist until edited or removed even if you remove the admin who added them from the account.

   [![Example of the Notification email dropdown](https://docs.getdbt.com/img/docs/deploy/example-notification-external-email.png?v=2 "Example of the Notification email dropdown")](#)Example of the Notification email dropdown
3. Select the **Environment** for the jobs you want to receive notifications about from the dropdown.
4. Click **Edit** to configure the email notification settings. Choose one or more of the run statuses for each job you want to receive notifications about.
5. When you're done with the settings, click **Save**.

   As an account admin, you can add more email recipients by choosing another **Notification email** from the dropdown, **Edit** the job notification settings, and **Save** the changes.

   To set up alerts on jobs from a different environment, select another **Environment** from the dropdown, **Edit** those job notification settings, and **Save** the changes.

   [![Example of the Email notifications page](https://docs.getdbt.com/img/docs/deploy/example-email-notification-settings-page.png?v=2 "Example of the Email notifications page")](#)Example of the Email notifications page

### Unsubscribe from email notifications[​](#unsubscribe-from-email-notifications "Direct link to Unsubscribe from email notifications")

1. Select your profile icon and click on **Notification settings**.
2. On the **Email notifications** page, click **Unsubscribe from all email notifications**.

## Slack notifications[​](#slack-notifications "Direct link to Slack notifications")

You can receive Slack alerts about jobs by setting up the Slack integration and then configuring the dbt Slack notification settings. dbt integrates with Slack via OAuth to ensure secure authentication.

note

Virtual Private Cloud (VPC) admins must [contact support](mailto:support@getdbt.com) to complete the Slack integration.

If there has been a change in user roles or Slack permissions where you no longer have access to edit a configured Slack channel, please [contact support](mailto:support@getdbt.com) for assistance.

### Prerequisites[​](#prerequisites-1 "Direct link to Prerequisites")

* You must be a Slack Workspace Owner.
* You must be an account admin to configure Slack notifications in dbt. For more details, refer to [Users and licenses](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users).
* The integration only supports *public* channels in the Slack workspace.

### Set up the Slack integration[​](#set-up-the-slack-integration "Direct link to Set up the Slack integration")

1. Select **Account settings** and then select **Integrations** from the left sidebar.
2. Locate the **OAuth** section with the Slack application and click **Link**.

   [![Link for the Slack app](https://docs.getdbt.com/img/docs/dbt-cloud/Link-your-Slack-Profile.png?v=2 "Link for the Slack app")](#)Link for the Slack app

#### Logged in to Slack[​](#logged-in-to-slack "Direct link to Logged in to Slack")

If you're already logged in to Slack, the handshake only requires allowing the app access. If you're a member of multiple workspaces, you can select the appropriate workspace from the dropdown menu in the upper right corner.

[![Allow dbt access to Slack](https://docs.getdbt.com/img/docs/dbt-cloud/Allow-dbt-to-access-slack.png?v=2 "Allow dbt access to Slack")](#)Allow dbt access to Slack

#### Logged out[​](#logged-out "Direct link to Logged out")

If you're logged out or the Slack app/website is closed, you must authenticate before completing the integration.

1. Complete the field defining the Slack workspace you want to integrate with dbt.

   [![Define the workspace](https://docs.getdbt.com/img/docs/dbt-cloud/define-workspace.png?v=2 "Define the workspace")](#)Define the workspace
2. Sign in with an existing identity or use the email address and password.
3. Once you have authenticated successfully, accept the permissions.

   [![Allow dbt access to Slack](https://docs.getdbt.com/img/docs/dbt-cloud/accept-permissions.png?v=2 "Allow dbt access to Slack")](#)Allow dbt access to Slack

### Configure Slack notifications[​](#configure-slack-notifications "Direct link to Configure Slack notifications")

1. Select your profile icon and then click on **Notification settings**.
2. Select **Slack notifications** in the left sidebar.
3. Select the **Notification channel** you want to receive the job run notifications from the dropdown.

   [![Example of the Notification channel dropdown](https://docs.getdbt.com/img/docs/deploy/example-notification-slack-channels.png?v=2 "Example of the Notification channel dropdown")](#)Example of the Notification channel dropdown
4. Select the **Environment** for the jobs you want to receive notifications about from the dropdown.
5. Click **Edit** to configure the Slack notification settings. Choose one or more of the run statuses for each job you want to receive notifications about.
6. When you're done with the settings, click **Save**.

   To send alerts to another Slack channel, select another **Notification channel** from the dropdown, **Edit** those job notification settings, and **Save** the changes.

   To set up alerts on jobs from a different environment, select another **Environment** from the dropdown, **Edit** those job notification settings, and **Save** the changes.

   [![Example of the Slack notifications page](https://docs.getdbt.com/img/docs/deploy/example-slack-notification-settings-page.png?v=2 "Example of the Slack notifications page")](#)Example of the Slack notifications page

### Disable the Slack integration[​](#disable-the-slack-integration "Direct link to Disable the Slack integration")

1. Select **Account settings** and on the **Integrations** page, scroll to the **OAuth** section.
2. Click the trash can icon (on the far right of the Slack integration) and click **Unlink**. Channels that you configured will no longer receive Slack notifications. *This is not an account-wide action.* Channels configured by other account admins will continue to receive Slack notifications if they still have active Slack integrations. To migrate ownership of a Slack channel notification configuration, have another account admin edit their configuration.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Artifacts](https://docs.getdbt.com/docs/deploy/artifacts)[Next

Model notifications](https://docs.getdbt.com/docs/deploy/model-notifications)

* [Email notifications](#email-notifications)
  + [Prerequisites](#prerequisites)+ [Configure email notifications](#configure-email-notifications)+ [Unsubscribe from email notifications](#unsubscribe-from-email-notifications)* [Slack notifications](#slack-notifications)
    + [Prerequisites](#prerequisites-1)+ [Set up the Slack integration](#set-up-the-slack-integration)+ [Configure Slack notifications](#configure-slack-notifications)+ [Disable the Slack integration](#disable-the-slack-integration)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/deploy/job-notifications.md)
