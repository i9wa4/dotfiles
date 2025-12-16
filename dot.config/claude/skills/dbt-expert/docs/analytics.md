---
title: "One post tagged with \"analytics\" | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/tags/analytics"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



## Introduction[​](#introduction "Direct link to Introduction")

Building scalable data pipelines in a fast-growing fintech can feel like fixing a bike while riding it. You must keep insights flowing even as data volumes explode. At Kuda (a Nigerian neo-bank), we faced this problem as our user base surged. Traditional batch ETL (rebuilding entire tables each run) started to buckle; pipelines took hours, and costs ballooned. We needed to keep data fresh without reprocessing everything. Our solution was to leverage dbt’s [incremental models](https://docs.getdbt.com/docs/build/incremental-models), which process only new or changed records. This dramatically cut run times and curbed our BigQuery costs, letting us scale efficiently.
