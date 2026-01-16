---
title: "Euan Johnston - One post | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/euan-johnston"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

## The problem, the builder and tooling[​](#the-problem-the-builder-and-tooling "Direct link to The problem, the builder and tooling")

**The problem**: My partner and I are considering buying a property in Portugal. There is no reference data for the real estate market here - how many houses are being sold, for what price? Nobody knows except the property office and maybe the banks, and they don’t readily divulge this information. The only data source we have is Idealista, which is a portal where real estate agencies post ads.

Unfortunately, there are significantly fewer properties than ads - it seems many real estate companies re-post the same ad that others do, with intentionally different data and often misleading bits of info. The real estate agencies do this so the interested parties reach out to them for clarification, and from there they can start a sales process. At the same time, the website with the ads is incentivised to allow this to continue as they get paid per ad, not per property.

**The builder:** I’m a data freelancer who deploys end to end solutions, so when I have a data problem, I cannot just let it go.

**The tools:** I want to be able to run my project on [Google Cloud Functions](https://cloud.google.com/functions) due to the generous free tier. [dlt](https://dlthub.com/) is a new Python library for declarative data ingestion which I have wanted to test for some time. Finally, I will use dbt Core for transformation.
