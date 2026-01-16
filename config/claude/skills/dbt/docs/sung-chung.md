---
title: "Sung Won Chung - 3 posts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/sung-chung"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

I, Sung, entered the data industry by chance in Fall 2014. I was using this thing called audit command language (ACL) to automate debits equal credits for accounting analytics (yes, it’s as tedious as it sounds). I remember working my butt off in a hotel room in Des Moines, Iowa where the most interesting thing there was a Panda Express. It was late in the AM. I’m thinking about 2 am. And I took a step back and thought to myself, “Why am I working so hard for something that I just don’t care about with tools that hurt more than help?”

*Special Thanks: Emilie Schario, Matt Winkler*

dbt has done a great job of building an elegant, common interface between data engineers, analytics engineers, and any data-y role, by uniting our work on SQL. This unification of tools and workflows creates interoperability between what would normally be distinct teams within the data organization.

I like to call this interoperability a “baton pass.” Like in a relay race, there are clear handoff points & explicit ownership at all stages of the process. But there’s one baton pass that’s still relatively painful and undefined: the handoff between machine learning (ML) engineers and analytics engineers.

In my experience, the initial collaboration workflow between ML engineering & analytics engineering starts off strong but eventually becomes muddy during the maintenance phase. This eventually leads to projects becoming unusable and forgotten.

In this article, we’ll explore a real-life baton pass between ML engineering and analytics engineering and highlighting where things went wrong.

Airflow and dbt are often framed as either / or:

You either build SQL transformations using Airflow’s SQL database operators (like [SnowflakeOperator](https://airflow.apache.org/docs/apache-airflow-providers-snowflake/stable/operators/snowflake.html)), or develop them in a dbt project.

You either orchestrate dbt models in Airflow, or you deploy them using dbt Cloud.

In my experience, these are false dichotomies, that sound great as hot takes but don’t really help us do our jobs as data people.
