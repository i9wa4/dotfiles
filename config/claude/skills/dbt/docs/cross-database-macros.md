---
title: "About cross-database macros | dbt Developer Hub"
source_url: "https://docs.getdbt.com/reference/dbt-jinja-functions/cross-database-macros"
fetched_at: "2025-12-16T14:20:18.809572+00:00"
---



* * [Jinja reference](https://docs.getdbt.com/category/jinja-reference)* [dbt Jinja functions](https://docs.getdbt.com/reference/dbt-jinja-functions)* cross-database macros

Copy page

Copy page

Copy page as Markdown for LLMs

[Open in ChatGPT

Ask questions about this page](https://chatgpt.com/?hints=search&prompt=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fcross-database-macros+so+I+can+ask+questions+about+it.)[Open in Claude

Ask questions about this page](https://claude.ai/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fcross-database-macros+so+I+can+ask+questions+about+it.)[Open in Perplexity

Ask questions about this page](https://www.perplexity.ai/search/new?q=Read+from+https%3A%2F%2Fdocs.getdbt.com%2Freference%2Fdbt-jinja-functions%2Fcross-database-macros+so+I+can+ask+questions+about+it.)

On this page

These macros benefit three different user groups:

* If you maintain a package, your package is more likely to work on other adapters by using these macros (rather than a specific database's SQL syntax)
* If you maintain an adapter, your adapter is more likely to support more packages by implementing (and testing) these macros.
* If you're an end user, more packages and adapters are likely to "just work" for you (without you having to do anything).

Note

Please make sure to take a look at the [SQL expressions section](#sql-expressions) to understand quoting syntax for string values and date literals.

## All functions (alphabetical)[​](#all-functions-alphabetical "Direct link to All functions (alphabetical)")

* [Cross-database macros](#cross-database-macros)
  + [All functions (alphabetical)](#all-functions-alphabetical)
  + [Data type functions](#data-type-functions)
    - [type\_bigint](#type_bigint)
    - [type\_boolean](#type_boolean)
    - [type\_float](#type_float)
    - [type\_int](#type_int)
    - [type\_numeric](#type_numeric)
    - [type\_string](#type_string)
    - [type\_timestamp](#type_timestamp)
    - [current\_timestamp](#current_timestamp)
  + [Set functions](#set-functions)
    - [except](#except)
    - [intersect](#intersect)
  + [Array functions](#array-functions)
    - [array\_append](#array_append)
    - [array\_concat](#array_concat)
    - [array\_construct](#array_construct)
  + [String functions](#string-functions)
    - [concat](#concat)
    - [hash](#hash)
    - [length](#length)
    - [position](#position)
    - [replace](#replace)
    - [right](#right)
    - [split\_part](#split_part)
  + [String literal functions](#string-literal-functions)
    - [escape\_single\_quotes](#escape_single_quotes)
    - [string\_literal](#string_literal)
  + [Aggregate and window functions](#aggregate-and-window-functions)
    - [any\_value](#any_value)
    - [bool\_or](#bool_or)
    - [listagg](#listagg)
  + [Cast functions](#cast-functions)
    - [cast](#cast)
    - [cast\_bool\_to\_text](#cast_bool_to_text)
    - [safe\_cast](#safe_cast)
  + [Date and time functions](#date-and-time-functions)
    - [date](#date)
    - [dateadd](#dateadd)
    - [datediff](#datediff)
    - [date\_trunc](#date_trunc)
    - [last\_day](#last_day)
  + [Date and time parts](#date-and-time-parts)
  + [SQL expressions](#sql-expressions)

[**Data type functions**](#data-type-functions)

* [type\_bigint](#type_bigint)
* [type\_boolean](#type_boolean)
* [type\_float](#type_float)
* [type\_int](#type_int)
* [type\_numeric](#type_numeric)
* [type\_string](#type_string)
* [type\_timestamp](#type_timestamp)

[**Set functions**](#set-functions)

* [except](#except)
* [intersect](#intersect)

[**Array functions**](#array-functions)

* [array\_append](#array_append)
* [array\_concat](#array_concat)
* [array\_construct](#array_construct)

[**String functions**](#string-functions)

* [concat](#concat)
* [hash](#hash)
* [length](#length)
* [position](#position)
* [replace](#replace)
* [right](#right)
* [split\_part](#split_part)

[**String literal functions**](#string-literal-functions)

* [escape\_single\_quotes](#escape_single_quotes)
* [string\_literal](#string_literal)

[**Aggregate and window functions**](#aggregate-and-window-functions)

* [any\_value](#any_value)
* [bool\_or](#bool_or)
* [listagg](#listagg)

[**Cast functions**](#cast-functions)

* [cast](#cast)
* [cast\_bool\_to\_text](#cast_bool_to_text)
* [safe\_cast](#safe_cast)

[**Date and time functions**](#date-and-time-functions)

* [date](#date)
* [dateadd](#dateadd)
* [datediff](#datediff)
* [date\_trunc](#date_trunc)
* [last\_day](#last_day)

## Data type functions[​](#data-type-functions "Direct link to Data type functions")

### type\_bigint[​](#type_bigint "Direct link to type_bigint")

**Args**:

* None

This macro yields the database-specific data type for a `BIGINT`.

**Usage**:

```
{{ dbt.type_bigint() }}
```

**Sample Output (PostgreSQL)**:

```
bigint
```

### type\_boolean[​](#type_boolean "Direct link to type_boolean")

**Args**:

* None

This macro yields the database-specific data type for a `BOOLEAN`.

**Usage**:

```
{{ dbt.type_boolean() }}
```

**Sample Output (PostgreSQL)**:

```
BOOLEAN
```

### type\_float[​](#type_float "Direct link to type_float")

**Args**:

* None

This macro yields the database-specific data type for a `FLOAT`.

**Usage**:

```
{{ dbt.type_float() }}
```

**Sample Output (PostgreSQL)**:

```
FLOAT
```

### type\_int[​](#type_int "Direct link to type_int")

**Args**:

* None

This macro yields the database-specific data type for an `INT`.

**Usage**:

```
{{ dbt.type_int() }}
```

**Sample Output (PostgreSQL)**:

```
INT
```

### type\_numeric[​](#type_numeric "Direct link to type_numeric")

**Args**:

* None

This macro yields the database-specific data type for a `NUMERIC`.

**Usage**:

```
{{ dbt.type_numeric() }}
```

**Sample Output (PostgreSQL)**:

```
numeric(28,6)
```

### type\_string[​](#type_string "Direct link to type_string")

**Args**:

* None

This macro yields the database-specific data type for `TEXT`.

**Usage**:

```
{{ dbt.type_string() }}
```

**Sample Output (PostgreSQL)**:

```
TEXT
```

### type\_timestamp[​](#type_timestamp "Direct link to type_timestamp")

**Args**:

* None

This macro yields the database-specific data type for a `TIMESTAMP` (which may or may not match the behavior of `TIMESTAMP WITHOUT TIMEZONE` from ANSI SQL-92).

**Usage**:

```
{{ dbt.type_timestamp() }}
```

**Sample Output (PostgreSQL)**:

```
TIMESTAMP
```

### current\_timestamp[​](#current_timestamp "Direct link to current_timestamp")

This macro returns the current date and time for the system. Depending on the adapter:

* The result may be an aware or naive timestamp.
* The result may correspond to the start of the statement or the start of the transaction.

**Args**

* None

**Usage**

* You can use the `current_timestamp()` macro within your dbt SQL files like this:

```
{{ dbt.current_timestamp() }}
```

**Sample output (PostgreSQL)**

```
now()
```

## Set functions[​](#set-functions "Direct link to Set functions")

### except[​](#except "Direct link to except")

**Args**:

* None

`except` is one of the set operators specified ANSI SQL-92 (along with `union` and `intersect`) and is akin to [set difference](https://en.wikipedia.org/wiki/Complement_(set_theory)#Relative_complement).

**Usage**:

```
{{ dbt.except() }}
```

**Sample Output (PostgreSQL)**:

```
except
```

### intersect[​](#intersect "Direct link to intersect")

**Args**:

* None

`intersect` is one of the set operators specified ANSI SQL-92 (along with `union` and `except`) and is akin to [set intersection](https://en.wikipedia.org/wiki/Intersection_(set_theory)).

**Usage**:

```
{{ dbt.intersect() }}
```

**Sample Output (PostgreSQL)**:

```
intersect
```

## Array functions[​](#array-functions "Direct link to Array functions")

### array\_append[​](#array_append "Direct link to array_append")

**Args**:

* `array` (required): The array to append to.
* `new_element` (required): The element to be appended. This element must *match the data type of the existing elements* in the array in order to match PostgreSQL functionality and *not null* to match BigQuery functionality.

This macro appends an element to the end of an array and returns the appended array.

**Usage**:

```
{{ dbt.array_append("array_column", "element_column") }}
{{ dbt.array_append("array_column", "5") }}
{{ dbt.array_append("array_column", "'blue'") }}
```

**Sample Output (PostgreSQL)**:

```
array_append(array_column, element_column)
array_append(array_column, 5)
array_append(array_column, 'blue')
```

### array\_concat[​](#array_concat "Direct link to array_concat")

**Args**:

* `array_1` (required): The array to append to.
* `array_2` (required): The array to be appended to `array_1`. This array must match the data type of `array_1` in order to match PostgreSQL functionality.

This macro returns the concatenation of two arrays.

**Usage**:

```
{{ dbt.array_concat("array_column_1", "array_column_2") }}
```

**Sample Output (PostgreSQL)**:

```
array_cat(array_column_1, array_column_2)
```

### array\_construct[​](#array_construct "Direct link to array_construct")

**Args**:

* `inputs` (optional): The list of array contents. If not provided, this macro will create an empty array. All inputs must be the *same data type* in order to match PostgreSQL functionality and *not null* to match BigQuery functionality.
* `data_type` (optional): Specifies the data type of the constructed array. This is only relevant when creating an empty array (will otherwise use the data type of the inputs). If `inputs` are `data_type` are both not provided, this macro will create an empty array of type integer.

This macro returns an array constructed from a set of inputs.

**Usage**:

```
{{ dbt.array_construct(["column_1", "column_2", "column_3"]) }}
{{ dbt.array_construct([], "integer") }}
{{ dbt.array_construct([1, 2, 3, 4]) }}
{{ dbt.array_construct(["'blue'", "'green'"]) }}
```

**Sample Output (PostgreSQL)**:

```
array[ column_1 , column_2 , column_3 ]
array[]::integer[]
array[ 1 , 2 , 3 , 4 ]
array[ 'blue' , 'green' ]
```

## String functions[​](#string-functions "Direct link to String functions")

### concat[​](#concat "Direct link to concat")

**Args**:

* `fields`: Jinja array of [attribute names or expressions](#sql-expressions).

This macro combines a list of strings together.

**Usage**:

```
{{ dbt.concat(["column_1", "column_2"]) }}
{{ dbt.concat(["year_column", "'-'" , "month_column", "'-'" , "day_column"]) }}
{{ dbt.concat(["first_part_column", "'.'" , "second_part_column"]) }}
{{ dbt.concat(["first_part_column", "','" , "second_part_column"]) }}
```

**Sample Output (PostgreSQL)**:

```
column_1 || column_2
year_column || '-' || month_column || '-' || day_column
first_part_column || '.' || second_part_column
first_part_column || ',' || second_part_column
```

### hash[​](#hash "Direct link to hash")

**Args**:

* `field`: [attribute name or expression](#sql-expressions).

This macro provides a hash (such as [MD5](https://en.wikipedia.org/wiki/MD5)) of an [expression](#sql-expressions) cast as a string.

**Usage**:

```
{{ dbt.hash("column") }}
{{ dbt.hash("'Pennsylvania'") }}
```

**Sample Output (PostgreSQL)**:

```
md5(cast(column as
    varchar
))
md5(cast('Pennsylvania' as
    varchar
))
```

### length[​](#length "Direct link to length")

**Args**:

* `expression`: string [expression](#sql-expressions).

This macro calculates the number of characters in a string.

**Usage**:

```
{{ dbt.length("column") }}
```

**Sample Output (PostgreSQL)**:

```
    length(
        column
    )
```

### position[​](#position "Direct link to position")

**Args**:

* `substring_text`: [attribute name or expression](#sql-expressions).
* `string_text`: [attribute name or expression](#sql-expressions).

This macro searches for the first occurrence of `substring_text` within `string_text` and returns the 1-based position if found.

**Usage**:

```
{{ dbt.position("substring_column", "text_column") }}
{{ dbt.position("'-'", "text_column") }}
```

**Sample Output (PostgreSQL)**:

```
    position(
        substring_column in text_column
    )

    position(
        '-' in text_column
    )
```

### replace[​](#replace "Direct link to replace")

**Args**:

* `field`: [attribute name or expression](#sql-expressions).
* `old_chars`: [attribute name or expression](#sql-expressions).
* `new_chars`: [attribute name or expression](#sql-expressions).

This macro updates a string and replaces all occurrences of one substring with another. The precise behavior may vary slightly from one adapter to another.

**Usage**:

```
{{ dbt.replace("string_text_column", "old_chars_column", "new_chars_column") }}
{{ dbt.replace("string_text_column", "'-'", "'_'") }}
```

**Sample Output (PostgreSQL)**:

```
    replace(
        string_text_column,
        old_chars_column,
        new_chars_column
    )

    replace(
        string_text_column,
        '-',
        '_'
    )
```

### right[​](#right "Direct link to right")

**Args**:

* `string_text`: [attribute name or expression](#sql-expressions).
* `length_expression`: numeric [expression](#sql-expressions).

This macro returns the N rightmost characters from a string.

**Usage**:

```
{{ dbt.right("string_text_column", "length_column") }}
{{ dbt.right("string_text_column", "3") }}
```

**Sample Output (PostgreSQL)**:

```
    right(
        string_text_column,
        length_column
    )

    right(
        string_text_column,
        3
    )
```

### split\_part[​](#split_part "Direct link to split_part")

**Args**:

* `string_text` (required): Text to be split into parts.
* `delimiter_text` (required): Text representing the delimiter to split by.
* `part_number` (required): Requested part of the split (1-based). If the value is negative, the parts are counted backward from the end of the string.

This macro splits a string of text using the supplied delimiter and returns the supplied part number (1-indexed).

**Usage**:

When referencing a column, use one pair of quotes. When referencing a string, use single quotes enclosed in double quotes.

```
{{ dbt.split_part(string_text='column_to_split', delimiter_text='delimiter_column', part_number=1) }}
{{ dbt.split_part(string_text="'1|2|3'", delimiter_text="'|'", part_number=1) }}
```

**Sample Output (PostgreSQL)**:

```
    split_part(
        column_to_split,
        delimiter_column,
        1
        )

    split_part(
        '1|2|3',
        '|',
        1
        )
```

## String literal functions[​](#string-literal-functions "Direct link to String literal functions")

### escape\_single\_quotes[​](#escape_single_quotes "Direct link to escape_single_quotes")

**Args**:

* `value`: Jinja string literal value

This macro adds escape characters for any single quotes within the provided string literal. Note: if given a column, it will only operate on the column *name*, not the values within the column.

To escape quotes for column values, consider a macro like [replace](#replace) or a regular expression replace.

**Usage**:

```
{{ dbt.escape_single_quotes("they're") }}
{{ dbt.escape_single_quotes("ain't ain't a word") }}
```

**Sample Output (PostgreSQL)**:

```
they''re
ain''t ain''t a word
```

### string\_literal[​](#string_literal "Direct link to string_literal")

**Args**:

* `value`: Jinja string value

This macro converts a Jinja string into a SQL string literal.

To cast column values to a string, consider a macro like [safe\_cast](#safe_cast) or an ordinary cast.

**Usage**:

```
select {{ dbt.string_literal("Pennsylvania") }}
```

**Sample Output (PostgreSQL)**:

```
select 'Pennsylvania'
```

## Aggregate and window functions[​](#aggregate-and-window-functions "Direct link to Aggregate and window functions")

### any\_value[​](#any_value "Direct link to any_value")

**Args**:

* `expression`: an [expression](#sql-expressions).

This macro returns some value of the expression from the group. The selected value is non-deterministic (rather than random).

**Usage**:

```
{{ dbt.any_value("column_name") }}
```

**Sample Output (PostgreSQL)**:

```
any(column_name)
```

### bool\_or[​](#bool_or "Direct link to bool_or")

**Args**:

* `expression`: [attribute name or expression](#sql-expressions).

This macro returns the logical `OR` of all non-`NULL` expressions -- `true` if at least one record in the group evaluates to `true`.

**Usage**:

```
{{ dbt.bool_or("boolean_column") }}
{{ dbt.bool_or("integer_column = 3") }}
{{ dbt.bool_or("string_column = 'Pennsylvania'") }}
{{ dbt.bool_or("column1 = column2") }}
```

**Sample Output (PostgreSQL)**:

```
bool_or(boolean_column)
bool_or(integer_column = 3)
bool_or(string_column = 'Pennsylvania')
bool_or(column1 = column2)
```

### listagg[​](#listagg "Direct link to listagg")

**Args**:

* `measure` (required): The [attribute name or expression](#sql-expressions) that determines the values to be concatenated. To only include distinct values add keyword `DISTINCT` to beginning of expression (example: 'DISTINCT column\_to\_agg').
* `delimiter_text` (required): Text representing the delimiter to separate concatenated values by.
* `order_by_clause` (optional): An expression (typically one or more column names separated by commas) that determines the order of the concatenated values.
* `limit_num` (optional): Specifies the maximum number of values to be concatenated.

This macro returns the concatenated input values from a group of rows separated by a specified delimiter.

**Usage**:

Note: If there are instances of `delimiter_text` within your `measure`, you cannot include a `limit_num`.

```
{{ dbt.listagg(measure="column_to_agg", delimiter_text="','", order_by_clause="order by order_by_column", limit_num=10) }}
```

**Sample Output (PostgreSQL)**:

```
array_to_string(
        (array_agg(
            column_to_agg
            order by order_by_column
        ))[1:10],
        ','
        )
```

## Cast functions[​](#cast-functions "Direct link to Cast functions")

### cast[​](#cast "Direct link to cast")

**Availability**:
dbt v1.8 or higher. For more information, select the version from the documentation navigation menu.

**Args**:

* `field`: [attribute name or expression](#sql-expressions).
* `type`: data type to convert to

This macro casts a value to the specified data type. Unlike [safe\_cast](#safe_cast), this macro will raise an error when the cast fails.

**Usage**:

```
{{ dbt.cast("column_1", api.Column.translate_type("string")) }}
{{ dbt.cast("column_2", api.Column.translate_type("integer")) }}
{{ dbt.cast("'2016-03-09'", api.Column.translate_type("date")) }}
```

**Sample Output (PostgreSQL)**:

```
    cast(column_1 as TEXT)
    cast(column_2 as INT)
    cast('2016-03-09' as date)
```

### cast\_bool\_to\_text[​](#cast_bool_to_text "Direct link to cast_bool_to_text")

**Args**:

* `field`: boolean [attribute name or expression](#sql-expressions).

This macro casts a boolean value to a string.

**Usage**:

```
{{ dbt.cast_bool_to_text("boolean_column_name") }}
{{ dbt.cast_bool_to_text("false") }}
{{ dbt.cast_bool_to_text("true") }}
{{ dbt.cast_bool_to_text("0 = 1") }}
{{ dbt.cast_bool_to_text("1 = 1") }}
{{ dbt.cast_bool_to_text("null") }}
```

**Sample Output (PostgreSQL)**:

```
    cast(boolean_column_name as
    varchar
)

    cast(false as
    varchar
)

    cast(true as
    varchar
)

    cast(0 = 1 as
    varchar
)

    cast(1 = 1 as
    varchar
)

    cast(null as
    varchar
)
```

### safe\_cast[​](#safe_cast "Direct link to safe_cast")

**Args**:

* `field`: [attribute name or expression](#sql-expressions).
* `type`: data type to convert to

For databases that support it, this macro will return `NULL` when the cast fails (instead of raising an error).

**Usage**:

```
{{ dbt.safe_cast("column_1", api.Column.translate_type("string")) }}
{{ dbt.safe_cast("column_2", api.Column.translate_type("integer")) }}
{{ dbt.safe_cast("'2016-03-09'", api.Column.translate_type("date")) }}
```

**Sample Output (PostgreSQL)**:

```
    cast(column_1 as TEXT)
    cast(column_2 as INT)
    cast('2016-03-09' as date)
```

## Date and time functions[​](#date-and-time-functions "Direct link to Date and time functions")

### date[​](#date "Direct link to date")

**Availability**:
dbt v1.8 or later. For more information, select the version from the documentation navigation menu.

**Args**:

* `year`: an integer
* `month`: an integer
* `day`: an integer

This macro converts the `year`, `month`, and `day` into an SQL `DATE` type.

**Usage**:

```
{{ dbt.date(2023, 10, 4) }}
```

**Sample output (PostgreSQL)**:

```
to_date('2023-10-04', 'YYYY-MM-DD')
```

### dateadd[​](#dateadd "Direct link to dateadd")

**Args**:

* `datepart`: [date or time part](#date-and-time-parts).
* `interval`: integer count of the `datepart` to add (can be positive or negative)
* `from_date_or_timestamp`: date/time [expression](#sql-expressions).

This macro adds a time/day interval to the supplied date/timestamp. Note: The `datepart` argument is database-specific.

**Usage**:

```
{{ dbt.dateadd(datepart="day", interval=1, from_date_or_timestamp="'2016-03-09'") }}
{{ dbt.dateadd(datepart="month", interval=-2, from_date_or_timestamp="'2016-03-09'") }}
```

**Sample Output (PostgreSQL)**:

```
    '2016-03-09' + ((interval '10 day') * (1))
    '2016-03-09' + ((interval '10 month') * (-2))
```

### datediff[​](#datediff "Direct link to datediff")

**Args**:

* `first_date`: date/time [expression](#sql-expressions).
* `second_date`: date/time [expression](#sql-expressions).
* `datepart`: [date or time part](#date-and-time-parts).

This macro calculates the difference between two dates.

**Usage**:

```
{{ dbt.datediff("column_1", "column_2", "day") }}
{{ dbt.datediff("column", "'2016-03-09'", "month") }}
{{ dbt.datediff("'2016-03-09'", "column", "year") }}
```

**Sample Output (PostgreSQL)**:

```
        ((column_2)::date - (column_1)::date)

        ((date_part('year', ('2016-03-09')::date) - date_part('year', (column)::date))
     * 12 + date_part('month', ('2016-03-09')::date) - date_part('month', (column)::date))

        (date_part('year', (column)::date) - date_part('year', ('2016-03-09')::date))
```

### date\_trunc[​](#date_trunc "Direct link to date_trunc")

**Args**:

* `datepart`: [date or time part](#date-and-time-parts).
* `date`: date/time [expression](#sql-expressions).

This macro truncates / rounds a timestamp to the first instant for the given [date or time part](#date-and-time-parts).

**Usage**:

```
{{ dbt.date_trunc("day", "updated_at") }}
{{ dbt.date_trunc("month", "updated_at") }}
{{ dbt.date_trunc("year", "'2016-03-09'") }}
```

**Sample Output (PostgreSQL)**:

```
date_trunc('day', updated_at)
date_trunc('month', updated_at)
date_trunc('year', '2016-03-09')
```

### last\_day[​](#last_day "Direct link to last_day")

**Args**:

* `date`: date/time [expression](#sql-expressions).
* `datepart`: [date or time part](#date-and-time-parts).

This macro gets the last day for a given date and datepart.

**Usage**:

* The `datepart` argument is database-specific.
* This macro currently only supports dateparts of `month` and `quarter`.

```
{{ dbt.last_day("created_at", "month") }}
{{ dbt.last_day("'2016-03-09'", "year") }}
```

**Sample Output (PostgreSQL)**:

```
cast(
    date_trunc('month', created_at) + ((interval '10 month') * (1))
 + ((interval '10 day') * (-1))
        as date)

cast(
    date_trunc('year', '2016-03-09') + ((interval '10 year') * (1))
 + ((interval '10 day') * (-1))
        as date)
```

## Date and time parts[​](#date-and-time-parts "Direct link to Date and time parts")

Often supported date and time parts (case insensitive):

* `year`
* `quarter`
* `month`
* `week`
* `day`
* `hour`
* `minute`
* `second`
* `millisecond`
* `microsecond`
* `nanosecond`

This listing is not meant to be exhaustive, and some of these date and time parts may not be supported for particular adapters.
Some macros may not support all date and time parts. Some adapters may support more or less precision.

## SQL expressions[​](#sql-expressions "Direct link to SQL expressions")

A SQL expression may take forms like the following:

* function
* column name
* date literal
* string literal
* <other data type> literal (number, etc)
* `NULL`

Example:
Suppose there is an `orders` table with a column named `order_date`. The following shows 3 different types of expressions:

```
select
    date_trunc(month, order_date) as expression_function,
    order_date as expression_column_name,
    '2016-03-09' as expression_date_literal,
    'Pennsylvania' as expression_string_literal,
    3 as expression_number_literal,
    NULL as expression_null,
from orders
```

Note that the string literal example includes single quotes. (Note: the string literal character may vary per database. For this example, we suppose a single quote.) To refer to a SQL string literal in Jinja, surrounding double quotes are required.

So within Jinja, the string values would be:

* `"date_trunc(month, order_date)"`
* `"order_date"`
* `"'2016-03-09'"`
* `"'Pennsylvania'"`
* `"NULL"`

## Was this page helpful?

YesNo

[Privacy policy](https://www.getdbt.com/cloud/privacy-policy)[Create a GitHub issue](https://github.com/dbt-labs/docs.getdbt.com/issues)

This site is protected by reCAPTCHA and the Google [Privacy Policy](https://policies.google.com/privacy) and [Terms of Service](https://policies.google.com/terms) apply.

0

[Previous

config](https://docs.getdbt.com/reference/dbt-jinja-functions/config)[Next

dbt\_project.yml context](https://docs.getdbt.com/reference/dbt-jinja-functions/dbt-project-yml-context)

* [All functions (alphabetical)](#all-functions-alphabetical)* [Data type functions](#data-type-functions)
    + [type\_bigint](#type_bigint)+ [type\_boolean](#type_boolean)+ [type\_float](#type_float)+ [type\_int](#type_int)+ [type\_numeric](#type_numeric)+ [type\_string](#type_string)+ [type\_timestamp](#type_timestamp)+ [current\_timestamp](#current_timestamp)* [Set functions](#set-functions)
      + [except](#except)+ [intersect](#intersect)* [Array functions](#array-functions)
        + [array\_append](#array_append)+ [array\_concat](#array_concat)+ [array\_construct](#array_construct)* [String functions](#string-functions)
          + [concat](#concat)+ [hash](#hash)+ [length](#length)+ [position](#position)+ [replace](#replace)+ [right](#right)+ [split\_part](#split_part)* [String literal functions](#string-literal-functions)
            + [escape\_single\_quotes](#escape_single_quotes)+ [string\_literal](#string_literal)* [Aggregate and window functions](#aggregate-and-window-functions)
              + [any\_value](#any_value)+ [bool\_or](#bool_or)+ [listagg](#listagg)* [Cast functions](#cast-functions)
                + [cast](#cast)+ [cast\_bool\_to\_text](#cast_bool_to_text)+ [safe\_cast](#safe_cast)* [Date and time functions](#date-and-time-functions)
                  + [date](#date)+ [dateadd](#dateadd)+ [datediff](#datediff)+ [date\_trunc](#date_trunc)+ [last\_day](#last_day)* [Date and time parts](#date-and-time-parts)* [SQL expressions](#sql-expressions)

[Edit this page](https://github.com/dbt-labs/docs.getdbt.com/edit/current/website/docs/reference/dbt-jinja-functions/cross-database-macros.md)
