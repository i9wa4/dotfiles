---
title: "About dbt environment command | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/commands/dbt-environment"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [List of commands](https://docs.getdbt.com/category/list-of-commands)* environment

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fdbt-environment+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fdbt-environment+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Fdbt-environment+so+I+can+ask+questions+about+it.)

On this page

The `dbt environment` command enables you to interact with your dbt environment. Use the command for:

* Viewing your local configuration details (account ID, active project ID, deployment environment, and more).
* Viewing your dbt configuration details (environment ID, environment name, connection type, and more).

This guide lists all the commands and options you can use with `dbt environment` in the [Cloud CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation). To use them, add a command or option like this: `dbt environment [command]` or use the shorthand `dbt env [command]`.

### dbt environment show[​](#dbt-environment-show "Direct link to dbt environment show")

`show` command — To view your local and dbt configuration details. To run the command with the Cloud CLI, type one of the following commands, including the shorthand:

```
dbt environment show
```

```
dbt env show
```

The command returns the following information:

```
❯ dbt env show
Local Configuration:
  Active account ID              185854
  Active project ID              271692
  Active host name               cloud.getdbt.com
  dbt_cloud.yml file path        /Users/cesar/.dbt/dbt_cloud.yml
  dbt_project.yml file path      /Users/cesar/git/cloud-cli-test-project/dbt_project.yml
  <Constant name="cloud" /> CLI version          0.35.7
  OS info                        darwin arm64

Cloud Configuration:
  Account ID                     185854
  Project ID                     271692
  Project name                   Snowflake
  Environment ID                 243762
  Environment name               Development
  Defer environment ID           [N/A]
  dbt version                    1.6.0-latest
  Target name                    default
  Connection type                snowflake

Snowflake Connection Details:
  Account                        ska67070
  Warehouse                      DBT_TESTING_ALT
  Database                       DBT_TEST
  Schema                         CLOUD_CLI_TESTING
  Role                           SYSADMIN
  User                           dbt_cloud_user
  Client session keep alive      false
```

Note, that dbt won't return anything that is a secret key and will return an 'NA' for any field that isn't configured.

### dbt environment flags[​](#dbt-environment-flags "Direct link to dbt environment flags")

Use the following flags (or options) with the `dbt environment` command:

* `-h`, `--help` — To view the help documentation for a specific command in your command line interface.

  ```
  dbt environment [command] --help
  ```

  The `--help` flag returns the following information:

  ```
    ❯ dbt help environment
    Interact with dbt environments

  Usage:
    dbt environment [command]

  Aliases:
    environment, env

  Available Commands:
    show        Show the working environment

  Flags:
    -h, --help   help for environment

  Use "dbt environment [command] --help" for more information about a command.
  ```

  For example, to view the help documentation for the `show` command, type one of the following commands, including the shorthand:

  ```
  dbt environment show --help
  dbt env show -h
  ```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

deps](https://docs.getdbt.com/reference/commands/deps)[Next

init](https://docs.getdbt.com/reference/commands/init)

* [dbt environment show](#dbt-environment-show)* [dbt environment flags](#dbt-environment-flags)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/commands/dbt-environment.md)
