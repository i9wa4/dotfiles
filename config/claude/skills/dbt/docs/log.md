---
title: "log | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/log"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* log

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Flog+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Flog+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Flog+so+I+can+ask+questions+about+it.)

**Args**:

* `msg`: The message (string) to log
* `info`: If False, write to the log file. If True, write to both the log file and stdout (default=False)

Logs a line to either the log file or stdout.

Details

Code source
Refer to [GitHub](https://github.com/dbt-labs/dbt-core/blob/HEAD/core/dbt/context/base.py#L549-L566) or the following code as a source:


```
    def log(msg: str, info: bool = False) -> str:
        """Logs a line to either the log file or stdout.

        :param msg: The message to log
        :param info: If `False`, write to the log file. If `True`, write to
            both the log file and stdout.

        > macros/my_log_macro.sql

            {% macro some_macro(arg1, arg2) %}
              {{ log("Running some_macro: " ~ arg1 ~ ", " ~ arg2) }}
            {% endmacro %}"
        """
        if info:
            fire_event(JinjaLogInfo(msg=msg, node_info=get_node_info()))
        else:
            fire_event(JinjaLogDebug(msg=msg, node_info=get_node_info()))
        return ""
```

```
{% macro some_macro(arg1, arg2) %}

	{{ log("Running some_macro: " ~ arg1 ~ ", " ~ arg2) }}

{% endmacro %}
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

local\_md5](https://docs.getdbt.com/reference/dbt-jinja-functions/local_md5)[Next

model](https://docs.getdbt.com/reference/dbt-jinja-functions/model)
