---
title: "About exceptions namespace | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/exceptions"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* exceptions

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fexceptions+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fexceptions+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fexceptions+so+I+can+ask+questions+about+it.)

On this page

The `exceptions` namespace can be used to raise warnings and errors in dbt userspace.

## raise\_compiler\_error[​](#raise_compiler_error "Direct link to raise_compiler_error")

The `exceptions.raise_compiler_error` method will raise a compiler error with the provided message. This is typically only useful in macros or materializations when invalid arguments are provided by the calling model. Note that throwing an exception will cause a model to fail, so please use this variable with care!

**Example usage**:

exceptions.sql

```
{% if number < 0 or number > 100 %}
  {{ exceptions.raise_compiler_error("Invalid `number`. Got: " ~ number) }}
{% endif %}
```

## warn[​](#warn "Direct link to warn")

Use the `exceptions.warn` method to raise a compiler warning with the provided message, but any model will still be successful and be treated as a PASS. By default, warnings will not cause dbt runs to fail. However:

* If you use the `--warn-error` flag, all warnings will be promoted to errors.
* To promote only Jinja warnings to errors (and leave other warnings alone), use `--warn-error-options`. For example, `--warn-error-options '{"error": ["JinjaLogWarning"]}'`.

Learn more about [Warnings](https://docs.getdbt.com/reference/global-configs/warnings).

**Example usage**:

warn.sql

```
{% if number < 0 or number > 100 %}
  {% do exceptions.warn("Invalid `number`. Got: " ~ number) %}
{% endif %}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

env\_var](https://docs.getdbt.com/reference/dbt-jinja-functions/env_var)[Next

execute](https://docs.getdbt.com/reference/dbt-jinja-functions/execute)

* [raise\_compiler\_error](#raise_compiler_error)* [warn](#warn)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/exceptions.md)
