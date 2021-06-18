use DateTimeFmt;

my $dateA = DateTime.new:
        :1234year, :5month, :6day,
        :7hour, :8minute, second => 9.012345678,
        :0123timezone;
my $dateB = DateTime.new:
        :9876year, :12month, :31day,
        :14hour, :58minute, second => 53.9304,
        :0123timezone;
use Test;

# Checks that we properly bail when at the end of
# a string and have a bad formatting sequence
subtest {
    is $dateA.fmt('---%'), '---%';
    is $dateA.fmt('---%-'), '---%-';
    is $dateA.fmt('---%+7'), '---%+7';
    is $dateA.fmt('---%89'), '---%89';
    is $dateA.fmt('---%q'), '---%q';
}, 'Terminal psuedo-formatters';

# Checks that we properly bail when in the middle of
# a string and have a bad formatting sequence
subtest {
    is $dateA.fmt('---%+--'), '---%+--';
    is $dateA.fmt('---%9--'), '---%9--';
    is $dateA.fmt('---%_7-'), '---%_7-';
    is $dateA.fmt('---%89--'), '---%89--';
    is $dateA.fmt('---%q--'), '---%q--';
}, 'Medial psuedo-formatters';

# Checks that each padding type produces correct output
subtest {
    is $dateA.fmt('-%-m'), '-5';
    is $dateA.fmt('-%0m'), '-05';
    is $dateA.fmt('-%_m'), '- 5';
    is $dateA.fmt('-%_4m'), '-   5';

}, 'Different padding types';

# Checks that two radically different dates generate correct output
subtest {
        is $dateA.fmt('%a/%A/%b/%B'), 'Sat/Saturday/May/May';
        is $dateB.fmt('%a/%A/%b/%B'), 'Sun/Sunday/Dec/December';

}, 'Formatting codes';

done-testing;
