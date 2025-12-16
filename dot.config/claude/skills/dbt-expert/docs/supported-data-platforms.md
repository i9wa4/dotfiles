---
title: "Supported data platforms | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/supported-data-platforms"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * Supported data platforms

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fsupported-data-platforms+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fsupported-data-platforms+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fsupported-data-platforms+so+I+can+ask+questions+about+it.)

dbt connects to and runs SQL against your database, warehouse, lake, or query engine. These SQL-speaking platforms are collectively referred to as *data platforms*. dbt connects with data platforms by using a dedicated adapter plugin for each. Plugins are built as Python modules that dbt Core discovers if they are installed on your system. Refer to the [Build, test, document, and promote adapters](https://docs.getdbt.com/guides/adapter-creation) guide for details.

You can [connect](https://docs.getdbt.com/docs/connect-adapters) to adapters and data platforms natively in dbt or install them manually using dbt Core.

You can also further customize how dbt works with your specific data platform via configuration: see [Configuring Postgres](https://docs.getdbt.com/reference/resource-configs/postgres-configs) for an example.

## Types of Adapters[​](#types-of-adapters "Direct link to Types of Adapters")

There are two types of adapters available today:

* **Trusted** — [Trusted adapters](https://docs.getdbt.com/docs/trusted-adapters) are those where the adapter maintainers have decided to participate in the Trusted Adapter Program and have made a commitment to meeting those requirements. For adapters supported in dbt, maintainers have undergone an additional rigorous process that covers contractual requirements for development, documentation, user experience, and maintenance.
* **Community** — [Community adapters](https://docs.getdbt.com/docs/community-adapters) are open-source and maintained by community members. These adapters are not part of the Trusted Adapter Program and could have usage inconsistencies.

Considerations for depending on an open-source project

1. Does it work?
2. Does anyone "own" the code, or is anyone liable for ensuring it works?
3. Do bugs get fixed quickly?
4. Does it stay up-to-date with new dbt Core features?
5. Is the usage substantial enough to self-sustain?
6. Do other known projects depend on this library?

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Next

Connect to adapters](https://docs.getdbt.com/docs/connect-adapters)
