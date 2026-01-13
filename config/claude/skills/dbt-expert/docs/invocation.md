---
title: "About dbt invocation command | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/commands/invocation"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [List of commands](https://docs.getdbt.com/category/list-of-commands)* invocation

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Finvocation+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Finvocation+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Finvocation+so+I+can+ask+questions+about+it.)

On this page

The `dbt invocation` command is available in the [Cloud CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation) and allows you to:

* List active invocations to debug long-running or hanging invocations.
* Identify and investigate sessions causing the `Session occupied` error.
* Monitor currently active dbt commands (like `run`, `build`) in real-time.

The `dbt invocation` command only lists *active invocations*. If no sessions are running, the list will be empty. Completed sessions aren't included in the output.

## Usage[​](#usage "Direct link to Usage")

This page lists the command and flag you can use with `dbt invocation`. To use them, add a command or option like this: `dbt invocation [command]`.

Available flags in the command line interface (CLI) are [`help`](#dbt-invocation-help) and [`list`](#dbt-invocation-list).

### dbt invocation help[​](#dbt-invocation-help "Direct link to dbt invocation help")

The `help` command provides you with the help output for the `invocation` command in the CLI, including the available flags.

```
dbt invocation help
```

or

```
dbt help invocation
```

The command returns the following information:

```
dbt invocation help
Manage invocations

Usage:
  dbt invocation [command]

Available Commands:
  list        List active invocations

Flags:
  -h, --help   help for invocation

Global Flags:
      --log-format LogFormat   The log format, either json or plain. (default plain)
      --log-level LogLevel     The log level, one of debug, info, warning, error or fatal. (default info)
      --no-color               Disables colorization of the output.
  -q, --quiet                  Suppress all non-error logging to stdout.

Use "dbt invocation [command] --help" for more information about a command.
```

### dbt invocation list[​](#dbt-invocation-list "Direct link to dbt invocation list")

The `list` command provides you with a list of active invocations in your Cloud CLI. When a long-running session is active, you can use this command in a separate terminal window to view the active session to help debug the issue.

```
dbt invocation list
```

The command returns the following information, including the `ID`, `status`, `type`, `arguments`, and `started at` time of the active session:

```
dbt invocation list

Active Invocations:
  ID                             6dcf4723-e057-48b5-946f-a4d87e1d117a
  Status                         running
  Type                           cli
  Args                           [run --select test.sql]
  Started At                     2025-01-24 11:03:19

➜  jaffle-shop git:(test-cli) ✗
```

tip

To cancel an active session in the terminal, use the `Ctrl + Z` shortcut.

## Related docs[​](#related-docs "Direct link to Related docs")

* [Install dbt CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation)
* [Troubleshooting dbt CLI 'Session occupied' error](https://docs.getdbt.com/faqs/Troubleshooting/long-sessions-cloud-cli)

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

init](https://docs.getdbt.com/reference/commands/init)[Next

ls (list)](https://docs.getdbt.com/reference/commands/list)

* [Usage](#usage)
  + [dbt invocation help](#dbt-invocation-help)+ [dbt invocation list](#dbt-invocation-list)* [Related docs](#related-docs)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/commands/invocation.md)
