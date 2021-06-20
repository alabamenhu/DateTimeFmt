### DateTimeFmt

A quick test area for code to be potentially integrated into core's `Datish`.

Currently supports all formatters specified by POSIX.

## Available format codes

| Code   | Function                            | Width | Padding | Source |
|:------:| ----------------------------------- |:-----:|:-------:|:------:|
|  `%a`  | name of day (abbreviated)           |     0 |    none | POSIX✧ |
|  `%A`  | name of day                         |     0 |    none | POSIX✧ |
|  `%b`  | name of month (abbreviated)         |     0 |    none | POSIX✧ |
|  `%B`  | name of month                       |     0 |    none | POSIX✧ |
|  `%c`  | short for `%a %b %e %H:%M:%S %Y`    |     0 |    none | POSIX✧ |
|  `%C`  | century                             |     2 |   zeros | POSIX  |
|  `%d`  | short for `%m/%d/%y`                |     0 |   zeros | POSIX  |
|  `%e`  | day of month                        |     2 |  spaces | POSIX  |
|  `%f`  | microseconds                        |     6 |   zeros | Python | 
|  `%F`  | short for `%+4Y-%m-%d`              |     0 |    none | POSIX  |
|  `%g`  | last two digits of week-year        |     2 |   zeros | POSIX  | 
|  `%G`  | week-year                           |     4 |   zeros | POSIX  | 
|  `%h`  | abbr. name of month, alias of `%b`  |     0 |    none | POSIX✧ |
|  `%H`  | Hour (0–23 based)                   |     2 |   zeros | POSIX  |           
|  `%I`  | Hour (1–12 based)                   |     2 |   zeros | POSIX  |   
|  `%j`  | day of year (1–366)                 |     3 |   zeros | POSIX  |   
|  `%k`  | Hour (0–23 based)                   |     2 |  spaces | GNU/Ruby/Perl |           
|  `%l`  | Hour (1–12 based)                   |     2 |  spaces | GNU/Ruby/Perl |   
|  `%L`  | milliseconds                        |     6 |   zeros | Perl   |   
|  `%m`  | month (1–12)                        |     2 |   zeros | POSIX  |           
|  `%M`  | minute (0–60)                       |     2 |   zeros | POSIX  |   
|  `%n`  | literal newline                     |     0 |    none | POSIX  |   
|  `%N`  | fractional seconds (precision=width)|     9 |    none | Perl   |   
|  `%p`  | AM/PM                               |     2 |    none | POSIX  |   
|  `%P`  | am/pm                               |     2 |    none | Ruby   |   
|  `%r`  | short for `%I:%M:%S %p`             |     0 |    none | POSIX✧ |
|  `%R`  | short for `%H:%M`                   |     0 |    none | GNU    |
|  `%s`  | seconds since UNIX epoch            |     0 |    none | GNU    |
|  `%S`  | seconds (0–61)                      |     2 |   zeros | POSIX  |
|  `%t`  | literal tab                         |     0 |    none | POSIX  |   
|  `%T`  | short for `%H:%M:%S`                |     0 |    none | POSIX  |
|  `%u`  | weekday (1–7, Monday = 1)           |     0 |    none | POSIX  |   
|  `%U`  | week (0–53, Sunday-based, 1<sup>st</sup> Sun. = 1)| 0 | none | POSIX |   
|  `%V`  | week (1–53, Monday-based, 1<sup>st</sup> Thu. = 1)| 0 | none | POSIX |   
|  `%w`  | weekday (0–6, Sunday = 0)           |     0 |    none | POSIX  |   
|  `%W`  | week (0–53, Monday-based, 1<sup>st</sup> Mon. = 1)| 0 | none | POSIX |   
|  `%x`  | short for `%m/%d/%y`                |     0 |    none | POSIX✧ |   
|  `%X`  | short for `%H:%M:%S`                |     0 |    none | POSIX✧ |   
|  `%Y`  | year                                |     4 |    zero | POSIX  |   
|  `%y`  | year (last two digits)              |     2 |    zero | POSIX  |   
|  `%z`  | UTC-style timezone offset           |     4 |    zero | POSIX  |   
|  `%Z`  | Timezone (or blank if unavailable)  |     4 |    zero | POSIX  |   
|  `%+`  | short for `%a %b %e %H:%M:%S %Z %Y` |     0 |    zero | POSIX  |   
|  `%%`  | literal percent                     |     0 |    zero | POSIX  |   

Sources indicated with a **✧** are locale-based ones, and are fixed as they exclusively use the POSIX locale.
The style `%+` is seen in some implementations (Android, Apple, GNU), which conflicts with the POSIX modifier `+`.  It can only be obtained by way of some other modifier, like `%-+`.

## Formatting flags

| Flag | Effect                                                                         |
|:----:|:------------------------------------------------------------------------------ |
| `0`  | Pad to minimum width with zeros                                                |
| `_`  | Pad to minimum width with spaces                                               |
| `+`  | Add a `+` if longer than minimum width, and `−`<sub>(U+2212)</sub> if negative |
| `-`  | Do not pad (overrides minimum width to `0`)                                    |
| `^`  | Uppercase (overrides minimum width to `0`)                                     |
| `#`  | Lowercase (overrides minimum width to `0`)|

Only `0` and `+` are specified in POSIX, but the others are quite common in different implementations. `#` is generally a context-sensitive one, but we generalize it to lowercase.

## Modifiers

| Flag | Effect                                           |
|:----:|:------------------------------------------------ |
| `E`  | Use locale-specified variations (ignored)        |
| `O`  | Use locale-specified, numbering system (ignored) |

Modifiers are ignored because we assume the POSIX locale (effectively equivalent to `en-US`).

## Implementation notes

Per the POSIX standard for `strftime` (upon which this is based)

> The results are unspecified if more than one flag character is specified, a flag character is specified without a minimum field width; a minimum field width is specified without a flag character; a modifier is specified with a flag or with a minimum field width; or if a minimum field width is specified for any conversion specifier other than C, F, G, or Y

Many implementations have come to a consensus (for ease of implementation) that the flags, minimum widths, and modifiers are all independently set, and each conversion specifier has a sort of "default" flag/width.  This is the approach used and default values are indicated in the table.

Because `Z` requires access to the timezone abbreviation (which neither `DateTime` nor `$*TZ` provide), `Z` requests `.tz-abbr` available in `DateTime::Timezones`.  Per the standard, if unavailable, it results in blank output.  This is questionable behavior, though, as Raku doesn't define a named timezone interface at all.  As `DateTime::Timezones` uses an `IntStr` for `.timezone`, it could try a heuristic to know if formatting should follow UTC-style ±0000 format or use a string (AFAICT, using `New York/America` would be POSIX-compliant)