---
title: "Jerrie Kumalah Kenney - 2 posts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/jerrie-kumalah-kenney"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

👋 Greetings, dbt’ers! It’s Faith & Jerrie, back again to offer tactical advice on *where* to put tests in your pipeline.

In [our first post](https://docs.getdbt.com/blog/test-smarter-not-harder) on refining testing best practices, we developed a prioritized list of data quality concerns. We also documented first steps for debugging each concern. This post will guide you on where specific tests should go in your data pipeline.

*Note that we are constructing this guidance based on how we [structure data at dbt Labs.](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview#guide-structure-overview)* You may use a different modeling approach—that’s okay! Translate our guidance to your data’s shape, and let us know in the comments section what modifications you made.

First, here’s our opinions on where specific tests should go:

* Source tests should be fixable data quality concerns. See the [callout box below](#sources) for what we mean by “fixable”.
* Staging tests should be business-focused anomalies specific to individual tables, such as accepted ranges or ensuring sequential values. In addition to these tests, your staging layer should clean up any nulls, duplicates, or outliers that you can’t fix in your source system. You generally don’t need to test your cleanup efforts.
* Intermediate and marts layer tests should be business-focused anomalies resulting specifically from joins or calculations. You also may consider adding additional primary key and not null tests on columns where it’s especially important to protect the grain.

The [Analytics Development Lifecycle (ADLC)](https://www.getdbt.com/resources/guides/the-analytics-development-lifecycle) is a workflow for improving data maturity and velocity. Testing is a key phase here. Many dbt developers tend to focus on [primary keys and source freshness.](https://www.getdbt.com/blog/building-a-data-quality-framework-with-dbt-and-dbt-cloud) We think there is a more holistic and in-depth path to tread. Testing is a key piece of the ADLC, and it should drive data quality.

In this blog, we’ll walk through a plan to define data quality. This will look like:

* identifying *data hygiene* issues
* identifying *business-focused anomaly* issues
* identifying *stats-focused anomaly* issues

Once we have *defined* data quality, we’ll move on to *prioritize* those concerns. We will:

* think through each concern in terms of the breadth of impact
* decide if each concern should be at error or warning severity
