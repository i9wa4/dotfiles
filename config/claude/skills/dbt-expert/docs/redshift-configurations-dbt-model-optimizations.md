---
title: "Optimizing dbt Models with Redshift Configurations | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/redshift-configurations-dbt-model-optimizations"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



On this page

If you're reading this article, it looks like you're wondering how you can better optimize your Redshift queries - and you're *probably* wondering how you can do that in conjunction with dbt.

In order to properly optimize, we need to understand **why** we might be seeing issues with our performance and **how** we can fix these with dbt [sort and dist configurations](https://docs.getdbt.com/reference/resource-configs/redshift-configs#using-sortkey-and-distkey).

In this article, we’ll cover:

* A simplified explanation of how Redshift clusters work
* What distribution styles are and what they mean
* Where to use distribution styles and the tradeoffs
* What sort keys are and how to use them
* How to use all these concepts to optimize your dbt models.

Let’s fix this once and for all!

## The Redshift cluster[​](#the-redshift-cluster "Direct link to The Redshift cluster")

In order to understand how we should model in dbt for optimal performance on Redshift, I’m first going to step through a simplified explanation of the underlying architecture so that we can set up our examples for distributing and sorting.

First, let’s visualize an example cluster:

![Cluster.png](data:image/png;base64,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)

This cluster has two nodes, which serve the purpose of storing data and computing some parts of your queries. You could have more than this, but for simplicity we’ll keep it at two.

These two nodes are like the office spaces of two different people who have been assigned a portion of work for the same assignment based on the information they have in their respective offices. Upon completion of their work, they give their results back to their boss who then assembles the deliverable items and reports the combined information back to the stakeholder.

Let's look at the data waiting to be loaded into Redshift:

![Source-Data.png](https://docs.getdbt.com/assets/images/Source-Data-8fe923987d733c9c9e110589459e9fd6.png)

You can see there are three tables of data here. When you load data into Redshift, the data gets distributed between the offices. In order to understand how that happens, let’s take a look at distribution styles.

## What are distribution styles?[​](#what-are-distribution-styles "Direct link to What are distribution styles?")

Distribution styles determine how data will be stored between offices (our nodes).
Redshift has three distribution styles:

* `all`
* `even`
* key-based

Let’s dive into what these mean and how they work.

### The `all` distribution style[​](#the-all-distribution-style "Direct link to the-all-distribution-style")

An `all` distribution means that both workers get the same copies of data.
To implement this distribution on our tables in dbt, we would apply this
configuration to each of our models:

```
{{ config(materialized='table', dist='all') }}
```

Here's a visualization of the data stored on our nodes:
![All-Distribution.png](https://docs.getdbt.com/assets/images/All-Distribution-b8a67c946d22658f98f5e081030a4f22.png)

**When to use the `all` distribution**:

This type of distribution is great for smaller data which doesn’t update frequently. Because `all` puts copies of our tables on all of our nodes, we’ll want to be sure we’re not giving our cluster extra work by needing to do this frequently.

### The `even` distribution style[​](#the-even-distribution-style "Direct link to the-even-distribution-style")

An `even` distribution means that both workers get close to equal amounts of data distributed to them. Redshift does this in a round-robin playing card style.

To implement this distribution on our tables in dbt, we would apply this
configuration to each of our models:

```
{{ config(materialized='table', dist='even') }}
```

Here's a visualization of the data stored on our nodes:
![Even-Distribution.png](https://docs.getdbt.com/assets/images/Even-Distribution-a42f4b5f316abbca1f5cf38801d8bf60.png)

Notice how our first worker received the first rows of our data\*\*,\*\* the second worker received the second rows, the first worker received the third rows, etc.

**When to use the `even` distribution**

This distribution type is great for a well-rounded workload by ensuring that each node has equal amounts of data. We’re not picky about *which* data each node handles, so the data can be evenly split between the nodes. That also means an equal amount of assignments are passed out resulting in no capacity wasted.

### The key-based distribution style[​](#the-key-based-distribution-style "Direct link to The key-based distribution style")

A key-based distribution means that each worker is assigned data based on a specific identifying value.

Let's distribute our **known\_visitor\_profiles** table by `person_id` by applying this configuration to the top of the model in dbt:

```
{{ config(materialized='table', dist='person_id') }}
```

Here's a visualization of the data stored on our nodes:
![Key-Based.png](data:image/png;base64,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EUAQQAQQBBABBAFEAEEAEUAQQAQQBLBDABFAEEAEEAQQAQQBRABBABFAEEAEEAQQAQQBRABBABFAEEAEEAQwgwAigCCACCAIIAIIAogAggAigCCACCAIIAIIAogAggAigCCAHQKIAIIAIoAggAggCCACCAKIAIIAIoAggAggCCACCAKIAIIAIoAggBkEEAEEAUQAQQARQBBABBAEEAEEAUQAQQARQBBABBAEEAEEAewQQAQQBBABBAFEAEEAEUAQQAQQBBABBAFEAEEAEUAQQAQQBBABBAHMIIAIIAggAggCiACCACKAIIAIIAggAggCiACCACKAIIAIIAhghwAigCCACCAIIAIIAogAggAigCCACCAIIAIIAogAggAigCCACCAIYAYBRABBABFAEEAEEAQQAQQBRABBABFAEEAEEAQQAQQBRABBADsEEAEEAUQAQQARQBBABBAEEAEEAUQAQQARQBBABBAEEAEEAUQAQQAzCCACCAKIAIIAIoAggAggCCACCAKIAIIAIoAggAggCCACCALYIYAIIAggAggCiACCACKAIIAIIAggAggCiACCACKAIIAIIAggAggCmEEAEUAQQAQQBBABBAFEAEEAEUAQQAQQBBABBAFEAEEAEUAQwA4BRABBABFAEEAEEAQQAQQBRABBABFAEEAEEAQQAQQBRABBABFAEMAMAogAggAigCCACCAIIAIIAogAggAigCCACCAIIAIIAogAggB2CCACCAKIAIIAIoAggAggCCACCAKIAIIAIoAggAggCCACCAKIAIIAZhBABBAEEAEEAUQAQQARQBBABBAEEAEEAUQAQQARQBBABBAEsEMAEUAQQAQQBBABBAFEAEEAEUAQQAQQBBABBAFEAEEAEUAQQAQQBDCDACKAIIAIIAggAggCiACCACKAIIAIIAggAggCiACCACKAIIAdAogAggAigCCACCAIIAIIAogAggAigCCACCAIIAIIAogAggAigCCAGQQQAQQBRABBABFAEEAEEAQQAQQBRABBABFAEEAEEAQQAQQB7BBABBAEEAEEAUQAQQARQBBABBAEEAEEAUQAQQARQBBABBAEEAEEAcwggAggCCACCAKIAIIAIoAggAggCCACCAKIAIIAIoAggAggCGCHACKAIIAIIAggAggCiACCACKAIIAIIAggAggCiACCACKAIIAIIAhgCAFEAEEAEUAQQAQQBBABBAFEAEEAEUAQQAQQBBABBAFEAEEAEUAaAQQBRABBABFAEEAEEAQQAQQBRABBABFAEEAEEAQQAQQBRABBADMIIAIIAogAggAigCCACCAIIAIIAogAggAigCCACCAIIAIIAogAYpTNUcvBYwSMchujnLUcfIyAUW5jlLdaDs4RMMptjPL5qsXgZwSMciOjvNc14AAa5X5G+V1LwecIGOVeRvlVC8HvCBjlbkZ5/tUi8LqPhFHuZ5TnPCoGx7w9xyLnfNQlYJQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8A/Irn1cqsZreQAAAABJRU5ErkJggg==)

It doesn’t look that different from `even`, right? The difference here is that because we’re using `person_id` as our distribution key, we ensure:

* Node 1 will always get data associated with values 1, 3, 5
* Node 2 will always get data associated with values 2, 4, 6

Let’s do this with another table to really see the effects. We'll apply the following configuration to our `visitors.sql` file:

```
{{ config(materialized='table', dist='person_id') }}
```

Here's a visualization of the data stored on our nodes:
![Key-Based-2.png](https://docs.getdbt.com/assets/images/Key-Based-2-595cb24b43cdc619a282ac5eca611092.png)

You can see above that because we distributed `visitors` on `person_id` as well, the nodes received the associated data we outlined above. We did have some null `person_ids` - those will be treated as a key value and distributed to one node.

**When to use key-based distribution**

Key-based distribution is great for when you’re really stepping it up. If we can dial in to our commonly joined data, then we can leverage the benefits of **co-locating** the data on the same node. This means our worker can have the data they need to complete the tasks they have **without duplicating** the amount of storage we need.

### Things to keep in mind when working with these configurations[​](#things-to-keep-in-mind-when-working-with-these-configurations "Direct link to Things to keep in mind when working with these configurations")

**Redshift has defaults.**
Redshift initially assigns an `all` distribution to your data, but switches seamlessly to an `even` distribution based on the growth of your data. This gives you time to model out your data without worrying too much about optimization. Reference what you learned above when you’re ready to start tweaking your modeling flows!

**Distribution only works on stored data.**
These configurations don’t work on views or ephemeral models.
This is because the data needs to be stored in order to be distributed. That means that the benefits only happen using table or incremental materializations.

**Applying sort and distribution configurations from dbt doesn’t affect how your raw data is sorted and distributed.**
Since dbt operates on top of raw data that’s already loaded into your warehouse, the following examples are geared towards optimizing your models *created with dbt*.

You can still use what you learn from this guide to choose how to optimize from ingestion\*\*,\*\* however this would need to be implemented via your loading mechanism. For example if you’re using a tool like Fivetran or Stitch, you’ll want to consult their docs to find out whether you can set the sort and distribution on load through their interfaces.

**Redshift is a columnar-store database.**
It doesn’t actually orient data values per row that it belongs to, but by column they belong to. This isn’t a necessary concept to understand for this guide, but in general columnar stores can be faster at retrieving data the more specific the selection you make. *While being selective of columns can optimize your model, I’ve found that it doesn’t have as tremendous an impact most of the time as setting sort and distribution configs.* As such, I won’t be covering this.

# Handling joins: Where distribution styles shine

Distribution styles *really* come in handy when we’re **handling joins**. Let’s work with an example. Say we have this query:

```
select <your_list_of_columns>
from visitors
left join known_visitor_profiles
on visitors.person_id = known_visitor_profiles.person_id
```

Now let’s look at what Redshift does per distribution style if we distribute both tables the same way.

### All[​](#all "Direct link to All")

Using `all` copies our data sets and stores the entirety of each within each node.

![All-Joining.gif](https://docs.getdbt.com/assets/images/All-Joining-5853347fd47d82a40024b1ae8d5ddb98.gif)

In our offices example, that means our workers can do their load of the work in peace without being interrupted or needing to leave their office, since they each have all the information they need.

The con here is that every time data needs to be distributed, it takes extra time and effort - we need to run to the copy machine, print copies for everyone, and pass them out to each office. It also means we have 2x the paper!

This is fine if we have data that doesn’t update too frequently.

### Even[​](#even "Direct link to Even")

Using `even` distributes our data sets as described in the [What are Distribution Styles?](#what-are-distribution-styles) section (round-robin) to each node. The even distribution results in each node having data that they *may* or *may not* need for their assigned tasks.

![Even-Joining.gif](https://docs.getdbt.com/assets/images/Even-Joining-756287f58188e20a44790ed2f6599eea.gif)

In our scenario of office workers, that means that if our workers can’t find the data they need to complete their assignment in their own office they need to send a request for information to the other office to try to locate the data. This communication takes time!

You can imagine how this would impact how long our query takes to complete. However, this distribution is usually a good starting point even with this impact because the workload to assemble data is shared in equal amounts and probably not too *skewed* - in other words, one worker isn’t sitting around with nothing to do while the other worker feverishly tries to work through stacks of information.

### Key-based[​](#key-based "Direct link to Key-based")

Our key-based distribution of `person_id` gave our nodes *assigned* data to work with. Here’s a refresher from the [What are Distribution Styles?](#what-are-distribution-styles) section:

* Node 1 was distributed data associated with key values null, 1, 3, and 5.
* Node 2 was distributed data associated with key values 2, 4, and 6

![Key-Based-Joining.gif](https://docs.getdbt.com/assets/images/Key-Based-Joining-ec512ce1fd81e61d2fc74ad6bbe574bc.gif)

This means that when we join the two tables we distributed, the data is **co-located** on the same node and therefore our workers don’t need leave their offices to collect the data they need to complete their work. Cool, huh?

## Where it breaks down 🚒 🔥 👩🏻‍🚒[​](#where-it-breaks-down--- "Direct link to Where it breaks down 🚒 🔥 👩🏻‍🚒")

You would think the most ideal distribution would be key-based. However, you can only assign **one key** to distribute by and that means if we have a query like this, we run into issues again:

```
select <your_list_of_columns>
from visitors
left join known_visitor_profiles
	on visitors.person_id = known_visitor_profiles.person_id
left join unknown_visitor_profiles
	on visitors.mask_id = anonymous_visitor_profiles.mask_id
```

How would you decide to distribute the `anonymous_visitor_profiles` data?

![Key-Based-Joining-2.png](https://docs.getdbt.com/assets/images/Key-Based-Joining-2-07919fd7b5ad5135529cd0e26a579267.png)

We have a few options:

* **Distribute by `all`**
  But if it’s a table that updates frequently, this may not be the best route.
  ![Key-Based-All.gif](https://docs.getdbt.com/assets/images/Key-Based-All-97159d1fff662958dd274fad97fae13b.gif)
* **Distribute by `even`**
  But then our nodes need to communicate when `visitors` is joined to `anonymous_visitor_profiles`.

  If you decide to do something like this, you should consider what your *largest* datasets are first and distribute using appropriate keys to co-locate that data. Then, benchmark the run times with your additional tables distributed with all or even - the additional time may be something you can live with!
  ![Key-Based-Even.gif](https://docs.getdbt.com/assets/images/Key-Based-Even-333847895cc3b07d72c50033a1c6f5f0.gif)
* **Distribute by key**
  Distributing the `anonymous_visitor_profiles` with a key in this situation won’t really do anything, since you’re not co-locating any data! For example, we could change to distribute by `mask_id`, but then we’d have to distribute the `visitors` table by `mask_id` and then you’d end up in the same boat again with the `known_visitor_profiles` model!

Thankfully with dbt, distributing isn’t our only option.

## How to have your cake and eat it, too 🎂[​](#how-to-have-your-cake-and-eat-it-too- "Direct link to How to have your cake and eat it, too 🎂")

Okay, so what if you want to have a key-based distribution, but you want to make those joins happen as well?

This is where the power of dbt modeling really comes in! dbt allows you to break apart your queries into things that make sense. With each query, you can assign your distribution keys to each model, meaning you can have much more control.

The following are some methods I’ve used in order to properly optimize run times, leveraging dbt’s ability to modularize models.

Note

I won’t get into our modeling methodology at dbt Labs in this article, but there are [plenty of resources](https://learn.getdbt.com/) to understand what might be happening in the following DAGs!

### Staggered joins[​](#staggered-joins "Direct link to Staggered joins")

![Staggered-Joins.png](https://docs.getdbt.com/assets/images/Staggered-Joins-62040b45159a02e28a698b01224f494a.jpg)

In this method, you piece out your joins based on the main table they’re joining to. For example, if you had five tables that were all joined using `person_id`, then you would stage your data (doing your clean up too, of course), distribute those by using `dist='person_id'`, and then marry them up in some table downstream. Now with that new table, you can choose the next distribution key you’ll need for the next process that will happen. In our example above, the next step is joining to the `anonymous_visitor_profiles` table which is distributed by `mask_id`, so the results of our join should also distribute by `mask_id`.

### Resolve to a single key[​](#resolve-to-a-single-key "Direct link to Resolve to a single key")

![Resolve-to-single-key](https://docs.getdbt.com/assets/images/Resolve-to-single-key-1911a9d1b47e1c1a33e358158fc4718d.jpg)

This method takes some time to think about, and it may not make sense to do it depending on what you need. This is definitely balance between coherence, usability, and performance.

The main point here is that you’re resolving the various keys and grains before the details are joined in. Because we’re not joining until the end, this means that only our intermediate tables get distributed based on the resolved keys and finally joined up in `dim_all_visitors`.

Sometimes the work you’re doing downstream is much easier to do when you do some complex modeling up front! When you want or need it, you’ll know.

# Sort keys

Lastly, let’s talk about sort keys. No matter how we’ve **distributed** our data, we can define how data is sorted within our nodes. By setting a sort key, we’re telling Redshift to chunk our rows into blocks, which are then assigned a min and max value. Redshift can now use those min and max values to make an informed decision about which data it can skip scanning.

Imagine that our office workers have no organization taking place with their documents - the papers are just added in the order they’re given. Now imagine that each worker needs to retrieve all paperwork associated to the person who wore a dog mask to the party. They would need to thumb through every drawer and every paper in their filing cabinets in order to pull out and assemble the information related to the dog-masked person.

Let’s take a look at the information in our filing cabinet in both sorted and unsorted formats. Below is our `anonymous_visitor_profiles` table sorted by `mask_id`:

![Sorting.gif](https://docs.getdbt.com/assets/images/Sorting-84ff360f7f7c624e026ef7ef2ee48388.gif)

Once sorted, Redshift can keep track of what exists in blocks of information. This is equivalent to the information in our filing cabinet being organized into folders where items with mask ids starting with letters b through c are in located in one folder, mask ids starting with letters d through f are in another folder, and so on. Now our office worker can skip looking through the folder b-c and skip straight to d-f:

![Scanning-Sort.gif](https://docs.getdbt.com/assets/images/Scanning-Sort-0d9ea701a28e261fcdbd45094ae598b8.gif)

Even without setting an explicit distribution, this can help immensely with optimization. Here are some good places to apply it:

* On any model you expect to be frequently filtered by range.
* Your ending models (often referred to as `marts`). Your stakeholders will be using these to slice and dice data. It’s best to sort based on how the data is most often filtered (This is most likely dates or datetimes!)
* On frequently joined keys. Redshift suggests you distribute **and** sort by these, as it allows Redshift to execute a sort merge join in which the sorting phase gets bypassed.

# Parting thoughts

Now that you know all about distribution, sorting, and how you can piece out your dbt models for better optimization, it should be much easier to make the decision on how to plan your optimization tactfully!

I have some ending thoughts before you get into tweaking these configurations:

### Let Redshift do its thing[​](#let-redshift-do-its-thing "Direct link to Let Redshift do its thing")

It’s nice to be able to sit back and watch how it performs without intervention! By allowing yourself the time to watch your models, you can be *much more* *targeted* with your optimization plans.

### Document before tweaking[​](#document-before-tweaking "Direct link to Document before tweaking")

If you’re about to tweak these configurations, make sure you document how long the model takes before the changes! If you have dev limits in place, you can still run a benchmark against the limit before and after the tweaks, although it *is* more ideal to work with larger amounts of data to really understand how it would affect processing once in production. I’ve been able to successfully test tweaks on limited data sets and it’s translated beautifully within production environments, but your milage may vary.

### Test removing legacy `dist` styles and sort keys first[​](#test-removing-legacy-dist-styles-and-sort-keys-first "Direct link to test-removing-legacy-dist-styles-and-sort-keys-first")

If there are any sort keys or distribution styles already defined, remove those to see how your models do with the default. Having a bad sort key or distribution style can negatively impact your performance, which is why I suggest not configuring these on any net new modeling unless you’re sure about the impact.

### Decide whether you you need to optimize at all![​](#decide-whether-you-you-need-to-optimize-at-all "Direct link to Decide whether you you need to optimize at all!")

Identifying whether you need to change these configurations sometimes isn’t straightforward, especially when you have a lot going on in your model! Here’s some tips to help you out:

* **Use the query optimizer**
  If you have access to look at Redshift’s query optimizer in the Redshift console or have permissions to run an explain/explain analyze yourself, it can be helpful in drilling down to problematic areas.
* **Organize with CTEs**
  You know we love CTEs - and in this instance they really help! I usually start troubleshooting a complex query by stepping through the CTEs of the problematic model. If the CTEs are executing logic in nicely rounded ways, it’s easy to find out which joins or statements are causing the issues.
* **Look for ways to clean up logic**
  This can be things like too much logic used on a join key, a model handling too many transformations, or bad materialization assignments.
  Sometimes all you need is a little code cleanup!
* **Step through joins one at a time**
  If it's one join, it’s easy to understand which keys to optimize by. If there’s multiple joins, you might need to comment out joins in order to understand which present the most problems. It’s a good idea to benchmark each approach you take.

  Here’s an example workflow:

  1. Run the problematic model (I do this a couple of times to get a baseline average on runtime). Notate the build time.
  2. Comment out joins and one by one, run the model. Keep doing this until you find which join is causing unideal run times.
  3. Decide on how best to optimize the join:
     + Optimize the logic or flow, such as moving the calculation on a key to a prior CTE or upstream model before the join.
     + Optimizing the distribution, such as doing the join in an upstream model so you can facilitate co-location of the data.
     + Optimizing the sort, such as identifying and assigning a frequently filtered column so that finding data is faster in downstream processing.

Now you have a better understanding of how to leverage Redshift sort and distribution configurations in conjunction with dbt modeling to alleviate your modeling woes.

If you have any more questions about Redshift and dbt, the #db-redshift channel in [dbt’s community Slack](https://www.getdbt.com/community/join-the-community/) is a great resource.

Now get out there and optimize! 😊

#### Comments

![Loading](https://docs.getdbt.com/img/loader-icon.svg)

[Newer post

A star (generator) is born](https://docs.getdbt.com/blog/star-sql-love-letter)[Older post

Stakeholder-friendly model names: Model naming conventions that give context](https://docs.getdbt.com/blog/stakeholder-friendly-model-names)
