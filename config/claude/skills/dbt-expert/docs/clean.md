---
title: "About dbt clean command | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/commands/clean"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [List of commands](https://docs.getdbt.com/category/list-of-commands)* clean

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fclean+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fclean+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fclean+so+I+can+ask+questions+about+it.)

On this page

`dbt clean` is a utility function that deletes the paths specified within the [`clean-targets`](https://docs.getdbt.com/reference/project-configs/clean-targets) list in the `dbt_project.yml` file. It helps by removing unnecessary files or directories generated during the execution of other dbt commands, ensuring a clean state for the project.

## Example usage[​](#example-usage "Direct link to Example usage")

```
dbt clean
```

## Supported flags[​](#supported-flags "Direct link to Supported flags")

This section will briefly explain the following flags:

* [`--clean-project-files-only`](#--clean-project-files-only) (default)
* [`--no-clean-project-files-only`](#--no-clean-project-files-only)

To view the list of all supported flags for the `dbt clean` command in the terminal, use the `--help` flag, which will display detailed information about the available flags you can use, including its description and usage:

```
dbt clean --help
```

### --clean-project-files-only[​](#--clean-project-files-only "Direct link to --clean-project-files-only")

By default, dbt deletes all the paths within the project directory specified in `clean-targets`.

note

Avoid using paths outside the dbt project; otherwise, you will see an error.

#### Example usage[​](#example-usage-1 "Direct link to Example usage")

```
dbt clean --clean-project-files-only
```

### --no-clean-project-files-only[​](#--no-clean-project-files-only "Direct link to --no-clean-project-files-only")

Deletes all the paths specified in the `clean-targets` list of `dbt_project.yml`, including those outside the current dbt project.

```
dbt clean --no-clean-project-files-only
```

## dbt clean with remote file system[​](#dbt-clean-with-remote-file-system "Direct link to dbt clean with remote file system")

To avoid complex permissions issues and potentially deleting crucial aspects of the remote file system without access to fix them, this command does not work when interfacing with the RPC server that powers the Studio IDE. Instead, when working in dbt, the `dbt deps` command cleans before it installs packages automatically. The `target` folder can be manually deleted from the sidebar file tree if needed.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

build](https://docs.getdbt.com/reference/commands/build)[Next

clone](https://docs.getdbt.com/reference/commands/clone)

* [Example usage](#example-usage)* [Supported flags](#supported-flags)
    + [--clean-project-files-only](#--clean-project-files-only)+ [--no-clean-project-files-only](#--no-clean-project-files-only)* [dbt clean with remote file system](#dbt-clean-with-remote-file-system)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/commands/clean.md)
