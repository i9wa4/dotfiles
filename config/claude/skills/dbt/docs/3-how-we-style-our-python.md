---
title: "How we style our Python | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-style/3-how-we-style-our-python"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* [How we style our dbt projects](https://docs.getdbt.com/best-practices/how-we-style/0-how-we-style-our-dbt-projects)* How we style our Python

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F3-how-we-style-our-python+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F3-how-we-style-our-python+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F3-how-we-style-our-python+so+I+can+ask+questions+about+it.)

On this page

## Python tooling[​](#python-tooling "Direct link to Python tooling")

* 🐍 Python has a more mature and robust ecosystem for formatting and linting (helped by the fact that it doesn't have a million distinct dialects). We recommend using those tools to format and lint your code in the style you prefer.
* 🛠️ Our current recommendations are

  + [black](https://pypi.org/project/black/) formatter
  + [ruff](https://pypi.org/project/ruff/) linter

  info

  ☁️ dbt comes with the [black formatter built-in](https://docs.getdbt.com/docs/cloud/studio-ide/lint-format) to automatically lint and format their Python. You don't need to download or configure anything, just click `Format` in a Python model and you're good to go!

## Example Python[​](#example-python "Direct link to Example Python")

```
import pandas as pd


def model(dbt, session):
    # set length of time considered a churn
    pd.Timedelta(days=2)

    dbt.config(enabled=False, materialized="table", packages=["pandas==1.5.2"])

    orders_relation = dbt.ref("stg_orders")

    # converting a DuckDB Python Relation into a pandas DataFrame
    orders_df = orders_relation.df()

    orders_df.sort_values(by="ordered_at", inplace=True)
    orders_df["previous_order_at"] = orders_df.groupby("customer_id")[
        "ordered_at"
    ].shift(1)
    orders_df["next_order_at"] = orders_df.groupby("customer_id")["ordered_at"].shift(
        -1
    )
    return orders_df
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

How we style our SQL](https://docs.getdbt.com/best-practices/how-we-style/2-how-we-style-our-sql)[Next

How we style our Jinja](https://docs.getdbt.com/best-practices/how-we-style/4-how-we-style-our-jinja)

* [Python tooling](#python-tooling)* [Example Python](#example-python)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-style/3-how-we-style-our-python.md)
