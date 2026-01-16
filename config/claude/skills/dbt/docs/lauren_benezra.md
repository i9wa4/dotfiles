---
title: "Lauren Benezra - 3 posts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/author/lauren_benezra"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

If you’ve ever heard of Marie Kondo, you’ll know she has an incredibly soothing and meditative method to tidying up physical spaces. Her KonMari Method is about categorizing, discarding unnecessary items, and building a sustainable system for keeping *stuff*.

As an analytics engineer at your company, doesn’t that last sentence describe your job perfectly?! I like to think of the practice of analytics engineering as applying the KonMari Method to data modeling. Our goal as Analytics Engineers is not only to organize and clean up data, but to design a sustainable and scalable transformation project that is easy to navigate, grow, and consume by downstream customers.

Let’s talk about how to apply the KonMari Method to a new migration project. Perhaps you’ve been tasked with unpacking the kitchen in your new house; AKA, you’re the engineer hired to move your legacy SQL queries into dbt and get everything working smoothly. That might mean you’re grabbing a query that is 1500 lines of SQL and reworking it into modular pieces. When you’re finished, you have a performant, scalable, easy-to-navigate data flow.

Let’s set the scene. You are an [analytics engineer](https://www.getdbt.com/what-is-analytics-engineering/) at your company. You have several relational datasets flowing through your warehouse, and, of course, you can easily access and transform these tables through dbt. You’ve joined together the tables appropriately and have near-real time reporting on the relationships for each `entity_id` as it currently exists.

But, at some point, your stakeholder wants to know how each entity is changing over time. Perhaps, it is important to understand the trend of a product throughout its lifetime. You need the history of each `entity_id` across all of your datasets, because each related table is updated on its own timeline.

What is your first thought? Well, you’re a seasoned analytics engineer and you *know* the good people of dbt Labs have a solution for you. And then it hits you — the answer is [snapshots](https://docs.getdbt.com/docs/building-a-dbt-project/snapshots)!

Hey data champion — so glad you’re here! Sometimes datasets need a **team** of engineers to tackle their deduplification (totz a real word), and that’s why we wrote this down. *For you*, friend, *we wrote it down for you*. You’re welcome!

Let’s get rid of these dupes and send you on your way to do the rest of the *super-fun-analytics-engineering* that you want to be doing, on top of *super-sparkly-clean* data. But first, let’s make sure we’re all on the same page.
