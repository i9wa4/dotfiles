---
title: "Jordan Stein - One post | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/jordan-stein"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

There’s nothing quite like the feeling of launching a new product.
On launch day emotions can range from excitement, to fear, to accomplishment all in the same hour.
Once the dust settles and the product is in the wild, the next thing the team needs to do is track how the product is doing.
How many users do we have? How is performance looking? What features are customers using? How often? Answering these questions is vital to understanding the success of any product launch.

At dbt we recently made the [Semantic Layer Generally Available](https://www.getdbt.com/blog/new-dbt-cloud-features-announced-at-coalesce-2023). The Semantic Layer lets teams define business metrics centrally, in dbt, and access them in multiple analytics tools through our semantic layer APIs.
I’m a Product Manager on the Semantic Layer team, and the launch of the Semantic Layer put our team in an interesting, somewhat “meta,” position: we need to understand how a product launch is doing, and the product we just launched is designed to make defining and consuming metrics much more efficient. It’s the perfect opportunity to put the semantic layer through its paces for product analytics. This blog post walks through the end-to-end process we used to set up product analytics for the dbt Semantic Layer using the dbt Semantic Layer.
