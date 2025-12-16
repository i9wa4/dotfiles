---
title: "Analyses | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/build/analyses"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Build dbt projects](https://docs.getdbt.com/docs/build/projects)* [Build your DAG](https://docs.getdbt.com/docs/build/models)* Analyses

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fanalyses+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fanalyses+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fbuild%2Fanalyses+so+I+can+ask+questions+about+it.)

On this page

## Overview[​](#overview "Direct link to Overview")

dbt's notion of `models` makes it easy for data teams to version control and collaborate on data transformations. Sometimes though, a certain SQL statement doesn't quite fit into the mold of a dbt model. These more "analytical" SQL files can be versioned inside of your dbt project using the `analysis` functionality of dbt.

Any `.sql` files found in the `analyses/` directory of a dbt project will be compiled, but not executed. This means that analysts can use dbt functionality like `{{ ref(...) }}` to select from models in an environment-agnostic way.

In practice, an analysis file might look like this (via the [open source Quickbooks models](https://github.com/dbt-labs/quickbooks)):

analyses/running\_total\_by\_account.sql

```
-- analyses/running_total_by_account.sql

with journal_entries as (

  select *
  from {{ ref('quickbooks_adjusted_journal_entries') }}

), accounts as (

  select *
  from {{ ref('quickbooks_accounts_transformed') }}

)

select
  txn_date,
  account_id,
  adjusted_amount,
  description,
  account_name,
  sum(adjusted_amount) over (partition by account_id order by id rows unbounded preceding)
from journal_entries
order by account_id, id
```

To compile this analysis into runnable sql, run:

```
dbt compile
```

Then, look for the compiled SQL file in `target/compiled/{project name}/analyses/running_total_by_account.sql`. This SQL can then be pasted into a data visualization tool, for instance. Note that no `running_total_by_account` relation will be materialized in the database as this is an `analysis`, not a `model`.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Groups](https://docs.getdbt.com/docs/build/groups)

* [Overview](#overview)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/build/analyses.md)
