---
title: "Gwen Windflower - 2 posts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/gwen-windflower"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

The [dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl) is founded on the idea that data transformation should be both *flexible*, allowing for on-the-fly aggregations grouped and filtered by definable dimensions and *version-controlled and tested*. Like any other codebase, you should have confidence that your transformations express your organization’s business logic correctly. Historically, you had to choose between these options, but the dbt Semantic Layer brings them together. This has required new paradigms for *how* you express your transformations though.

dbt Cloud now includes a suite of new features that enable configuring precise and unique connections to data platforms at the environment and user level. These enable more sophisticated setups, like connecting a project to multiple warehouse accounts, first-class support for [staging environments](https://docs.getdbt.com/docs/deploy/deploy-environments#staging-environment), and user-level [overrides for specific dbt versions](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud#override-dbt-version). This gives dbt Cloud developers the features they need to tackle more complex tasks, like Write-Audit-Publish (WAP) workflows and safely testing dbt version upgrades. While you still configure a default connection at the project level and per-developer, you now have tools to get more advanced in a secure way. Soon, dbt Cloud will take this even further allowing multiple connections to be set globally and reused with *global connections*.
