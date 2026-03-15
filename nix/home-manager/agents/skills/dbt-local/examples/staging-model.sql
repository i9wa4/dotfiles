-- staging model example
-- Source: raw schema, Target: staging schema
-- Naming convention: stg_<source>__<entity>
with
    source as (select * from {{ source("raw", "orders") }}),

    renamed as (
        select
            id as order_id, customer_id, status as order_status, created_at, updated_at
        from source
    )

select *
from renamed
