---
title: "About as_native filter | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/as_native"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* as\_native

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fas_native+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fas_native+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fas_native+so+I+can+ask+questions+about+it.)

The `as_native` Jinja filter will coerce Jinja-compiled output into its
Python native representation according to [`ast.literal_eval`](https://docs.python.org/3/library/ast.html#ast.literal_eval).
The result can be any Python native type (set, list, tuple, dict, etc).

To render boolean and numeric values, it is recommended to use [`as_bool`](https://docs.getdbt.com/reference/dbt-jinja-functions/as_bool)
and [`as_number`](https://docs.getdbt.com/reference/dbt-jinja-functions/as_number) instead.

Proceed with caution

Unlike `as_bool` and `as_number`, `as_native` will return a rendered value
regardless of the input type. Ensure that your inputs match expectations.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

as\_bool](https://docs.getdbt.com/reference/dbt-jinja-functions/as_bool)[Next

as\_number](https://docs.getdbt.com/reference/dbt-jinja-functions/as_number)
