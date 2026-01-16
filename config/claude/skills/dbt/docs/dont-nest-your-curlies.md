---
title: "Don't nest your curlies | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/dont-nest-your-curlies"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* Don't nest your curlies

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fdont-nest-your-curlies+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fdont-nest-your-curlies+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fdont-nest-your-curlies+so+I+can+ask+questions+about+it.)

On this page

### Poetry[​](#poetry "Direct link to Poetry")

**Don't Nest Your Curlies**

> If dbt errors out early
>
> and your Jinja is making you surly
>
> don't post to the slack
>
> just take a step back
>
> and check if you're nesting your curlies.

### Jinja[​](#jinja "Direct link to Jinja")

When writing Jinja code in a dbt project, it may be tempting to nest expressions inside of each other. Take this example:

```
  {{ dbt_utils.date_spine(
      datepart="day",
      start_date=[ USE JINJA HERE ]
      )
  }}
```

To nest a Jinja expression inside of another Jinja expression, simply place the desired code (without curly brackets) directly into the expression.

**Correct example**
Here, the return value of the `var()` context method is supplied as the `start_date` argument to the `date_spine` macro. Great!

```
  {{ dbt_utils.date_spine(
      datepart="day",
      start_date=var('start_date')
      )
  }}
```

**Incorrect example**
Once we've denoted that we're inside a Jinja expression (using the `{{` syntax), no further curly brackets are required inside of the Jinja expression. This code will supply a literal string value, `"{{ var('start_date') }}"`, as the `start_date` argument to the `date_spine` macro. This is probably not what you actually want to do!

```
-- Do not do this! It will not work!

  {{ dbt_utils.date_spine(
      datepart="day",
      start_date="{{ var('start_date') }}"
      )
  }}
```

Here's another example:

```
{# Either of these work #}

{% set query_sql = 'select * from ' ~ ref('my_model') %}

{% set query_sql %}
select * from {{ ref('my_model') }}
{% endset %}

{# This does not #}
{% set query_sql = "select * from {{ ref('my_model')}}" %}
```

### An exception[​](#an-exception "Direct link to An exception")

There is one exception to this rule: curlies inside of curlies are acceptable in hooks (ie. `on-run-start`, `on-run-end`, `pre-hook`, and `post-hook`).

Code like this is both valid, and encouraged:

```
{{ config(post_hook="grant select on {{ this }} to role bi_role") }}
```

So why are curlies inside of curlies allowed in this case? Here, we actually *want* the string literal `"grant select on {{ this }} ..."` to be saved as the configuration value for the post-hook in this model. This string will be re-rendered when the model runs, resulting in a sensible SQL expression like `grant select on "schema"."table"....` being executed against the database. These hooks are a special exception to the rule stated above.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Conclusion](https://docs.getdbt.com/best-practices/materializations/7-conclusion)[Next

Clone incremental models as the first step of your CI job](https://docs.getdbt.com/best-practices/clone-incremental-models)

* [Poetry](#poetry)* [Jinja](#jinja)* [An exception](#an-exception)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/dont-nest-your-curlies.md)
