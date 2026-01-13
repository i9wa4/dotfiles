---
title: "SQL magic | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/tags/sql-magic"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



## Introduction[​](#introduction "Direct link to Introduction")

Most data modeling approaches for customer segmentation are based on a wide table with user attributes. This table only stores the current attributes for each user, and is then loaded into the various SaaS platforms via Reverse ETL tools.

Take for example a Customer Experience (CX) team that uses Salesforce as a CRM. The users will create tickets to ask for assistance, and the CX team will start attending them in the order that they are created. This is a good first approach, but not a data driven one.

An improvement to this would be to prioritize the tickets based on the customer segment, answering our most valuable customers first. An Analytics Engineer can build a segmentation to identify the power users (for example with an RFM approach) and store it in the data warehouse. The Data Engineering team can then export that user attribute to the CRM, allowing the customer experience team to build rules on top of it.

In general, data people prefer the more granular over the less granular. [Timestamps > dates](https://docs.getdbt.com/blog/when-backend-devs-spark-joy#signs-the-data-is-sparking-joy), daily data > weekly data, etc.; having data at a more granular level always allows you to zoom in. However, you’re likely looking at your data at a somewhat zoomed-out level—weekly, monthly, or even yearly. To do that, you’re going to need a handy dandy function that helps you round out date or time fields.

The DATE\_TRUNC function will truncate a date or time to the first instance of a given date part. Wordy, wordy, wordy! What does this really mean? If you were to truncate `2021-12-13` out to its month, it would return `2021-12-01` (the first day of the month).

Using the DATE\_TRUNC function, you can truncate to the weeks, months, years, or other date parts for a date or time field. This can make date/time fields easier to read, as well as help perform cleaner time-based analyses.

*“How long has it been since this customer last ordered with us?”*

*“What is the average number of days to conversion?”*

Business users will have these questions, data people will have to answer these questions, and the only way to solve them is by calculating the time between two different dates. Luckily, there’s a handy DATEDIFF function that can do that for you.

The DATEDIFF function will return the difference in specified units (ex. days, weeks, years) between a start date/time and an end date/time. It’s a simple and widely used function that you’ll find yourself using more often than you expect.

We’ve likely been here: Table A has 56 columns and we want to select all but one of them (`column_56`). So here we go, let’s get started…

```
select
	column_1,
	column_2,
	column_3,
	please_save_me…
from {{ ref('table_a') }}
```

At this point, you realize your will to continue typing out the next 52 columns has essentially dwindled down to nothing and you’re probably questioning the life choices that led you here.

But what if there was a way to make these 56+ lines of code come down to a handful? Well, that’s where a handy [dbt macro](https://docs.getdbt.com/docs/build/jinja-macros) comes into play.

There are so many different date functions in SQL—you have [DATEDIFF](https://docs.getdbt.com/blog/datediff-sql-love-letter/), [DATEADD](https://docs.getdbt.com/blog/sql-dateadd), DATE\_PART, and [DATE\_TRUNC](https://docs.getdbt.com/date-trunc-sql) to name a few. They all have their different use cases and understanding how and when they should be used is a SQL fundamental to get down. Are any of those as easy to use as the EXTRACT function? Well, that debate is for another time…

In this post, we’re going to give a deep dive into the EXTRACT function, how it works, and why we use it.

We’ve all been there:

* In a user signup form, user A typed in their name as `Kira Furuichi`, user B typed it in as `john blust`, and user C wrote `DAvid KrevitT` (what’s up with that, David??)
* Your backend application engineers are adamant customer emails are in all caps
* All of your event tracking names are lowercase

In the real world of human imperfection, opinions, and error, string values are likely to take inconsistent capitalization across different data sources (or even within the same data source). There’s always a little lack of rhyme or reason for why some values are passed as upper or lowercase, and it’s not worth the headache to unpack that.

So how do you create uniformity for string values that you collect across all your data sources? The LOWER function!

It’s inevitable in the field of analytics engineering: you’re going to encounter moments when there’s mysterious or unhelpful blank values in your data. Null values surely have their time and place, but when you need those null values filled with more meaningful data, COALESCE comes to the rescue.

COALESCE is an incredibly useful function that allows you to fill in unhelpful blank values that may show up in your data. In the words of analytics engineer [Lauren Benezra](https://docs.getdbt.com/author/lauren_benezra), you will probably almost never see a data model that doesn’t use COALESCE somewhere.

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

I’ve used the dateadd SQL function thousands of times.

I’ve googled the syntax of the dateadd SQL function all of those times except one, when I decided to hit the "are you feeling lucky" button and go for it.

In switching between SQL dialects (BigQuery, Postgres and Snowflake are my primaries), I can literally never remember the argument order (or exact function name) of dateadd.

This article will go over how the DATEADD function works, the nuances of using it across the major cloud warehouses, and how to standardize the syntax variances using dbt macro.

It is a thankless but necessary task. In SQL, often we’ll need to UNION ALL two or more tables vertically, to combine their values.
