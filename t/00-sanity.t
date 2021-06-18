use DateTimeFmt;

my $test = DateTime.now;
use Test;

# Nonsense strings (behavior is undefined, some implementations retain the %, others delete it)
is $test.fmt('---%'), '---';
is $test.fmt('---%-'), '---';
is $test.fmt('---%+7'), '---';

# Different padding  types
is $test.fmt('-%-m'), '-6';
is $test.fmt('-%0m'), '-06';
is $test.fmt('-%_m'), '- 6';
is $test.fmt('-%_4m'), '-   6';


done-testing;
