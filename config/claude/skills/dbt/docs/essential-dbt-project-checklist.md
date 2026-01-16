---
title: "Your Essential dbt Project Checklist | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/essential-dbt-project-checklist"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



On this page

If you’ve been using dbt for over a year, your project is out-of-date. This is natural.

New functionalities have been released. Warehouses change. Best practices are updated. Over the last year, I and others on the Fishtown Analytics (now dbt Labs!) team have conducted seven audits for clients who have been using dbt for a minimum of 2 months.

In every single audit, we found opportunities to:

1. Improve performance
2. Improve maintainability
3. Make it easier for new people to get up-to-speed on the project

This post is the checklist I created to guide our internal work, and I’m sharing it here so you can use it to clean up your own dbt project. Think of this checklist like a `Where's Waldo?` book: you’ll still have to go out and find him, but with this in hand, you’ll at least know what you’re looking for.

## ✅ dbt\_project.yml[​](#-dbt_projectyml "Direct link to ✅ dbt_project.yml")

---

* Project naming conventions
  + What is the name of your project?
    - Did you keep it as ‘my\_new\_project’ per the init project or renamed it to make sense?
    - Our recommendation is to name it after your company such as ‘fishtown\_analytics’.
    - If you have multiple dbt projects, something like ‘fishtown\_analytics\_marketing’ might make more sense.
* Do you have unnecessary configurations like materialized: view?
  + By default, dbt models are materialized as “views”. This removes the need to declare any models as views.
  + If all of your models in a folder are tables, define the materialization on the dbt\_project.yml file rather than on the model file. This removes clutter from the model file.
* Do you have a ton of placeholder comments from the init command?
  + This creates unnecessary clutter.
* Do you use post-hooks to grant permissions to other transformers and BI users?
  + If no, you should! This will ensure that any changes made will be accessible to your collaborators and be utilized on the BI layer.
    ![on run end](data:image/png;base64,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)
* Are you utilizing tags in your project?
  + The majority of your project’s models should be untagged. Use tags for models and tests that fall out of the norm with how you want to interact with them. For example, tagging ‘nightly’ models makes sense, but *also* tagging all your non-nightly models as ‘hourly’ is unnecessary - you can simply exclude the nightly models!
  + Check to see if a node selector is a good option here instead of tags.
  + Are you tagging individual models in config blocks?
    - You can use folder selectors in many cases to eliminate over tagging of every model in a folder.
* Are you using YAML selectors?
  + These enable intricate, layered model selection and can eliminate complicated tagging mechanisms and improve the legibility of the project configuration

**Useful links**:

* [.yml files](https://docs.getdbt.com/docs/build/sources#testing-and-documenting-sources)
* [Materializations](https://docs.getdbt.com/docs/build/materializations#configuring-materializations)
* [YAML selectors](https://docs.getdbt.com/reference/node-selection/yaml-selectors)

## ✅ Package Management[​](#-package-management "Direct link to ✅ Package Management")

---

* How up to date are the versions of your dbt Packages?
  + You can check this by looking at your packages.yml file and comparing it to the packages hub page.
* Do you have the dbt\_utils package installed?
  + This is by far our most popular and essential package. The package contains clever macros to improve your dbt Project. Once implemented, you have access to the macros (no need to copy them over to your project).

**Useful links**

* [Packages Docs](https://docs.getdbt.com/docs/build/packages)
* [Package Hub](https://hub.getdbt.com/)
* [dbt utils package](https://github.com/dbt-labs/dbt-utils)

## ✅ Code style[​](#-code-style "Direct link to ✅ Code style")

---

* Do you have a clearly defined code style?
* Are you following it strictly?
* Are you optimizing your SQL?
  + Are you using window functions and aggregations?

**Useful links**

* [dbt Labs' code style](https://github.com/dbt-labs/corp/blob/master/dbt_style_guide.md)
* [Leveling up SQL](https://blog.getdbt.com/one-analysts-guide-for-going-from-good-to-great/)

## ✅ Project structure[​](#-project-structure "Direct link to ✅ Project structure")

---

* If you are using dimensional modeling techniques, do you have staging and marts models?
  + Do they use table prefixes like ‘fct\_’ and ‘dim\_’?
* Is the code modular? Is it one transformation per one model?
* Are you filtering as early as possible?
  + One of the most common mistakes we have found is not filtering or transforming early enough. This causes multiple models downstream to have the same repeated logic (i.e., wet code) and makes updating business logic more cumbersome.
* Are the CTEs modular with one transformation per CTE?
* If you have macro files, are you naming them in a way that clearly represent the macro(s) contained in the file?

**Useful links**

* [How Fishtown Structures our dbt Project](https://discourse.getdbt.com/t/how-we-structure-our-dbt-projects/355)
* [Why the Fishtown SQL style guide uses so many CTEs](https://discourse.getdbt.com/t/why-the-fishtown-sql-style-guide-uses-so-many-ctes/1091)

## ✅ dbt[​](#-dbt "Direct link to ✅ dbt")

---

* What version of dbt are you on?

  + The further you get away from the latest release, the more likely you are to keep around old bugs and make updating that much harder.
* What happens when you `dbt run`?

  + What are your longest-running models?
    - Is it time to reevaluate your modeling strategy?
    - Should the model be incremental?
      * If it’s already incremental, should you adjust your incremental strategy?
  + How long does it take to run the entire dbt project?
  + Does every model run? (This is not a joke.)
    - If not, why?
  + Do you have circular model references?
* Do you use sources?

  + If so, do you use source freshness tests?
* Do you use refs and sources for everything?

  + Make sure nothing is querying off of raw tables, etc.
    ![no querying raw tables](https://docs.getdbt.com/assets/images/checklist-8ddc2f76de24c98690ef986dcc7974bff09adb59-530a2087c2c21d256c0f0c150f52b23e.png)
* Do you regularly run `dbt test` as part of your workflow and production jobs?
* Do you use Jinja & Macros for repeated code?

  + If you do, is the balance met where it’s not being overused to the point code is not readable?
  + Is your Jinja easy to read?
    - Did you place all of your `set` statements at the top of the model files?
    - Did you format the code for Jinja-readability or just for the compiled SQL?
    - Do you alter your whitespace?
      * Example: `{{ this }}` and not `{{this}}`
  + Did you make complex macros as approachable as possible?
    - Way to do this are providing argument names and in-line documentation using `{# <insert text> #}`
* If you have incremental models, are they using unique keys and is\_incremental() macro?
* If you have tags, do they make sense? Do they get utilized?

**Useful links**

* [dbt release version](https://github.com/dbt-labs/dbt/releases)
* [Sources](https://docs.getdbt.com/docs/build/sources)
* [Refs](https://docs.getdbt.com/reference/dbt-jinja-functions/ref)
* [tags](https://docs.getdbt.com/reference/resource-configs/tags)
* [Jinja docs](https://docs.getdbt.com/guides/using-jinja)

## ✅ Testing & Continuous Integration[​](#-testing--continuous-integration "Direct link to ✅ Testing & Continuous Integration")

---

* Do your models have tests?
  + The ideal project has 100% test coverage on all of its models. While there are cases where this doesn’t make sense, our rule of thumb is models should have at least a not\_null/unique test on the primary key.
* What are you testing for? Does it make sense?
* What are the assumptions you should be testing for?
  + Think about your core business logic as well as your understanding of your sources.
* Are you using pull requests/other forms of version control?
  + How easy is it to understand what the code change and intention behind the code change do?
* Do you have mandatory PR reviews before merging code to your dbt project or BI layer?
  + Do you use a PR template?

**Useful links**

* [Version control](https://docs.getdbt.com/best-practices/best-practice-workflows#version-control-your-dbt-project)
* [dbt Labs' PR Template](https://docs.getdbt.com/blog/analytics-pull-request-template)

## ✅ Documentation[​](#-documentation "Direct link to ✅ Documentation")

---

* Do you use documentation?
* Are there descriptions for each model?
* Are complex transformations and business logic explained in an easily accessible place?
* Are your stakeholders using your documentation?
  + If not, why?
* Do you have a readme and regularly update it?
* How easy would it be to onboard someone to your project?
* If you have column-level descriptions, are you using doc blocks?

Useful Links

* [FAQs for documentation](https://docs.getdbt.com/docs/build/documentation#faqs)
* [Doc blocks](https://docs.getdbt.com/docs/build/documentation#using-docs-blocks)

## ✅ dbt Cloud specifics[​](#-dbt-cloud-specifics "Direct link to ✅ dbt Cloud specifics")

---

* What dbt version are the jobs?
  + Are the majority of them inheriting from the environment to make upgrading easier?
* What do your jobs look like? Do they make sense?
* How are your dbt cloud projects organized?
  + Do you have any unused projects?
* Have you chosen the most appropriate job for your account level documentation?
* Are the number of runs syncing up with how often your raw data updates and are viewed?
  + If your data isn’t updating as often as the runs are happening, this is just not doing anything.
* Do you have a full refresh of the production data?
* Do you run tests on a periodic basis?
* What are the longest-running jobs?
* Do you have a Continuous Integration job? (Github only)

Are you using the IDE and if so, how well?

* We found that the IDE has assisted in alleviating issues of maintaining the upgraded dbt version.
* Does dbt cloud have its own user in their warehouse? What is the default warehouse/role?
* Are you getting notifications for failed jobs? Have you set up the slack notifications?

**Useful links**

* [dbt Cloud as a CI tool](https://docs.getdbt.com/docs/deploy/continuous-integration)

## ✅ DAG Auditing[​](#-dag-auditing "Direct link to ✅ DAG Auditing")

---

*Note: diagrams in this section show what NOT to do!*

* Does your DAG have any common modeling pitfalls?
  + Are there any direct joins from sources into an intermediate model?

    - All sources should have a corresponding staging model to clean and standardize the data structure. They should not look like the image below.

      ![bad dag](https://docs.getdbt.com/assets/images/checklist-28c75101367e272fbc2db2ebb1a1ec030517bb5e_2_517x250-bedbcbcd1f8af035a7a2a8c8bc4769dd.jpeg)
  + Do sources join directly together?

    - All sources should have a corresponding staging model to clean and standardize the data structure. They should not look like the image below.

      ![bad dag 2](https://docs.getdbt.com/assets/images/checklist-5d8ad45deb695eb6771003e010b242c0a3c122b9_2_517x220-af89a1987dff20961be4b3f630d48a2a.jpeg)
  + Are there any rejoining of upstream concepts?

    - This may indicate:
      * a model may need to be expanded so all the necessary data is available downstream
      * a new intermediate model is necessary to join the concepts for use in both places

        ![bad dag 2](https://docs.getdbt.com/assets/images/checklist-acd57c0e781b1eaf75a65b5063f97ac3ddc5c493_2_517x136-e09f838fb03aa321fb4c08e1fa4b09de.jpeg)
  + Are there any “bending connections”?

    - Are models in the same layer dependent on each other?
    - This may indicate a change in naming is necessary, or the model should reference further upstream models

      ![bad dag 3](https://docs.getdbt.com/assets/images/checklist-0532fd13a7d63e3e5df71d025700c4d9c158a7ff_2_517x155-bd1ffcfe8861129584e97417aacde02f.jpeg)
  + Are there model fan outs of intermediate/dimension/fact models?

    - This might indicate some transformations should move to the BI layer, or transformations should be moved upstream
    - Your dbt project needs a defined end point!

      [![bad dag 4](https://docs.getdbt.com/assets/images/checklist-33fcd7c4922233412d1364b39227c876d0cb8215_2_517x111-15e5c68fba606c10258e83871699df31.jpeg)
  + Is there repeated logic found in multiple models?

    - This indicates an opportunity to move logic into upstream models or create specific intermediate models to make that logic reusable
    - One common place to look for this is complex join logic. For example, if you’re checking multiple fields for certain specific values in a join, these can likely be condensed into a single field in an upstream model to create a clean, simple join.

Thanks to Christine Berger for her DAG diagrams!

**Useful links**

* [How we structure our dbt Project](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview)
* [Coalesce DAG Audit Talk](https://www.youtube.com/watch?v=5W6VrnHVkCA&t=2s)
* [Modular Data Modeling Technique](https://getdbt.com/analytics-engineering/modular-data-modeling-technique/)
* [Understanding Threads](https://docs.getdbt.com/docs/running-a-dbt-project/using-threads)

This is a quick overview of things to think about in your project. We’ll keep this post updated as we continue to refine our best practices! Happy modeling!

#### Comments

![Loading](https://docs.getdbt.com/img/loader-icon.svg)

[Newer post

How to Create Near Real-time Models With Just dbt + SQL](https://docs.getdbt.com/blog/how-to-create-near-real-time-models-with-just-dbt-sql)
