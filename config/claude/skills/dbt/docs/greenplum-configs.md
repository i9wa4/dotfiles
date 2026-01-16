---
title: "Greenplum configurations | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/resource-configs/greenplum-configs"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Platform-specific configs](https://docs.getdbt.com/reference/resource-configs/resource-configs)* Greenplum configurations

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fgreenplum-configs+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fgreenplum-configs+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fresource-configs%2Fgreenplum-configs+so+I+can+ask+questions+about+it.)

On this page

## Performance Optimizations[​](#performance-optimizations "Direct link to Performance Optimizations")

Tables in Greenplum have powerful optimization configurations to improve query performance:

* distribution
* column orientation
* compression
* `appendonly` toggle
* partitions

Supplying these values as model-level configurations apply the corresponding settings in the generated `CREATE TABLE`(except partitions). Note that these settings will have no effect for models set to `view`.

### Distribution[​](#distribution "Direct link to Distribution")

In Greenplum, you can choose a [distribution key](https://gpdb.docs.pivotal.io/6-4/admin_guide/distribution.html), that will be used to sort data by segments. Joining on the partition will become more performant after specifying distribution.

By default dbt-greenplum distributes data `RANDOMLY`. To implement a distribution key you need to specify the `distributed_by` parameter in model's config:

```
{{
    config(
        ...
        distributed_by='<field_name>'
        ...
    )
}}


select ...
```

Also you can choose `DISTRIBUTED REPLICATED` option:

```
{{
    config(
        ...
        distributed_replicated=true
        ...
    )
}}


select ...
```

### Column orientation[​](#column-orientation "Direct link to Column orientation")

Greenpum supports two type of [orientation](https://gpdb.docs.pivotal.io/6-6/admin_guide/ddl/ddl-storage.html#topic39) row and column:

```
{{
    config(
        ...
        orientation='column'
        ...
    )
}}


select ...
```

### Compression[​](#compression "Direct link to Compression")

Compression allows reducing read-write time. Greenplum suggest several [algorithms](https://gpdb.docs.pivotal.io/6-6/admin_guide/ddl/ddl-storage.html#topic40) algotihms to compress append-optimized tables:

* RLE\_TYPE(only for column oriented table)
* ZLIB
* ZSTD
* QUICKLZ

```
{{
    config(
        ...
        appendonly='true',
        compresstype='ZLIB',
        compresslevel=3,
        blocksize=32768
        ...
    )
}}


select ...
```

As you can see, you can also specify `compresslevel` and `blocksize`.

### Partition[​](#partition "Direct link to Partition")

Greenplum does not support partitions with `create table as` [construction](https://gpdb.docs.pivotal.io/6-9/ref_guide/sql_commands/CREATE_TABLE_AS.html), so you need to build model in two steps

1. create table schema
2. insert data

To implement partitions into your dbt-model you need to specify the following config parameters:

* `fields_string` - definition of columns name, type and constraints
* `raw_partition` - partition specification

```
{% set fields_string %}
    some_filed int4 null,
    date_field timestamp NULL
{% endset %}


{% set raw_partition %}
   PARTITION BY RANGE (date_field)
   (
       START ('2021-01-01'::timestamp) INCLUSIVE
       END ('2023-01-01'::timestamp) EXCLUSIVE
       EVERY (INTERVAL '1 day'),
       DEFAULT PARTITION default_part
   );
{% endset %}

{{
   config(
       ...
       fields_string=fields_string,
       raw_partition=raw_partition,
       ...
   )
}}

select *
```

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

Firebolt configurations](https://docs.getdbt.com/reference/resource-configs/firebolt-configs)[Next

Infer configurations](https://docs.getdbt.com/reference/resource-configs/infer-configs)

* [Performance Optimizations](#performance-optimizations)
  + [Distribution](#distribution)+ [Column orientation](#column-orientation)+ [Compression](#compression)+ [Partition](#partition)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/resource-configs/greenplum-configs.md)
