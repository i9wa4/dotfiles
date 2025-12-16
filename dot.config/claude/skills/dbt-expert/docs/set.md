---
title: "About set context method | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/set"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* set

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fset+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fset+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fset+so+I+can+ask+questions+about+it.)

On this page

*Not to be confused with the `{% set foo = "bar" ... %}` expression in Jinja!*

The `set` context method can be used to convert any iterable to a sequence of iterable elements that are unique (a set).

**Args**:

* `value`: The iterable to convert (e.g. a list)
* `default`: A default value to return if the `value` argument is not a valid iterable

### Usage[​](#usage "Direct link to Usage")

```
{% set my_list = [1, 2, 2, 3] %}
{% set my_set = set(my_list) %}
{% do log(my_set) %}  {# {1, 2, 3} #}
```

```
{% set my_invalid_iterable = 1234 %}
{% set my_set = set(my_invalid_iterable) %}
{% do log(my_set) %}  {# None #}
```

```
{% set email_id = "'admin@example.com'" %}
```

### set\_strict[​](#set_strict "Direct link to set_strict")

The `set_strict` context method can be used to convert any iterable to a sequence of iterable elements that are unique (a set). The difference to the `set` context method is that the `set_strict` method will raise an exception on a `TypeError`, if the provided value is not a valid iterable and cannot be converted to a set.

**Args**:

* `value`: The iterable to convert (e.g. a list)

```
{% set my_list = [1, 2, 2, 3] %}
{% set my_set = set(my_list) %}
{% do log(my_set) %}  {# {1, 2, 3} #}
```

```
{% set my_invalid_iterable = 1234 %}
{% set my_set = set_strict(my_invalid_iterable) %}
{% do log(my_set) %}

Compilation Error in ... (...)
  'int' object is not iterable
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

selected\_resources](https://docs.getdbt.com/reference/dbt-jinja-functions/selected_resources)[Next

source](https://docs.getdbt.com/reference/dbt-jinja-functions/source)

* [Usage](#usage)* [set\_strict](#set_strict)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/set.md)
