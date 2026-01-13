---
title: "Version control basics | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/git/version-control-basics"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt platform](https://docs.getdbt.com/docs/cloud/about-cloud-setup)* [Configure Git](https://docs.getdbt.com/docs/cloud/git/git-configuration-in-dbt-cloud)* [Git version control](https://docs.getdbt.com/docs/cloud/git/git-version-control)* Version control basics

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fversion-control-basics+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fversion-control-basics+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fgit%2Fversion-control-basics+so+I+can+ask+questions+about+it.)

On this page

When you develop in the command line interface (CLI) or Cloud integrated development environment (Studio IDE), you can leverage Git directly to version control your code. To use version control, make sure you are connected to a Git repository in the CLI or Studio IDE.

You can create a separate branch to develop and make changes. The changes you make aren’t merged into the default branch in your connected repository (typically named the `main` branch) unless it successfully passes tests. This helps keep the code organized and improves productivity by making the development process smooth.

You can read more about git terminology below and also check out [GitHub Docs](https://docs.github.com/en) as well.

## Git overview[​](#git-overview "Direct link to Git overview")

Check out some common git terms below that you might encounter when developing:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name Definition|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Repository or repo A repository is a directory that stores all the files, folders, and content needed for your project. You can think of this as an object database of the project, storing everything from the files themselves to the versions of those files, commits, and deletions. Repositories are not limited by user and can be shared and copied.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Branch A branch is a parallel version of a repository. It is contained within the repository but does not affect the primary or main branch allowing you to work freely without disrupting the live version. When you've made the changes you want to make, you can merge your branch back into the main branch to publish your changes|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Checkout The `checkout` command is used to create a new branch, change your current working branch to a different branch, or switch to a different version of a file from a different branch.| Commit A commit is a user’s change to a file (or set of files). When you make a commit to save your work, Git creates a unique ID that allows you to keep a record of the specific changes committed along with who made them and when. Commits usually contain a commit message which is a brief description of what changes were made.| main The primary, base branch of all repositories. All committed and accepted changes should be on the main branch.   In the Studio IDE, the main branch is protected. This means you can't directly edit, format, or lint files, and execute dbt commands in your protected primary git branch when using the dbt platform user interface. Keep in mind that all Studio IDE Git activity is subject to the permissions of your configured credentials, and the rules configured at the remote Git provider (for example, GitHub or GitLab branch protection). Since the Studio IDE prevents commits to the protected branch, you can commit those changes to a new branch.| Merge Merge takes the changes from one branch and adds them into another (usually main) branch. These commits are usually first requested via pull request before being merged by a maintainer.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Pull Request If someone has changed code on a separate branch of a project and wants it to be reviewed to add to the main branch, they can submit a pull request. Pull requests ask the repo maintainers to review the commits made, and then, if acceptable, merge the changes upstream. A pull happens when adding the changes to the main branch.|  |  |  |  | | --- | --- | --- | --- | | Push A `push` updates a remote branch with the commits made to the current branch. You are literally *pushing* your changes into the remote.| Remote This is the version of a repository or branch that is hosted on a server. Remote versions can be connected to local clones so that changes can be synced. | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## The git button in the Cloud IDE[​](#the-git-button-in-the-cloud-ide "Direct link to The git button in the Cloud IDE")

You can perform git tasks with the git button in the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio). The following are descriptions of each git button command and what they do:

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Name Actions|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Abort merge This option allows you to cancel a merge that had conflicts. Be careful with this action because all changes will be reset and this operation can't be reverted, so make sure to commit or save all your changes before you start a merge.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Change branch This option allows you to change between branches (checkout).|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | Commit A commit is an individual change to a file (or set of files). When you make a commit to save your work, Git creates a unique ID (a.k.a. the "SHA" or "hash") that allows you to keep record of the specific changes committed along with who made them and when. Commits usually contain a commit message which is a brief description of what changes were made. When you make changes to your code in the future, you'll need to commit them as well.| Create new branch This allows you to branch off of your base branch and edit your project. You’ll notice after initializing your project that the main branch is protected.   This means you can directly edit, format, or lint files and execute dbt commands in your protected primary git branch. When ready, you can commit those changes to a new branch.| Initialize your project This is done when first setting up your project. Initializing a project creates all required directories and files within an empty repository by using the dbt starter project.   Note: This option will not display if your repo isn't completely empty (i.e. includes a README file).   Once you click **Initialize your project**, click **Commit** to finish setting up your project.| Open pull request This allows you to open a pull request in Git for peers to review changes before merging into the base branch.| Pull changes from main This option is available if you are on any local branch that is behind the remote version of the base branch or the remote version of the branch that you're currently on.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | Pull from remote This option is available if you’re on the local base branch and changes have recently been pushed to the remote version of the branch. Pulling in changes from the remote repo allows you to pull in the most recent version of the base branch.|  |  |  |  | | --- | --- | --- | --- | | Rollback to remote Reset changes to your repository directly from the Studio IDE. You can rollback your repository back to an earlier clone from your remote. To do this, click on the three dot ellipsis in the bottom right-hand side of the Studio IDE and select **Rollback to remote**.| Refresh git state This enables you to pull new branches from a different remote branch to your local branch with just one command. | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Merge conflicts[​](#merge-conflicts "Direct link to Merge conflicts")

Merge conflicts often occur when multiple users are concurrently making edits to the same section in the same file. This makes it difficult for Git to determine which change should be kept.

Refer to [merge conflicts](https://docs.getdbt.com/docs/cloud/git/merge-conflicts) to learn how to resolve merge conflicts.

## The .gitignore file[​](#the-gitignore-file "Direct link to The .gitignore file")

dbt implements a global [`.gitignore file`](https://github.com/dbt-labs/dbt-starter-project/blob/main/.gitignore) that automatically excludes the following sub-folders from your git repository to ensure smooth operation:

```
dbt_packages/
logs/
target/
```

This inclusion uses a trailing slash, making these lines in the `.gitignore` file act as 'folder wildcards' that prevent any files or folders within them from being tracked by git. You can also specify additional exclusions as needed for your project.

However, this global `.gitignore` *does not* apply to dbt Core and Cloud CLI users directly. Therefore, if you're working with dbt Core or Cloud CLI, you need to manually add the three lines mentioned previously to your project's `.gitignore` file.

It's worth noting that while some git providers generate a basic `.gitignore` file when the repository is created, these often lack the necessary exclusions for dbt. This means it's important to ensure you add the three lines mentioned previously in your `.gitignore` to ensure dbt operates smoothly.

note

* **dbt projects created after Dec 1, 2022** — If you use the **Initialize dbt Project** button in the Studio IDE to set up a new and empty dbt project, dbt will automatically add a `.gitignore` file with the required entries. If a `.gitignore` file already exists, the necessary folders will be appended to the existing file.
* **Migrating project from dbt Core to dbt** — Make sure you check the `.gitignore` file contains the necessary entries. dbt Core doesn't interact with git so dbt doesn't automatically add or verify entries in the `.gitignore` file. Additionally, if the repository already contains dbt code and doesn't require initialization, dbt won't add any missing entries to the .gitignore file.

For additional info or troubleshooting tips please refer to the [detailed FAQ](https://docs.getdbt.com/faqs/Git/gitignore).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

About git](https://docs.getdbt.com/docs/cloud/git/git-version-control)[Next

PR template](https://docs.getdbt.com/docs/cloud/git/pr-template)

* [Git overview](#git-overview)* [The git button in the Cloud IDE](#the-git-button-in-the-cloud-ide)* [Merge conflicts](#merge-conflicts)* [The .gitignore file](#the-gitignore-file)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/git/version-control-basics.md)
