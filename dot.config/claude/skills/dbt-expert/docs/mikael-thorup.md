---
title: "Mikael Thorup - One post | dbt Developer Hub"
source_url: "https://docs.getdbt.com/blog/authors/mikael-thorup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



---

At [Lunar](https://www.lunar.app/), most of our dbt models are sourcing from event-driven architecture. As an example, we have the following models for our `activity_based_interest` folder in our ingestion layer:

* `activity_based_interest_activated.sql`
* `activity_based_interest_deactivated.sql`
* `activity_based_interest_updated.sql`
* `downgrade_interest_level_for_user.sql`
* `set_inactive_interest_rate_after_july_1st_in_bec_for_user.sql`
* `set_inactive_interest_rate_from_july_1st_in_bec_for_user.sql`
* `set_interest_levels_from_june_1st_in_bec_for_user.sql`

This results in a lot of the same columns (e.g. `account_id`) existing in different models, across different layers. This means I end up:

1. Writing/copy-pasting the same documentation over and over again
2. Halfway through, realizing I could improve the wording to make it easier to understand, and go back and update the `.yml` files I already did
3. Realizing I made a syntax error in my `.yml` file, so I go back and fix it
4. Realizing the columns are defined differently with different wording being used in other folders in our dbt project
5. Reconsidering my choice of career and pray that a large language model will steal my job
6. Considering if there’s a better way to be generating documentation used across different models
