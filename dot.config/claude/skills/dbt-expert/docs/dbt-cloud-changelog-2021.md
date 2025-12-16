---
title: "Changelog 2021 | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-versions/release-notes/dbt-cloud-changelog-2021"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt release notes](https://docs.getdbt.com/docs/dbt-versions/dbt-cloud-release-notes)* Changelog (2021)

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Frelease-notes%2Fdbt-cloud-changelog-2021+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Frelease-notes%2Fdbt-cloud-changelog-2021+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Frelease-notes%2Fdbt-cloud-changelog-2021+so+I+can+ask+questions+about+it.)

On this page

note

This changelog references dbt versions that are no longer supported and have been removed from the docs. For more information about upgrading to a supported version of dbt in your dbt environment, read [Upgrade dbt version in Cloud](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud).

Welcome to the 2021 changelog for the dbt application! You can use this changelog to see highlights of what was new, fixed, and enhanced.

## dbt Cloud v1.1.41 (December 8, 2021)[​](#dbt-cloud-v1141-december-8-2021 "Direct link to dbt Cloud v1.1.41 (December 8, 2021)")

It's one of the best weeks of the year - it's [Coalesce](https://coalesce.getdbt.com/)! We'll have some exciting product announcements to share! Did somebody say [metrics](https://coalesce.getdbt.com/talks/keynote-metric-system/) and [dbt Core v1.0](https://coalesce.getdbt.com/talks/dbt-v10-reveal/)?!

#### New products and features[​](#new-products-and-features "Direct link to New products and features")

* dbt v1.0 is now available in dbt... nbd.

#### Performance improvements and enhancements[​](#performance-improvements-and-enhancements "Direct link to Performance improvements and enhancements")

* Now whenever you log back into dbt, you'll return to the account and project that you most recently were working in!

## dbt Cloud v1.1.39 (November 10, 2021)[​](#dbt-cloud-v1139-november-10-2021 "Direct link to dbt Cloud v1.1.39 (November 10, 2021)")

We shipped environment variables in dbt. Environment variables create a way to separate code from configuration - allowing you to set config based on context and keep secrets like git tokens securely stored.

#### New products and features[​](#new-products-and-features-1 "Direct link to New products and features")

* You can now add environment variables to your dbt project. Why does this matter? Environment variables are a fundamental building block of a dbt project, which until now, we only enabled in dbt Core. They power many use cases such as cloning private packages, limiting the amount of data that is processed in development environments, changing your data sources depending on the environment, and more. Read about environment variables in our [blog post](https://blog.getdbt.com/introducing-environment-variables-in-dbt-cloud/) or [docs](https://docs.getdbt.com/docs/build/environment-variables).

## dbt Cloud v1.1.38 (October 27, 2021)[​](#dbt-cloud-v1138-october-27-2021 "Direct link to dbt Cloud v1.1.38 (October 27, 2021)")

Have you used the [Metadata API](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api) yet? The Metadata API is available to customers on the Team and Enterprise plans, and with it, you can learn tons about your dbt project, if it's running dbt v0.19.0 or later. You can now query information about *any* run, not just the last run of a job. Mo' data, mo' fun!

## dbt Cloud v1.1.37 (October 13, 2021)[​](#dbt-cloud-v1137-october-13-2021 "Direct link to dbt Cloud v1.1.37 (October 13, 2021)")

dbt v0.21 is now available in dbt Cloud. The big change with this release is it introduces the `dbt build` command. `dbt build` logically does everything you'd want to do in your DAG. It runs your models, tests your tests, snapshots your snapshots, and seeds your seeds. It does this, resource by resource, from left to right across your DAG. dbt build is an opinionated task. It’s the culmination of all we’ve built- running models with resilient materializations, prioritizing data quality with tests, updating fixtures with seeds, capturing slowly changing dimensions with snapshot. Give it a try!

#### New products and features[​](#new-products-and-features-2 "Direct link to New products and features")

* We have a new beta feature, which we're calling Model Bottlenecks. It allows you to visually see how long it takes to build models in each run, so you can see clearly which models are taking the longest. If you're interested in learning more, check out #beta-feedback-model-bottlenecks in the dbt community Slack, and we can add you to the beta.

## dbt Cloud v1.1.36 (September 29, 2021)[​](#dbt-cloud-v1136-september-29-2021 "Direct link to dbt Cloud v1.1.36 (September 29, 2021)")

Check out the release candidate for `dbt v0.21.0`! Also tab switching in the dbt Cloud IDE now keeps track of your scroll position - at last!

#### Bug fixes[​](#bug-fixes "Direct link to Bug fixes")

* Some Redshift customers were experiencing timeouts on runs. We've since fixed this bug by keeping the session alive longer.

#### Performance improvements and enhancements[​](#performance-improvements-and-enhancements-1 "Direct link to Performance improvements and enhancements")

* You won't lose track of the code snippets you were looking at when you switch back and forth between tabs in the dbt Cloud IDE, as we now keep track of your scroll position.

## dbt Cloud v1.1.35 (September 15, 2021)[​](#dbt-cloud-v1135-september-15-2021 "Direct link to dbt Cloud v1.1.35 (September 15, 2021)")

Have you ever been working in the Studio IDE, taken a several hour break from developing, and when you returned to your work, the Studio IDE started behaving in unexpected ways? Your develop session became inactive, without any notification. Well, that silent failure won’t happen anymore! dbt now will let you know when you have to refresh your Studio IDE so you can continue to pick up work where you last left off.

#### New products and features[​](#new-products-and-features-3 "Direct link to New products and features")

* dbt v0.20.2 is released in dbt.

#### Performance improvements and enhancements[​](#performance-improvements-and-enhancements-2 "Direct link to Performance improvements and enhancements")

* Set default threads to 4 for new jobs and in development creds.

#### Bug fixes[​](#bug-fixes-1 "Direct link to Bug fixes")

* The user is now prompted to refresh the page when in a disconnected Studio IDE state.
* dbt tasks that fail or error are now correctly ordered in the run drawer history.

## dbt Cloud v1.1.34 (September 1, 2021)[​](#dbt-cloud-v1134-september-1-2021 "Direct link to dbt Cloud v1.1.34 (September 1, 2021)")

We just launched our beta for supporting environment variables in dbt. Environment variables are exciting because they allow you to clone private packages. If you’re interested in joining the beta, check out the #beta-feedback-for-env-vars channel in dbt Slack for more information.

#### Performance improvements and enhancements[​](#performance-improvements-and-enhancements-3 "Direct link to Performance improvements and enhancements")

Our Studio IDE SQL drawer got a fresh new look, and it now has improved accessibility.

## dbt Cloud v1.1.33 (August 18, 2021)[​](#dbt-cloud-v1133-august-18-2021 "Direct link to dbt Cloud v1.1.33 (August 18, 2021)")

We added a DAG in the Studio IDE, so that you can see your model dependencies as you develop! If you haven’t seen the DAG visualization yet, take a moment to spin up the Studio IDE, navigate to the Lineage tab, and click-click-click around in there — it is legitimately a brand new modality for developing dbt projects, and it’s something worth being excited about!

#### New products and features[​](#new-products-and-features-4 "Direct link to New products and features")

* [Dashboard Status Tiles](https://docs.getdbt.com/docs/explore/data-tile) can now be embedded on dashboards (or anywhere you can embed an iFrame) to give immediate insight into data freshness and quality. This helps dbt project maintainers build trust internally about the data that end users are seeing.
* We shipped DAG in the Studio IDE to GA!
* Support for `dbt v0.20.1` in Cloud.

#### Bug fixes[​](#bug-fixes-2 "Direct link to Bug fixes")

* Databricks users will now be able to see and update the token/schema for deployment environments.
* Some Github users were experiencing a broken profile image in dbt. This should be fixed if users disconnect and reconnect their Github accounts.

## dbt Cloud v1.1.32 (August 4, 2021)[​](#dbt-cloud-v1132-august-4-2021 "Direct link to dbt Cloud v1.1.32 (August 4, 2021)")

The Metadata API is now in GA! When dbt invokes certain commands like run, test, seed, etc, dbt generates metadata in the form of [artifacts](https://docs.getdbt.com/reference/artifacts/dbt-artifacts). These artifacts give you tons of information about project set up, run times, test details, compiled SQL, and so much more. Now dbt serves a GraphQL API which supports arbitrary queries over these artifacts, so you can retrieve the metadata you want almost instantaneously.

#### New products and features[​](#new-products-and-features-5 "Direct link to New products and features")

* The Metadata API is the start of our metadata product suite. Learn more about how to use the Metadata API [here](https://docs.getdbt.com/docs/dbt-cloud-apis/discovery-api).
* dbt Enterprise customers using GitHub now get better fine-grained access control in their dbt projects. dbt will enforce git permissions for every developer to ensure that read / write policies in GitHub carry through to the IDE.

## dbt Cloud v1.1.31 (July 21, 2021)[​](#dbt-cloud-v1131-july-21-2021 "Direct link to dbt Cloud v1.1.31 (July 21, 2021)")

We’ve improved the tabbing experience in the Studio IDE. Tabs now work much more intuitively, and you don’t have to worry about losing your work anymore!

#### New products and features[​](#new-products-and-features-6 "Direct link to New products and features")

* We are working to release a DAG directly in the IDE, so that when you’re developing, you have a clear idea of where the model you’re working on sits in the dependency graph. If you’re interested in testing out the feature early, head over to the `#beta-feedback-for-ide-dag` channel in the dbt Slack, and we’ll get the new product feature-flagged on your account!
* Added dbt 0.20.0 to Cloud

#### Bug fixes[​](#bug-fixes-3 "Direct link to Bug fixes")

* Users will now be able to initialize any project that doesn't contain a `dbt_project.yml` file, regardless of whether or not there are pre-existing files and/or commits to that repo.

#### Performance improvements and enhancements[​](#performance-improvements-and-enhancements-4 "Direct link to Performance improvements and enhancements")

* We've been working on some nice improvements to tabs in our Studio IDE. We’ve fixed deficiencies with tabs that caused users to lose work if they didn’t hit save regularly enough. Additionally, opening, closing, and the order of the tabs work much more smoothly.
* You may have noticed that there is now a source freshness checkbox in your execution settings when you configure a job on dbt Cloud. Selecting this checkbox will run `dbt source freshness` as the first step in your job, but it will not break subsequent steps if it fails. Updated source freshness documentation available [here](https://docs.getdbt.com/docs/deploy/source-freshness).
* Added a new endpoint to allow API key rotation via `POST https://cloud.getdbt.com/api/v2/users/{user-id}/apikey`

## dbt Cloud v1.1.30 (July 7, 2021)[​](#dbt-cloud-v1130-july-7-2021 "Direct link to dbt Cloud v1.1.30 (July 7, 2021)")

We shipped a resizable folder pane in the Studio IDE, and we're hearing great things! "My quality of life has greatly increased with this little update!" Hope this helps everyone else enjoy the Studio IDE a little more too.

#### New products and features[​](#new-products-and-features-7 "Direct link to New products and features")

* Resizable folder pane in the Studio IDE: Have you ever developed in the Studio IDE and not been able to see the full name of your model because you couldn’t adjust the width of the file pane? Yeah, us too. Now you’ll be able to adjust your project’s file tree width to be as wide or as narrow as you’d like. It’s these small things that make developing in the Studio IDE so much easier.

#### Bug fixes[​](#bug-fixes-4 "Direct link to Bug fixes")

* Made some changes to GitLab webhooks so that the status of the dbt run gets properly updated in GitLab.
* Resolved an issue where users saw a blank screen rather than the SSO reauthentication page.

#### Performance improvements and enhancements[​](#performance-improvements-and-enhancements-5 "Direct link to Performance improvements and enhancements")

* Refreshed the design of the repository import page.

## dbt Cloud v1.1.29 (June 23, 2021)[​](#dbt-cloud-v1129-june-23-2021 "Direct link to dbt Cloud v1.1.29 (June 23, 2021)")

We're heads down working on a handful of new features that we're going to share at the end of this month. The finish line is in sight. In the meantime, check out our latest release candidates for dbt Core. The biggest changes are better tests, providing consistency, configurability, and persistence. Additionally, we've refactored partial parsing and introduced an experimental parser; both are set to off by default.

#### New products and features[​](#new-products-and-features-8 "Direct link to New products and features")

* Add support for latest Core release candidates to dbt: v0.19.2-rc2 and v0.20.0-rc1

#### Bug fixes[​](#bug-fixes-5 "Direct link to Bug fixes")

* Add a safeguard for the SSO reauth page to avoid 401 interceptors

#### Performance improvements and enhancements[​](#performance-improvements-and-enhancements-6 "Direct link to Performance improvements and enhancements")

* Ensure navigation bar is in dark mode when Studio IDE is set to dark mode

## dbt Cloud v1.1.28 (June 9, 2021)[​](#dbt-cloud-v1128-june-9-2021 "Direct link to dbt Cloud v1.1.28 (June 9, 2021)")

We shipped a far better experience for GitLab users. Be sure to check out new CI features that are now available for customers using GitLab. Additionally, all developers should test out Slim CI which will speed up their model builds.

#### New products and features[​](#new-products-and-features-9 "Direct link to New products and features")

* `Slim CI`: We’ve made Slim CI available for all our cloud customers! With Slim CI, you don't have to rebuild and test all your models; you can instruct dbt Cloud to run jobs on only modified or new resources. If you are a GitHub or GitLab user, try creating a new job that runs on pull requests and you can signal to dbt to run only on these modified resources by including the `state:modified+` argument. Read more about Slim CI [here](https://docs.getdbt.com/docs/deploy/continuous-integration).
* Native GitLab authentication for dbt Developer and Team Tiers: We’ve shipped native GitLab auth into GA. You can now import new GitLab repos with a couple clicks, trigger CI builds when Merge Requests are opened in GitLab, and carry GitLab permissions through to Studio IDE's git actions. Read how to set up native GitLab auth [here](https://docs.getdbt.com/docs/cloud/git/connect-gitlab).

#### Bug fixes[​](#bug-fixes-6 "Direct link to Bug fixes")

* Allow users to select artifacts from a job that runs source freshness on jobs with the source freshness execution settings set to `ON`.
* Resolve `RUN ONLY ON CUSTOM BRANCH?` button to toggle on and off properly.
* Retain information in a `Statement` tab when the page is refreshed.
* Unsaved changes in the Studio IDE are now saved when committing work.
* Drop temporary schemas in the data warehouse for closed or merged GitLab merge requests.

#### Performance improvements and enhancements[​](#performance-improvements-and-enhancements-7 "Direct link to Performance improvements and enhancements")

* Behind the scenes, we’ve been moving off of Angular and onto React. We’ve started the process of migrating the central pieces of our UI over - the first of which is the main navigation. We think this will have a big impact on our ability to reduce UI bugs and improve user experience.
* Added support for dbt 0.19.2rc2 + 0.20.0rc1 in dbt.

## dbt Cloud v1.1.27 (May 26, 2021)[​](#dbt-cloud-v1127-may-26-2021 "Direct link to dbt Cloud v1.1.27 (May 26, 2021)")

A lot of improvements coming for GitLab webhooks and native auth. We also fixed a number of bugs in the Studio IDE. Our goal is for you to never see an infinite spinner again!

#### Enhancements[​](#enhancements "Direct link to Enhancements")

* Add dbt v0.19.2rc1 and v0.20.0b1
* Add an open/closable overlay for the DAG
* Disable department dropdown
* Add DAG flags, button, and tab context
* Add run source freshness option to jobs
* Implement conditional redirecting after GitLab app integration
* Add Develop Pod Support for Rook and Ceph file storage
* Show all common actions for valid top level commands

#### Fixed[​](#fixed "Direct link to Fixed")

* Fix link to documentation
* Disable the "Restart Studio IDE" Button while the Studio IDE is loading
* Continue canceling runs when we run into deleted accounts
* Fix SSO re-auth page
* Fix blank verify email page
* Resolve git refresh regression
* Fix missing "Run on Merge" button in Job creation/edit form-
* Warn users they have unsaved changes
* Updates test command suggestions and regex for common action suggestions
* Updates order of stylesheet import to fix missing border bug
* Fix GitLab PR link for Run Page
* Fix infinite spinner for missing environment or development credentials
* Fix infinite spinner when user is missing dev credentials
* Do not try to push if awaiting a merge
* Fix deleting schemas
* Fix favicon reference

## dbt Cloud v1.1.26 (May 12, 2021)[​](#dbt-cloud-v1126-may-12-2021 "Direct link to dbt Cloud v1.1.26 (May 12, 2021)")

If you haven't seen it yet, spin up the Studio IDE: the command bar now has recent actions (you can up-arrow like on the command line) as well as some hardcoded suggestions that will auto-populate your active model, if there is one. Check it out! Other fixes and adjustments as well, as we all get ready for Staging this Thursday - exciting week for the Product org over at ol' Fishtown!

#### Enhancements[​](#enhancements-1 "Direct link to Enhancements")

* Made dbt default version on env 0.19.1
* Rolled out new command line experience to all customers
* Post webhook triggered run status back to gitlab
* Temporary tabs can also populate the model from manifest
* Check command line content is minimally valid
* Allow user to restart server when develop pod crashes
* Prevent overflow of menu items

#### Fixed[​](#fixed-1 "Direct link to Fixed")

* Handle validation error for improper remote URLs in the Scheduler
* Refactor exception logging out of GitRepo and into exception handlers
* Required tags returning null from core no longer causing infinite spinner
* Removed deleted repos while fetching repository for sending commit statuses
* Refactor git provider service
* Resolve files with special characters becoming forever dirty
* Disable input when RPC command running & add button when command bar is empty
* Updating button for the Cancel/Enter button on commandline
* Fix connection setup to always use the project referenced in the route
* Fix "View data sources" URL in environment page
* Add support for clicking on previously run commands and updating the text inside of the commandline
* Fix sources URL in environments page
* Fix metadata token not allowed API response

## dbt Cloud v1.1.25 (April 28, 2021)[​](#dbt-cloud-v1125-april-28-2021 "Direct link to dbt Cloud v1.1.25 (April 28, 2021)")

Exciting things coming down the pipe - ongoing enhancements to the command bar experience in the Studio IDE, doing some work to ensure that more git providers are presented with a first class experience in Cloud, as well as assorted bug fixes - "I must have bug fixes, always and always" - that was Monet I think

#### Enhancements[​](#enhancements-2 "Direct link to Enhancements")

* Made a grip of visual updates to the new command bar work
* Moved to using the active model name instead of a placeholder in command bar work
* Added user ability to delete connections, remove association from a given project.
* Added verification of dbt version for command bar beta feature flag

#### Fixed[​](#fixed-2 "Direct link to Fixed")

* Removed testing prop that keeps drawer open
* Added double encoding to handle Snowflake roles with spaces
* Fixed account switching in user notifications
* Handled invalid Azure SSO group responses
* Fixed error which only showed common actions when run drawer was closed
* Allowed unencrypted adapter fields to be edited
* Fixed bugs with file and folder renaming, alongside associated tab state

## dbt Cloud v1.1.24 (April 14, 2021)[​](#dbt-cloud-v1124-april-14-2021 "Direct link to dbt Cloud v1.1.24 (April 14, 2021)")

Phew! As our company grows, so too does our changelog! Look at all these! The big chunks you'll see here are related to some ongoing in-Studio IDE work, focused on the command bar experience, as well as some partner & connection work (see the Gits, Databricks, and so forth), and of course ongoing longer-term bets around metadata!

#### Enhancements[​](#enhancements-3 "Direct link to Enhancements")

* Added onFocus and onBlur properties to populate and remove "dbt" in command bar
* Enabled executing command on enter if user's cursor is in the command bar
* Added Metadata API access button to account settings
* Added feature flag for displaying only recent actions
* Added dbt 0.19.1
* Added regex validation to Databrick's hostname web-form field
* Updated Connection Edit to allow adapter editing
* Enabled self-service Github and GitLab integration disconnection
* Added link to docs for license map & handle duplicate error gracefully
* Moved deferred job execution to execution settings.
* Recorded user command history
* Enabled new file creation flow

#### Fixed[​](#fixed-3 "Direct link to Fixed")

* Added styling class to popup to ensure text is readable
* Fixed sourcemaps syntax for dev commands
* Added timeout and retry to dbt deps
* Updated databricks schema field type and add error handling to ConnectionSetup
* Fixed Bigquery private keys & convert text to textarea
* Fixed last used datetime in the service token UI
* Added missing token URI to Bigquery connection edit
* Prevent multiple develop sessions for one user
* Fixed SchemaForm validating non-displayed fields
* Fixed required fields for Bigquery connection JSON uploads
* Fixed self selection as deferred job
* Always create a Monaco model on tab open if no matching model exists
* Fixed tab dirty indicator on open tab
* Fixed password reset flow
* Fixed docs and sources links in dashboard page for read only users
* Fixed truncating first\_name to 30 characters

## dbt Cloud v1.1.23 (March 31, 2021)[​](#dbt-cloud-v1123-march-31-2021 "Direct link to dbt Cloud v1.1.23 (March 31, 2021)")

Some backend work, some frontend work, some bug fixes: a nice mix for this release. A few user facing changes you may have noticed already are the persistence of dark/light mode settings across refresh (no more blinding Studio IDE!), branches in the Studio IDE being categorized by Active vs. Removed from Remote, and a tidier new file creation flow, with the file tree expanding to show the new file and opening a new tab to populate the said file!

#### Enhancements[​](#enhancements-4 "Direct link to Enhancements")

* Splitting Local-only and Remote branches into different sections of the dropdown selector
* Update Profile Integrations to include SSO info
* Upgrade to Tailwind 2.0 and FUI 0.0.5
* Allow users to create metadata tokens from the UI
* Support manually-managed group memberships
* SSO: resolve bug w/ first & last names acting up
* Integrate Delighted for NPS surveys
* Add dbt 0.19.1rc1 to Cloud
* Add an account-level setting to require users to re-authenticate via SSO
* Read-only metadata ServiceToken for Cloud
* Persist Studio IDE light mode / dark mode across refresh
* Categorize & order git branches
* Improve new file creation flow

#### Fixed[​](#fixed-4 "Direct link to Fixed")

* Check for an empty repository before checking matching remote
* Increase wait if run was finished recently
* Support default branches through git when a custom branch is not specified
* Don't download logs for skipped steps
* API Gateway is no longer flooded with errors due to Studio IDE blindly polling dead Develop pod
* Fix user license creation via admin interface
* Adjusted addition of global .gitignore

## dbt Cloud v1.1.22 (March 17, 2021)[​](#dbt-cloud-v1122-march-17-2021 "Direct link to dbt Cloud v1.1.22 (March 17, 2021)")

Rolling out a few long-term bets to ensure that our beloved dbt does not fall over for want of memory, as well as a grip of bug fixes and error messaging improvements (error messages should be helpful, not scolding or baffling, after all!)

#### Enhancements[​](#enhancements-5 "Direct link to Enhancements")

* Release Scribe to 100% of multi-tenant accounts
* Update language for SQL drawer empty state
* Reduce Scribe memory usage

#### Fixed[​](#fixed-5 "Direct link to Fixed")

* Fix NoSuchKey error
* Guarantee unique notification settings per account, user, and type
* Fix for account notification settings
* Don't show deleted projects on notifications page
* Fix unicode error while decoding last\_chunk
* Show more relevant errors to customers
* Groups are now editable by non-sudo requests
* Normalize domain names across inputs/outputs
* Redirect auth failed errors back to appropriate page with error description

## dbt Cloud v1.1.21 (March 3, 2021)[​](#dbt-cloud-v1121-march-3-2021 "Direct link to dbt Cloud v1.1.21 (March 3, 2021)")

This changelog wraps up work on what we've been calling the SQL Drawer in the Studio IDE - some design nudges, some interface adjustments, overall a cleaner and snappier experience. If you haven't dipped into the Studio IDE in a while it's worth taking a look! Some back-end work as well, making SSO and role based admin easier and more broadly available for Enterprise level folks, along with your usual assortment of bug squashes and iterations.

#### Enhancements[​](#enhancements-6 "Direct link to Enhancements")

* Styling and copy adjustments in the Cloud Studio IDE
* Open self-service role based access control to all Enterprise customers
* Update AuthProvider UI to enable SAML and Okta
* Add a SAML auth redirect URL

#### Fixed[​](#fixed-6 "Direct link to Fixed")

* Add param to admin project mapper to included soft deleted projects
* Fix delaying logs when we are waiting for a model to finish executing
* Saving GSuite auth provider form triggers an authorize
* Scribe populates truncated debug logs when runs are executing
* Delay attempts for non-200 status codes
* Add logic to support select fields in adapter UI
* Undo clobbering groups

## dbt Cloud v1.1.20 (February 17, 2021)[​](#dbt-cloud-v1120-february-17-2021 "Direct link to dbt Cloud v1.1.20 (February 17, 2021)")

Continued stability and quality of life improvements for folks with multiple accounts and projects - no longer will you have to remember the chronological order of birth of your accounts and projects, as they'll be ordered by the much easier to parse (for human brains anyway) alphabetical order. We're also shipping some experience improvements in the SQL Drawer at the bottom half of the Studio IDE.

#### Enhancements[​](#enhancements-7 "Direct link to Enhancements")

* Deleted Info and Logs Studio IDE Tabs, logs will now be displayed in Results Tab
* Removed service token feature flag
* List Jobs dropdown in alphabetical order
* List Account and Project dropdowns in alphabetica order
* Pre-join Job Definition results to speed up scheduler
* Combine scheduler queries to speedup runtime by about 30%

#### Fixed[​](#fixed-7 "Direct link to Fixed")

* Fix issue with source freshness for 0.19.0

## dbt Cloud v1.1.19 (February 3, 2021)[​](#dbt-cloud-v1119-february-3-2021 "Direct link to dbt Cloud v1.1.19 (February 3, 2021)")

The latest release of dbt (Oh Nineteen Oh) is now available for your enjoyment on dbt! We're also releasing some service token pieces here, though they're not quite ready for wide release yet. Moving forward, Oh Nineteen Oh will probably end up being the minimum version required to run the Metadata API & Metadata Toolkit, so, this is a big release!

#### Enhancements[​](#enhancements-8 "Direct link to Enhancements")

* Added dbt 0.19.0 😻
* Allowed account-wide service tokens to create connections
* Added integration for service token UI and API
* Authorized requests that supply a service token

#### Fixed[​](#fixed-8 "Direct link to Fixed")

* Added logic to show the entered service token name prior to the request completing
* Fixed endlessly running rpc queries with non-working cancel button on Studio IDE refresh

## dbt Cloud v1.1.18 (January 20, 2021)[​](#dbt-cloud-v1118-january-20-2021 "Direct link to dbt Cloud v1.1.18 (January 20, 2021)")

Most notable things here are around foundational work toward future feature releases, as well as strong assurances of future stability for dbt, and ensuring future sales tax compliance (which we understand turns out to be quite important!) - turns out to be a quite future-looking release!

#### Enhancements[​](#enhancements-9 "Direct link to Enhancements")

* Add service tokens UI (stubbed) behind a feature flag
* Fixing and Upgrading social-auth
* Add dbt Spark 0.19.0rc1
* Adds the reconciliation of persisted file content and tab state when navigating into the Studio IDE
* Adds the reconciliation of persisted file content and tab state between Studio IDE sessions
* Read logs from scribe and stop logging to db
* Upgrade social auth 3.3.3
* Add warning logs for social auth failures
* Add dbt 0.19.0rc1

#### Fixed[​](#fixed-9 "Direct link to Fixed")

* Prevent social-auth from updating first or last name
* Page through Stripe results when listing subscriptions
* Prevent enqueueing runs in deleted projects
* Fix Studio IDE git actions causing open tab contents to be lost on Studio IDE re-entry
* Add DBT\_CLOUD\_CONTEXT environment variable
* Add logic to hide IP whitelist message for on-prem customers
* fix 0.19.0rc1 run image dependencies

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

2022 dbt Cloud release notes](https://docs.getdbt.com/docs/dbt-versions/2022-release-notes)[Next

Changelog (2019 and 2020)](https://docs.getdbt.com/docs/dbt-versions/release-notes/dbt-cloud-changelog-2019-2020)

* [dbt Cloud v1.1.41 (December 8, 2021)](#dbt-cloud-v1141-december-8-2021)* [dbt Cloud v1.1.39 (November 10, 2021)](#dbt-cloud-v1139-november-10-2021)* [dbt Cloud v1.1.38 (October 27, 2021)](#dbt-cloud-v1138-october-27-2021)* [dbt Cloud v1.1.37 (October 13, 2021)](#dbt-cloud-v1137-october-13-2021)* [dbt Cloud v1.1.36 (September 29, 2021)](#dbt-cloud-v1136-september-29-2021)* [dbt Cloud v1.1.35 (September 15, 2021)](#dbt-cloud-v1135-september-15-2021)* [dbt Cloud v1.1.34 (September 1, 2021)](#dbt-cloud-v1134-september-1-2021)* [dbt Cloud v1.1.33 (August 18, 2021)](#dbt-cloud-v1133-august-18-2021)* [dbt Cloud v1.1.32 (August 4, 2021)](#dbt-cloud-v1132-august-4-2021)* [dbt Cloud v1.1.31 (July 21, 2021)](#dbt-cloud-v1131-july-21-2021)* [dbt Cloud v1.1.30 (July 7, 2021)](#dbt-cloud-v1130-july-7-2021)* [dbt Cloud v1.1.29 (June 23, 2021)](#dbt-cloud-v1129-june-23-2021)* [dbt Cloud v1.1.28 (June 9, 2021)](#dbt-cloud-v1128-june-9-2021)* [dbt Cloud v1.1.27 (May 26, 2021)](#dbt-cloud-v1127-may-26-2021)* [dbt Cloud v1.1.26 (May 12, 2021)](#dbt-cloud-v1126-may-12-2021)* [dbt Cloud v1.1.25 (April 28, 2021)](#dbt-cloud-v1125-april-28-2021)* [dbt Cloud v1.1.24 (April 14, 2021)](#dbt-cloud-v1124-april-14-2021)* [dbt Cloud v1.1.23 (March 31, 2021)](#dbt-cloud-v1123-march-31-2021)* [dbt Cloud v1.1.22 (March 17, 2021)](#dbt-cloud-v1122-march-17-2021)* [dbt Cloud v1.1.21 (March 3, 2021)](#dbt-cloud-v1121-march-3-2021)* [dbt Cloud v1.1.20 (February 17, 2021)](#dbt-cloud-v1120-february-17-2021)* [dbt Cloud v1.1.19 (February 3, 2021)](#dbt-cloud-v1119-february-3-2021)* [dbt Cloud v1.1.18 (January 20, 2021)](#dbt-cloud-v1118-january-20-2021)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-versions/release-notes/98-dbt-cloud-changelog-2021.md)
