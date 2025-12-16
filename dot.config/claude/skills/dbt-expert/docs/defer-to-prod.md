---
title: "More time coding, less time waiting: Mastering defer in dbt | dbt Developer Blog"
source_url: "https://docs.getdbt.com/blog/defer-to-prod"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



On this page

Picture this — you’ve got a massive dbt project, thousands of models chugging along, creating actionable insights for your stakeholders. A ticket comes your way — a model needs to be refactored! "No problem," you think to yourself, "I will simply make that change and test it locally!" You look at your lineage, and realize this model is many layers deep, buried underneath a long chain of tables and views.

“OK,” you think further, “I’ll just run a `dbt build -s +my_changed_model` to make sure I have everything I need built into my dev schema and I can test my changes”. You run the command. You wait. You wait some more. You get some coffee, and completely take yourself out of your dbt development flow state. A lot of time and money down the drain to get to a point where you can *start* your work. That’s no good!

Luckily, dbt’s defer functionality allow you to *only* build what you care about when you need it, and nothing more. This feature helps developers spend less time and money in development, helping ship trusted data products faster. dbt Cloud offers native support for this workflow in development, so you can start deferring without any additional overhead!

## Defer to prod or prefer to slog[​](#defer-to-prod-or-prefer-to-slog "Direct link to Defer to prod or prefer to slog")

A lot of dbt’s magic relies on the elegance and simplicity of the `{{ ref() }}` function, which is how you can build your lineage graph, and how dbt can be run in different environments — the `{{ ref() }}` functions dynamically compile depending on your environment settings, so that you can run your project in development and production without changing any code.

Here's how a simple `{{ ref() }}` would compile in different environments:

* Raw Model Code* Compiled in Dev* Compiled in Prod

```
-- in models/my_model.sql
select * from {{ ref('model_a') }}
```

```
-- in target/compiled/models/my_model.sql
select * from analytics.dbt_dconnors.model_a
```

```
-- in target/compiled/models/my_model.sql
select * from analytics.analytics.model_a
```

All of that is made possible by the dbt `manifest.json`, [the artifact](https://docs.getdbt.com/reference/artifacts/manifest-json) that is produced each time you run a dbt command, containing the comprehensive and encyclopedic compendium of all things in your project. Each node is assigned a `unique_id` (like `model.my_project.my_model` ) and the manifest stores all the metadata about that model in a dictionary associated to that id. This includes the data warehouse location that gets returned when you write `{{ ref('my_model') }}` in SQL. Different runs of your project in different environments result in different metadata written to the manifest.

Let’s think back to the hypothetical above — what if we made use of the production metadata to read in data from production, so that I don’t have to rebuild *everything* upstream of the model I’m changing? That’s exactly what `defer` does! When you supply dbt with a production version of the `manifest.json` artifact, and pass the `--defer` flag to your dbt command, dbt will resolve the `{{ ref() }}` functions for any resource upstream of your selected models with the *production metadata* — no need to rebuild anything you don’t have to!

Let’s take a look at a simplified example — let’s say your project looks like this in production:

[![A simplified dbt project running in production.](https://docs.getdbt.com/img/blog/2024-01-09-defer-in-development/prod-environment-plain.png?v=2 "A simplified dbt project running in production.")](#)A simplified dbt project running in production.

And you’re tasked with making changes to `model_f`. Without defer, you would need to make sure to at minimum execute a `dbt run -s +model_f` to ensure all the upstream dependencies of `model_f` are present in your development schema so that you can start to run `model_f`.\* You just spent a whole bunch of time and money duplicating your models, and now your warehouse looks like this:

[![The whole project has been rebuilt into the dev schema, which can be time consuming and expensive!](https://docs.getdbt.com/img/blog/2024-01-09-defer-in-development/prod-and-dev-full.png?v=2 "The whole project has been rebuilt into the dev schema, which can be time consuming and expensive!")](#)The whole project has been rebuilt into the dev schema, which can be time consuming and expensive!

With defer, we should not build anything other than the models that have changed, and are now different from their production counterparts! Let’s tell dbt to use production metadata to resolve our refs, and only build the model I have changed — that command would be `dbt run -s model_f --defer` .\*\*

[![Using defer, we can only build one single model](https://docs.getdbt.com/img/blog/2024-01-09-defer-in-development/prod-and-dev-defer.png?v=2 "Using defer, we can only build one single model")](#)Using defer, we can only build one single model

This results in a *much slimmer build* — we read data in directly from the production version of `model_b` and `model_c`, and don’t have to worry about building anything other than what we selected!

\* [Another option](https://docs.getdbt.com/reference/commands/clone) is to run `dbt clone -s +model_f` , which will make clones of your production models into your development schema, making use of zero copy cloning where available. Check out this [great dev blog](https://docs.getdbt.com/blog/to-defer-or-to-clone) from Doug and Kshitij on when to use `clone` vs `defer`!

\*\* in dbt Core, you also have to tell dbt where to find the production artifacts! Otherwise it doesn’t know what to defer to. You can either use the `--state path/to/artifact/folder` option, or set a `DBT_STATE` environment variable.

### Batteries included deferral in dbt Cloud[​](#batteries-included-deferral-in-dbt-cloud "Direct link to Batteries included deferral in dbt Cloud")

dbt Cloud offers a seamless deferral experience in both the dbt Cloud IDE and the dbt Cloud CLI — dbt Cloud ***always*** has the latest run artifacts from your production environment. Rather than having to go through the painful process of somehow getting a copy of your latest production `manifest.json` into your local filesystem to defer to, and building a pipeline to always keep it fresh, dbt Cloud does all that work for you. When developing in dbt Cloud, the latest artifact is automatically provided to you under the hood, and dbt Cloud handles the `--defer` flag for you when you run commands in “defer mode”. dbt Cloud will use the artifacts from the deployment environment in your project marked as `Production` in the [environments settings](https://docs.getdbt.com/docs/deploy/deploy-environments#set-as-production-environment) in both the IDE and the Cloud CLI. Be sure to configure a production environment to unlock this feature!

In the dbt Cloud IDE, there’s as simple toggle switch labeled `Defer to production`. Simply enabling this toggle will defer your command to the production environment when you run any dbt command in the IDE!

[![The defer to prod toggle in the IDE](https://docs.getdbt.com/img/blog/2024-01-09-defer-in-development/defer-toggle.png?v=2 "The defer to prod toggle in the IDE")](#)The defer to prod toggle in the IDE

The cloud CLI has this setting *on by default* — there’s nothing else you need to do to set this up! If you prefer not to defer, you can pass the `--no-defer` flag to override this behavior. You can also set an environment other than your production environment as the deferred to environment in your `dbt-cloud` settings in your `dbt_project.yml` :

```
dbt-cloud:
  project-id: <Your project id>
  defer-env-id: <An environment id>
```

When you’re developing with dbt Cloud, you can defer right away, and completely avoid unnecessary model builds in development!

### Other things to to know about defer[​](#other-things-to-to-know-about-defer "Direct link to Other things to to know about defer")

**Favoring state**

One of the major gotchas in the defer workflow is that when you’re in defer mode, dbt assumes that all the objects in your development schema are part of your current work stream, and will prioritize those objects over the production objects when possible.

Let’s take a look at that example above again, and pretend that some time before we went to make this edit, we did some work on `model_c`, and we have a local copy of `model_c` hanging out in our development schema:

[![Hypothetical starting point, with a development copy of model_c in the development schema at the start of the development cycle.](https://docs.getdbt.com/img/blog/2024-01-09-defer-in-development/prod-and-dev-model-c.png?v=2 "Hypothetical starting point, with a development copy of model_c in the development schema at the start of the development cycle.")](#)Hypothetical starting point, with a development copy of model\_c in the development schema at the start of the development cycle.

When you run `dbt run -s model_f --defer` , dbt will detect the development copy of `model_c` and say “Hey, y’know, I bet Dave is working on that model too, and he probably wants to make sure his changes to `model_c` work together with his changes to `model_f` . Because I am a kind and benevolent data transformation tool, i’ll make sure his `{{ ref('model_c') }]` function compiles to his development changes!” Thanks dbt!

As a result, we’ll effectively see this behavior when we run our command:

[![With a development version of model_a in our dev schema, dbt will preferentially use that version instead of deferring](https://docs.getdbt.com/img/blog/2024-01-09-defer-in-development/prod-and-dev-mixed.png?v=2 "With a development version of model_a in our dev schema, dbt will preferentially use that version instead of deferring")](#)With a development version of model\_a in our dev schema, dbt will preferentially use that version instead of deferring

Where our code would compile from

```
# in models/model_f.sql
with

model_b as (
 select * from {{ ref('model_b') }}
),

model_c as (
 select * from {{ ref('model_c') }}
),

...
```

to

```
# in target/compiled/models/model_f.sql
with

model_b as (
 select * from analytics.analytics.model_b
),

model_c as (
 select * from analytics.dbt_dconnors.model_b
),

...
```

A mix of prod and dev models may not be what we want! To avoid this, we have a couple options:

1. **Start fresh every time:** The simplest way to avoid this issue is to make sure you are always drop your development schema at the start of a new development session. That way, the only things that show up in your development schema are the things you intentionally selected with your commands!
2. **Favor state:** Passing the `--favor-state` flag to your command tells dbt “Hey benevolent tool, go ahead and use what you find in the production manifest no matter what you find in my development schema” so that both `{{ ref() }}` functions in the example above point to the production schema, even if `model_c` was hanging around in there.

In this example, `model_c` is a relic of a previous development cycle, but I should be clear here that defaulting to using dev relations is *usually the right course of action* — generally, a dbt PR spans a few models, and you want to coordinate your changes across those models together. This behavior can just get a bit confusing if you’re encountering it for the first time!

**When should I *not* defer to prod**

While defer is a faster and cheaper option for most folks in most situations, defer to prod does not support all projects. The most common reason you should not use defer is regulatory — defer to prod makes the assumption that data is shared between your production and development environments, so reading between these environments is not an issue. For some organizations, like healthcare companies, have restrictions around the data access and sharing that precludes the basic defer structure presented here.

### Call me Willem Defer[​](#call-me-willem-defer "Direct link to Call me Willem Defer")

[![Willem Dafoe after using the `-—defer` flag](https://docs.getdbt.com/img/blog/2024-01-09-defer-in-development/willem.png?v=2 "Willem Dafoe after using the `-—defer` flag")](#)Willem Dafoe after using the `-—defer` flag

Defer to prod is a powerful way to improve your development velocity with dbt, and dbt Cloud makes it easier than ever to make use of this feature! You too could look this cool while you’re saving time and money developing on your dbt projects!

#### Comments

![Loading](https://docs.getdbt.com/img/loader-icon.svg)

[Newer post

Deprecation of dbt Server](https://docs.getdbt.com/blog/deprecation-of-dbt-server)[Older post

How to integrate with dbt](https://docs.getdbt.com/blog/integrating-with-dbtcloud)
