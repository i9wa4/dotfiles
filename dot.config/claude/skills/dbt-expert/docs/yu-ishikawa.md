---
title: "Yu Ishikawa - One post | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/yu-ishikawa"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

*Editors note - this post assumes working knowledge of dbt Package development. For an introduction to dbt Packages check out [So You Want to Build a dbt Package](https://docs.getdbt.com/blog/so-you-want-to-build-a-package).*

It’s important to be able to test any dbt Project, but it’s even more important to make sure you have robust testing if you are developing a [dbt Package](https://docs.getdbt.com/docs/build/packages).

I love dbt Packages, because it makes it easy to extend dbt’s functionality and create reusable analytics resources. Even better, we can find and share dbt Packages which others developed, finding great packages in [dbt hub](https://hub.getdbt.com/). However, it is a bit difficult to develop complicated dbt macros, because dbt on top of [Jinja2](https://palletsprojects.com/p/jinja/) is lacking some of the functionality you’d expect for software development - like unit testing.

In this article, I would like to share options for unit testing your dbt Package - first through discussing the commonly used pattern of integration testing and then by showing how we can implement unit tests as part of our testing arsenal.
