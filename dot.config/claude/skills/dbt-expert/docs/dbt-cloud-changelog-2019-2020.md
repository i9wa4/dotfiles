---
title: "Changelog 2019 and 2020 | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/dbt-versions/release-notes/dbt-cloud-changelog-2019-2020"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [dbt release notes](https://docs.getdbt.com/docs/dbt-versions/dbt-cloud-release-notes)* Changelog (2019 and 2020)

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Frelease-notes%2Fdbt-cloud-changelog-2019-2020+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Frelease-notes%2Fdbt-cloud-changelog-2019-2020+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fdbt-versions%2Frelease-notes%2Fdbt-cloud-changelog-2019-2020+so+I+can+ask+questions+about+it.)

On this page

note

This changelog references dbt versions that are no longer supported and have been removed from the docs. For more information about upgrading to a supported version of dbt in your dbt Cloud environment, read [Upgrade dbt version in Cloud](https://docs.getdbt.com/docs/dbt-versions/upgrade-dbt-version-in-cloud).

Welcome to the 2019 and 2020 changelog for the dbt application! You can use this changelog to see the highlights of what was new, fixed, and enhanced during this time period.

## dbt Cloud v1.1.16 (December 23, 2020)[​](#dbt-cloud-v1116-december-23-2020 "Direct link to dbt Cloud v1.1.16 (December 23, 2020)")

This release adds preview support for Databricks Spark in dbt
and adds two new permission sets for Enterprise acccounts.

#### Enhancements[​](#enhancements "Direct link to Enhancements")

* Added preview support for Databricks Spark support
* Added two new Enterprise permission sets: Account Viewer and Project Creator

#### Fixed[​](#fixed "Direct link to Fixed")

* Improve logging infrastructure for dbt run logs
* Fix for SSH tunnel logging errors

## dbt Cloud v1.1.15 (December 10, 2020)[​](#dbt-cloud-v1115-december-10-2020 "Direct link to dbt Cloud v1.1.15 (December 10, 2020)")

Lots of great stuff to confer about this go-round: things really coalesced this week! Lots of excitement around adding Spark to the connection family, as well as knocking out some longstanding bugs.

#### Enhancements[​](#enhancements-1 "Direct link to Enhancements")

* Add Spark as an option for database setup

#### Fixed[​](#fixed-1 "Direct link to Fixed")

* Fix this one hairy bug where one email could have multiple user accounts
* Fix setup-connection react-page routing
* Break out group selection logic from license types and group names
* Handle JSON errors in v1/v2 body parsing
* Handle AuthForbidden and AuthCancelled graciously - ie, not throw 500s
* Fix regression with Studio IDE loading spinner

## dbt Cloud v1.1.14 (November 25, 2020)[​](#dbt-cloud-v1114-november-25-2020 "Direct link to dbt Cloud v1.1.14 (November 25, 2020)")

This release adds a few new pieces of connective tissue, notably OAuth for BigQuery and SparkAdapter work. There are also some quality of life improvements and investments for the future, focused on our beloved Studio IDE users, and some improved piping for observability into log management and API usage.

#### Enhancements[​](#enhancements-2 "Direct link to Enhancements")

* Update IP allowlist
* User can OAuth for BigQuery in profile credentials
* Adding SparkAdapter backend models, mappers, and services
* Added BigQuery OAuth integration
* Adding db index for owner\_thread\_id

#### Fixed[​](#fixed-2 "Direct link to Fixed")

* Fix post /run error rate
* Fix bug where bad argument was passed to dbt runs
* Log out unhandled error in environment variable context manager
* Remove account settings permissions for user integrations

## dbt Cloud v1.1.13 (November 12, 2020)[​](#dbt-cloud-v1113-november-12-2020 "Direct link to dbt Cloud v1.1.13 (November 12, 2020)")

This release adds support for triggering runs with overriden attributes via the
[triggerRun](https://docs.getdbt.com/dbt-cloud/api-v2) API endpoint. Additionally,
a number of bugs have been squashed and performance improvements have been made.

#### Enhancements[​](#enhancements-3 "Direct link to Enhancements")

* Improve error handling for long-running queries in the Studio IDE
* Use S3 client caching to improve log download speed for scheduled runs
* Support triggering jobs [with overriden attributes from the API](https://docs.getdbt.com/dbt-cloud/api-v2)
* Clarify "upgrade" copy on the billing page

#### Fixed[​](#fixed-3 "Direct link to Fixed")

* GitLab groups endpoint now returns all groups and subgroups
* Support BigQuery retry configs with value 0
* Prevent web IDE from crashing after running an invalid dbt command
* Apply additional log scrubbing to filter short-lived git credentials
* Fix older migration to make auth\_url field nullable
* Support paths in GitLab instance URL
* Fix for auth token request url in GitLab oauth flow

## dbt Cloud v1.1.12 (October 30, 2020)[​](#dbt-cloud-v1112-october-30-2020 "Direct link to dbt Cloud v1.1.12 (October 30, 2020)")

This release adds dbt v.18.1 and 0.19.0b1 to dbt Cloud. Additionally, a number of bugs have been fixed.

#### Enhancements[​](#enhancements-4 "Direct link to Enhancements")

* Update copy on billing page for picking a plan at the end of a trial
* Improved authorization for metadata API
* Add dbt 0.19.0b1
* Add dbt 0.18.1

#### Fixed[​](#fixed-4 "Direct link to Fixed")

* Fixed an issue where groups from other logged-in accounts appeared in the RBAC UI
* Fixed requested GitLab scopes and an issue when encrypting deploy tokens for GitLab auth
* Fixed an issue where null characters in logs threw errors in scheduled runs

## dbt Cloud v1.1.11 (October 15, 2020)[​](#dbt-cloud-v1111-october-15-2020 "Direct link to dbt Cloud v1.1.11 (October 15, 2020)")

Release v1.1.11 includes some quality-of-life enhancements, copy tweaks, and error resolutions. It also marks the last time we'll have the same digit four times in a row in a release until v2.2.22.

#### Enhancements[​](#enhancements-5 "Direct link to Enhancements")

* Add InterfaceError exception handling for commands
* Rename My Account --> Profile
* Add project and connection to admin backend

#### Fixed[​](#fixed-5 "Direct link to Fixed")

* Resolve errors from presence of null-characters in logs
* Email verifications backend
* Undo run.serialize
* Fix error while serialized run
* Fix logic error in connection setup
* Fix a bug with GitLab auth flow for unauthenticated users
* Fix bug where Native Okta SSO uses the wrong port

## dbt Cloud v1.1.10 (October 8, 2020)[​](#dbt-cloud-v1110-october-8-2020 "Direct link to dbt Cloud v1.1.10 (October 8, 2020)")

This release adds support for repositories imported via GitLab (Enterprise)
and contains a number of bugfixes and improvements in the Studio IDE.

#### Enhancements[​](#enhancements-6 "Direct link to Enhancements")

* Add Gitlab integration (Enterprise)
* Add GitLab repository setup to project setup flow (Enterprise)
* Add GitLab automated Deploy Token installation (Enterprise)
* Add dbt 0.18.1rc1

#### Fixed[​](#fixed-6 "Direct link to Fixed")

* Fix bug where Studio IDE gets stuck after changing project repository
* Fix race condition where connections can be added to the wrong project
* Fix revoking email invites
* Fix a bug in slim CI deferring run search where missing previous run caused the scheduler to raise an error
* Fix a source of Studio IDE instability
* Gracefully clean up Studio IDE backend on shutdown
* Always show SSO mappings on Group Details page

## dbt Cloud v1.1.9 (October 1, 2020)[​](#dbt-cloud-v119-october-1-2020 "Direct link to dbt Cloud v1.1.9 (October 1, 2020)")

This release adds the ability for admins on the Enterprise plan to configure
the Role Based Access Control permissions applied to Projects in their account.
Additionally, job execution deferral is now available behind a feature flag,
and a number of fixes and improvements were released as well.

#### Enhancements[​](#enhancements-7 "Direct link to Enhancements")

* Add dbt version in the navigation sidebar
* Add RBAC Group Permission view, create, and modify UIs
* Add personal git auth for Studio IDE error handling modals
* Add Develop Requests to backend views
* Implemented job execution deferral
* Add support for dbt v0.18.1b2

#### Fixed[​](#fixed-7 "Direct link to Fixed")

* Fixed the scenario where interacting with the Refresh Studio IDE button causes an index.lock file to remain in the Studio IDE file system
* Validate PR URL for XSS attempts
* Address RBAC inconsistencies
* Fixed users not being able to update their dbt password in-app
* Fix for applying user permissions across multiple accounts after SSO auth
* Google API: default to common api endpoint but allow override
* Fix for missing email variable in GSuite debug logging
* Destroy Studio IDE session when switching projects

## dbt Cloud v1.1.8 (September 17, 2020)[​](#dbt-cloud-v118-september-17-2020 "Direct link to dbt Cloud v1.1.8 (September 17, 2020)")

This release adds native support for Okta SSO and dbt v0.18.0. It also adds
initial support for a GitLab integration and self-service RBAC configuration.

#### Enhancements[​](#enhancements-8 "Direct link to Enhancements")

* Add dbt 0.18.0
* Add native Okta SSO support
* Add additional logging for Gsuite and Azure SSO
* Add git cloning support via GitLab deploy tokens for scheduled runs (coming soon)
* add RBAC Groups Detail Page and Groups List UIs

#### Fixed[​](#fixed-8 "Direct link to Fixed")

* Allow `*_proxy` env vars in scheduled runs

## dbt Cloud v1.1.7 [September 3, 2020][​](#dbt-cloud-v117-september-3-2020 "Direct link to dbt Cloud v1.1.7 [September 3, 2020]")

This release adds a Release Candidate for [dbt
v0.18.0](https://docs.getdbt.com/docs/dbt-versions/core-upgrade) and
includes bugfixes and improvements to the Cloud IDE
and job scheduler.

#### Enhancements[​](#enhancements-9 "Direct link to Enhancements")

* Improve scheduler backoff behavior
* Add dbt 0.18.0rc1
* Add support for non-standard ssh ports in connection tunnels
* Add support for closing the Studio IDE filesystem context menu by clicking outside the menu

#### Fixed[​](#fixed-9 "Direct link to Fixed")

* Fix for joining threads in run triggers
* Fix thread caching for s3 uploads

## dbt Cloud v1.1.6 (August 20, 2020)[​](#dbt-cloud-v116-august-20-2020 "Direct link to dbt Cloud v1.1.6 (August 20, 2020)")

This release includes security enhancements and improvements across the entire
dbt application.

#### Enhancements[​](#enhancements-10 "Direct link to Enhancements")

* Support for viewing development docs inside of the Studio IDE ([docs](https://docs.getdbt.com/docs/cloud/studio-ide/develop-in-studio)
* Change CI temporary schema names to be prefixed with `dbt_cloud` instead of `sinter`
* Change coloring and iconography to improve accessibility and UX across the application
* [Enterprise] Support the specification of multiple authorized domains in SSO configuration
* [On-premises] Upgrade boto3 to support KIAM authentication

#### Fixed[​](#fixed-10 "Direct link to Fixed")

* [Enterprise] Fix for missing IdP group membership mappings when users belong to >100 Azure AD groups
* Disallow the creation of symlinks in the Studio IDE
* Improve reliability of background cleanup processes
* Improve performance and reliability of artifact management and PR webhook processing

## dbt Cloud v1.1.5 (August 4, 2020)[​](#dbt-cloud-v115-august-4-2020 "Direct link to dbt Cloud v1.1.5 (August 4, 2020)")

This release adds a major new feature to the Studio IDE: merge conflict resolution!

It also includes changes to the job scheduler that cut the time and resource utilization
significantly.

#### Enhancements[​](#enhancements-11 "Direct link to Enhancements")

* Add dbt 0.17.2
* Add dbt 0.18.0 beta 2
* Add merge conflict resolution, a merge commit workflow, and merge abort workflow to the IDE
* Deprecate dbt versions prior to 0.13.0
* Refactor to cut job scheduler loop time
* Reduce extra database calls to account table in job scheduler loop
* [On-premises] Allow clients to disable authentication for SMTP
* [On-premises] Allow disabling of TLS for SMTP
* [On-premises] Making k8s access mode for Studio IDE pods an environment variable
* [Security] Force session cookie to be secure
* Make api and admin modules flake8 complaint

#### Fixed[​](#fixed-11 "Direct link to Fixed")

* Fix incorrect usage of `region_name` in KMS client
* Fix a call to a deprecated Github API
* Remove extraneous billing API calls during job scheduler loop
* Fix error where refreshing the IDE would leave running dbt processes in a bad state

## dbt Cloud v1.1.4 (July 21, 2020)[​](#dbt-cloud-v114-july-21-2020 "Direct link to dbt Cloud v1.1.4 (July 21, 2020)")

This release dramatically speeds up the job scheduler. It adds a new
stable dbt version (0.17.1) and a new prerelease (0.17.2b1), and it
includes a number of bugfixes.

#### Enhancements[​](#enhancements-12 "Direct link to Enhancements")

* Add dbt 0.17.2b1
* Add dbt 0.17.1 and set as default version
* Speed up job scheduler by 50%
* Added generate docs to rpc service and new view docs route
* Queue limiting by account for scheduled jobs

#### Fixed[​](#fixed-12 "Direct link to Fixed")

* Fix enterprise SSO configuration when old Auth0 Azure AD is configured
* Do not schedule jobs for deleted job definitions or environments
* Fix permissions issues
* Fix a bug with metadata set in azure storage provider
* Fixed error when switching to developer plan from trial
* Fix authentication bug where we setup all accounts with same domain
* [Security] Add security check to prevent potentially malicious html files in dbt docs

## dbt Cloud v1.1.3 (July 7, 2020)[​](#dbt-cloud-v113-july-7-2020 "Direct link to dbt Cloud v1.1.3 (July 7, 2020)")

This release contains a number of IDE features and bugfixes, a new release candidate of dbt, and a brand new Enterprise Single-Sign On method: Azure Active Directory!

#### Enhancements[​](#enhancements-13 "Direct link to Enhancements")

* Add dbt 0.17.1rc3
* Snowflake: Add support for `client_session_keep_alive` config
* Enterprise: Native Azure Oauth2 for Enterprise accounts
* Studio IDE: Add custom command palette for finding files

#### Fixed[​](#fixed-13 "Direct link to Fixed")

* Do not run CI builds for draft PRs in GitHub
* Remove race condition when syncing account with stripe billing events
* Enterprise: Fixed JIT provisioning bug impacting accounts with shared IdP domains
* Studio IDE: Fix a regression with Github git clone method
* Studio IDE: Fix a race condition where git clone didn't complete before user entered Studio IDE
* Studio IDE: Fix bug with checking out an environment custom branch on Studio IDE refresh
* Bigquery: Fix PR schema dropping

## dbt Cloud v1.1.2 (June 23, 2020)[​](#dbt-cloud-v112-june-23-2020 "Direct link to dbt Cloud v1.1.2 (June 23, 2020)")

This branch includes an important security fix, two new versions of dbt, and some miscellaneous fixes.

#### Enhancements[​](#enhancements-14 "Direct link to Enhancements")

* Add project names to the account settings notifications section
* Add dbt 0.17.1 release candidate
* Update development dbt version to Marian Anderson
* Add remember me to login page and expire user sessions at browser close
* Adding Auth Provider and enabling Gsuite SSO for enterprise customers

#### Fixed[​](#fixed-14 "Direct link to Fixed")

* [Security] Fix intra-account API key leakage
* Support queries containing unicode characters in the Studio IDE

## dbt Cloud v1.1.1 (June 9, 2020)[​](#dbt-cloud-v111-june-9-2020 "Direct link to dbt Cloud v1.1.1 (June 9, 2020)")

This release includes dbt 0.17.0 and a number of IDE quality of life improvements.

#### Enhancements[​](#enhancements-15 "Direct link to Enhancements")

* Added dbt 0.17.0
* Added the ability to create a new folder in the IDE
* Added gitignore status to file system and display dbt artifacts, including directories dbt\_modules, logs, and target
* (Cloud only) Added rollbar and update some various error handling clean up
* (On-premises only) Admin site: allow Repository's Pull Request Template field to be blank
* (On-premises only) Added AWS KMS support

#### Fixed[​](#fixed-15 "Direct link to Fixed")

* Expires old pending password reset codes when a new password reset is requested

## dbt Cloud v1.1.0 (June 2, 2020)[​](#dbt-cloud-v110-june-2-2020 "Direct link to dbt Cloud v1.1.0 (June 2, 2020)")

This release adds some new admin backend functionality, as well as automatic seat usage reporting.

### On-Premises Only[​](#on-premises-only "Direct link to On-Premises Only")

#### Added[​](#added "Direct link to Added")

* Added automatic reporting of seat usage.

#### Changed[​](#changed "Direct link to Changed")

* Admins can now edit remote URLs for repository in the admin backend.
* Admins can now edit credentials in the admin backend.

---

## dbt Cloud v1.0.12 (May 27, 2020)[​](#dbt-cloud-v1012-may-27-2020 "Direct link to dbt Cloud v1.0.12 (May 27, 2020)")

This release contains a few bugfixes for the Studio IDE and email notifications, as well as the latest release candidate of 0.17.0.

### All versions[​](#all-versions "Direct link to All versions")

#### Added[​](#added-1 "Direct link to Added")

* Use the correct starter project tag, based on dbt version, when initializing a new project in the IDE
* Added branch filtering to IDE git checkout UI.
* Added dbt 0.17.0-rc3.

#### Fixed[​](#fixed-16 "Direct link to Fixed")

* Fixed source freshness report for dbt version v0.17.0
* Fixed issue with checking-out git branches
* Fixed issue of logs being omitted on long running queries in the Studio IDE
* Fixed slack notifications failing to send if email notifications fail

### On-Premises Only[​](#on-premises-only-1 "Direct link to On-Premises Only")

#### Added[​](#added-2 "Direct link to Added")

* Added an Admin page for deleting credentials.

---

## dbt Cloud v1.0.11 (May 19, 2020)[​](#dbt-cloud-v1011-may-19-2020 "Direct link to dbt Cloud v1.0.11 (May 19, 2020)")

This version adds some new permission sets, and a new release candidate of dbt.

### All versions[​](#all-versions-1 "Direct link to All versions")

#### Added[​](#added-3 "Direct link to Added")

* Added permission sets for Job Viewer, Job Admin and Analyst.
* Added dbt 0.17.0-rc1

---

## dbt Cloud v1.0.10 (May 11, 2020)[​](#dbt-cloud-v1010-may-11-2020 "Direct link to dbt Cloud v1.0.10 (May 11, 2020)")

### All versions[​](#all-versions-2 "Direct link to All versions")

#### Added[​](#added-4 "Direct link to Added")

* Added dbt 0.17.0-b1.
* PR Url is now self serve configurable.
* Added more granular permissions around creating and deleting permissions. (Account Admin can create new projects by default while both Account Admin and Project Admin can delete the projects they have permissions for by default)
* Added an error message to display to users that do not have permissions set up for any projects on an account.

#### Fixed[​](#fixed-17 "Direct link to Fixed")

* Removed .sql from CSV download filename
* Fixed breaking JobDefinition API with new param custom\_branch\_only
* Fixed Studio IDE query table column heading casing

---

## dbt Cloud v1.0.9 (May 5, 2020)[​](#dbt-cloud-v109-may-5-2020 "Direct link to dbt Cloud v1.0.9 (May 5, 2020)")

This release includes bugfixes around how permissions are applied to runs and run steps, fixes a bug where the scheduler would hang up, and improves performance of the Studio IDE.

### All versions[​](#all-versions-3 "Direct link to All versions")

#### Fixed[​](#fixed-18 "Direct link to Fixed")

* Fixed permission checks around Runs and Run Steps, this should only affect Enterprise accounts with per-project permissions.
* Fixed receiving arbitrary remote\_url when creating a git url repository.
* Fixed issue when handling non-resource specific errors from RPC server in Studio IDE.
* Fixed a bug where the scheduler would stop if the database went away.
* Fixed IDE query results table not supporting horizontal scrolling.

#### Changed[​](#changed-1 "Direct link to Changed")

* Improve Studio IDE query results performance.
* Allow configuration on jobs to only run builds when environment target branch is env's custom branch.
* Allow configuration of GitHub installation IDs in the admin backend.

### On-Premises Only[​](#on-premises-only-2 "Direct link to On-Premises Only")

#### Fixed[​](#fixed-19 "Direct link to Fixed")

* Fixed logic error for installations with user/password auth enabled in an on-premises context

---

## dbt Cloud v1.0.8 (April 28, 2020)[​](#dbt-cloud-v108-april-28-2020 "Direct link to dbt Cloud v1.0.8 (April 28, 2020)")

This release adds a new version of dbt (0.16.1), fixes a number of IDE bugs, and fixes some dbt Cloud on-premises bugs.

### All versions[​](#all-versions-4 "Direct link to All versions")

#### Added[​](#added-5 "Direct link to Added")

* Add dbt 0.16.1

#### Fixed[​](#fixed-20 "Direct link to Fixed")

* Fixed Studio IDE filesystem loading to check for directories to ensure that load and write methods are only performed on files.
* Fixed a bug with generating private keys for connection SSH tunnels.
* Fixed issue preventing temporary PR schemas from being dropped when PR is closed.
* Fix issues with Studio IDE tabs not updating query compile and run results.
* Fix issues with query runtime timer in Studio IDE for compile and run query functions.
* Fixed what settings are displayed on the account settings page to align with the user's permissions.
* Fixed bug with checking user's permissions in frontend when user belonged to more than one project.
* Fixed bug with access control around environments and file system/git interactions that occurred when using Studio IDE.
* Fixed a bug with Environments too generously matching repository.

#### Changed[​](#changed-2 "Direct link to Changed")

* Make the configured base branch in the Studio IDE read-only.
* Support configuring groups using an account ID in the admin backend.
* Use gunicorn webserver in Studio IDE.
* Allow any repository with a Github installation ID to use build-on-PR.
* Member and Owner Groups are now editable from admin UI.

### On-Premises Only[​](#on-premises-only-3 "Direct link to On-Premises Only")

#### Fixed[​](#fixed-21 "Direct link to Fixed")

* Fixed an issue where account license counts were not set correctly from onprem license file.
* Fixed an issue where docs would sometimes fail to load due to a server error.

---

## dbt Cloud v1.0.7 (April 13, 2020)[​](#dbt-cloud-v107-april-13-2020 "Direct link to dbt Cloud v1.0.7 (April 13, 2020)")

This release rolls out a major change to how permissions are applied in dbt's API. It also adds some minor bugfixes, and some tooling for improved future QA.

### All versions[​](#all-versions-5 "Direct link to All versions")

#### Added[​](#added-6 "Direct link to Added")

* Added support to permission connections on a per project basis.
* Added support to permission credentials on a per project basis.
* Added support to permission repositories on a per project basis.
* Smoke tests for account signup, user login and basic project setup
* Add dbt 0.16.1rc1
* Non-enterprise users can now add new accounts from the Accounts dropdown.

#### Fixed[​](#fixed-22 "Direct link to Fixed")

* Fix missing migration for credentials.
* Fixed issue with testing connections with a non-default target name specified in the credentials.
* Fix issue where Bigquery connections could be created with invalid values for `location`.

---

## dbt Cloud v1.0.6 (March 30, 2020)[​](#dbt-cloud-v106-march-30-2020 "Direct link to dbt Cloud v1.0.6 (March 30, 2020)")

This release adds UIs to select group permissions in the project settings UI. It also contains bugfixes for the Studio IDE, PR build schema dropping, and adds support for dissociating Github and Slack integrations via the Admin backend.

### All versions[​](#all-versions-6 "Direct link to All versions")

#### Added[​](#added-7 "Direct link to Added")

* (Enterprise only) Added ability to create group permissions for specific projects in the project settings UI.

#### Fixed[​](#fixed-23 "Direct link to Fixed")

* Fix empty state for selecting github repositories
* Fixed an issue with the IDE failing to report an invalid project subdirectory for a dbt project
* Fix blank loading screen displayed when switching accounts while on account/profile settings page
* Fix issue preventing schemas from dropping during PR builds
* Fix issue where whitespace in user's name breaks default schema name
* Added webhook processing for when a user disassociates github access to their account.
* Added slack disassociation capability on user integrations page and on backend admin panel (for notifications).

#### Changed[​](#changed-3 "Direct link to Changed")

* Declare application store using configureStore from redux-toolkit

---

## dbt Cloud v1.0.5 (March 23, 2020)[​](#dbt-cloud-v105-march-23-2020 "Direct link to dbt Cloud v1.0.5 (March 23, 2020)")

### All versions[​](#all-versions-7 "Direct link to All versions")

#### Added[​](#added-8 "Direct link to Added")

* Add support for authenticating Development and Deployment Snowflake credentials using keypair auth
* Add support for checking out tags, render git output in "clone" run step
* Add dbt 0.15.3
* Add dbt 0.16.0

#### Fixed[​](#fixed-24 "Direct link to Fixed")

* Git provider urls now built with correct github account and repository directories.
* Invalid DateTime Start time in Studio IDE Results Panel KPIs.
* Fix a race condition causing the Invite User UI to not work properly.
* Incorrect model build times in Studio IDE.

#### Changed[​](#changed-4 "Direct link to Changed")

* Git: ignore `logs/` and `target/` directories in the IDE.

---

## 1.0.4 (March 16, 2020)[​](#104-march-16-2020 "Direct link to 1.0.4 (March 16, 2020)")

This release adds two new versions of dbt, adds Snowflake SSO support for Enterprise accounts, and fixes a number of bugs.

### All versions[​](#all-versions-8 "Direct link to All versions")

#### Added[​](#added-9 "Direct link to Added")

* Added dbt 0.15.3rc1
* Added dbt 0.16.0rc2
* Add support for cloning private deps in the IDE when using deploy key auth.
* Log user that kicked off manual runs.
* Enterprise support for authenticating user Snowflake connections using Snowflake single sign-on

#### Fixed[​](#fixed-25 "Direct link to Fixed")

* Fixed issue loading accounts for a user if they lack permissions for any subset of accounts they have a user license for.
* Fixed issue with showing blank page for user who is not associated with any accounts.
* Fixed issue where runs would continue to kick off on a deleted project.
* Fixed issue where accounts connected to GitHub integrations with SAML protection could not import repositories
* Improved error messages shown to the user if repos are unauthorized in a GitHub integration when importing a repo
* Fix colors of buttons in generated emails

### On-Premises[​](#on-premises "Direct link to On-Premises")

#### Added[​](#added-10 "Direct link to Added")

* Added Admin backend UIs for managing user permissions.

---

## 1.0.3 (March 1, 2020)[​](#103-march-1-2020 "Direct link to 1.0.3 (March 1, 2020)")

This release contains the building blocks for RBAC, and a number of bugfixes and upgrades.

### All versions[​](#all-versions-9 "Direct link to All versions")

#### Added[​](#added-11 "Direct link to Added")

* Add support for a read replica for reading runs from the API.
* Added groups, group permissions, and user groups.
* Add email address to email verification screen.
* Add Enterprise Permissions.
* Allow account-level access to resources for groups with a permission statement of "all resources" for api backwards compatibility.
* Add dbt 0.16.0b3

#### Fixed[​](#fixed-26 "Direct link to Fixed")

* Fix issue with loading projects after switching accounts.
* Fix broken links to connections from deployment environment settings.
* Fix a bug with inviting readonly users.
* Fix a bug where permissions were removed from Enterprise users upon login.

#### Changed[​](#changed-5 "Direct link to Changed")

* Update Django version: 2.2.10
* Update Django admin panel version
* Update Social Auth version and the related Django component
* Update jobs from using account-based resource permissions to project-based resource permissions
* Update modal that shows when trials are expired; fix copy for past-due accounts in modal
* Replace formatted string logging with structured logging
* Move connection and repository settings from account settings to project settings
* Update project setup flow to be used for creating projects
* Update develop requests to have a foreign key on projects

### On-Premises[​](#on-premises-1 "Direct link to On-Premises")

#### Added[​](#added-12 "Direct link to Added")

* Accounts created from admin backend will come with a default set of groups

#### Changed[​](#changed-6 "Direct link to Changed")

* Rename "Fishtown Analytics User" to "Superuser"

---

## dbt Cloud v1.0.2 (February 20, 2020)[​](#dbt-cloud-v102-february-20-2020 "Direct link to dbt Cloud v1.0.2 (February 20, 2020)")

This release contains a number of package upgrades, and a number of bugfixes.

### All versions[​](#all-versions-10 "Direct link to All versions")

#### Added[​](#added-13 "Direct link to Added")

* Add request context data to logs
* Comprehensive logging for git subprocesses

#### Fixed[​](#fixed-27 "Direct link to Fixed")

* Fix an issue where the "Cancel Run" button does not work
* Fix warnings regarding mutable resource model defaults for jobs and job notifications
* Fix bug where users can create multiple connection user credentials through the project setup workflow
* Update auth for requests against Github's api from using query parameters to using an Authorization header
* Remove unused threads input from deployment environments
* Fix issue that prevented user from viewing documentation and data sources
* Fix issue rendering code editor panel in the IDE when using Safari
* Fix issue with log levels that caused dbt logs to be too chatty

#### Changed[​](#changed-7 "Direct link to Changed")

* Update Django version: 2.2.10
* Update Django admin panel version
* Update Social Auth version and the related Django component
* Update jobs from using account-based resource permissions to project-based resource permissions
* Update modal that shows when trials are expired; fix copy for past-due accounts in modal
* Replace formatted string logging with structured logging
* Move connection and repository settings from account settings to project settings
* Update project setup flow to be used for creating projects

#### Removed[​](#removed "Direct link to Removed")

None.

---

## dbt Cloud v1.0.1 (February 4, 2020)[​](#dbt-cloud-v101-february-4-2020 "Direct link to dbt Cloud v1.0.1 (February 4, 2020)")

This release makes the IDE generally available, and adds two new versions of dbt (0.15.1, 0.15.2).

For on-premises customers, there is a new set of configurations in the configuration console:

SMTP: You can now configure dbt to send email notifications through your own SMTP server.

RSA Encryption: You can now provide your own RSA keypair for dbt to use for encryption.

These fields need to be specified for your instance of dbt to function properly.

### All versions[​](#all-versions-11 "Direct link to All versions")

#### Added[​](#added-14 "Direct link to Added")

* New Team List page
* New Team User Detail page
* New Invite User page
* New dashboard for Read Only users
* New dbt version: 0.15.1
* New dbt version: 0.15.2
* Ability to rename files in Studio IDE
* New backend service for project-based resource permissions

#### Fixed[​](#fixed-28 "Direct link to Fixed")

* Fix an issue where the user has to repeat steps in the onboarding flow
* Fix issue where user can get stuck in the onboarding flow
* Fix bug where email notifications could be sent to deleted users
* Fix UI bug not allowing user to check "Build on pull request?" when creating a job
* Fix UI bug in header of the Edit User page
* Fix issue that did not take into account pending invites and license seats when re-sending a user invite.
* Fix an issue when processing Github webhooks with unconfigured environments
* Fix console warning presented when updating React state from unmounted component
* Fix issue where closed tabs would continue to be shown, though the content was removed correctly
* Fix issue that prevented opening an adjacent tab when a tab was closed
* Fix issue creating BigQuery connections causing the account connections list to not load correctly.
* Fix for locked accounts that have downgraded to the developer plan at trial end
* Fix for not properly showing server error messages on the user invite page

#### Changed[​](#changed-8 "Direct link to Changed")

* Deployed a number of Studio IDE visual improvements
* Batch logs up every 5 seconds instead of every second to improve database performance
* Make `retries` profile configuration for BigQuery connections optional
* Support `retries` profile configuration for BigQuery connections (new in dbt v0.15.1)
* Replace Gravatar images with generic person icons in the top navbar
* Remove deprecated account subscription models
* Remove external JS dependencies

#### Removed[​](#removed-1 "Direct link to Removed")

* Remove the "read only" role (this is now a "read only" license type)
* Remove the "standard" license type
* Remove "beta" tag from Studio IDE
* Remove unused frontend code (team page/create repository page and related services)

### Self-Service[​](#self-service "Direct link to Self-Service")

#### Fixed[​](#fixed-29 "Direct link to Fixed")

* Fix for locked accounts that have downgraded to the developer plan at trial end

#### Added[​](#added-15 "Direct link to Added")

* New Plans page
* Add a 14 day free trial
* Add the ability to provision a new repository via dbt
* New Invite Team step for project setup process for trial accounts

#### Changed[​](#changed-9 "Direct link to Changed")

* The "Basic" and "Pro" plans are no longer available. The new "Developer" and "Team" plans are available.
* Prorations are now charged immediately, instead of applied to the next billing cycle.
* It is no longer possible to downgrade to a plan that does not support the current number of allocated seats.
* A "Team" plan that has been cancelled will be locked (closed) at the end of the subscription's period

### On-Premises[​](#on-premises-2 "Direct link to On-Premises")

#### Added[​](#added-16 "Direct link to Added")

* Support custom SMTP settings
* Support Azure Blob Storage for run logs + artifacts
* Optionally disable anonymous usage tracking

---

## dbt Cloud v0.5.0 (December 19, 2019)[​](#dbt-cloud-v050-december-19-2019 "Direct link to dbt Cloud v0.5.0 (December 19, 2019)")

This release preps dbt for the general Studio IDE release in January. Beta Studio IDE functionality can be turned on by checking "Develop file system" in the Accounts page in the dbt backend.

### All versions[​](#all-versions-12 "Direct link to All versions")

#### Added[​](#added-17 "Direct link to Added")

* New dbt version: 0.14.2
* New dbt version: 0.14.3
* New dbt version: 0.14.4
* New dbt version: 0.15.0
* New API endpoint: v3/projects
* New API endpoint: v3/credentials
* New API endpoint: v3/environments
* New API endpoint: v3/events
* Studio IDE: Add git workflow UI
* Studio IDE: Add filesystem management
* Studio IDE: Hup the server when files change
* Studio IDE: Display server status and task history
* Added development and deployment environments and credentials
* Support `--warn-error` flag in dbt runs

#### Fixed[​](#fixed-30 "Direct link to Fixed")

* Fixed an issue where the run scheduler would hang up when deleting PR schemas
* Fixed an issue where the webhook processor would mark a webhook as processed without queuing a run
* Fix a bug where SSH tunnels were not created for the Develop Studio IDE
* Fix Develop Studio IDE scrolling in Firefox
* Fix a bug where requests were timed out too aggressively
* Require company name at signup
* Fix security issue where IP blacklist could be bypassed using shorthand
* Do a better job of handling git errors
* Allow users to delete projects

#### Changed[​](#changed-10 "Direct link to Changed")

* Move account picker to sidebar
* Increase require.js timeout from 7s to 30s
* Migrate environments to projects
* Move some UIs into Account Settings
* Make cron scheduling available on the free tier
* Apply new styles to Studio IDE
* Speed up develop

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Changelog (2021)](https://docs.getdbt.com/docs/dbt-versions/release-notes/dbt-cloud-changelog-2021)

* [dbt Cloud v1.1.16 (December 23, 2020)](#dbt-cloud-v1116-december-23-2020)* [dbt Cloud v1.1.15 (December 10, 2020)](#dbt-cloud-v1115-december-10-2020)* [dbt Cloud v1.1.14 (November 25, 2020)](#dbt-cloud-v1114-november-25-2020)* [dbt Cloud v1.1.13 (November 12, 2020)](#dbt-cloud-v1113-november-12-2020)* [dbt Cloud v1.1.12 (October 30, 2020)](#dbt-cloud-v1112-october-30-2020)* [dbt Cloud v1.1.11 (October 15, 2020)](#dbt-cloud-v1111-october-15-2020)* [dbt Cloud v1.1.10 (October 8, 2020)](#dbt-cloud-v1110-october-8-2020)* [dbt Cloud v1.1.9 (October 1, 2020)](#dbt-cloud-v119-october-1-2020)* [dbt Cloud v1.1.8 (September 17, 2020)](#dbt-cloud-v118-september-17-2020)* [dbt Cloud v1.1.7 [September 3, 2020]](#dbt-cloud-v117-september-3-2020)* [dbt Cloud v1.1.6 (August 20, 2020)](#dbt-cloud-v116-august-20-2020)* [dbt Cloud v1.1.5 (August 4, 2020)](#dbt-cloud-v115-august-4-2020)* [dbt Cloud v1.1.4 (July 21, 2020)](#dbt-cloud-v114-july-21-2020)* [dbt Cloud v1.1.3 (July 7, 2020)](#dbt-cloud-v113-july-7-2020)* [dbt Cloud v1.1.2 (June 23, 2020)](#dbt-cloud-v112-june-23-2020)* [dbt Cloud v1.1.1 (June 9, 2020)](#dbt-cloud-v111-june-9-2020)* [dbt Cloud v1.1.0 (June 2, 2020)](#dbt-cloud-v110-june-2-2020)
                                  + [On-Premises Only](#on-premises-only)* [dbt Cloud v1.0.12 (May 27, 2020)](#dbt-cloud-v1012-may-27-2020)
                                    + [All versions](#all-versions)+ [On-Premises Only](#on-premises-only-1)* [dbt Cloud v1.0.11 (May 19, 2020)](#dbt-cloud-v1011-may-19-2020)
                                      + [All versions](#all-versions-1)* [dbt Cloud v1.0.10 (May 11, 2020)](#dbt-cloud-v1010-may-11-2020)
                                        + [All versions](#all-versions-2)* [dbt Cloud v1.0.9 (May 5, 2020)](#dbt-cloud-v109-may-5-2020)
                                          + [All versions](#all-versions-3)+ [On-Premises Only](#on-premises-only-2)* [dbt Cloud v1.0.8 (April 28, 2020)](#dbt-cloud-v108-april-28-2020)
                                            + [All versions](#all-versions-4)+ [On-Premises Only](#on-premises-only-3)* [dbt Cloud v1.0.7 (April 13, 2020)](#dbt-cloud-v107-april-13-2020)
                                              + [All versions](#all-versions-5)* [dbt Cloud v1.0.6 (March 30, 2020)](#dbt-cloud-v106-march-30-2020)
                                                + [All versions](#all-versions-6)* [dbt Cloud v1.0.5 (March 23, 2020)](#dbt-cloud-v105-march-23-2020)
                                                  + [All versions](#all-versions-7)* [1.0.4 (March 16, 2020)](#104-march-16-2020)
                                                    + [All versions](#all-versions-8)+ [On-Premises](#on-premises)* [1.0.3 (March 1, 2020)](#103-march-1-2020)
                                                      + [All versions](#all-versions-9)+ [On-Premises](#on-premises-1)* [dbt Cloud v1.0.2 (February 20, 2020)](#dbt-cloud-v102-february-20-2020)
                                                        + [All versions](#all-versions-10)* [dbt Cloud v1.0.1 (February 4, 2020)](#dbt-cloud-v101-february-4-2020)
                                                          + [All versions](#all-versions-11)+ [Self-Service](#self-service)+ [On-Premises](#on-premises-2)* [dbt Cloud v0.5.0 (December 19, 2019)](#dbt-cloud-v050-december-19-2019)
                                                            + [All versions](#all-versions-12)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/dbt-versions/release-notes/99-dbt-cloud-changelog-2019-2020.md)
