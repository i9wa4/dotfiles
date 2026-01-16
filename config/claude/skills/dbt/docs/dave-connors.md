---
title: "Dave Connors - 7 posts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/dave-connors"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

You ever wonder what’s *really* going on in your database when you fire off a (perfect, efficient, full-of-insight) SQL query to your database?

OK, probably not 😅. Your personal tastes aside, we’ve been talking a *lot* about SQL Comprehension tools at dbt Labs in the wake of our acquisition of SDF Labs, and think that the community would benefit if we included them in the conversation too! We recently published a [blog that talked about the different levels of SQL Comprehension tools](https://docs.getdbt.com/blog/the-levels-of-sql-comprehension). If you read that, you may have encountered a few new terms you weren’t super familiar with.

In this post, we’ll talk about the technologies that underpin SQL Comprehension tools in more detail. Hopefully, you come away with a deeper understanding of and appreciation for the hard work that your computer does to turn your SQL queries into actionable business insights!

## What’s in a data platform?[​](#whats-in-a-data-platform "Direct link to What’s in a data platform?")

[Raising a dbt project](https://docs.getdbt.com/blog/how-to-build-a-mature-dbt-project-from-scratch) is hard work. We, as data professionals, have poured ourselves into raising happy healthy data products, and we should be proud of the insights they’ve driven. It certainly wasn’t without its challenges though — we remember the terrible twos, where we worked hard to just get the platform to walk straight. We remember the angsty teenage years where tests kept failing, seemingly just to spite us. A lot of blood, sweat, and tears are shed in the service of clean data!

Once the project could dress and feed itself, we also worked hard to get buy-in from our colleagues who put their trust in our little project. Without deep trust and understanding of what we built, our colleagues who depend on your data (or even those involved in developing it with you — it takes a village after all!) are more likely to be in your DMs with questions than in their BI tools, generating insights.

When our teammates ask about where the data in their reports come from, how fresh it is, or about the right calculation for a metric, what a joy! This means they want to put what we’ve built to good use — the challenge is that, historically, *it hasn’t been all that easy to answer these questions well.* That has often meant a manual, painstaking process of cross checking run logs and your dbt documentation site to get the stakeholder the information they need.

Enter [dbt Explorer](https://www.getdbt.com/product/dbt-explorer)! dbt Explorer centralizes documentation, lineage, and execution metadata to reduce the work required to ship trusted data products faster.

Picture this — you’ve got a massive dbt project, thousands of models chugging along, creating actionable insights for your stakeholders. A ticket comes your way — a model needs to be refactored! "No problem," you think to yourself, "I will simply make that change and test it locally!" You look at your lineage, and realize this model is many layers deep, buried underneath a long chain of tables and views.

“OK,” you think further, “I’ll just run a `dbt build -s +my_changed_model` to make sure I have everything I need built into my dev schema and I can test my changes”. You run the command. You wait. You wait some more. You get some coffee, and completely take yourself out of your dbt development flow state. A lot of time and money down the drain to get to a point where you can *start* your work. That’s no good!

Luckily, dbt’s defer functionality allow you to *only* build what you care about when you need it, and nothing more. This feature helps developers spend less time and money in development, helping ship trusted data products faster. dbt Cloud offers native support for this workflow in development, so you can start deferring without any additional overhead!

Those who have been building data warehouses for a long time have undoubtedly encountered the challenge of building surrogate keys on their data models. Having a column that uniquely represents each entity helps ensure your data model is complete, does not contain duplicates, and able to join across different data models in your warehouse.

Sometimes, we are lucky enough to have data sources with these keys built right in — Shopify data synced via their API, for example, has easy-to-use keys on all the tables written to your warehouse. If this is not the case, or if you build a data model with a compound key (aka the data is unique across multiple dimensions), you will have to rely on some strategy for creating and maintaining these keys yourself. How can you do this with dbt? Let’s dive in.

Measuring the number of business hours between two dates using SQL is one of those classic problems that sounds simple yet has [plagued analysts since time immemorial](https://www.sqlteam.com/forums/topic.asp?TOPIC_ID=74645).

This comes up in a couple places at dbt Labs:

* Calculating the time it takes for a support ticket to be solved
* Measuring team performance against response time SLAs

We internally refer to this at "Time on Task," and it can be a critical data point for customer or client facing teams. Thankfully our tools for calculating Time on Task have improved just a little bit since 2006.

Even still, you've got to do some pretty gnarly SQL or dbt gymnastics to get this right, including:

1. Figuring out how to exclude nights and weekends from your SQL calculations
2. Accounting for holidays using a custom holiday calendar
3. Accommodating for changes in business hour schedules

This piece will provide an overview of how and critically *why* to calculate Time on Task and how we use it here at dbt Labs.

> *[We would love to have] A maturity curve of an end-to-end dbt implementation for each version of dbt .... There are so many features in dbt now but it'd be great to understand, "what is the minimum set of dbt features/components that need to go into a base-level dbt implementation?...and then what are the things that are extra credit?"*
> -*Will Weld on dbt Community Slack*

One question we hear time and time again is this - what does it look like to progress through the different stages of maturity on a dbt project?

When Will posed this question on Slack, it got me thinking about what it would take to create a framework for dbt project maturity.

If you’ve been using dbt for over a year, your project is out-of-date. This is natural.

New functionalities have been released. Warehouses change. Best practices are updated. Over the last year, I and others on the Fishtown Analytics (now dbt Labs!) team have conducted seven audits for clients who have been using dbt for a minimum of 2 months.
