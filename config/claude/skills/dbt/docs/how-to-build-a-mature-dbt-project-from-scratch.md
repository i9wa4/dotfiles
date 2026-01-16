---
title: "How to Build a Mature dbt Project from Scratch | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/how-to-build-a-mature-dbt-project-from-scratch"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



On this page

> *[We would love to have] A maturity curve of an end-to-end dbt implementation for each version of dbt .... There are so many features in dbt now but it'd be great to understand, "what is the minimum set of dbt features/components that need to go into a base-level dbt implementation?...and then what are the things that are extra credit?"*
> -*Will Weld on dbt Community Slack*

One question we hear time and time again is this - what does it look like to progress through the different stages of maturity on a dbt project?

When Will posed this question on Slack, it got me thinking about what it would take to create a framework for dbt project maturity.

As an analytics engineer on the professional services team at dbt Labs, my teammates and I have had the unique opportunity to work on an unusually high number of dbt projects at organizations ranging from tiny startups to Fortune 500 companies and everything in between. From this vantage point, we have gained a unique understanding of the dbt adoption curve - how companies actually implement and expand their usage of dbt.

With every new engagement, we find ourselves working in a project with a unique mix of data challenges. With the explosion in popularity of dbt, and the constant release of new features and capabilities available in the tool, it’s really easy for data teams to go down the rabbit hole of dbt’s shiniest new features before prioritizing the simple ones that will likely be the most immediately impactful to their organization.

A lot of teams find themselves in this position because getting the organizational buy-in for the tool is actually the *easy* part. Folks have a lot of freedom to go ahead to try out dbt, but once you get started it can be hard to know whether you are taking advantage of all the dbt features that would be right for your project.

In working alongside teams on their dbt journey, we’ve noticed that there tend to be distinct stages of dbt usage that organizations progress through. We’ve come to think of these stages as representing \*\*dbt project maturity. \*\*

We can break the concept of maturity down into two categories. The first is\*\* feature\*\* **completeness**, or the number of distinct dbt features you are using. The other is\*\* feature depth\*\*, the level of sophistication within the use of individual features. For example, adding the source feature to your project would be increasing the completeness of your project, but adding the source freshness feature to the sources you already defined would be a way to add depth to your project. Walking along this matrix we can watch a teeny tiny baby project grow into a fully mature production grade dbt pipeline.

![image alt text](https://docs.getdbt.com/assets/images/image_0-f0e15e928107c12ad297a6af2344617b.png)

**How do we do this?**

Let’s pretend that we are an analytics engineer at Seeq Wellness, a hypothetical EHR (electronic health record!) company, and we want to try out dbt to model our patient, doctor and claims data for a critical KPI dashboard. We’re going to create a new dbt project together, and walk through the stages of development, incrementally adding key dbt features as we go along.

[We’ve developed a repository](https://github.com/dbt-labs/dbt-project-maturity) that traces the progress in this project; **for each step along the maturity curve**, there is a subfolder in that repo with a **fully functional version of our dbt project** at that stage. We’ve also included some sample raw data to add to your warehouse so you can run these projects yourself! You can use this repository to **benchmark the maturity of your own dbt project**.

## Caveats and Assumptions[​](#caveats-and-assumptions "Direct link to Caveats and Assumptions")

**This is an art, not science!**

*There are real life use cases where some features get introduced into projects out of the order described here, and that is perfectly reasonable. There are often justifiable reasons to introduce more advanced dbt features earlier in the development cycle.*

**You are the pace setter**

*There is no sense of timescale in this presentation! Some teams may mature their project in weeks rather than months. It's more important to think about ****how**** features build upon themselves (and each other) rather than ****how quickly**** they do so.*

## Level 1 - Infancy - Running your first model[​](#level-1---infancy---running-your-first-model "Direct link to Level 1 - Infancy - Running your first model")

**Key Outcomes**

* Create your first [model](https://docs.getdbt.com/docs/build/sql-models)
* Execute your first [dbt run](https://docs.getdbt.com/reference/commands/run)

![image alt text](https://docs.getdbt.com/assets/images/image_1-6da23f77c9b0d610c578926d07850952.png)

**Themes and Goals**

Now, I definitely have no authority to speak on what it takes to raise a child, but I understand that a big part of caring for an infant has to do with taking care of its inputs and outputs. The same can be said about a dbt project in this stage!

The goal here is to learn the very basics of interacting with a dbt project; feeding it SQL, getting data objects out of it. We will build on this later, but right now, the important thing to do is create a model in dbt, give dbt a command, and see that it properly produces the view or table in our warehouse that we expect.

In addition to learning the basic pieces of dbt, we're familiarizing ourselves with the modern, version-controlled analytics engineering workflow, and experimenting with how it feels to use it at our organization.

If we decide not to do this, we end up missing out on what the dbt workflow has to offer. If you want to learn more about why we think analytics engineering with dbt is the way to go, I encourage you to read the [dbt Viewpoint](https://docs.getdbt.com/community/resources/viewpoint#analytics-is-collaborative)!

In order to learn the basics, we’re going to [port over the SQL file](https://docs.getdbt.com/guides/refactoring-legacy-sql) that powers our existing "patient\_claim\_summary" report that we use in our KPI dashboard in parallel to our old transformation process. We’re not ripping out the old plumbing just yet. In doing so, we're going to try dbt on for size and get used to interfacing with a dbt project.

**Project Appearance**

We have one single SQL model in our models folder, and really, that's it. At this stage, the README and dbt\_project.yml are just artifacts from the [dbt init command](https://docs.getdbt.com/reference/commands/init), and don’t yet have specific documentation or configuration. At this stage of our journey, we just want to get up and running with a functional dbt project.

![image alt text](data:image/png;base64,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)

The most important thing we’re introducing when your project is an infant is the modern, version-controlled, collaborative approach to analytics that dbt offers. The thrill of executing your first successful dbt run is all you need to do to understand how dbt can be massively impactful to your analytics team.

## Level 2 - Toddlerhood - Building Modular Data Models[​](#level-2---toddlerhood---building-modular-data-models "Direct link to Level 2 - Toddlerhood - Building Modular Data Models")

**Key Outcomes**

* Configure your first [sources](https://docs.getdbt.com/docs/build/sources)
* Introduce modularity with [{{ ref() }}](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) and [{{ source() }}](https://docs.getdbt.com/reference/dbt-jinja-functions/source)
* [Document](https://docs.getdbt.com/docs/build/documentation) and [test](https://docs.getdbt.com/docs/build/data-tests) your first models

![image alt text](https://docs.getdbt.com/assets/images/image_3-e1b9afcfc260a57c31ca1702f70727a4.png)

**Themes and Goals**

Now that we're comfortable translating SQL into a model from our infant project, it's time to teach our project to take its very first steps.

Specifically, now is when it's useful to introduce ***modularity*** to our project.

We’re going to:

* Break out reused code into separate models and use [{{ ref() }}](https://docs.getdbt.com/reference/dbt-jinja-functions/ref) to build dependencies
* Use the [{{ source() }}](https://docs.getdbt.com/reference/commands/source) macro to declare our raw data dependencies
* Dip our toes into testing and documenting our models

**Project Appearance**

Let's check in on the growth of [our project](https://github.com/dbt-labs/dbt-project-maturity/tree/main/2-toddlerhood). We've broken some of our logic into its own model — our original script had repetitive logic in subqueries, now it's following a key principle of analytics engineering: Don't Repeat Yourself (DRY). For more information on how to refactor your SQL queries for Modularity - check out our [free on-demand course](https://learn.getdbt.com/courses/refactoring-sql-for-modularity).

We also added our first [YML files](https://circleci.com/blog/what-is-yaml-a-beginner-s-guide/). Here, we have one YAML file to [configure our sources](https://github.com/dbt-labs/dbt-project-maturity/blob/main/2-toddlerhood/models/source.yml), and one one YAML file to [describe our models](https://github.com/dbt-labs/dbt-project-maturity/blob/main/2-toddlerhood/models/schema.yml). We're just starting with basic declarations of our sources, primary key testing using dbt built in tests, and a model-level description -- these are the first steps of a project just learning to walk!

![image alt text](https://docs.getdbt.com/assets/images/image_4-834f2eb732a0779f93e5464609ab2cf1.png)

Leveling up from infant to toddler is a huge jump in terms of feature completeness! By adding in sources and refs, we’ve really started to take advantage of what makes dbt special.

## Level 3 - Childhood - Developing Standards for Code Collaboration and Maintainability[​](#level-3---childhood---developing-standards-for-code-collaboration-and-maintainability "Direct link to Level 3 - Childhood - Developing Standards for Code Collaboration and Maintainability")

**Key Outcomes**

* Standardize [project structure](https://discourse.getdbt.com/t/how-we-structure-our-dbt-projects/355), [SQL style guide](https://github.com/dbt-labs/corp/blob/master/dbt_style_guide.md) and [model naming conventions](https://www.getdbt.com/analytics-engineering/modular-data-modeling-technique/) in a contribution guide
* Develop testing and documentation requirements
* Create a PR template to ensure quality and consistency
* [Deploy your project](https://docs.getdbt.com/docs/deploy/deployments)!

![image alt text](https://docs.getdbt.com/assets/images/image_5-9afd8d018fe94ff2590a7e050cfb3b65.png)

**Themes and Goals**

We made a huge jump in our feature completeness in the last stage - now it’s time to think about getting the project ready to be used by multiple developers and even deployed into production. The best way to ensure consistency as we start collaborating is to define standards for how we write code and model data then enforce them in the review process. From the data team's perspective, we shouldn't be able to infer who wrote what line of code because one of our teammates uses the dreaded leading comma. Analytics code is an asset, and should be treated as production grade software.

**Project Appearance**

We've added project-level documentation to [our repo](https://github.com/dbt-labs/dbt-project-maturity/tree/main/3-childhood) for developers to review as they get started in this project. This generally includes:

1. A [contribution and SQL style guide](https://github.com/dbt-labs/dbt-project-maturity/blob/main/3-childhood/CONTRIBUTING.md).
2. A [README](https://github.com/dbt-labs/dbt-project-maturity/blob/main/3-childhood/README.md) with a set up guide with project-specific resources and links out to general dbt resources.
3. A [pull request template](https://github.com/dbt-labs/dbt-project-maturity/blob/main/3-childhood/.github/pull_request_template.md) to make sure we're checking new code against these guidelines every time we want to add new modeling work!

Let's look at our models — we went from a early stage DAG, starting to get a feel for modularity, to a clean, standardized and logically organized DAG — we can now see logical layers of modeling that correspond to the file tree structure we saw before — we can even see the model naming conventions lining up with these layers (stg, int, fct). Defining the standards in how we organize our models in our project level has resulted in a cleaner, easier to understand DAG too!

![image alt text](https://docs.getdbt.com/assets/images/image_6-991f426c1a94c6518360c8f80ab47f5e.png)

Even though we haven't changed the function of a lot of our features *codifying and standardizing the use of these features is a huge step forward for project maturity.* Getting to this level of maturity is when we generally start to think about running this project in production. With these guardrails in place, we can be confident our project isn’t going to fall out of bed at night and hurt itself -- it’s ready to take on a little bit of independence!

## Level 4 - Adolescence - Increasing Flexibility[​](#level-4---adolescence---increasing-flexibility "Direct link to Level 4 - Adolescence - Increasing Flexibility")

**Key Outcomes**

* Leverage code from dbt [packages](https://docs.getdbt.com/docs/build/packages)
* Increase model flexibility and scope of project
* Reduce dbt production build times with [advanced materializations](https://docs.getdbt.com/docs/build/materializations)

![image alt text](https://docs.getdbt.com/assets/images/image_7-2523fb43d13e02d83a154eff67dbedd7.png)

**Themes and Goals**

Wow, our project is growing up fast — it's heading off into the world, learning new things, getting into trouble (don't worry that's just normal teen stuff). Our project is finally starting to think about its place in the world and in the greater dbt ecosystem. It's also starting to get buy-in from our stakeholders, and they want \*more. \*At this stage, learning how to do some more advanced tricks with dbt can allow us to think beyond the business logic we’re defining, and instead think more about \*how \*that business logic is built. Where can we make this project more efficient? How can we start serving up more information *about* our data to our stakeholders?

I want to also call out that a "feature" to introduce at this stage is engagement with the [dbt community](https://www.getdbt.com/community/) — in reality, I'm hopeful that we'd have been doing that this whole time, but thinking about opening up your projects to community-supported packages, as well as using the braintrust in the community Slack as a jumping off point for solving some of your data problems starts to really blossom around this point in the project lifecycle.

**Project Appearance**

We can see the major development at [this stage](https://github.com/dbt-labs/dbt-project-maturity/tree/main/4-adolescence) is adding additional models that make our original claims report a lot more flexible -- we had only shown our users a subset of patient and doctor information in our fact model. Now, we have a more Kimball-ish-style marts setup, and we can leave selecting the dimensions up to our BI tool.

![image alt text](https://docs.getdbt.com/assets/images/image_8-135499dcc1bcb0836740ed76fb40f1b3.png)

Other enhancements not seen in the DAG at this stage include new custom macros to make SQL writing more dynamic and less repetitive. We can also see a packages.yml file, and we can start leveraging tests, macros, and even models developed by the dbt community. Leveraging package code is a key way to shrink our development time! We've also leveled up to using incremental logic for our largest data sets to speed up our runs and deliver insights faster. We're also interested in surfacing a little bit of the metadata from our project — we can start by enhancing our marts with data about its recency by enabling the source freshness feature. Knowing that the data in our dashboard is up to date and reliable can massively improve consumer confidence in our stack.

We've spent this level focused on deepening and optimizing our feature set — we haven't introduced much more feature completeness except for SQL macros and the use of packages. Now, we're strong enough dbt developers that our time and energy is focused on taking a step back from making this project work to thinking about how to make it work *well*.

## Level 5 - Adulthood - Solidifying Relationships[​](#level-5---adulthood---solidifying-relationships "Direct link to Level 5 - Adulthood - Solidifying Relationships")

**Key Outcomes**

* Formalize dbt’s relationship to BI with [exposures](https://docs.getdbt.com/docs/build/exposures)!
* Advanced use of metadata

![image alt text](https://docs.getdbt.com/assets/images/image_9-3552e38f1fecc1887e2625601a415952.png)

**Themes and Goals**

In adulthood, we're turning our gaze even further inward. Our dbt project itself is independent enough to start asking itself the big questions! What does it mean to be a dbt project in the year 2021? How have I been changing? How am I relating to my peers?

At this point, like we started to do in adolescence, we are going to focus on thinking about dbt-as-a-product, and how that product interacts with the rest of our stack. We are sinking our roots a layer deeper.

**Project Appearance**

We see the biggest jump from the previous stage in the [macros folder](https://github.com/dbt-labs/dbt-project-maturity/tree/main/5-adulthood/macros). By introducing advanced macros that go beyond simple SQL templating, we’re able to have dbt deepen its relationship to our warehouse. Now we can have dbt manage things like custom schema behavior, run post hooks to drop retired models and dynamically orchestrate object permission controls; dbt itself can become your command post for warehouse management.

Additionally, we’ve added an exposures file to formally define the use of our marts models in our BI tool. Exposures are the most mature way to declare the data team's contracts with data consumers. We now have close to end-to-end awareness of the data lineage — we know what data our project depends on, whether it's fresh, how it is transformed in our dbt models, and finally where it’s consumed in reports. Now, we can also know which of our key reports are impacted if and when we hit an error at any point in this flow.

That end to end awareness is visible on the DAG too — we can see the dashboard we declared in our exposures file here in orange!

![image alt text](https://docs.getdbt.com/assets/images/image_10-0b8a45ca6bc9a431c913a2d8c0308fd4.png)

Making the jump to thinking about metadata is a really powerful way to find areas for improvement in your project. For example, you can develop macros to measure things like your test coverage, and test to model ratio. You can look into packages like dbt\_meta\_testing to ensure your hitting minimum testing and documentation requirements.

If you're on cloud, you can do all of these and more in a more programmatic way with the metadata API — you can dig into model runtimes and bottlenecks, and leverage exposures directly in your BI tool to bring that metadata to your end users! Neat!

## Conclusion[​](#conclusion "Direct link to Conclusion")

Life is truly a highway. We’ve traced the growth of the Seeq Wellness dbt project from birth to mid-life crisis, and we have so much growing left to do. Hopefully you can use this framework as a jumping off point to find areas in your own projects where it could stand to grow up a bit. We would love to hear from you in the repo if there are any questions, disagreements, or enhancements you’d like to see here! Another huge thank you to Will Weld, who was instrumental in developing this framework!

#### Comments

![Loading](https://docs.getdbt.com/img/loader-icon.svg)

[Newer post

How We Calculate Time on Task, the Business Hours Between Two Dates](https://docs.getdbt.com/blog/measuring-business-hours-sql-time-on-task)[Older post

The Exact GitHub Pull Request Template We Use at dbt Labs](https://docs.getdbt.com/blog/analytics-pull-request-template)
