---
title: "Simo Tumelius - One post | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/simo-tumelius"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

Different from dbt Cloud CLI

This blog explains how to use the `dbt-cloud-cli` Python library to create a data catalog app with dbt Cloud artifacts. This is different from the [dbt Cloud CLI](https://docs.getdbt.com/docs/cloud/cloud-cli-installation), a tool that allows you to run dbt commands against your dbt Cloud development environment from your local command line.

dbt Cloud is a hosted service that many organizations use for their dbt deployments. Among other things, it provides an interface for creating and managing deployment jobs. When triggered (e.g., cron schedule, API trigger), the jobs generate various artifacts that contain valuable metadata related to the dbt project and the run results.

dbt Cloud provides a REST API for managing jobs, run artifacts and other dbt Cloud resources. Data/analytics engineers would often write custom scripts for issuing automated calls to the API using tools [cURL](https://curl.se/) or [Python Requests](https://requests.readthedocs.io/en/latest/). In some cases, the engineers would go on and copy/rewrite them between projects that need to interact with the API. Now, they have a bunch of scripts on their hands that they need to maintain and develop further if business requirements change. If only there was a dedicated tool for interacting with the dbt Cloud API that abstracts away the complexities of the API calls behind an easy-to-use interface… Oh wait, there is: [the dbt-cloud-cli](https://github.com/data-mie/dbt-cloud-cli)!
