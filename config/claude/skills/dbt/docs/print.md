---
title: "About print function | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/print"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* print

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fprint+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fprint+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fprint+so+I+can+ask+questions+about+it.)

On this page

Use the `print()` function when you want to print messages to both the log file and standard output (stdout).

When used in conjunction with the `QUIET` global config, which suppresses non-error logs, you will only see error logs and the print messages in stdout. For more information, see [Global configs](https://docs.getdbt.com/reference/global-configs/about-global-configs).

## Example[​](#example "Direct link to Example")

```
  {% macro some_macro(arg1, arg2) %}
    {{ print("Running some_macro: " ~ arg1 ~ ", " ~ arg2) }}
  {% endmacro %}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

on-run-end context](https://docs.getdbt.com/reference/dbt-jinja-functions/on-run-end-context)[Next

profiles.yml context](https://docs.getdbt.com/reference/dbt-jinja-functions/profiles-yml-context)

* [Example](#example)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/print.md)
