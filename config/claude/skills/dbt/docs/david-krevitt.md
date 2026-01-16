---
title: "David Krevitt - 5 posts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/david-krevitt"
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

Doing analytics is hard. Doing analytics *right* is even harder.

There are a massive number of factors to consider: Is data missing? How do we make this insight discoverable? Why is my database locked? *Are we even asking the right questions?*

Compounding this is the fact that analytics can sometimes feel like a lonely pursuit.

Sure, our data is generally proprietary and therefore we can’t talk much about it. But we certainly **can** share what we’ve learned **about** working with that data.

So let’s all commit to sharing our hard won knowledge with each other—and in doing so pave the path for the next generations of analytics practitioners.

I’ve used the dateadd SQL function thousands of times.

I’ve googled the syntax of the dateadd SQL function all of those times except one, when I decided to hit the "are you feeling lucky" button and go for it.

In switching between SQL dialects (BigQuery, Postgres and Snowflake are my primaries), I can literally never remember the argument order (or exact function name) of dateadd.

This article will go over how the DATEADD function works, the nuances of using it across the major cloud warehouses, and how to standardize the syntax variances using dbt macro.

It is a thankless but necessary task. In SQL, often we’ll need to UNION ALL two or more tables vertically, to combine their values.
