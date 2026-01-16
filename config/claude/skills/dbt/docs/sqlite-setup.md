---
title: "SQLite setup | dbt Developer Hub"
source_url: "https://docs.getdbt.com/docs/core/connect-data-platform/sqlite-setup"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Set up dbt](https://docs.getdbt.com/docs/about-setup)* [dbt Core and Fusion](https://docs.getdbt.com/docs/about-dbt-install)* [Connect dbt Core to your data platform](https://docs.getdbt.com/docs/core/connect-data-platform/about-core-connections)* SQLite setup

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fsqlite-setup+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fsqlite-setup+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Fdocs%2Fcore%2Fconnect-data-platform%2Fsqlite-setup+so+I+can+ask+questions+about+it.)

On this page

Community plugin

Some core functionality may be limited. If you're interested in contributing, check out the source code for each repository listed below.

* **Maintained by**: Community* **Authors**: Jeff Chiu (https://github.com/codeforkjeff)* **GitHub repo**: [codeforkjeff/dbt-sqlite](https://github.com/codeforkjeff/dbt-sqlite) [![](https://img.shields.io/github/stars/codeforkjeff/dbt-sqlite?style=for-the-badge)](https://github.com/codeforkjeff/dbt-sqlite)* **PyPI package**: `dbt-sqlite` [![](https://badge.fury.io/py/dbt-sqlite.svg)](https://badge.fury.io/py/dbt-sqlite)* **Slack channel**: [n/a](https://www.getdbt.com/community)* **Supported dbt Core version**: v1.1.0 and newer* **dbt support**: Not Supported* **Minimum data platform version**: SQlite Version 3.0

## Installing dbt-sqlite

Use `pip` to install the adapter. Before 1.8, installing the adapter would automatically install `dbt-core` and any additional dependencies. Beginning in 1.8, installing an adapter does not automatically install `dbt-core`. This is because adapters and dbt Core versions have been decoupled from each other so we no longer want to overwrite existing dbt-core installations.
Use the following command for installation:

`python -m pip install dbt-core dbt-sqlite`

## Configuring dbt-sqlite

For SQLite-specific configuration, please refer to [SQLite configs.](https://docs.getdbt.com/reference/resource-configs/no-configs)

Starting with the release of dbt Core 1.0.0, versions of dbt-sqlite are aligned to the same major+minor [version](https://semver.org/) of dbt Core.

* versions 1.1.x of this adapter work with dbt Core 1.1.x
* versions 1.0.x of this adapter work with dbt Core 1.0.x

## Connecting to SQLite with dbt-sqlite[​](#connecting-to-sqlite-with-dbt-sqlite "Direct link to Connecting to SQLite with dbt-sqlite")

SQLite targets should be set up using the following configuration in your `profiles.yml` file.

Example:

~/.dbt/profiles.yml

```
your_profile_name:
  target: dev
  outputs:
    dev:
      type: sqlite
      threads: 1
      database: 'database'
      schema: 'main'
      schemas_and_paths:
        main: 'file_path/database_name.db'
      schema_directory: 'file_path'
      #optional fields
      extensions:
        - "/path/to/sqlean/crypto.so"
```

#### Description of SQLite Profile Fields[​](#description-of-sqlite-profile-fields "Direct link to Description of SQLite Profile Fields")

|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Field Description|  |  |  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | `type` Required. Must be set to `sqlite`.| `threads` Required. Must be set to `1`. SQLite locks the whole db on writes so anything > 1 won't help.| `database` Required but the value is arbitrary because there is no 'database' portion of relation names in SQLite so it gets stripped from the output of ref() and from SQL everywhere. It still needs to be set in the configuration and is used by dbt internally.|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | `schema` Value of 'schema' must be defined in schema\_paths below. in most cases, this should be main.|  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | | `schemas_and_paths` Connect schemas to paths: at least one of these must be 'main'|  |  |  |  | | --- | --- | --- | --- | | `schema_directory` Directory where all \*.db files are attached as schema, using base filename as schema name, and where new schemas are created. This can overlap with the dirs of files in schemas\_and\_paths as long as there's no conflicts.|  |  | | --- | --- | | `extensions` Optional. List of file paths of SQLite extensions to load. crypto.so is needed for snapshots to work; see SQLlite Extensions below. | | | | | | | | | | | | | | | |

|  |  |  |  |  |
| --- | --- | --- | --- | --- |
||  |  |  |  |  |
| --- | --- | --- | --- | --- |
| Loading table... | | | | |

## Caveats[​](#caveats "Direct link to Caveats")

* Schemas are implemented as attached database files. (SQLite conflates databases and schemas.)

  + SQLite automatically assigns 'main' to the file you initially connect to, so this must be defined in your profile. Other schemas defined in your profile
    get attached when database connection is created.
  + If dbt needs to create a new schema, it will be created in `schema_directory` as `schema_name.db`. Dropping a schema results in dropping all its relations and detaching the database file from the session.
  + Schema names are stored in view definitions, so when you access a non-'main' database file outside dbt, you'll need to attach it using the same name, or the views won't work.
  + SQLite does not allow views in one schema (i.e. database file) to reference objects in another schema. You'll get this error from SQLite: "view [someview] cannot reference objects in database [somedatabase]". You must set `materialized='table'` in models that reference other schemas.
* Materializations are simplified: they drop and re-create the model, instead of doing the backup-and-swap-in new model that the other dbt database adapters support. This choice was made because SQLite doesn't support `DROP ... CASCADE` or `ALTER VIEW` or provide information about relation dependencies in something information\_schema-like. These limitations make it really difficult to make the backup-and-swap-in functionality work properly. Given how SQLite aggressively [locks](https://sqlite.org/lockingv3.html) the database anyway, it's probably not worth the effort.

## SQLite Extensions[​](#sqlite-extensions "Direct link to SQLite Extensions")

For snapshots to work, you'll need the `crypto` module from SQLean to get an `md5()` function. It's recommended that you install all the SQLean modules, as they provide many common SQL functions missing from SQLite.

Precompiled binaries are available for download from the [SQLean github repository page](https://github.com/nalgeon/sqlean). You can also compile them yourself if you want.

Point to these module files in your profile config as shown in the example above.

Mac OS seems to ship with [SQLite libraries that do not have support for loading extensions compiled in](https://docs.python.org/3/library/sqlite3.html#f1), so this won't work "out of the box." Accordingly, snapshots won't work. If you need snapshot functionality, you'll need to compile SQLite/python or find a python distribution for Mac OS with this support.

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

SingleStore setup](https://docs.getdbt.com/docs/core/connect-data-platform/singlestore-setup)[Next

Starrocks setup](https://docs.getdbt.com/docs/core/connect-data-platform/starrocks-setup)

* [Connecting to SQLite with dbt-sqlite](#connecting-to-sqlite-with-dbt-sqlite)* [Caveats](#caveats)* [SQLite Extensions](#sqlite-extensions)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/docs/core/connect-data-platform/sqlite-setup.md)
