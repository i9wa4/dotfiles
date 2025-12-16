---
title: "About dbt run-operation command | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/commands/run-operation"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Commands](https://docs.getdbt.com/reference/dbt-commands)* [List of commands](https://docs.getdbt.com/category/list-of-commands)* run-operation

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Frun-operation+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Frun-operation+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fcommands%2Frun-operation+so+I+can+ask+questions+about+it.)

On this page

### Overview[​](#overview "Direct link to Overview")

The `dbt run-operation` command is used to invoke a macro. For usage information, consult the docs on [operations](https://docs.getdbt.com/docs/build/hooks-operations#about-operations).

### Usage[​](#usage "Direct link to Usage")

```
$ dbt run-operation {macro} --args '{args}'
  {macro}        Specify the macro to invoke. dbt will call this macro
                        with the supplied arguments and then exit
  --args ARGS           Supply arguments to the macro. This dictionary will be
                        mapped to the keyword arguments defined in the
                        selected macro. This argument should be a YAML string,
                        eg. '{my_variable: my_value}'
```

### Command line examples[​](#command-line-examples "Direct link to Command line examples")

Example 1:

`$ dbt run-operation grant_select --args '{role: reporter}'`

Example 2:

`$ dbt run-operation clean_stale_models --args '{days: 7, dry_run: True}'`

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

run](https://docs.getdbt.com/reference/commands/run)[Next

seed](https://docs.getdbt.com/reference/commands/seed)

* [Overview](#overview)* [Usage](#usage)* [Command line examples](#command-line-examples)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/commands/run-operation.md)
