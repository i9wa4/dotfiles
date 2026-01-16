---
title: "Andrew Escay - One post | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/andrew-escay"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

February 2024 Update

This blog references dbt Core versions older than v1.0.

It's been a few years since dbt-core turned 1.0! Since then, we've committed to releasing zero breaking changes whenever possible and it's become much easier to upgrade dbt Core versions.

In 2024, we're taking this promise further by:

* Stabilizing interfaces for everyone — adapter maintainers, metadata consumers, and (of course) people writing dbt code everywhere — as discussed in [our November 2023 roadmap update](https://github.com/dbt-labs/dbt-core/blob/main/docs/roadmap/2023-11-dbt-tng.md).
* Introducing [Release tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) (formerly known as Versionless) to dbt Cloud. No more manual upgrades and no need for *a second sandbox project* just to try out new features in development. For more details, refer to [Upgrade Core version in Cloud](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud).

We're leaving the rest of this post as is, so we can all remember how it used to be. Enjoy a stroll down memory lane.

Without a command to run them, dbt models and tests are just taking up space in a Git repo.

The specific dbt commands you run in production are the control center for your project. They are the structure that defines your team’s data quality + freshness standards.
