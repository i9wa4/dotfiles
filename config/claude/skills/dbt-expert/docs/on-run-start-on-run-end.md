---
title: "on-run-start & on-run-end | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/project-configs/on-run-start-on-run-end"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Project configs](https://docs.getdbt.com/category/project-configs)* on-run-start & on-run-end

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fon-run-start-on-run-end+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fon-run-start-on-run-end+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fproject-configs%2Fon-run-start-on-run-end+so+I+can+ask+questions+about+it.)

On this page

dbt\_project.yml

```
on-run-start: sql-statement | [sql-statement]
on-run-end: sql-statement | [sql-statement]
```

## Definition[​](#definition "Direct link to Definition")

A SQL statement (or list of SQL statements) to be run at the start or end of the following commands:

`dbt build`, `dbt compile`, `dbt docs generate`, `dbt run`, `dbt seed`, `dbt snapshot`, or `dbt test`.

`on-run-start` and `on-run-end` hooks can also [call macros](#call-a-macro-to-grant-privileges) that return SQL statements.

## Usage notes[​](#usage-notes "Direct link to Usage notes")

* The `on-run-end` hook has additional Jinja variables available in the context — check out the [docs](https://docs.getdbt.com/reference/dbt-jinja-functions/on-run-end-context).

## Examples[​](#examples "Direct link to Examples")

### Grant privileges on all schemas that dbt uses at the end of a run[​](#grant-privileges-on-all-schemas-that-dbt-uses-at-the-end-of-a-run "Direct link to Grant privileges on all schemas that dbt uses at the end of a run")

This leverages the [schemas](https://docs.getdbt.com/reference/dbt-jinja-functions/schemas) variable that is only available in an `on-run-end` hook.

dbt\_project.yml

```
on-run-end:
  - "{% for schema in schemas %}grant usage on schema {{ schema }} to group reporter; {% endfor %}"
```

### Call a macro to grant privileges[​](#call-a-macro-to-grant-privileges "Direct link to Call a macro to grant privileges")

dbt\_project.yml

```
on-run-end: "{{ grant_select(schemas) }}"
```

### Additional examples[​](#additional-examples "Direct link to Additional examples")

We've compiled some more in-depth examples [here](https://docs.getdbt.com/docs/build/hooks-operations#additional-examples).

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

name](https://docs.getdbt.com/reference/project-configs/name)[Next

packages-install-path](https://docs.getdbt.com/reference/project-configs/packages-install-path)

* [Definition](#definition)* [Usage notes](#usage-notes)* [Examples](#examples)
      + [Grant privileges on all schemas that dbt uses at the end of a run](#grant-privileges-on-all-schemas-that-dbt-uses-at-the-end-of-a-run)+ [Call a macro to grant privileges](#call-a-macro-to-grant-privileges)+ [Additional examples](#additional-examples)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/project-configs/on-run-start-on-run-end.md)
