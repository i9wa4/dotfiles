---
title: "How we style our dbt projects | dbt Developer Hub"
source_url: "https://docs.getdbt.com/best-practices/how-we-style/0-how-we-style-our-dbt-projects"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Best practices](https://docs.getdbt.com/best-practices)* How we style our dbt projects

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F0-how-we-style-our-dbt-projects+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F0-how-we-style-our-dbt-projects+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fbest-practices%2Fhow-we-style%2F0-how-we-style-our-dbt-projects+so+I+can+ask+questions+about+it.)

On this page

## Why does style matter?[​](#why-does-style-matter "Direct link to Why does style matter?")

Style might seem like a trivial, surface-level issue, but it's a deeply material aspect of a well-built project. A consistent, clear style enhances readability and makes your project easier to understand and maintain. Highly readable code helps build clear mental models making it easier to debug and extend your project. It's not just a favor to yourself, though; equally importantly, it makes it less effort for others to understand and contribute to your project, which is essential for peer collaboration, open-source work, and onboarding new team members. [A style guide lets you focus on what matters](https://mtlynch.io/human-code-reviews-1/#settle-style-arguments-with-a-style-guide), the logic and impact of your project, rather than the superficialities of how it's written. This brings harmony and pace to your team's work, and makes reviews more enjoyable and valuable.

## What's important about style?[​](#whats-important-about-style "Direct link to What's important about style?")

There are two crucial tenets of code style:

* Clarity
* Consistency

Style your code in such a way that you can quickly read and understand it. It's also important to consider code review and git diffs. If you're making a change to a model, you want reviewers to see just the material changes you're making clearly.

Once you've established a clear style, stay consistent. This is the most important thing. Everybody on your team needs to have a unified style, which is why having a style guide is so crucial. If you're writing a model, you should be able to look at other models in the project that your teammates have written and read in the same style. If you're writing a macro or a test, you should see the same style as your models. Consistency is key.

## How should I style?[​](#how-should-i-style "Direct link to How should I style?")

You should style the project in a way you and your teammates or collaborators agree on. The most important thing is that you have a style guide and stick to it. This guide is just a suggestion to get you started and to give you a sense of what a style guide might look like. It covers various areas you may want to consider, with suggested rules. It emphasizes lots of whitespace, clarity, clear naming, and comments.

We believe one of the strengths of SQL is that it reads like English, so we lean into that declarative nature throughout our projects. Even within dbt Labs, though, there are differing opinions on how to style, even a small but passionate contingent of leading comma enthusiasts! Again, the important thing is not to follow this style guide; it's to make *your* style guide and follow it. Lastly, be sure to include rules, tools, *and* examples in your style guide to make it as easy as possible for your team to follow.

## Automation[​](#automation "Direct link to Automation")

Use formatters and linters as much as possible. We're all human, we make mistakes. Not only that, but we all have different preferences and opinions while writing code. Automation is a great way to ensure that your project is styled consistently and correctly and that people can write in a way that's quick and comfortable for them, while still getting perfectly consistent output.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

The rest of the project](https://docs.getdbt.com/best-practices/how-we-structure/5-the-rest-of-the-project)[Next

How we style our dbt models](https://docs.getdbt.com/best-practices/how-we-style/1-how-we-style-our-dbt-models)

* [Why does style matter?](#why-does-style-matter)* [What's important about style?](#whats-important-about-style)* [How should I style?](#how-should-i-style)* [Automation](#automation)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/best-practices/how-we-style/0-how-we-style-our-dbt-projects.md)
