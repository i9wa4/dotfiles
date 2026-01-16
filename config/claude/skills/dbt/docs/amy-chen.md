---
title: "Amy Chen - 7 posts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/amy-chen"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

If you haven’t paid attention to the data industry news cycle, you might have missed the recent excitement centered around an open table format called Apache Iceberg™. It’s one of many open table formats like Delta Lake, Hudi, and Hive. These formats are changing the way data is stored and metadata accessed. They are groundbreaking in many ways.

But I have to be honest: **I don’t care**. But not for the reasons you think.

## Overview[​](#overview "Direct link to Overview")

Over the course of my three years running the Partner Engineering team at dbt Labs, the most common question I've been asked is, How do we integrate with dbt? Because those conversations often start out at the same place, I decided to create this guide so I’m no longer the blocker to fundamental information. This also allows us to skip the intro and get to the fun conversations so much faster, like what a joint solution for our customers would look like.

This guide doesn't include how to integrate with dbt Core. If you’re interested in creating a dbt adapter, please check out the [adapter development guide](https://docs.getdbt.com/guides/dbt-ecosystem/adapter-development/1-what-are-adapters) instead.

Instead, we're going to focus on integrating with dbt Cloud. Integrating with dbt Cloud is a key requirement to become a dbt Labs technology partner, opening the door to a variety of collaborative commercial opportunities.

Here I'll cover how to get started, potential use cases you want to solve for, and points of integrations to do so.

note

This blog post was updated on December 18, 2023 to cover the support of MVs on dbt-bigquery
and updates on how to test MVs.

## Introduction[​](#introduction "Direct link to Introduction")

The year was 2020. I was a kitten-only household, and dbt Labs was still Fishtown Analytics. A enterprise customer I was working with, Jetblue, asked me for help running their dbt models every 2 minutes to meet a 5 minute SLA.

After getting over the initial terror, we talked through the use case and soon realized there was a better option. Together with my team, I created [lambda views](https://discourse.getdbt.com/t/how-to-create-near-real-time-models-with-just-dbt-sql/1457) to meet the need.

Flash forward to 2023. I’m writing this as my giant dog snores next to me (don’t worry the cats have multiplied as well). Jetblue has outgrown lambda views due to performance constraints (a view can only be so performant) and we are at another milestone in dbt’s journey to support streaming. What. a. time.

Today we are announcing that we now support Materialized Views in dbt. So, what does that mean?

Packages are the easiest way for a dbt user to contribute code to the dbt community. This is a belief that I hold close as someone who is a contributor to packages and has helped many partners create their own during my time here at dbt Labs.

The reason is simple: packages, as an inherent part of dbt, follow our principle of being built by and for analytics engineers. They’re easy to install, accessible and at the end of the day, it’s just SQL (with sprinklings of git and jinja). You can either share your package with the community or just use it among your teams at your org.

So I challenge you after reading this article to test out your skillsets, think about the code that you find yourself reusing again and again, and build a package. Packages can be as complex as you would want; it’s just SQL hidden in the mix of reusable macros and expansive testing frameworks. So let’s get started on your journey.

At dbt Labs, as more folks adopt dbt, we have started to see more and more use cases that push the boundaries of our established best practices. This is especially true to those adopting dbt in the enterprise space.

After two years of helping companies from 20-10,000+ employees implement dbt & dbt Cloud, the below is my best attempt to answer the question: “Should I have one repository for my dbt project or many?” Alternative title: “To mono-repo or not to mono-repo, that is the question!”

More up-to-date information available

Since this blog post was first published, many data platforms have added support for [materialized views](https://docs.getdbt.com/blog/announcing-materialized-views), which are a superior way to achieve the goals outlined here. We recommend them over the below approach.

Before I dive into how to create this, I have to say this. **You probably don’t need this**. I, along with my other Fishtown colleagues, have spent countless hours working with clients that ask for near-real-time streaming data. However, when we start digging into the project, it is often realized that the use case is not there. There are a variety of reasons why near real-time streaming is not a good fit. Two key ones are:

1. The source data isn’t updating frequently enough.
2. End users aren’t looking at the data often enough.

So when presented with a near-real-time modeling request, I (and you as well!) have to be cynical.

If you’ve been using dbt for over a year, your project is out-of-date. This is natural.

New functionalities have been released. Warehouses change. Best practices are updated. Over the last year, I and others on the Fishtown Analytics (now dbt Labs!) team have conducted seven audits for clients who have been using dbt for a minimum of 2 months.
