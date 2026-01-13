---
title: "Run your dbt projects | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/running-a-dbt-project/run-your-dbt-projects"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* Run your dbt projects

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Frunning-a-dbt-project%2Frun-your-dbt-projects+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Frunning-a-dbt-project%2Frun-your-dbt-projects+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Frunning-a-dbt-project%2Frun-your-dbt-projects+so+I+can+ask+questions+about+it.)

On this page

You can run your dbt projects with [dbt](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features) or [dbt Core](https://github.com/dbt-labs/dbt-core):

* **dbt**: A hosted application where you can develop directly from a web browser using the [Studio IDE](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio). It also natively supports developing using a command line interface, [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation). Among other features, dbt provides:

  + Development environment to help you build, test, run, and [version control](https://docs.getdbt.com/docs/cloud/git/git-version-control) your project faster.
  + Share your [dbt project's documentation](https://docs.getdbt.com/docs/build/documentation) with your team.
  + Integrates with the Studio IDE, allowing you to run development tasks and environment in the dbt UI for a seamless experience.
  + The dbt CLI to develop and run dbt commands against your dbt development environment from your local command line.
  + For more details, refer to [Develop dbt](https://docs.getdbt.com/docs/cloud/about-develop-dbt).
* **dbt Core**: An open source project where you can develop from the [command line](https://docs.getdbt.com/docs/core/installation-overview).

The dbt CLI and dbt Core are both command line tools that enable you to run dbt commands. The key distinction is the dbt CLI is tailored for dbt's infrastructure and integrates with all its [features](https://docs.getdbt.com/docs/cloud/about-cloud/dbt-cloud-features).

The command line is available from your computer's terminal application such as Terminal and iTerm. With the command line, you can run commands and do other work from the current working directory on your computer. Before running the dbt project from the command line, make sure you are working in your dbt project directory. Learning terminal commands such as `cd` (change directory), `ls` (list directory contents), and `pwd` (present working directory) can help you navigate the directory structure on your system.

In dbt or dbt Core, the commands you commonly use are:

* [dbt run](https://docs.getdbt.com/reference/commands/run) — Runs the models you defined in your project
* [dbt build](https://docs.getdbt.com/reference/commands/build) — Builds and tests your selected resources such as models, seeds, snapshots, and tests
* [dbt test](https://docs.getdbt.com/reference/commands/test) — Executes the tests you defined for your project

For information on all dbt commands and their arguments (flags), see the [dbt command reference](https://docs.getdbt.com/reference/dbt-commands). If you want to list all dbt commands from the command line, run `dbt --help`. To list a dbt command’s specific arguments, run `dbt COMMAND_NAME --help` .

## Related docs[​](#related-docs "Direct link to Related docs")

* [How we set up our computers for working on dbt projects](https://discourse.getdbt.com/t/how-we-set-up-our-computers-for-working-on-dbt-projects/243)
* [Model selection syntax](https://docs.getdbt.com/reference/node-selection/syntax)
* [dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation)
* [Cloud Studio IDE features](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio#ide-features)
* [Does dbt offer extract and load functionality?](https://docs.getdbt.com/faqs/Project/transformation-tool)
* [Why does dbt compile need a data platform connection](https://docs.getdbt.com/faqs/Warehouse/db-connection-dbt-compile)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

Use threads](https://docs.getdbt.com/docs/running-a-dbt-project/using-threads)

* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/running-a-dbt-project/run-your-dbt-projects.md)
