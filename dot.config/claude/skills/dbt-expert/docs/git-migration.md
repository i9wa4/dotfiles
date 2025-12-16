---
title: "How to migrate git providers | dbt Developer Hub"
source_url: "https://docs.getdbt.com/faqs/Git/git-migration"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Frequently asked questions](https://docs.getdbt.com/docs/faqs)* [Git](https://docs.getdbt.com/category/git)* How to migrate git providers

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FGit%2Fgit-migration+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FGit%2Fgit-migration+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Ffaqs%2FGit%2Fgit-migration+so+I+can+ask+questions+about+it.)

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

Git](https://docs.getdbt.com/category/git)[Next

GitHub and dbt permissions error](https://docs.getdbt.com/faqs/Git/github-permissions)
