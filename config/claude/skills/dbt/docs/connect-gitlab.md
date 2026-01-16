---
title: "Connect to GitLab | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/git/connect-gitlab"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Configure Git](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud)* Connect to GitLab

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fconnect-gitlab+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fconnect-gitlab+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fconnect-gitlab+so+I+can+ask+questions+about+it.)

On this page

Connecting your GitLab account to dbt provides convenience and another layer of security to dbt:

* Import new GitLab repos with a couple clicks during dbt project setup.
* Clone repos using HTTPS rather than SSH.
* Carry GitLab user permissions through to dbt or dbt CLI's git actions.
* Trigger [Continuous integration](https://docs.getdbt.com/docs/deploy/continuous-integration) builds when merge requests are opened in GitLab.

info

When configuring the repository in dbt, GitLab automatically:

* Registers a webhook that triggers pipeline jobs in dbt.
* Creates a [project access token](https://docs.gitlab.com/ee/user/project/settings/project_access_tokens.html) in your GitLab repository, which sends the job run status back to GitLab using the dbt API for CI jobs. dbt automatically refreshes this token for you.

Requires a [GitLab Premium or Ultimate account](https://about.gitlab.com/pricing/).

Depending on your plan, use these steps to integrate GitLab in dbt:

* The Developer or Starter plan, read these [instructions](#for-dbt-developer-and-starter-plans).
* The Enterprise or Enterprise+ plan, jump ahead to these [instructions](#for-the-dbt-enterprise-plans).

## For dbt Developer and Starter plans[​](#for-dbt-developer-and-starter-plans "Direct link to For dbt Developer and Starter plans")

Before you can work with GitLab repositories in dbt, you’ll need to connect your GitLab account to your user profile. This allows dbt to authenticate your actions when interacting with Git repositories. Make sure to read about [limitations](#limitations) of the Team and Developer plans before you connect your account.

To connect your GitLab account:

1. From dbt, click on your account name in the left side menu and select **Account settings**.
2. Select **Personal profile** under the **Your profile** section.
3. Scroll down to **Linked accounts**.
4. Click **Link** to the right of your GitLab account.

[![The Personal profile settings with the Linked Accounts section of the user profile](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/connecting-github/github-connect.png?v=2 "The Personal profile settings with the Linked Accounts section of the user profile")](#)The Personal profile settings with the Linked Accounts section of the user profile

When you click **Link**, you will be redirected to GitLab and prompted to sign into your account. GitLab will then ask for your explicit authorization:

[![GitLab Authorization Screen](https://docs.getdbt.com/img/docs/dbt-cloud/connecting-gitlab/GitLab-Auth.png?v=2 "GitLab Authorization Screen")](#)GitLab Authorization Screen

Once you've accepted, you should be redirected back to dbt, and you'll see that your account has been linked to your profile.

### Requirements and limitations[​](#requirements-and-limitations "Direct link to Requirements and limitations")

dbt Team and Developer plans use a single GitLab deploy token created by the first user who connects the repository, which means:

* All repositories users access from the dbt platform must belong to a [GitLab group](https://docs.gitlab.com/user/group/).
* All Git operations (like commits and pushes) from the Studio IDE appear as coming from the same deploy token.
* GitLab push rules may reject pushes made through dbt, particularly when multiple users are committing via the same deploy token.

To support advanced Git workflows and multi-user commit behavior, upgrade to the Enterprise plan, which provides more flexible Git authentication strategies.

## For the dbt Enterprise plans[​](#for-the-dbt-enterprise-plans "Direct link to For the dbt Enterprise plans")

dbt Enterprise and Enterprise+ customers have the added benefit of bringing their own GitLab OAuth application to dbt. This tier benefits from extra security, as dbt will:

* Enforce user authorization with OAuth.
* Carry GitLab's user repository permissions (read / write access) through to dbt or dbt CLI's git actions.

In order to connect GitLab in dbt, a GitLab account admin must:

1. [Set up a GitLab OAuth application](#setting-up-a-gitlab-oauth-application).
2. [Add the GitLab app to dbt](#adding-the-gitlab-oauth-application-to-dbt-cloud).

Once the admin completes those steps, dbt developers need to:

1. [Personally authenticate with GitLab](#personally-authenticating-with-gitlab) from dbt.

### Setting up a GitLab OAuth application[​](#setting-up-a-gitlab-oauth-application "Direct link to Setting up a GitLab OAuth application")

We recommend that before you set up a project in dbt, a GitLab account admin set up an OAuth application in GitLab for use in dbt.

For more detail, GitLab has a [guide for creating a Group Application](https://docs.gitlab.com/ee/integration/oauth_provider.html#group-owned-applications).

In GitLab, navigate to your group settings and select **Applications**. Here you'll see a form to create a new application.

[![GitLab application navigation](https://docs.getdbt.com/img/docs/dbt-cloud/connecting-gitlab/gitlab nav.gif?v=2 "GitLab application navigation")](#)GitLab application navigation

In GitLab, when creating your Group Application, input the following:

|  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Value|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | **Name** dbt| **Redirect URI** `https://YOUR_ACCESS_URL/complete/gitlab`| **Confidential** ✅|  |  | | --- | --- | | **Scopes** ✅ api | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Replace `YOUR_ACCESS_URL` with the [appropriate Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan.

The application form in GitLab should look as follows when completed:

[![GitLab group owned application form](https://docs.getdbt.com/img/docs/dbt-cloud/connecting-gitlab/gitlab app.png?v=2 "GitLab group owned application form")](#)GitLab group owned application form

Click **Save application** in GitLab, and GitLab will then generate an **Application ID** and **Secret**. These values will be available even if you close the app screen, so this is not the only chance you have to save them.

If you're a Business Critical customer using [IP restrictions](https://docs.getdbt.com/docs/cloud/secure/ip-restrictions), ensure you've added the appropriate Gitlab CIDRs to your IP restriction rules, or else the Gitlab connection will fail.

### Adding the GitLab OAuth application to dbt[​](#adding-the-gitlab-oauth-application-to-dbt "Direct link to Adding the GitLab OAuth application to dbt")

After you've created your GitLab application, you need to provide dbt information about the app. In dbt, account admins should navigate to **Account Settings**, click on the **Integrations** tab, and expand the GitLab section.

[![Navigating to the GitLab Integration in dbt](https://docs.getdbt.com/img/docs/dbt-cloud/connecting-gitlab/GitLab-Navigation.gif?v=2 "Navigating to the GitLab Integration in dbt")](#)Navigating to the GitLab Integration in dbt

In dbt, input the following values:

|  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Field Value|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | **GitLab Instance** <https://gitlab.com>| **Application ID** *copy value from GitLab app*| **Secret** *copy value from GitLab app* | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

Note, if you have a special hosted version of GitLab, modify the **GitLab Instance** to use the hostname provided for your organization instead - for example `https://gitlab.yourgreatcompany.com/`.

Once the form is complete in dbt, click **Save**.

You will then be redirected to GitLab and prompted to sign into your account. GitLab will ask for your explicit authorization:

[![GitLab Authorization Screen](https://docs.getdbt.com/img/docs/dbt-cloud/connecting-gitlab/GitLab-Auth.png?v=2 "GitLab Authorization Screen")](#)GitLab Authorization Screen

Once you've accepted, you should be redirected back to dbt, and your integration is ready for developers on your team to [personally authenticate with](#personally-authenticating-with-gitlab).

### Personally authenticating with GitLab[​](#personally-authenticating-with-gitlab "Direct link to Personally authenticating with GitLab")

dbt developers on the Enterprise or Enterprise+ plan must each connect their GitLab profiles to dbt, as every developer's read / write access for the dbt repo is checked in the Studio IDE or dbt CLI.

To connect a personal GitLab account:

1. From dbt, click on your account name in the left side menu and select **Account settings**.
2. Select **Personal profile** under the **Your profile** section.
3. Scroll down to **Linked accounts**.

If your GitLab account is not connected, you’ll see "No connected account". Select **Link** to begin the setup process. You’ll be redirected to GitLab, and asked to authorize dbt in a grant screen.

[![Authorizing the dbt app for developers](https://docs.getdbt.com/img/docs/dbt-cloud/connecting-gitlab/GitLab-Auth.png?v=2 "Authorizing the dbt app for developers")](#)Authorizing the dbt app for developers

Once you approve authorization, you will be redirected to dbt, and you should see your connected account. You're now ready to start developing in the Studio IDE or dbt CLI.

## Troubleshooting[​](#troubleshooting "Direct link to Troubleshooting")

Unable to trigger a CI job with GitLab

When you connect dbt to a GitLab repository, GitLab automatically registers a webhook in the background, viewable under the repository settings. This webhook is also used to trigger [CI jobs](https://docs.getdbt.com/docs/deploy/ci-jobs) when you push to the repository.

If you're unable to trigger a CI job, this usually indicates that the webhook registration is missing or incorrect.

To resolve this issue, navigate to the repository settings in GitLab and view the webhook registrations by navigating to GitLab --> **Settings** --> **Webhooks**.

Some things to check:

* The webhook registration is enabled in GitLab.
* The webhook registration is configured with the correct URL and secret.

If you're still experiencing this issue, reach out to the Support team at [support@getdbt.com](mailto:support@getdbt.com) and we'll be happy to help!

Errors importing a repository on dbt project set up

If you don't see your repository listed, double-check that:

* Your repository is in a Gitlab group you have access to. dbt will not read repos associated with a user.

If you do see your repository listed, but are unable to import the repository successfully, double-check that:

* You are a maintainer of that repository. Only users with maintainer permissions can set up repository connections.

If you imported a repository using the dbt native integration with GitLab, you should be able to see if the clone strategy is using a `deploy_token`. If it's relying on an SSH key, this means the repository was not set up using the native GitLab integration, but rather using the generic git clone option. The repository must be reconnected in order to get the benefits described above.

How can I fix my .gitignore file?

A `.gitignore` file specifies which files git should intentionally ignore or 'untrack'. dbt indicates untracked files in the project file explorer pane by putting the file or folder name in *italics*.

If you encounter issues like problems reverting changes, checking out or creating a new branch, or not being prompted to open a pull request after a commit in the Studio IDE — this usually indicates a problem with the [.gitignore](https://github.com/dbt-labs/dbt-starter-project/blob/main/.gitignore) file. The file may be missing or lacks the required entries for dbt to work correctly.

The following sections describe how to fix the `.gitignore` file in:

 Fix in the Studio IDE

To resolve issues with your `gitignore` file, adding the correct entries won't automatically remove (or 'untrack') files or folders that have already been tracked by git. The updated `gitignore` will only prevent new files or folders from being tracked. So you'll need to first fix the `gitignore` file, then perform some additional git operations to untrack any incorrect files or folders.

1. Launch the Studio IDE into the project that is being fixed, by selecting **Develop** on the menu bar.
2. In your **File Explorer**, check to see if a `.gitignore` file exists at the root of your dbt project folder. If it doesn't exist, create a new file.
3. Open the new or existing `gitignore` file, and add the following:

```
# ✅ Correct
target/
dbt_packages/
logs/
# legacy -- renamed to dbt_packages in dbt v1
dbt_modules/
```

* **Note** — You can place these lines anywhere in the file, as long as they're on separate lines. The lines shown are wildcards that will include all nested files and folders. Avoid adding a trailing `'*'` to the lines, such as `target/*`.

For more info on `gitignore` syntax, refer to the [Git docs](https://git-scm.com/docs/gitignore).

4. Save the changes but *don't commit*.
5. Restart the IDE by clicking on the three dots next to the **IDE Status button** on the lower right corner of the IDE screen and select **Restart IDE**.

[![Restart the IDE by clicking the three dots on the lower right or click on the Status bar](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/restart-ide.png?v=2 "Restart the IDE by clicking the three dots on the lower right or click on the Status bar")](#)Restart the IDE by clicking the three dots on the lower right or click on the Status bar

6. Once the Studio IDE restarts, go to the **File Catalog** to delete the following files or folders (if they exist). No data will be lost:

   * `target`, `dbt_modules`, `dbt_packages`, `logs`
7. **Save** and then **Commit and sync** the changes.
8. Restart the Studio IDE again using the same procedure as step 5.
9. Once the Studio IDE restarts, use the **Create a pull request** (PR) button under the **Version Control** menu to start the process of integrating the changes.
10. When the git provider's website opens to a page with the new PR, follow the necessary steps to complete and merge the PR into the main branch of that repository.

    * **Note** — The 'main' branch might also be called 'master', 'dev', 'qa', 'prod', or something else depending on the organizational naming conventions. The goal is to merge these changes into the root branch that all other development branches are created from.
11. Return to the Studio IDE and use the **Change Branch** button, to switch to the main branch of the project.
12. Once the branch has changed, click the **Pull from remote** button to pull in all the changes.
13. Verify the changes by making sure the files/folders in the `.gitignore` file are in italics.

[![A dbt project on the main branch that has properly configured gitignore folders (highlighted in italics).](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/gitignore-italics.png?v=2 "A dbt project on the main branch that has properly configured gitignore folders (highlighted in italics).")](#)A dbt project on the main branch that has properly configured gitignore folders (highlighted in italics).

 Fix in the Git provider

Sometimes it's necessary to use the git providers web interface to fix a broken `.gitignore` file. Although the specific steps may vary across providers, the general process remains the same.

There are two options for this approach: editing the main branch directly if allowed, or creating a pull request to implement the changes if required:

* Edit in main branch* Unable to edit main branch

When permissions allow it, it's possible to edit the `.gitignore` directly on the main branch of your repo. Here are the following steps:

1. Go to your repository's web interface.
2. Switch to the main branch and the root directory of your dbt project.
3. Find the `.gitignore` file. Create a blank one if it doesn't exist.
4. Edit the file in the web interface, adding the following entries:

```
target/
dbt_packages/
logs/
# legacy -- renamed to dbt_packages in dbt v1
dbt_modules/
```

5. Commit (save) the file.
6. Delete the following folders from the dbt project root, if they exist. No data or code will be lost:
   * `target`, `dbt_modules`, `dbt_packages`, `logs`
7. Commit (save) the deletions to the main branch.
8. Switch to the Studio IDE , and open the project that you're fixing.
9. [Rollback your repo to remote](https://docs.getdbt.com/docs/cloud/git/version-control-basics#the-git-button-in-the-cloud-ide) in the IDE by clicking on the three dots next to the **IDE Status** button on the lower right corner of the IDE screen, then select **Rollback to remote**.
   * **Note** — Rollback to remote resets your repo back to an earlier clone from your remote. Any saved but uncommitted changes will be lost, so make sure you copy any modified code that you want to keep in a temporary location outside of dbt.
10. Once you rollback to remote, open the `.gitignore` file in the branch you're working in. If the new changes aren't included, you'll need to merge the latest commits from the main branch into your working branch.
11. Go to the **File Explorer** to verify the `.gitignore` file contains the correct entries and make sure the untracked files/folders in the .gitignore file are in *italics*.
12. Great job 🎉! You've configured the `.gitignore` correctly and can continue with your development!

If you can't edit the `.gitignore` directly on the main branch of your repo, follow these steps:

1. Go to your repository's web interface.
2. Switch to an existing development branch, or create a new branch just for these changes (This is often faster and cleaner).
3. Find the `.gitignore` file. Create a blank one if it doesn't exist.
4. Edit the file in the web interface, adding the following entries:

```
target/
dbt_packages/
logs/
# legacy -- renamed to dbt_packages in dbt v1
dbt_modules/
```

5. Commit (save) the file.
6. Delete the following folders from the dbt project root, if they exist. No data or code will be lost:
   * `target`, `dbt_modules`, `dbt_packages`, `logs`
7. Commit (save) the deleted folders.
8. Open a merge request using the git provider web interface. The merge request should attempt to merge the changes into the 'main' branch that all development branches are created from.
9. Follow the necessary procedures to get the branch approved and merged into the 'main' branch. You can delete the branch after the merge is complete.
10. Once the merge is complete, go back to the Studio IDE, and open the project that you're fixing.
11. [Rollback your repo to remote](https://docs.getdbt.com/docs/cloud/git/version-control-basics#the-git-button-in-the-cloud-ide) in the Studio IDE by clicking on the three dots next to the **Studio IDE Status** button on the lower right corner of the Studio IDE screen, then select **Rollback to remote**.
    * **Note** — Rollback to remote resets your repo back to an earlier clone from your remote. Any saved but uncommitted changes will be lost, so make sure you copy any modified code that you want to keep in a temporary location outside of dbt.
12. Once you rollback to remote, open the `.gitignore` file in the branch you're working in. If the new changes aren't included, you'll need to merge the latest commits from the main branch into your working branch.
13. Go to the **File Explorer** to verify the `.gitignore` file contains the correct entries and make sure the untracked files/folders in the .gitignore file are in *italics*.
14. Great job 🎉! You've configured the `.gitignore` correctly and can continue with your development!

For more info, refer to this [detailed video](https://www.loom.com/share/9b3b8e2b617f41a8bad76ec7e42dd014) for additional guidance.

I'm seeing a Gitlab authentication out of date error loop

If you're seeing a 'GitLab Authentication is out of date' 500 server error page - this usually occurs when the deploy key in the repository settings in both dbt and GitLab do not match.

No worries - this is a current issue the dbt Labs team is working on and we have a few workarounds for you to try:

#### First workaround[​](#first-workaround "Direct link to First workaround")

1. Disconnect repo from project in dbt.
2. Go to Gitlab and click on Settings > Repository.
3. Under Repository Settings, remove/revoke active dbt deploy tokens and deploy keys.
4. Attempt to reconnect your repository via dbt.
5. You would then need to check Gitlab to make sure that the new deploy key is added.
6. Once confirmed that it's added, refresh dbt and try developing once again.

#### Second workaround[​](#second-workaround "Direct link to Second workaround")

1. Keep repo in project as is -- don't disconnect.
2. Copy the deploy key generated in dbt.
3. Go to Gitlab and click on Settings > Repository.
4. Under Repository Settings, manually add to your Gitlab project deploy key repo (with `Grant write permissions` box checked).
5. Go back to dbt, refresh your page and try developing again.

If you've tried the workarounds above and are still experiencing this behavior - reach out to the Support team at [support@getdbt.com](mailto:support@getdbt.com) and we'll be happy to help!

Can self-hosted GitLab instances only be connected via dbt Enterprise plans?

Presently yes, this is only available to Enterprise users. This is because of the way you have to set up the GitLab app redirect URL for auth, which can only be customized if you're a user on an Enterprise plan.

Check out our [pricing page](https://www.getdbt.com/pricing/) for more information or feel free to [contact us](https://www.getdbt.com/contact) to build your Enterprise pricing.

How to migrate git providers

To migrate from one git provider to another, refer to the following steps to avoid minimal disruption:

1. Outside of dbt, you'll need to import your existing repository into your new provider. By default, connecting your repository in one account won't automatically disconnected it from another account.

   As an example, if you're migrating from GitHub to Azure DevOps, you'll need to import your existing repository (GitHub) into your new Git provider (Azure DevOps). For detailed steps on how to do this, refer to your Git provider's documentation (Such as [GitHub](https://docs.github.com/en/migrations/importing-source-code/using-github-importer/importing-a-repository-with-github-importer), [GitLab](https://docs.gitlab.com/ee/user/project/import/repo_by_url.html), [Azure DevOps](https://learn.microsoft.com/en-us/azure/devops/repos/git/import-git-repository?view=azure-devops))
2. Go back to dbt and set up your [integration for the new Git provider](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud), if needed.
3. Disconnect the old repository in dbt by going to **Account Settings** and then **Projects**.
4. Click on the **Repository** link, then click **Edit** and **Disconnect**.

   [![Disconnect and reconnect your Git repository in your dbt Account settings page.](https://docs.getdbt.com/img/docs/dbt-cloud/disconnect-repo.png?v=2 "Disconnect and reconnect your Git repository in your dbt Account settings page.")](#)Disconnect and reconnect your Git repository in your dbt Account settings page.
5. Click **Confirm Disconnect**.
6. On the same page, connect to the new Git provider repository by clicking **Configure Repository**

   * If you're using the native integration, you may need to OAuth to it.
7. That's it, you should now be connected to the new Git provider! 🎉

Note — As a tip, we recommend you refresh your page and Studio IDE before performing any actions.

GitLab token refresh message

When you connect dbt to a GitLab repository, GitLab automatically creates a [project access token](https://docs.gitlab.com/ee/user/project/settings/project_access_tokens.html) in your GitLab repository in the background. This sends the job run status back to Gitlab using the dbt API for CI jobs.

By default, the project access token follows a naming pattern: `dbt token for GitLab project: <project_id>`. If you have multiple tokens in your repository, look for one that follows this pattern to identify the correct token used by dbt.

If you're receiving a "Refresh token" message, don't worry — dbt automatically refreshes this project access token for you, which means you never have to manually rotate it.

If you still experience any token refresh errors, please try disconnecting and reconnecting the repository in your dbt project to refresh the token.

For any issues, please reach out to the Support team at [support@getdbt.com](mailto:support@getdbt.com) and we'll be happy to help!

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Connect to GitHub](https://docs.getdbt.com/docs/cloud/git/connect-github)[Next

Connect to Azure DevOps](https://docs.getdbt.com/docs/cloud/git/connect-azure-devops)

* [For dbt Developer and Starter plans](#for-dbt-developer-and-starter-plans)
  + [Requirements and limitations](#requirements-and-limitations)* [For the dbt Enterprise plans](#for-the-dbt-enterprise-plans)
    + [Setting up a GitLab OAuth application](#setting-up-a-gitlab-oauth-application)+ [Adding the GitLab OAuth application to dbt](#adding-the-gitlab-oauth-application-to-dbt)+ [Personally authenticating with GitLab](#personally-authenticating-with-gitlab)* [Troubleshooting](#troubleshooting)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/git/connect-gitlab.md)
