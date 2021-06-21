use DateTimeFmt;

my $dateA = DateTime.new:
        :1234year, :5month, :6day,
        :7hour, :8minute, second => 9.012345678,
        :0123timezone;
my $dateB = DateTime.new:
        :9876year, :12month, :31day,
        :14hour, :58minute, second => 53.9304,
        :timezone(-2109);
use Test;

# Checks that we properly bail when at the end of
# a string and have a bad formatting sequence
subtest {
    is $dateA.fmt('……%'  ), '……%',   'Ends on percent';
    is $dateA.fmt('……%-' ), '……%-',  'Ends on percent and modifier';
    is $dateA.fmt('……%+7'), '……%+7', 'Ends on percent, modifier, and width';
    is $dateA.fmt('……%89'), '……%89', 'Ends on percent and width';
    is $dateA.fmt('……%q' ), '……%q',  'Ends on percent on bad formatter';
}, 'Terminal psuedo-formatters';

# Checks that we properly bail when in the middle of
# a string and have a bad formatting sequence
subtest {
    is $dateA.fmt('……%+……' ), '……%+……', 'Medial percent and modifier with no formatter';
    is $dateA.fmt('……%9……' ), '……%9……', 'Medial percent and width with no formatter';
    is $dateA.fmt('……%_7…' ), '……%_7…', 'Medial percent, modifier, and width with no formatter';
    is $dateA.fmt('……%89…' ), '……%89…', 'Medial percent and extended width with no formatter';
    is $dateA.fmt('……%q……' ), '……%q……', 'Medial percent and bad formatter';
}, 'Medial psuedo-formatters';

# Checks that each padding type produces correct output
subtest {
    is $dateA.fmt('……%-m……' ), '……5……',    'Override to no padding';
    is $dateA.fmt('……%-5m……'), '……5……',    'Override to no padding, ignore extended width';
    is $dateA.fmt('……%0m……' ), '……05……',   'Redundant override to zero padding';
    is $dateA.fmt('……%04m……'), '……0005……', 'Extended width zero padding';
    is $dateA.fmt('……%_m……' ), '…… 5……',   'Override to space padding';
    is $dateA.fmt('……%_4m……'), '……   5……', 'Override to space padding, extended width';
    is $dateA.fmt('……%^a……' ), '……SAT……',  'Override to uppercase';
    is $dateA.fmt('……%^5a……'), '……SAT……',  'Override to uppercase, ignore extended width';
    is $dateA.fmt('……%#a……' ), '……sat……',  'Override to uppercase';
    is $dateA.fmt('……%#5a……'), '……sat……',  'Override to uppercase, ignore extended width';
    is $dateA.fmt('……%+4Y……'), '……1234……', 'Year within minimum width';
    is $dateA.fmt('……%+3Y……'), '……+1234……','Year beyond minimum width';

}, 'Different padding types';

# Checks that two radically different dates generate correct output
subtest {
        is $dateA.fmt('%a…%A…%b…%B…%h'), 'Sat…Saturday…May…May…May',    'Text day/month formatting (aAbBh-1)';
        is $dateB.fmt('%a…%A…%b…%B…%h'), 'Sun…Sunday…Dec…December…Dec', 'Text day/month formatting (aAbBh-2)';
        is $dateA.fmt('%c'), 'Sat May  6 07:08:09 1234', 'Long pattern expansion (c-1)';
        is $dateB.fmt('%c'), 'Sun Dec 31 14:58:53 9876', 'Long pattern expansion (c-2)';
        is $dateA.fmt('%C…%g…%G…%y…%Y'), '12…34…1234…34…1234', 'Year formatting (CgGyY-1)';
        is $dateB.fmt('%C…%g…%G…%y…%Y'), '98…76…9876…76…9876', 'Year formatting (CgGyY-2)';
        is $dateA.fmt('%d…%e…%j…%u…%w'), '06… 6…126…6…6', 'Day formatting (dejuw-1)';
        is $dateB.fmt('%d…%e…%j…%u…%w'), '31…31…366…7…0', 'Day formatting (dejuw-2)';
        is $dateA.fmt('%D…%F…%x'), '05/06/34…1234-05-06…05/06/34', 'Combined date formatting (dFx-1)';
        is $dateB.fmt('%D…%F…%x'), '12/31/76…9876-12-31…12/31/76', 'Combined date formatting (dFx-2)';
        is $dateA.fmt('%f…%L…%N'), '012346…012…012345678', 'Fractional second formatting (fLN-1)';
        is $dateB.fmt('%f…%L…%N'), '930400…930…930400000', 'Fractional second formatting (fLN-2)';
        is $dateA.fmt('%H…%I…%k…%l'), '07…07… 7… 7', 'Hour formatting (HIkl-1)';
        is $dateB.fmt('%H…%I…%k…%l'), '14…02…14… 2', 'Hour formatting (HIkl-2)';
        is $dateA.fmt('%m'), '05', 'Month formatting (m-1)';
        is $dateB.fmt('%m'), '12', 'Month formatting (m-2)';
        is $dateA.fmt('%M'), '08', 'Minute formatting (M-1)';
        is $dateB.fmt('%M'), '58', 'Minute formatting (M-2)';
        is $dateA.fmt('%p…%P'), 'AM…am', 'AM/PM formatting (pP-1)';
        is $dateB.fmt('%p…%P'), 'PM…pm', 'AM/PM formatting (pP-2)';
        is $dateA.fmt('%r…%R…%T…%X'), '07:08:09 AM…07:08…07:08:09…07:08:09', 'Combined time formatting (rRTX-1)';
        is $dateB.fmt('%r…%R…%T…%X'), '02:58:53 PM…14:58…14:58:53…14:58:53', 'Combined time formatting (rRTX-2)';
        is $dateA.fmt('%s…%S'), '-23215049634…09', 'Seconds formatting (sS-1)';
        is $dateB.fmt('%s…%S'), '249520836842…53', 'Seconds formatting (sS-2)';
        is $dateA.fmt('%u…%w'), '6…6', 'Weekday numeric formatting (uw-1)';
        is $dateB.fmt('%u…%w'), '7…0', 'Weekday numeric formatting (uw-2)';
        # %Z formatter always generates '', as its data isn't available in core
        # %z should *not* generate seconds, although some implementations do.
        is $dateA.fmt('%z…%Z'), '+0002…', 'Time zone formatting (zZ-1)';
        is $dateB.fmt('%z…%Z'), '-0035…', 'Time zone formatting (zZ-2)';

}, 'Formatting codes';

subtest {
    is DateTime.now.fmt('…%n…'),  "…\n…", "Literal newline";
    is DateTime.now.fmt('…%t…'),  "…\t…", "Literal tab";
    is DateTime.now.fmt('…%%…'),  "…%…",  "Literal percent";
    is DateTime.now.fmt('…%%n…'), "…%n…", "Literal percent next to format code";
}, 'Literal codes';

# Checks that the week numbers and week-years are correct near the new year
# The ISO week and week-year are handled by Raku, but the other styles are
# implemented by the formatters.
#   %g =  Same as %G, but just the last two digits (used in tests below)
#   %G = “Replaced by the week-based year (see below) as a decimal number.”
#         (the “see below” indicates it follows ISO, so it tracks %V)
#   %U = “Week of the year (Sunday as the first day of the week) as a
#         decimal number [00,53]. All days in a new year preceding the
#         first Sunday shall be considered to be in week 0.”
#   %V = “Week of the year (Monday as the first day of the week) as a
#         decimal number [01,53]. If the week containing January 1 has
#         four or more days in the new year, then it shall be considered
#         week 1; otherwise, it shall be the last week of the previous year,
#         and the next week shall be week 1.”
#   %W = “Week of the year (Monday as the first day of the week) as a
#         decimal number [00,53]. All days in a new year preceding the
#         first Monday shall be considered to be in week 0.”
subtest {
    my @dates2021 =
        Date.new(:2020year, :12month, :29day),
        Date.new(:2020year, :12month, :30day),
        Date.new(:2020year, :12month, :31day),
        Date.new(:2021year,  :1month,  :1day),
        Date.new(:2021year,  :1month,  :2day),
        Date.new(:2021year,  :1month,  :3day),
        Date.new(:2021year,  :1month,  :4day),
        Date.new(:2021year,  :1month,  :5day);
    is @dates2021.map(*.fmt: '%U').join('…'), '52…52…52…00…00…01…01…01',
        'First Sunday starts first week (U-1)';
    is @dates2021.map(*.fmt: '%W').join('…'), '52…52…52…00…00…00…01…01',
        'First Monday starts first week (W-1)';
    is @dates2021.map(*.fmt: '%g').join('…'), '20…20…20…20…20…20…21…21',
        'Years for Jan. 1, week with less than 4 days, Monday start (g-1)';
    is @dates2021.map(*.fmt: '%V').join('…'), '53…53…53…53…53…53…01…01',
        'January 1 in a week with less than 4 days, Monday start (V-1)';

    my @dates0102 =
        Date.new(:2001year, :12month, :29day),
        Date.new(:2001year, :12month, :30day),
        Date.new(:2001year, :12month, :31day),
        Date.new(:2002year,  :1month,  :1day),
        Date.new(:2002year,  :1month,  :2day),
        Date.new(:2002year,  :1month,  :3day),
        Date.new(:2002year,  :1month,  :4day),
        Date.new(:2002year,  :1month,  :5day);
    is @dates0102.map(*.fmt: '%g').join('/'), '01/01/02/02/02/02/02/02',
        'Years for Jan. 1, week with more than 4 days, Monday start (g-2)';
    is @dates0102.map(*.fmt: '%V').join('/'), '52/52/01/01/01/01/01/01',
        'January 1 in a week with more than 4 days, Monday start (V-2)';
    is @dates0102.map(*.fmt: '%U').join('/'), '51/52/52/00/00/00/00/00',
        'First Sunday starts first week (U-2)';
    is @dates0102.map(*.fmt: '%W').join('/'), '52/52/53/00/00/00/00/00',
        'First Monday starts first week (W-2)';

}, 'Week/Week-years calculations';

# DateTime provides the .timezone and .offset values.
# .offset should *always* produce an integer.
# I propose allowing .timezone to give an IntStr, where
# .timezone.Int provides the offset, and .timezone.Str
# could, but would not be required to, give a timezone
# name, without any requirement of format.
subtest {
    my $dateA = DateTime.now.clone:
        timezone => IntStr.new(-14400, 'America/New_York');
    my $dateB = DateTime.now.clone:
        timezone => Int.new(3600);

    # If IntStr were allowed
    # is $dateA.fmt('%z %Z'), '-0400…America/New_York';
    # But it's not, so…
    is $dateA.fmt('%z…%Z'), '-0400…';
    is $dateB.fmt('%z…%Z'), '+0100…';

}, 'Timezone formatting';

done-testing;
