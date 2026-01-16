---
title: "Doug Beatty - 4 posts | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/doug-beatty"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

Do you ever have "bad data" dreams? Or am I the only one that has recurring nightmares? 😱

Here's the one I had last night:

It began with a midnight bug hunt. A menacing insect creature has locked my colleagues in a dungeon, and they are pleading for my help to escape . Finding the key is elusive and always seems just beyond my grasp. The stress is palpable, a physical weight on my chest, as I raced against time to unlock them.

Of course I wake up without actually having saved them, but I am relieved nonetheless. And I've had similar nightmares involving a heroic code refactor or the launch of a new model or feature.

Good news: beginning in dbt v1.8, we're introducing a first-class unit testing framework that can handle each of the scenarios from my data nightmares.

Before we dive into the details, let's take a quick look at how we got here.

Hi all, I’m Kshitij, a senior software engineer on the Core team at dbt Labs.
One of the coolest moments of my career here thus far has been shipping the new `dbt clone` command as part of the dbt-core v1.6 release.

However, one of the questions I’ve received most frequently is guidance around “when” to clone that goes beyond [the documentation on “how” to clone](https://docs.getdbt.com/reference/commands/clone).
In this blog post, I’ll attempt to provide this guidance by answering these FAQs:

1. What is `dbt clone`?
2. How is it different from deferral?
3. Should I defer or should I clone?

For years working in data and analytics engineering roles, I treasured the daily camaraderie sharing a small office space with talented folks using a range of tools - from analysts using SQL and Excel to data scientists working in Python. I always sensed that there was so much we could work on in collaboration with each other - but siloed data and tooling made this much more difficult. The diversity of our tools and languages made the potential for collaboration all the more interesting, since we could have folks with different areas of expertise each bringing their unique spin to the project. But logistically, it just couldn’t be done in a scalable way.

So I couldn’t be more excited about dbt’s polyglot capabilities arriving in dbt Core 1.3. This release brings Python dataframe libraries that are crucial to data scientists and enables general-purpose Python but still uses a shared database for reading and writing data sets. Analytics engineers and data scientists are stronger together, and I can’t wait to work side-by-side in the same repo with all my data scientist friends.

Going polyglot is a major next step in the journey of dbt Core. While it expands possibilities, we also recognize the potential for confusion. When combined in an intentional manner, SQL, dataframes, and Python are also stronger together. Polyglot dbt allows informed practitioners to choose the language that best fits your use case.

In this post, we’ll give you your hands-on experience and seed your imagination with potential applications. We’ll walk you through a [demo](https://github.com/dbt-labs/demo-python-blog) that showcases string parsing - one simple way that Python can be folded into a dbt project.

We’ll also give you the intellectual resources to compare/contrast:

* different dataframe implementations within different data platforms
* dataframes vs. SQL

Finally, we’ll share “gotchas” and best practices we’ve learned so far and invite you to participate in discovering the answers to outstanding questions we are still curious about ourselves.

Based on our early experiences, we recommend that you:

✅ **Do**: Use Python when it is better suited for the job – model training, using predictive models, matrix operations, exploratory data analysis (EDA), Python packages that can assist with complex transformations, and select other cases where Python is a more natural fit for the problem you are trying to solve.

❌ **Don’t**: Use Python where the solution in SQL is just as direct. Although a pure Python dbt project is possible, we’d expect the most impactful projects to be a mixture of SQL and Python.

If you’ve needed to grant access to a dbt model between 2019 and today, there’s a good chance you’ve come across the ["The exact grant statements we use in a dbt project"](https://discourse.getdbt.com/t/the-exact-grant-statements-we-use-in-a-dbt-project/430) post on Discourse. It explained options for covering two complementary abilities:

1. querying relations via the "select" privilege
2. using the schema those relations are within via the "usage" privilege
