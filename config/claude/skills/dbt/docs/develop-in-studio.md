---
title: "About the Studio IDE | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Develop with dbt](https://docs.getdbt.com/docs/cloud/about-develop-dbt)* dbt Studio IDE

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fstudio-ide%2Fdevelop-in-studio+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fstudio-ide%2Fdevelop-in-studio+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcloud%2Fstudio-ide%2Fdevelop-in-studio+so+I+can+ask+questions+about+it.)

On this page

The dbt integrated development environment (Studio IDE) is a single web-based interface for building, testing, running, and version-controlling dbt projects. It compiles dbt code into SQL and executes it directly on your database.

The Studio IDE offers several [keyboard shortcuts](https://docs.getdbt.com/docs/cloud/studio-ide/keyboard-shortcuts) and [editing features](https://docs.getdbt.com/docs/cloud/studio-ide/ide-user-interface#editing-features) for faster and efficient development and governance:

* Syntax highlighting for SQL — Makes it easy to distinguish different parts of your code, reducing syntax errors and enhancing readability.
* AI copilot — Use [Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot), an AI-powered assistant that can [generate code](https://docs.getdbt.com/docs/cloud/studio-ide/develop-copilot#generate-and-edit-code) using natural language, and [generate resources](https://docs.getdbt.com/docs/cloud/studio-ide/develop-copilot#generate-resources) (like documentation, tests, and semantic models) for you — with the click of a button. Check out [Develop with Copilot](https://docs.getdbt.com/docs/cloud/studio-ide/develop-copilot) for more details.
* Auto-completion — Suggests table names, arguments, and column names as you type, saving time and reducing typos.
* Code [formatting and linting](https://docs.getdbt.com/docs/cloud/studio-ide/lint-format) — Helps standardize and fix your SQL code effortlessly.
* Navigation tools — Easily move around your code, jump to specific lines, find and replace text, and navigate between project files.
* Version control — Manage code versions with a few clicks.
* Project documentation — Generate and view your [project documentation](#build-and-document-your-projects) for your dbt project in real-time.
* Build, test, and run button — Build, test, and run your project with a button click or by using the Studio IDE command bar.

These [features](#dbt-cloud-ide-features) create a powerful editing environment for efficient SQL coding, suitable for both experienced and beginner developers.

[![The Studio IDE includes version control, files/folders, an editor, a command/console, and more.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/ide-basic-layout.png?v=2 "The Studio IDE includes version control, files/folders, an editor, a command/console, and more.")](#)The Studio IDE includes version control, files/folders, an editor, a command/console, and more.

[![Enable dark mode for a great viewing experience in low-light environments.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/cloud-ide-v2.png?v=2 "Enable dark mode for a great viewing experience in low-light environments.")](#)Enable dark mode for a great viewing experience in low-light environments.

Disable ad blockers

To improve your experience using dbt, we suggest that you turn off ad blockers. This is because some project file names, such as `google_adwords.sql`, might resemble ad traffic and trigger ad blockers.

## Prerequisites[​](#prerequisites "Direct link to Prerequisites")

* A [dbt account](https://www.getdbt.com/signup) and [Developer seat license](https://docs.getdbt.com/docs/cloud/manage-access/seats-and-users)
* A git repository set up and git provider must have `write` access enabled. See [Connecting your GitHub Account](https://docs.getdbt.com/docs/cloud/git/connect-github) or [Importing a project by git URL](https://docs.getdbt.com/docs/cloud/git/import-a-project-by-git-url) for detailed setup instructions
* A dbt project connected to a [data platform](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections)
* A [development environment and development credentials](#get-started-with-the-cloud-ide) set up
* The environment must be on dbt version 1.0 or higher

## Studio IDE features[​](#studio-ide-features "Direct link to Studio IDE features")

The Studio IDE comes with features that make it easier for you to develop, build, compile, run, and test data models.

To understand how to navigate the Studio IDE and its user interface elements, refer to the [Studio IDE user interface](https://docs.getdbt.com/docs/cloud/studio-ide/ide-user-interface) page.

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Feature Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | [**Studio IDE shortcuts**](https://docs.getdbt.com/docs/cloud/studio-ide/keyboard-shortcuts) You can access a variety of [commands and actions](https://docs.getdbt.com/docs/cloud/studio-ide/keyboard-shortcuts) in the Studio IDE by choosing the appropriate keyboard shortcut. Use the shortcuts for common tasks like building modified models or resuming builds from the last failure.| **IDE version control** The Studio IDE version control section and git button allow you to apply the concept of [version control](https://docs.getdbt.com/docs/cloud/git/version-control-basics) to your project directly into the Studio IDE.    - Create or change branches, execute git commands using the git button.  - Commit or revert individual files by right-clicking the edited file  - [Resolve merge conflicts](https://docs.getdbt.com/docs/cloud/git/merge-conflicts)  - Link to the repo directly by clicking the branch name   - Edit, format, or lint files and execute dbt commands in your primary protected branch, and commit to a new branch.  - Use Git diff view to view what has been changed in a file before you make a pull request.  - Use the **Prune branches** [button](https://docs.getdbt.com/docs/cloud/studio-ide/ide-user-interface#prune-branches-modal) to delete local branches that have been deleted from the remote repository, keeping your branch management tidy.  - Sign your [git commits](https://docs.getdbt.com/docs/cloud/studio-ide/git-commit-signing) to mark them as 'Verified'. [Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")| **Preview and Compile button** You can [compile or preview](https://docs.getdbt.com/docs/cloud/studio-ide/ide-user-interface#console-section) code, a snippet of dbt code, or one of your dbt models after editing and saving.| [**Copilot**](https://docs.getdbt.com/docs/cloud/studio-ide/develop-copilot) A powerful AI-powered assistant that can [generate code](https://docs.getdbt.com/docs/cloud/studio-ide/develop-copilot#generate-and-edit-code) using natural language, and [generate resources](https://docs.getdbt.com/docs/cloud/studio-ide/develop-copilot#generate-resources) (like documentation, tests, metrics, and semantic models) for you — with the click of a button. [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing").| **Build, test, and run button** Build, test, and run your project with the click of a button or by using the command bar.|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | **Command bar** You can enter and run commands from the command bar at the bottom of the Studio IDE. Use the [rich model selection syntax](https://docs.getdbt.com/reference/node-selection/syntax) to execute [dbt commands](https://docs.getdbt.com/reference/dbt-commands) directly within dbt. You can also view the history, status, and logs of previous runs by clicking History on the left of the bar.| **Drag and drop** Drag and drop files located in the file explorer, and use the file breadcrumb on the top of the Studio IDE for quick, linear navigation. Access adjacent files in the same file by right-clicking on the breadcrumb file.| **Organize tabs and files** - Move your tabs around to reorganize your work in the IDE   - Right-click on a tab to view and select a list of actions, including duplicate files   - Close multiple, unsaved tabs to batch save your work   - Double click files to rename files| **Find and replace** - Press Command-F or Control-F to open the find-and-replace bar in the upper right corner of the current file in the IDE. The IDE highlights your search results in the current file and code outline  - You can use the up and down arrows to see the match highlighted in the current file when there are multiple matches  - Use the left arrow to replace the text with something else| **Multiple selections** You can make multiple selections for small and simultaneous edits. The below commands are a common way to add more cursors and allow you to insert cursors below or above with ease.   - Option-Command-Down arrow or Ctrl-Alt-Down arrow  - Option-Command-Up arrow or Ctrl-Alt-Up arrow  - Press Option and click on an area or Press Ctrl-Alt and click on an area | **Lint and Format** [Lint and format](https://docs.getdbt.com/docs/cloud/studio-ide/lint-format) your files with a click of a button, powered by SQLFluff, sqlfmt, Prettier, and Black.| **dbt autocomplete** Autocomplete features to help you develop faster:   - Use `ref` to autocomplete your model names  - Use `source` to autocomplete your source name + table name  - Use `macro` to autocomplete your arguments  - Use `env var` to autocomplete env var  - Start typing a hyphen (-) to use in-line autocomplete in a YAML file  - Automatically create models from dbt sources with a click of a button.| **DAG in the IDE** You can see how models are used as building blocks from left to right to transform your data from raw sources into cleaned-up modular derived pieces and final outputs on the far right of the DAG. The default view is 2+model+2 (defaults to display 2 nodes away), however, you can change it to +model+ (full DAG). Note the `--exclude` flag isn't supported.| **Status bar** This area provides you with useful information about your Studio IDE and project status. You also have additional options like enabling light or dark mode, restarting the Studio IDE, or [recloning your repo](https://docs.getdbt.com/docs/cloud/git/version-control-basics).| **Dark mode** From the status bar in the Studio IDE, enable dark mode for a great viewing experience in low-light environments. | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

### Code generation[​](#code-generation "Direct link to Code generation")

The Studio IDE comes with **CodeGenCodeLens**, a powerful feature that simplifies creating models from your sources with a click of a button. To use this feature, click on the **Generate model** action next to each table in the source YAML file(s). It automatically creates a basic starting staging model for you to expand on. This feature helps streamline your workflow by automating the first steps of model generation.

### dbt YAML validation[​](#dbt-yaml-validation "Direct link to dbt YAML validation")

Use dbt-jsonschema to validate dbt YAML files, helping you leverage the autocomplete and assistance capabilities of the Studio IDE. This also provides immediate feedback on YAML file structure and syntax, helping you make sure your project configurations meet the required standards.

## Get started with the Studio IDE[​](#get-started-with-the-studio-ide "Direct link to Get started with the Studio IDE")

In order to start experiencing the great features of the Studio IDE, you need to first set up a [dbt development environment](https://docs.getdbt.com/docs/dbt-cloud-environments). In the following steps, we outline how to set up developer credentials and access the Studio IDE. If you're creating a new project, you will automatically configure this during the project setup.

The Studio IDE uses developer credentials to connect to your data platform. These developer credentials should be specific to your user and they should *not* be super user credentials or the same credentials that you use for your production deployment of dbt.

Set up your developer credentials:

1. Navigate to your **Credentials** under **Your Profile** settings, which you can access at `https://YOUR_ACCESS_URL/settings/profile#credentials`, replacing `YOUR_ACCESS_URL` with the [appropriate Access URL](https://docs.getdbt.com/docs/cloud/about-cloud/access-regions-ip-addresses) for your region and plan.
2. Select the relevant project in the list.
3. Click **Edit** on the bottom right of the page.
4. Enter the details under **Development Credentials**.
5. Click **Save.**

[![Configure developer credentials in your profile](https://docs.getdbt.com/img/docs/dbt-cloud/refresh-ide/dev-credentials.png?v=2 "Configure developer credentials in your profile")](#)Configure developer credentials in your profile

6. Navigate to the Studio IDE by clicking **Studio** in the left menu.
7. Initialize your project and familiarize yourself with the Studio IDE and its delightful [features](#cloud-ide-features).

Nice job, you're ready to start developing and building models 🎉!

### Considerations[​](#considerations "Direct link to Considerations")

* To improve your experience using dbt, we suggest that you turn off ad blockers. This is because some project file names, such as `google_adwords.sql`, might resemble ad traffic and trigger ad blockers.
* To preserve performance, there's a file size limitation for repositories over 6 GB. If you have a repo over 6 GB, please contact [dbt Support](mailto:support@getdbt.com) before running dbt.
* The Studio IDE's idle session timeout is one hour.
* About the start up process and work retention

  The following sections describe the start-up process and work retention in the Studio IDE.
  + #### Start-up process[​](#start-up-process "Direct link to Start-up process")

    There are three start-up states when using or launching the Studio IDE:

    - **Creation start —** This is the state where you are starting the IDE for the first time. You can also view this as a *cold start* (see below), and you can expect this state to take longer because the git repository is being cloned.
    - **Cold start —** This is the process of starting a new develop session, which will be available for you for one hour. The environment automatically turns off one hour after the last activity. This includes compile, preview, or any dbt invocation, however, it *does not* include editing and saving a file.
    - **Hot start —** This is the state of resuming an existing or active develop session within one hour of the last activity.
  + #### Work retention[​](#work-retention "Direct link to Work retention")

    The Studio IDE needs explicit action to save your changes. There are three ways your work is stored:

    - **Unsaved, local code —** The browser stores your code only in its local storage. In this state, you might need to commit any unsaved changes in order to switch branches or browsers. If you have saved and committed changes, you can access the "Change branch" option even if there are unsaved changes. But if you attempt to switch branches without saving changes, a warning message will appear, notifying you that you will lose any unsaved changes.

    [![If you attempt to switch branches without saving changes, a warning message will appear, telling you that you will lose your changes.](https://docs.getdbt.com/img/docs/dbt-cloud/cloud-ide/ide-unsaved-modal.png?v=2 "If you attempt to switch branches without saving changes, a warning message will appear, telling you that you will lose your changes.")](#)If you attempt to switch branches without saving changes, a warning message will appear, telling you that you will lose your changes.

    - **Saved but uncommitted code —** When you save a file, the data gets stored in durable, long-term storage, but isn't synced back to git. To switch branches using the **Change branch** option, you must "Commit and sync" or "Revert" changes. Changing branches isn't available for saved-but-uncommitted code. This is to ensure your uncommitted changes don't get lost.
    - **Committed code —** This is stored in the branch with your git provider and you can check out other (remote) branches.

## Build and document your projects[​](#build-and-document-your-projects "Direct link to Build and document your projects")

* **Build, compile, and run projects** — You can *build*, *compile*, *run*, and *test* dbt projects using the command bar or **Build** button. Use the **Build** button to quickly build, run, or test the model you're working on. The Studio IDE will update in real time when you run models, tests, seeds, and operations.

  + If a model or test fails, dbt makes it easy for you to view and download the run logs for your dbt invocations to fix the issue.
  + Use dbt's [rich model selection syntax](https://docs.getdbt.com/reference/node-selection/syntax) to [run dbt commands](https://docs.getdbt.com/reference/dbt-commands) directly within dbt.
  + Leverage [environments variables](https://docs.getdbt.com/docs/build/environment-variables#special-environment-variables) to dynamically use the Git branch name. For example, using the branch name as a prefix for a development schema.
  + Run [MetricFlow commands](https://docs.getdbt.com/docs/build/metricflow-commands) to create and manage metrics in your project with the [Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl).
* **Generate your YAML configurations with Copilot** — [dbt Copilot](https://docs.getdbt.com/docs/cloud/dbt-copilot) is a powerful artificial intelligence (AI) feature that helps automate development in dbt. It can [generate code](https://docs.getdbt.com/docs/cloud/studio-ide/develop-copilot#generate-and-edit-code) using natural language, and [generate resources](https://docs.getdbt.com/docs/cloud/studio-ide/develop-copilot#generate-resources) (like documentation, tests, metrics,and semantic models) for you directly in the Studio IDE, so you can accomplish more in less time. [Starter](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")[Enterprise +](https://www.getdbt.com/pricing "Go to https://www.getdbt.com/pricing")
* **Build and view your project's docs** — The Studio IDE makes it possible to [build and view](https://docs.getdbt.com/docs/explore/build-and-view-your-docs) documentation for your dbt project while your code is still in development. With this workflow, you can inspect and verify what your project's generated documentation will look like before your changes are released to production.

## Related docs[​](#related-docs "Direct link to Related docs")

* [How we style our dbt projects](https://docs.getdbt.com/best-practices/how-we-style/0-how-we-style-our-dbt-projects)
* [User interface](https://docs.getdbt.com/docs/cloud/studio-ide/ide-user-interface)
* [Version control basics](https://docs.getdbt.com/docs/cloud/git/version-control-basics)
* [dbt commands](https://docs.getdbt.com/reference/dbt-commands)

## FAQs[​](#faqs "Direct link to FAQs")

Is there a cost to using the Studio IDE?

Not at all! You can use dbt when you sign up for the [Free Developer plan](https://www.getdbt.com/pricing/), which comes with one developer seat. If you'd like to access more features or have more developer seats, you can upgrade your account to the Starter, Enterprise, or Enterprise+ plan.

Refer to [dbt pricing plans](https://www.getdbt.com/pricing/) for more details.

Can I be a contributor to dbt

As a proprietary product, dbt's source code isn't available for community contributions. If you want to build something in the dbt ecosystem, we encourage you to review [this article](https://docs.getdbt.com/community/contributing/contributing-coding) about contributing to a dbt package, a plugin, dbt-core, or this documentation site. Participation in open-source is a great way to level yourself up as a developer, and give back to the community.

What is the difference between developing on the Studio IDE, the dbt CLI, and dbt Core?

You can develop dbt using the web-based IDE in dbt or on the command line interface using the Cloud CLI or open-source dbt Core, all of which enable you to execute dbt commands. The key distinction between the Cloud CLI and dbt Core is the Cloud CLI is tailored for dbt's infrastructure and integrates with all its features:

* Studio IDE: [dbt](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features) is a web-based application that allows you to develop dbt projects with the IDE, includes a purpose-built scheduler, and provides an easier way to share your dbt documentation with your team. The IDE is a faster and more reliable way to deploy your dbt models and provides a real-time editing and execution environment for your dbt project.
* Cloud CLI: [The Cloud CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation) allows you to run dbt commands against your dbt dbt development environment from your local command line or code editor. It supports cross-project ref, speedier, lower-cost builds, automatic deferral of build artifacts, and more.
* dbt Core: dbt Core is an [open-sourced](https://github.com/dbt-labs/dbt) software that's freely available. You can build your dbt project in a code editor, and run dbt commands from the command line

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

Keyboard shortcuts](https://docs.getdbt.com/docs/cloud/studio-ide/keyboard-shortcuts)

* [Prerequisites](#prerequisites)* [Studio IDE features](#studio-ide-features)
    + [Code generation](#code-generation)+ [dbt YAML validation](#dbt-yaml-validation)* [Get started with the Studio IDE](#get-started-with-the-studio-ide)
      + [Considerations](#considerations)* [Build and document your projects](#build-and-document-your-projects)* [Related docs](#related-docs)* [FAQs](#faqs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/cloud/studio-ide/develop-in-the-cloud.md)
