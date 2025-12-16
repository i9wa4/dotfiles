---
title: "Connect to GitHub | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/git/connect-github"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Configure Git](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud)* Connect to GitHub

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fconnect-github+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fconnect-github+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fconnect-github+so+I+can+ask+questions+about+it.)

On this page

Connecting your GitHub account to dbt provides convenience and another layer of security to dbt:

* Import new GitHub repositories with a couple clicks during dbt project setup.
* Clone repos using HTTPS rather than SSH.
* Trigger [Continuous integration](https://docs.getdbt.com/docs/deploy/continuous-integration)(CI) builds when pull requests are opened in GitHub.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* For On-Premises GitHub deployment, reference [importing a project by git URL](https://docs.getdbt.com/docs/cloud/git/import-a-project-by-git-url) to set up your connection instead. Some git features are [limited](https://docs.getdbt.com/docs/cloud/git/import-a-project-by-git-url#limited-integration) with this setup.
  + **Note** — [Single tenant](https://docs.getdbt.com/docs/cloud/about-cloud/tenancy#single-tenant) accounts offer enhanced connection options for integrating with an On-Premises GitHub deployment setup using the native integration. This integration allows you to use all the features of the integration, such as triggering CI builds. The dbt Labs infrastructure team will coordinate with you to ensure any additional networking configuration requirements are met and completed. To discuss details, contact dbt Labs support or your dbt account team.
* You *must* be a **GitHub organization owner** in order to [install the dbt application](https://docs.getdbt.com/docs/cloud/git/connect-github#installing-dbt-in-your-github-account) in your GitHub organization. To learn about GitHub organization roles, see the [GitHub documentation](https://docs.github.com/en/organizations/managing-peoples-access-to-your-organization-with-roles/roles-in-an-organization).
* The GitHub organization owner requires [*Owner*](https://docs.getdbt.com/docs/cloud/manage-access/self-service-permissions) or [*Account Admin*](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) permissions when they log into dbt to integrate with a GitHub environment using organizations.
* You may need to temporarily provide an extra dbt user account with *Owner* or *Account Admin* [permissions](https://docs.getdbt.com/docs/cloud/manage-access/enterprise-permissions) for your GitHub organization owner until they complete the installation.

## Installing dbt in your GitHub account[​](#installing-dbt-in-your-github-account "Direct link to Installing dbt in your GitHub account")

You can connect your dbt account to GitHub by installing the dbt application in your GitHub organization and providing access to the appropriate repositories.
To connect your dbt account to your GitHub account:

1. From dbt, click on your account name in the left side menu and select **Account settings**.
2. Select **Personal profile** under the **Your profile** section.
3. Scroll down to **Linked accounts**.

[![Navigated to Linked Accounts under your profile](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/connecting-github/github-connect-1.png?v=2 "Navigated to Linked Accounts under your profile")](#)Navigated to Linked Accounts under your profile

4. In the **Linked accounts** section, set up your GitHub account connection to dbt by clicking **Link** to the right of GitHub. This redirects you to your account on GitHub where you will be asked to install and configure the dbt application.
5. Select the GitHub organization and repositories dbt should access.

   [![Installing the dbt application into a GitHub organization](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/connecting-github/github-app-install.png?v=2 "Installing the dbt application into a GitHub organization")](#)Installing the dbt application into a GitHub organization
6. Assign the dbt GitHub App the following permissions:

   * Read access to metadata
   * Read and write access to Checks
   * Read and write access to Commit statuses
   * Read and write access to Contents (Code)
   * Read and write access to Pull requests
   * Read and write access to Webhooks
   * Read and write access to Workflows
7. Once you grant access to the app, you will be redirected back to dbt and shown a linked account success state. You are now personally authenticated.
8. Ask your team members to individually authenticate by connecting their [personal GitHub profiles](#authenticate-your-personal-github-account).

## Limiting repository access in GitHub[​](#limiting-repository-access-in-github "Direct link to Limiting repository access in GitHub")

If you are your GitHub organization owner, you can also configure the dbt GitHub application to have access to only select repositories. This configuration must be done in GitHub, but we provide an easy link in dbt to start this process.

[![Configuring the dbt app](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/connecting-github/configure-github.png?v=2 "Configuring the dbt app")](#)Configuring the dbt app

## Authenticate your personal GitHub account[​](#authenticate-your-personal-github-account "Direct link to Authenticate your personal GitHub account")

After the dbt administrator [sets up a connection](https://docs.getdbt.com/docs/cloud/git/connect-github#installing-dbt-cloud-in-your-github-account) to your organization's GitHub account, you need to authenticate using your personal account. You must connect your personal GitHub profile to dbt to use the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio) and [CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation) and verify your read and write access to the repository.

GitHub profile connection

* dbt developers on the [Enterprise or Enterprise+ plan](https://www.getdbt.com/pricing/) must each connect their GitHub profiles to dbt. This is because the Studio IDE verifies every developer's read / write access for the dbt repo.
* dbt developers on the [Starter plan](https://www.getdbt.com/pricing/) don't need to each connect their profiles to GitHub, however, it's still recommended to do so.

To connect a personal GitHub account:

1. From dbt, click on your account name in the left side menu and select **Account settings**.
2. Select **Personal profile** under the **Your profile** section.
3. Scroll down to **Linked accounts**. If your GitHub account is not connected, you’ll see "No connected account".
4. Select **Link** to begin the setup process. You’ll be redirected to GitHub, and asked to authorize dbt in a grant screen.

[![Authorizing the dbt app for developers](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-configuring-dbt-cloud/connecting-github/github-auth.png?v=2 "Authorizing the dbt app for developers")](#)Authorizing the dbt app for developers

5. Once you approve authorization, you will be redirected to dbt, and you should now see your connected account.

You can now use the Studio IDE or dbt CLI.

## FAQs[​](#faqs "Direct link to FAQs")

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

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Connect with Git clone](https://docs.getdbt.com/docs/cloud/git/import-a-project-by-git-url)[Next

Connect to GitLab](https://docs.getdbt.com/docs/cloud/git/connect-gitlab)

* [Prerequisites](#prerequisites)* [Installing dbt in your GitHub account](#installing-dbt-in-your-github-account)* [Limiting repository access in GitHub](#limiting-repository-access-in-github)* [Authenticate your personal GitHub account](#authenticate-your-personal-github-account)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/git/connect-github.md)
