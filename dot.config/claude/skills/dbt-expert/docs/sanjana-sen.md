---
title: "Sanjana Sen - 2 posts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/sanjana-sen"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

We’ve all done it: fanned out data during a join to produce duplicate records (sometimes duplicated in multiple).

That time when historical revenue numbers doubled on Monday? Classic fanout.

Could it have been avoided? Yes, very simply: by defining the uniqueness grain for a table with a primary key and enforcing it with a dbt test.

So let’s dive deep into: what primary keys are, which cloud analytics warehouses support them, and how you can test them in your warehouse to enforce uniqueness.

### Why primary keys are important[​](#why-primary-keys-are-important "Direct link to Why primary keys are important")

We all know one of the most fundamental rules in data is that every table should have a primary key. Primary keys are critical for many reasons:

* They ensure that you don’t have duplicate rows in your table
* They help establish relationships to other tables
* They allow you to quickly identify the grain of the table (ex: the `customers` table with a PK of `customer_id` has one row per customer)
* You can test them in dbt, to ensure that your data is complete and unique
