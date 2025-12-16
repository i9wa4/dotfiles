---
title: "Microsoft Azure Synapse DWH configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/azuresynapse-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Microsoft Azure Synapse DWH configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fazuresynapse-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fazuresynapse-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fazuresynapse-configs+so+I+can+ask+questions+about+it.)

On this page

All [configuration options for the Microsoft SQL Server adapter](https://docs.getdbt.com/reference/resource-configs/mssql-configs) also apply to this adapter.

Additionally, the configuration options below are available.

### Indices and distributions[​](#indices-and-distributions "Direct link to Indices and distributions")

The main index and the distribution type can be set for models that are materialized to tables.

* Model config* Project config

models/example.sql

```
{{
    config(
        index='HEAP',
        dist='ROUND_ROBIN'
        )
}}

select *
from ...
```

dbt\_project.yml

```
models:
  your_project_name:
    materialized: view
    staging:
      materialized: table
      index: HEAP
```

The following are the supported index types:

* `CLUSTERED COLUMNSTORE INDEX` (default)
* `HEAP`
* `CLUSTERED INDEX (COLUMN_NAME)`
* `CLUSTERED COLUMNSTORE INDEX ORDER(COLUMN_NAME)`

The following are the supported distribution types:

* `ROUND_ROBIN` (default)
* `HASH(COLUMN_NAME)`
* `REPLICATE`

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)[Next

Amazon Athena configurations](https://docs.getdbt.com/reference/resource-configs/athena-configs)

* [Indices and distributions](#indices-and-distributions)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/azuresynapse-configs.md)
