---
title: "Jonathan Neo - One post | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/jonathan-neo"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

Dimensional modeling is one of many data modeling techniques that are used by data practitioners to organize and present data for analytics. Other data modeling techniques include Data Vault (DV), Third Normal Form (3NF), and One Big Table (OBT) to name a few.

[![Data modeling techniques on a normalization vs denormalization scale](https://docs.getdbt.com/img/blog/2023-04-18-building-a-kimball-dimensional-model-with-dbt/data-modelling.png?v=2 "Data modeling techniques on a normalization vs denormalization scale")](#)Data modeling techniques on a normalization vs denormalization scale

While the relevance of dimensional modeling [has been debated by data practitioners](https://discourse.getdbt.com/t/is-kimball-dimensional-modeling-still-relevant-in-a-modern-data-warehouse/225/6), it is still one of the most widely adopted data modeling technique for analytics.

Despite its popularity, resources on how to create dimensional models using dbt remain scarce and lack detail. This tutorial aims to solve this by providing the definitive guide to dimensional modeling with dbt.

By the end of this tutorial, you will:

* Understand dimensional modeling concepts
* Set up a mock dbt project and database
* Identify the business process to model
* Identify the fact and dimension tables
* Create the dimension tables
* Create the fact table
* Document the dimensional model relationships
* Consume the dimensional model
