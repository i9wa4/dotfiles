---
title: "Santiago Jauregui - One post | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/santiago-jauregui"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

## Introduction[​](#introduction "Direct link to Introduction")

Most data modeling approaches for customer segmentation are based on a wide table with user attributes. This table only stores the current attributes for each user, and is then loaded into the various SaaS platforms via Reverse ETL tools.

Take for example a Customer Experience (CX) team that uses Salesforce as a CRM. The users will create tickets to ask for assistance, and the CX team will start attending them in the order that they are created. This is a good first approach, but not a data driven one.

An improvement to this would be to prioritize the tickets based on the customer segment, answering our most valuable customers first. An Analytics Engineer can build a segmentation to identify the power users (for example with an RFM approach) and store it in the data warehouse. The Data Engineering team can then export that user attribute to the CRM, allowing the customer experience team to build rules on top of it.
