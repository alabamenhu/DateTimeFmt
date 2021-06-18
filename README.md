### DateTimeFmt

A quick test area for code to be potentially integrated into core's `Datish`.

Currently supports all formatters specified by POSIX.  It only uses the default POSIX locale, so modifiers `O` and `E` are parsed but effectively ignored.

In addition to POSIX formatters, also supports padding and width extensions, as well as formatters `%k` (alias of `%_H`), `%l` (alias of `%_I`), `%f` (microseconds), and `%N` (deciseconds to femtoseconds and smaller).  The latter requires special casing due to its unique nature.

Because `Z` requires access to the timezone abbreviation (which neither `DateTime` nor `$*TZ` provide), `Z` requests `.tz-abbr` available in `DateTime::Timezones`.  Per the standard, if unavailable, it results in blank output.