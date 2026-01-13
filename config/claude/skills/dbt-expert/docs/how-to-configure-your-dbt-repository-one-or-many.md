---
title: "How to Configure Your dbt Repository (One or Many)? | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/how-to-configure-your-dbt-repository-one-or-many"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



On this page

At dbt Labs, as more folks adopt dbt, we have started to see more and more use cases that push the boundaries of our established best practices. This is especially true to those adopting dbt in the enterprise space.

After two years of helping companies from 20-10,000+ employees implement dbt & dbt Cloud, the below is my best attempt to answer the question: “Should I have one repository for my dbt project or many?” Alternative title: “To mono-repo or not to mono-repo, that is the question!”

Before we jump into specific structures, I want to start by emphasizing that our guiding principle has always been that **simpler is better**, especially when you are getting started! It should also be noted that everything presented below builds upon Jeremy’s excellent write up on this [from a few years back](https://discourse.getdbt.com/t/should-i-have-an-organisation-wide-project-a-monorepo-or-should-each-work-flow-have-their-own/666/2). That is the prerequisite to this article.

Before we get started, we need to take inventory. Consider the workflow and teams that will be using dbt.

**From a workflow perspective, consider:**

* What will the review process look like at your organization?
  + Who can approve pull requests?
  + Who will be able to merge code to production?
* For more complex environments who have a dev/qa/prod git branching paradigm:
  + Who has access to the objects created in the dev environment? In the qa environment?
  + Who needs to be alerted when code has been released to the qa branch?
  + Who is responsible for promoting objects from dev to qa? From qa to prod?

**From a people or team perspective, consider:**

* How do teams using dbt usually work together?
* Do those teams have different code styles, review processes, and chief maintainers?
* Do the teams using dbt ever use the same data sources? Is the raw data located somewhere that all teams using dbt will have access to?
* Is there SQL that one team should have access to but another team should not? Can folks see the SQL behind the object creation?
* Are there objects that one team is responsible for that other teams are the consumers of?

The answers to these questions should help you navigate through the four options detailed below. I also want to make it clear: the options I’m about to show you will likely be influenced by your data team(s) size but that should not be the only factor to consider. I have seen a team of 30 folks use option 1 and a team of 10 use option 3. It is truly dependent on what your priorities lay.

**Note:** One repository in this context equates to one dbt project with one dbt\_project.yml. It does not need to have a 1:1 relationship with a dbt cloud project.

## Option 1: One Repository[​](#option-1-one-repository "Direct link to Option 1: One Repository")

---

![one repository](https://docs.getdbt.com/assets/images/monorepo-52954083da8268c53f27a578b4b5722b35803b03_2_624x439-96d13a079694069acb18f97117e2536b.png)

This is the most common structure we see for dbt repository configuration. Though the illustration separates models by business unit, all of the SQL files are stored and organized in a single repository.

**Strengths**

* Easy to share and maintain the same core business logic
* Full dependency lineage - your dbt generated DAG encompasses all of your [data transformations](https://www.getdbt.com/analytics-engineering/transformation/) for your entire company

**Weaknesses**

* Too many people! Your repository could have a lot of concurrently open issues/pull requests.
* Too many models! Your analyst is now wading through hundreds of files when their team only works on one business unit’s modeling
* Pull Request approval can be challenging (who has approval for which team? who approves changes to core models used across teams?)

This is our most time tested option and our most recommended. However, we have started to see folks “size out” of this approach. While it’s difficult to define qualitatively when your team has outgrown this model, these are some factors to consider that might push you to consider alternative options:

* Your project has 500+ models and the time it takes to compile your dbt project hinders the workflow of your developer\*
* Your git workflow is starting to become cumbersome because there are too many hands in the pot in terms of who needs to approve what

\*We are making significant efforts to improve this on larger projects but this is something to keep in mind.

## Option 2: Separate Team Repository with One Shared Repository[​](#option-2-separate-team-repository-with-one-shared-repository "Direct link to Option 2: Separate Team Repository with One Shared Repository")

---

![separate repository](data:image/png;base64,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)

This is one of the first structures we see people move toward when they “outgrow” the mono repo: there is one “core” repository that is incorporated into team specific repositories as a package. If you aren’t familiar with packages, [see the documentation](https://docs.getdbt.com/docs/build/packages/) for more information.

How would the above function? While each team would work in their own repository, they would put shared items into the shared repository which is then installed in as a package to their repository. Some common things to put into that shared repository would be:

* a core `dim_customers` model that is relevant across marketing and finance departments.
* `all_days` or calendar model that defines your specific business logics around your financial year calendar and company holidays.
* Macros to be used across your business units. Things like date conversions, seed files to help segment company wide attributes, etc.
* Shared sources (sources.yml files + staging models for those sources)

What doesn’t go into that shared repository?

* Models specific to the team (things like `fct_transactions` or `fct_ads`) would live in the unique team repos.
* Team specific logic (things like if you have different definitions of what revenue is, etc)

**Strengths**

* Easier approval workflows in terms of team-specific models
* Easier to control user permissions (especially if you have sensitive data or SQL)
* Fewer people contributing to each repository

**Weaknesses**

* Hard to decide what goes into the Shared Repository
* Maintaining downstream dependencies of macros and models. There is a need to create a CI/CD process that assures changes in the shared repository will not negatively impact the downstream repositories. It’s possible that you will have to introduce [semantic versioning](https://en.wikipedia.org/wiki/Software_versioning) to mitigate miscommunication about breaking changes.
* Incomplete lineage/documentation for objects not the shared repository

This is the option I recommend the most when one must stray away from Option 2. This follows our [dbt viewpoint](https://docs.getdbt.com/community/resources/viewpoint#analytics-is-collaborative) the best in terms of dry code and collaboration as opposed to Option 3 & 4.

## Option 3: Completely Separate Repositories[​](#option-3-completely-separate-repositories "Direct link to Option 3: Completely Separate Repositories")

---

![completely separate repos](https://docs.getdbt.com/assets/images/monorepo-7f6c787766d980479e44a0419e845bc2fc80fa1a_2_296x390-0b34b18a5392158c1abf04646b5c6bd6.png)

Then, there is the “don’t allow any overlap” complete separation of repositories within a single organization.

**Strengths**

* Simple approval process
* Fitting if different teams have separate Snowflake Accounts/Redshift instances

**Weaknesses**

* Easy to create duplicate business logic or out of sync business logic between repositories
  + A less than ideal work around: consumers from other teams can subscribe to another team’s releases to be aware of changes.
* Non-collaborative approach
* Incomplete lineage/documentation of company wide data transformations

There is a time and a place where this makes sense but you start to lose the reusability of code that is one of dbt’s biggest strengths! Unless there is a really good security reason behind this and a true separation of analytics needs across the teams, this approach is the one we recommend avoiding as much as possible.

## Option 4: Separate Team Repositories + One Documentation Repository[​](#option-4-separate-team-repositories--one-documentation-repository "Direct link to Option 4: Separate Team Repositories + One Documentation Repository")

---

![separate team repositories](https://docs.getdbt.com/assets/images/monorepo-275ba0c84ef31370a57f125ac13a0cbcb808af9a_2_600x365-39689357747c73906c0d3c93a6c36bb3.png)

This approach is nearly identical to the former (completely separate repositories) but solves one of the weaknesses (“incomplete lineage/documentation”) by introducing an additional repository. If you need something akin to Option 3, this is the better approach.

**Strengths**

* Creates a project to provide an overview of the entire organization’s dbt projects\*
* Simple maintenance
* Takes advantage of the strengths from `completely separate repositories` (see above example)

**Weaknesses**

* Creates an extraneous project for administrative oversight
* Does not prevent conflicting business logic or duplicate macros
* All models must have unique names across all packages

\*\* The project will include the information from the dbt projects but might be missing information that is pulled from your data warehouse if you are on multiple Snowflake accounts/Redshift instances. This is because dbt is only able to query the information schema from that one connection.

## So… to mono-repo or not to mono-repo?[​](#so-to-mono-repo-or-not-to-mono-repo "Direct link to So… to mono-repo or not to mono-repo?")

---

All of the above configurations “work”. And as detailed, they each solve for a different use case and business priority. At the end of the day, you need to choose what makes sense for your team today and what your team will need 6 months from now. My recommendations are:

1. Ask the above questions.
2. Figure out what may be a pain point in the future and try to plan for it from the beginning.
3. Don’t over-complicate things until you have the right reason. As I said in my Coalesce talk: **don’t drag your skeletons from one closet to another** 💀!

**Note:** Our attempt in writing guides like this and [How we structure our dbt projects](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview) aren’t to try to convince you that our way is right; it is to hopefully save you the hundreds of hours it has taken us to form those opinions!

#### Comments

![Loading](https://docs.getdbt.com/img/loader-icon.svg)

[Newer post

September 2021 dbt Update: DAG in the IDE + Metadata API in GA](https://docs.getdbt.com/blog/dbt-product-update-2021-september)[Older post

How to Create Near Real-time Models With Just dbt + SQL](https://docs.getdbt.com/blog/how-to-create-near-real-time-models-with-just-dbt-sql)
