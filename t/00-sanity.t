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
    is $dateA.fmt('---%'  ), '---%',   'Ends on parentheses';
    is $dateA.fmt('---%-' ), '---%-',  'Ends on parentheses and modifier';
    is $dateA.fmt('---%+7'), '---%+7', 'Ends on parentheses, modifier, and width';
    is $dateA.fmt('---%89'), '---%89', 'Ends on parentheses and width';
    is $dateA.fmt('---%q' ), '---%q',  'Ends on parentheses on bad formatter';
}, 'Terminal psuedo-formatters';

# Checks that we properly bail when in the middle of
# a string and have a bad formatting sequence
subtest {
    is $dateA.fmt('---%+--' ), '---%+--', 'Medial parentheses and modifier with no formatter';
    is $dateA.fmt('---%9--' ), '---%9--', 'Medial parentheses and width with no formatter';
    is $dateA.fmt('---%_7-' ), '---%_7-', 'Medial parentheses, modifier, and width with no formatter';
    is $dateA.fmt('---%89-' ), '---%89-', 'Medial parentheses and extended width with no formatter';
    is $dateA.fmt('---%q--' ), '---%q--', 'Medial parentheses and bad formatter';
}, 'Medial psuedo-formatters';

# Checks that each padding type produces correct output
subtest {
    is $dateA.fmt('-%-m' ), '-5',    'Override to no padding';
    is $dateA.fmt('-%0m' ), '-05',   'Redundant override to zero padding';
    is $dateA.fmt('-%_m' ), '- 5',   'Override to space padding';
    is $dateA.fmt('-%_4m'), '-   5', 'Override to space padding, extended width';

}, 'Different padding types';

# Checks that two radically different dates generate correct output
subtest {
        # Has been tested: aA bB cC d e f gG hH I j k lL mM nN pP rR tT w X yY zZ %
        # Needs to be tested D F uU V wW x
        is $dateA.fmt('%a/%A/%b/%B/%h'), 'Sat/Saturday/May/May/May',    'Text day/month formatting (aAbBh-1)';
        is $dateB.fmt('%a/%A/%b/%B/%h'), 'Sun/Sunday/Dec/December/Dec', 'Text day/month formatting (aAbBh-2)';
        is $dateA.fmt('%c'), 'Sat May  6 07:08:09 1234', 'Long pattern expansion (c-1)';
        is $dateB.fmt('%c'), 'Sun Dec 31 14:58:53 9876', 'Long pattern expansion (c-2)';
        is $dateA.fmt('%C/%g/%G/%y/%Y'), '12/12/1234/34/1234', 'Year formatting (CgGyY-1)';
        is $dateB.fmt('%C/%g/%G/%y/%Y'), '98/98/9876/76/9876', 'Year formatting (CgGyY-2)';
        is $dateA.fmt('%d/%e/%j/%u/%w'), '06/ 6/126/6/6', 'Day formatting (dejuw-1)';
        is $dateB.fmt('%d/%e/%j/%u/%w'), '31/31/366/7/0', 'Day formatting (dejuw-2)';
        is $dateA.fmt('%f/%L/%N'), '012346/012/012345678', 'Fractional second formatting (fLN-1)';
        is $dateB.fmt('%f/%L/%N'), '930400/930/930400000', 'Fractional second formatting (fLN-2)';
        is $dateA.fmt('%H/%I/%k/%l'), '07/07/ 7/ 7', 'Hour formatting (HIkl-1)';
        is $dateB.fmt('%H/%I/%k/%l'), '14/02/14/ 2', 'Hour formatting (HIkl-2)';
        is $dateA.fmt('%m'), '05', 'Month formatting (m-1)';
        is $dateB.fmt('%m'), '12', 'Month formatting (m-2)';
        is $dateA.fmt('%M'), '08', 'Minute formatting (M-1)';
        is $dateB.fmt('%M'), '58', 'Minute formatting (M-2)';
        is $dateA.fmt('%p/%P'), 'AM/am', 'AM/PM formatting (pP-1)';
        is $dateB.fmt('%p/%P'), 'PM/pm', 'AM/PM formatting (pP-2)';
        is $dateA.fmt('%s/%S'), '−23215049634/09', 'Seconds formatting (sS-1)';
        is $dateB.fmt('%s/%S'), '249520836842/53', 'Seconds formatting (sS-2)';
        is $dateA.fmt('%D/%F/%x'), '05/06/34/+1234-05-06/05/06/34', 'Combined date formatting (dFx-1)';
        is $dateB.fmt('%D/%F/%x'), '12/31/76/+9876-12-31/12/31/76', 'Combined date formatting (dFx-2)';
        is $dateA.fmt('%r/%R/%T/%X'), '07:08:09 AM/07:08/07:08:09/07:08:09', 'Combined time formatting (rRTX-1)';
        is $dateB.fmt('%r/%R/%T/%X'), '02:58:53 PM/14:58/14:58:53/14:58:53', 'Combined time formatting (rRTX-2)';
        # %Z formatter always generates '', as its data isn't available in core
        is $dateA.fmt('%z/%Z'), '+000203/', 'Time zone formatting (zZ-1)';
        is $dateB.fmt('%z/%Z'), '−003509/', 'Time zone formatting (zZ-2)';

}, 'Formatting codes';

subtest {
    is DateTime.now.fmt(' %n '), " \n ", "Literal newline";
    is DateTime.now.fmt(' %t '), " \t ", "Literal tab";
    is DateTime.now.fmt(' %% '), " % ",  "Literal percent";
}, 'Literal codes';

# Checks that the week numbers and week-years are correct near the new year
# The ISO week and week-year are handled by Raku, but the other styles are
# implemented by the formatters.
subtest {
    # 2021 Test
    # The first Sunday is the
    is 1,1;
}, 'Week/Week-years calculations';

subtest {
    is 1,1;
}, 'Numeric timezone formatting';

done-testing;
