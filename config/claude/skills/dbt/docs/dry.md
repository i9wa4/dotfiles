---
title: "DRY principles: How to write efficient SQL | dbt Labs"
source_url: "https://docs.getdbt.com/terms/dry"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



[Blog](https://docs.getdbt.com/blog "Blog")

 /

[Learn](https://docs.getdbt.com/blog/category/learn "Learn")

 /

DRY principles: How to write efficient SQL

# DRY principles: How to write efficient SQL

![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2Fd307e0a9a7dfa9c7b5f92d288b404955c979eb0c-512x512.jpg%3Ffit%3Dmax%26auto%3Dformat&w=1080&q=75)

[Daniel Poppy](https://docs.getdbt.com/authors/daniel-poppy)

last updated on Oct 09, 2025

DRY is a software development principle that stands for “Don’t Repeat Yourself.” Living by this principle means that your aim is to reduce repetitive patterns and duplicate code and logic in favor of modular and referenceable code.

The DRY code principle was originally made with software engineering in mind and coined by Andy Hunt and Dave Thomas in their book, *The Pragmatic Programmer*. They believed that “every piece of knowledge must have a single, unambiguous, authoritative representation within a system.” As the field of analytics engineering and [data transformation](https://www.getdbt.com/blog/data-transformation "data transformation") develops, there’s a growing need to adopt [software engineering best practices](https://www.getdbt.com/product/what-is-dbt/ "software engineering best practices"), including writing DRY code.

## Why write DRY code?

DRY code is one of the practices that makes a good developer, a great developer. Solving a problem by any means is great to a point, but eventually, you need to be able to write code that's maintainable by people other than yourself and scalable as system load increases. That's the essence of DRY code.

But what's so great about being DRY as a bone anyway, when you can be WET?

### Don’t be WET

WET, which stands for “Write Everything Twice,” is the opposite of DRY. It's a tongue-in-cheek reference to code that doesn’t exactly meet the DRY standard. In a practical sense, WET code typically involves the repeated *writing* of the same code throughout a project, whereas DRY code would represent the repeated *reference* of that code.

Well, how would you know if your code isn't DRY enough? That’s kind of subjective and will vary by the norms set within your organization. That said, a good rule of thumb is [the Rule of Three](https://en.wikipedia.org/wiki/Rule_of_three_(writing)#:~:text=The%20rule%20of%20three%20is,or%20effective%20than%20other%20numbers. "the Rule of Three"). This rule states that the *third* time you encounter a certain pattern, you should probably abstract it into some reusable unit.

There is, of course, a tradeoff between simplicity and conciseness in code. The more abstractions you create, the harder it can be for others to understand and maintain your code without proper documentation. So, the moral of the story is: DRY code is great as long as you [write great documentation.](https://docs.getdbt.com/docs/build/documentation "write great documentation.")

### Save time & energy

DRY code means you get to write duplicate code less often. You're saving lots of time writing the same thing over and over. Not only that, but you're saving your cognitive energy for bigger problems you'll end up needing to solve, instead of wasting that time and energy on tedious syntax.

Sure, you might have to frontload some of your cognitive energy to create a good abstraction. But in the long run, it'll save you a lot of headaches. Especially if you're building something complex and one typo can be your undoing.

### Create more consistent definitions

Let's go back to what Andy and Dave said in *The Pragmatic Programmer*: “Every piece of knowledge must have a single, unambiguous, authoritative representation within a system.” As a data person, the words “single” and “unambiguous” might have stood out to you.

Most teams have essential business logic that defines the successes and failures of a business. For a subscription-based DTC company, this could be [monthly recurring revenue (MRR)](https://www.getdbt.com/blog/modeling-subscription-revenue/ "monthly recurring revenue (MRR)") and for a SaaS product, this could look like customer lifetime value (CLV). Standardizing the SQL that generates those metrics is essential to creating consistent definitions and values.

By writing DRY definitions for key business logic and metrics that are referenced throughout a dbt project and/or BI (business intelligence) tool, data teams can create those single, unambiguous, and authoritative representations for their essential transformations. Gone are the days of 15 different definitions and values for churn, and in are the days of standardization and DRYness.

### dbt Semantic Layer, powered by MetricFlow

The [dbt Semantic Layer](https://docs.getdbt.com/docs/use-dbt-semantic-layer/dbt-sl "dbt Semantic Layer"), powered by [MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow "MetricFlow"), simplifies the process of defining and using critical business metrics, like revenue in the modeling layer (your dbt project). By centralizing metric definitions, data teams can ensure consistent self-service access to these metrics in downstream data tools and applications. The dbt Semantic Layer eliminates duplicate coding by allowing data teams to define metrics on top of existing models and automatically handles data joins.

## Tools to help you write DRY code

Let’s just say it: Writing DRY code is easier said than done. For classical software engineers, there’s a ton of resources out there to help them write DRY code. In the world of data transformation, there are also some tools and methodologies that can help folks in [the field of analytics engineering](https://www.getdbt.com/blog/what-is-analytics-engineering "the field of analytics engineering") write more DRY and [modular code](https://www.getdbt.com/blog/modular-data-modeling-techniques "modular code").

### Common Table Expressions (CTEs)

[CTEs](https://www.getdbt.com/blog/guide-to-cte "CTEs") are a great way to help you write more DRY code in your data analysis and dbt models. In a formal sense, a CTE is a temporary results set that can be used in a query. In a much more human and practical sense, we like to think of CTEs as separate, smaller queries within the larger query you’re building up. Essentially, you can use CTEs to break up complex queries into simpler blocks of code that are easier to debug and can connect and build off of each other.

If you’re referencing a specific query, perhaps for aggregations that join back to an unaggregated view, CTEs can simply be referenced throughout a query with its `CTE_EXPRESSION_NAME.`

### View materializations

View [materializations](https://docs.getdbt.com/docs/build/materializations "materializations") are also extremely useful for abstracting code that might otherwise be repeated often. A view is a defined passthrough SQL query that can be run against a database. Unlike a table, it doesn’t store data, but it defines the logic that you need to use to fetch the underlying data.

If you’re referencing the same query, CTE, or block of code, throughout multiple data models, that’s probably a good sign that code should be its own view.

For example, you might define a SQL view to count new users created in a day:

```
  select
    created_date,
    count(distinct(user_id)) as new_users
  from {{ ref('users') }}
  group by created_date
```

While this is a simple query, writing this logic every time you need it would be super tedious. And what if the `user_id` field changed to a new name? If you’d written this in a WET way, you’d have to find every instance of this code and make the change to the new field versus just updating it once in the code for the view.

To make any subsequent references to this view DRY-er, you simply reference the view in your data model or query.

### dbt macros and packages

dbt also supports the use of [macros](https://docs.getdbt.com/docs/build/jinja-macros "macros") and [packages](https://docs.getdbt.com/docs/build/packages "packages") to help data folks write DRY code in their dbt projects. Macros are Jinja-supported functions that can be reused and applied throughout a dbt project. Packages are libraries of dbt code, typically models, macros, and/or tests, that can be referenced and used in a dbt project. They are a great way to use transformations for common data sources (like [ad platforms](https://hub.getdbt.com/dbt-labs/facebook_ads/latest/ "ad platforms")) or use more [custom tests for your data models](https://hub.getdbt.com/calogica/dbt_expectations/0.1.2/ "custom tests for your data models") *without having to write out the code yourself*. At the end of the day, is there really anything more DRY than that?

## Conclusion

DRY code is a principle that you should always be striving for. It saves you time and energy. It makes your code more maintainable and extensible. And potentially most importantly, it’s the fine line that can help transform you from a good analytics engineer to a great one.

## Further reading

* [Data modeling technique for more modularity](https://www.getdbt.com/analytics-engineering/modular-data-modeling-technique/ "Data modeling technique for more modularity")
* [Why we use so many CTEs](https://docs.getdbt.com/docs/best-practices "Why we use so many CTEs")
* [Getting started with CTEs](https://www.getdbt.com/blog/guide-to-cte "Getting started with CTEs")

## DRY principle FAQs

### What is the "Don't Repeat Yourself" (DRY) principle and why is it important in software development?

### What does the DRY principle assert about how knowledge should be represented within a software system?

### How does applying DRY improve maintainability, readability, consistency, and reduce errors in a codebase?

### What practical techniques can developers use to enforce DRY, such as creating functions, using classes/inheritance, extracting constants, or modularizing code?

### How would you know if your code isn't DRY enough?

### VS Code Extension

The free dbt VS Code extension is the best way to develop locally in dbt.

[Install free extension](https://docs.getdbt.com/docs/install-dbt-extension)

##### Share this article

Copy post link

### Latest posts

[![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2F8685b7a2b4eac3ca9a5d780b1d32d1a62f5b76b2-800x452.png%3Ffit%3Dmax%26auto%3Dformat&w=1920&q=75)](/blog/bring-structured-context-to-conversational-analytics-with-dbt "Bring structured context to conversational analytics with dbt")

Product10 min

### [Bring structured context to conversational analytics with dbt](https://docs.getdbt.com/blog/bring-structured-context-to-conversational-analytics-with-dbt)

![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2F8a15d40ea0f07c7b281c14569318f36dcb01e412-504x506.png%3Ffit%3Dmax%26auto%3Dformat&w=1080&q=75)

![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2F1d6ae2706b536a6f79cd1c20f8b8107474748de6-1649x1798.jpg%3Ffit%3Dmax%26auto%3Dformat&w=3840&q=75)

[Sai Maddali](https://docs.getdbt.com/authors/sai-maddali),[Chakshu Mehta](https://docs.getdbt.com/authors/chakshu-mehta)

on  Dec 03, 2025

[![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2Fe7b6a59e1ed4b7f794c4a5fcd8e6d0ec26f1ddb7-800x452.png%3Ffit%3Dmax%26auto%3Dformat&w=1920&q=75)](/blog/using-state-aware-orchestration-to-slash-your-data-costs "Using state-aware orchestration to slash your data costs")

Learn8 min

### [Using state-aware orchestration to slash your data costs](https://docs.getdbt.com/blog/using-state-aware-orchestration-to-slash-your-data-costs)

![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2Fa51c868eb64eb6faa131bd891762fc732eb30a3e-2316x3088.jpg%3Ffit%3Dmax%26auto%3Dformat&w=3840&q=75)

[Kathryn Chubb](https://docs.getdbt.com/authors/kathryn-chubb)

on  Nov 26, 2025

[![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2F5c3948733ba4addd9ecd1c4aaf5b5fb0f18399c1-800x452.png%3Ffit%3Dmax%26auto%3Dformat&w=1920&q=75)](/blog/reducing-etl-licensing-costs "Reducing ETL licensing costs with the dbt Fusion engine")

Learn9 min

### [Reducing ETL licensing costs with the dbt Fusion engine](https://docs.getdbt.com/blog/reducing-etl-licensing-costs)

![](https://docs.getdbt.com/_next/image?url=https%3A%2F%2Fcdn.sanity.io%2Fimages%2Fwl0ndo6t%2Fmain%2Fa51c868eb64eb6faa131bd891762fc732eb30a3e-2316x3088.jpg%3Ffit%3Dmax%26auto%3Dformat&w=3840&q=75)

[Kathryn Chubb](https://docs.getdbt.com/authors/kathryn-chubb)

on  Nov 26, 2025

The dbt Community

## Join the largest community shaping data

The dbt Community is your gateway to best practices, innovation, and direct collaboration with thousands of data leaders and AI practitioners worldwide. Ask questions, share insights, and build better with the experts.

[Join the Community](https://docs.getdbt.com/community/join-the-community)[Explore the community](https://docs.getdbt.com/community)

100,000+active members

50k+teams using dbt weekly

50+Community meetups
