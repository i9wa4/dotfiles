---
title: "Snapshot configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/snapshot-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Resource configs and properties](https://docs.getdbt.com/reference/resource-configs/resource-path)* [For snapshots](https://docs.getdbt.com/reference/snapshot-properties)* Snapshot configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fsnapshot-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fsnapshot-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fsnapshot-configs+so+I+can+ask+questions+about+it.)

On this page

Learn about using snapshot configurations in dbt, including snapshot-specific configurations and general configurations.

## Related documentation[​](#related-documentation "Direct link to Related documentation")

* [Snapshots](https://docs.getdbt.com/docs/build/snapshots)
* The `dbt snapshot` [command](https://docs.getdbt.com/reference/commands/snapshot)

Learn by video!

For video tutorials on Snapshots, go to dbt Learn and check out the [Snapshots course](https://learn.getdbt.com/courses/snapshots).

## Available configurations[​](#available-configurations "Direct link to Available configurations")

### Snapshot-specific configurations[​](#snapshot-specific-configurations "Direct link to Snapshot-specific configurations")

Resource-specific configurations are applicable to only one dbt resource type rather than multiple resource types. You can define these settings in the project file (`dbt_project.yml`), a property file (`models/properties.yml` for models, similarly for other resources), or within the resource’s file using the `{{ config() }}` macro.

The following resource-specific configurations are only available to Snapshots:

* Project file* YAML file* Config block

info

Starting from [the dbt "Latest" release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) and dbt Core v1.9, defining snapshots in a `.sql` file using a config block is a legacy method. You can define snapshots in YAML format using the latest [snapshot-specific configurations](https://docs.getdbt.com/docs/build/snapshots#configuring-snapshots). For new snapshots, we recommend using these latest configs. If applying them to existing snapshots, you'll need to [migrate](#snapshot-configuration-migration) over.

### Snapshot configuration migration[​](#snapshot-configuration-migration "Direct link to Snapshot configuration migration")

The latest snapshot configurations introduced in dbt Core v1.9 (such as [`snapshot_meta_column_names`](https://docs.getdbt.com/reference/resource-configs/snapshot_meta_column_names), [`dbt_valid_to_current`](https://docs.getdbt.com/reference/resource-configs/dbt_valid_to_current), and `hard_deletes`) are best suited for new snapshots, but you can also adopt them in existing snapshots by migrating your table schema and configs carefully to avoid any inconsistencies in your snapshots.

Here's how you can do it:

1. In your data platform, create a backup snapshot table. You can copy it to a new table:

   ```
   create table my_snapshot_table_backup as
   select * from my_snapshot_table;
   ```

   This allows you to restore your snapshot if anything goes wrong during migration.
2. If you want to use the new configs, add required columns to your existing snapshot table using `alter` statements as needed. Here's an example of what to add if you're going to use `dbt_valid_to_current` and `snapshot_meta_column_names`:

   ```
   alter table my_snapshot_table
   add column dbt_valid_from timestamp,
   add column dbt_valid_to timestamp;
   ```
3. Then update your snapshot config:

   ```
   snapshots:
     - name: orders_snapshot
       relation: source('something','orders')
       config:
         strategy: timestamp
         updated_at: updated_at
         unique_key: id
         dbt_valid_to_current: "to_date('9999-12-31')"
         snapshot_meta_column_names:
           dbt_valid_from: start_date
           dbt_valid_to: end_date
   ```
4. Test each change before adopting multiple new configs by running `dbt snapshot` in development or staging.
5. Confirm if the snapshot run completes without errors, the new columns are created, and historical logic behaves as you’d expect. The table should look like this:

   |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
   | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
   | `id` `start_date` `end_date` `updated_at`|  |  |  |  |  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | | 1 2024-10-01 09:00:00 2024-10-03 08:00:00 2024-10-01 09:00:00|  |  |  |  |  |  |  |  | | --- | --- | --- | --- | --- | --- | --- | --- | | 2 2024-10-03 08:00:00 9999-12-31 00:00:00 2024-10-03 08:00:00|  |  |  |  | | --- | --- | --- | --- | | 3 2024-10-02 11:15:00 9999-12-31 00:00:00 2024-10-02 11:15:00 | | | | | | | | | | | | | | | |

   |  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   ||  |  |  |  |  |
   | --- | --- | --- | --- | --- |
   | Loading table... | | | | |

Note: The `end_date` column (defined by `snapshot_meta_column_names`) uses the configured value from `dbt_valid_to_current` (9999-12-31) for newly inserted records, instead of the default `NULL`. Existing records will have `NULL` for `end_date`.

warning

If you use one of the latest configs, such as `dbt_valid_to_current`, without migrating your data, you may have mixed old and new data, leading to an incorrect downstream result.

### General configurations[​](#general-configurations "Direct link to General configurations")

General configurations provide broader operational settings applicable across multiple resource types. Like resource-specific configurations, these can also be set in the project file, property files, or within resource-specific files.

* Project file* YAML file* Config block

dbt\_project.yml

info

Starting from [the dbt "Latest" release track](https://docs.getdbt.com/docs/dbt-versions/cloud-release-tracks) and dbt Core v1.9, defining snapshots in a `.sql` file using a config block is a legacy method. You can define snapshots in YAML format using the latest [snapshot-specific configurations](https://docs.getdbt.com/docs/build/snapshots#configuring-snapshots). For new snapshots, we recommend using these latest configs. If applying them to existing snapshots, you'll need to [migrate](#snapshot-configuration-migration) over.

## Configuring snapshots[​](#configuring-snapshots "Direct link to Configuring snapshots")

Snapshots can be configured in multiple ways:

Snapshot configurations are applied hierarchically in the order above with higher taking precedence. You can also apply [data tests](https://docs.getdbt.com/reference/snapshot-properties) to snapshots using the [`tests` property](https://docs.getdbt.com/reference/resource-properties/data-tests).

### Examples[​](#examples "Direct link to Examples")

* #### Apply configurations to all snapshots[​](#apply-configurations-to-all-snapshots "Direct link to Apply configurations to all snapshots")

  To apply a configuration to all snapshots, including those in any installed [packages](https://docs.getdbt.com/docs/build/packages), nest the configuration directly under the `snapshots` key:

  dbt\_project.yml

  ```
  snapshots:
    +unique_key: id
  ```
* #### Apply configurations to all snapshots in your project[​](#apply-configurations-to-all-snapshots-in-your-project "Direct link to Apply configurations to all snapshots in your project")

  To apply a configuration to all snapshots in your project only (for example, *excluding* any snapshots in installed packages), provide your project name as part of the resource path.

  For a project named `jaffle_shop`:

  dbt\_project.yml

  ```
  snapshots:
    jaffle_shop:
      +unique_key: id
  ```

  Similarly, you can use the name of an installed package to configure snapshots in that package.
* #### Apply configurations to one snapshot only[​](#apply-configurations-to-one-snapshot-only "Direct link to Apply configurations to one snapshot only")

  You can also use the full resource path (including the project name, and subdirectories) to configure an individual snapshot from your `dbt_project.yml` file.

  For a project named `jaffle_shop`, with a snapshot file within the `snapshots/postgres_app/` directory, where the snapshot is named `orders_snapshot` (as above), this would look like:

  dbt\_project.yml

  ```
  snapshots:
    jaffle_shop:
      postgres_app:
        orders_snapshot:
          +unique_key: id
          +strategy: timestamp
          +updated_at: updated_at
  ```

  You can also define some common configs in a snapshot's `config` block. However, we don't recommend this for a snapshot's required configuration.

  dbt\_project.yml

  ```
  snapshots:
    - name: orders_snapshot
      +persist_docs:
        relation: true
        columns: true
  ```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Snapshot properties](https://docs.getdbt.com/reference/snapshot-properties)[Next

Legacy snapshot configurations](https://docs.getdbt.com/reference/resource-configs/snapshots-jinja-legacy)

* [Related documentation](#related-documentation)* [Available configurations](#available-configurations)
    + [Snapshot-specific configurations](#snapshot-specific-configurations)+ [Snapshot configuration migration](#snapshot-configuration-migration)+ [General configurations](#general-configurations)* [Configuring snapshots](#configuring-snapshots)
      + [Examples](#examples)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/snapshot-configs.md)
