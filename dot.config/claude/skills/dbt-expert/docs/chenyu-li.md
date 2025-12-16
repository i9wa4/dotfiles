---
title: "Chenyu Li - One post | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/chenyu-li"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

Versionless is now the "latest" release track

This blog post was updated on December 04, 2024 to rename "versionless" to the "latest" release track allowing for the introduction of less-frequent release tracks. Learn more about [Release Tracks](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) and how to use them.

As long as dbt Cloud has existed, it has required users to select a version of dbt Core to use under the hood in their jobs and environments. This made sense in the earliest days, when dbt Core minor versions often included breaking changes. It provided a clear way for everyone to know which version of the underlying runtime they were getting.

However, this came at a cost. While bumping a project's dbt version *appeared* as simple as selecting from a dropdown, there was real effort required to test the compatibility of the new version against existing projects, package dependencies, and adapters. On the other hand, putting this off meant foregoing access to new features and bug fixes in dbt.

But no more. Today, we're ready to announce the general availability of a new option in dbt Cloud: [**the "Latest" release track.**](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks)
