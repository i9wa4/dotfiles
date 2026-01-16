---
title: "Simon Podhajsky - One post | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/simon-podhajsky"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

Set up CI/CD with dbt Cloud

This blog is specifically tailored for dbt Core users. If you're using dbt Cloud and your Git provider doesn't have a native dbt Cloud integration (like BitBucket), follow the [Customizing CI/CD with custom pipelines guide](https://docs.getdbt.com/guides/custom-cicd-pipelines?step=3) to set up CI/CD.

Continuous Integration (CI) sets the system up to test everyone’s pull request before merging. Continuous Deployment (CD) deploys each approved change to production. “Slim CI” refers to running/testing only the changed code, [thereby saving compute](https://discourse.getdbt.com/t/how-we-sped-up-our-ci-runs-by-10x-using-slim-ci/2603). In summary, CI/CD automates dbt pipeline testing and deployment.

[dbt Cloud](https://www.getdbt.com/), a much beloved method of dbt deployment, [supports GitHub- and Gitlab-based CI/CD](https://blog.getdbt.com/adopting-ci-cd-with-dbt-cloud/) out of the box. It doesn’t support Bitbucket, AWS CodeCommit/CodeDeploy, or any number of other services, but you need not give up hope even if you are tethered to an unsupported platform.

Although this article uses Bitbucket Pipelines as the compute service and Bitbucket Downloads as the storage service, this article should serve as a blueprint for creating a dbt-based Slim CI/CD *anywhere*. The idea is always the same:
