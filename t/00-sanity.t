use DateTimeFmt;

my $test = DateTime.now;
use Test;

# nonsense strings
#is $test.fmt('---%'), '---';
#is $test.fmt('---%-'), '---';
#is $test.fmt('---%+7'), '---';

#is $test.fmt('-%-m'), '-6';
#is $test.fmt('-%0m'), '-06';
#is $test.fmt('-%_m'), '- 6';
#is $test.fmt('-%_4m'), '-   6';
my $a = now;
for ^1000 { sink $test.&fmt('%a %b %e %H:%M:%S %Y') };
say now - $a;

my $b = now;
for ^1000 { sink $test.Str }
say now - $b;
my $c = now;
for ^1000 { sink $test.&fmt('%a %b %e %H:%M:%S %Y') };
say now - $c;
my $d = now;
for ^1000 { sink $test.Str }
say now - $d;
my $e = now;
for ^1000 { sink $test.&{.day ~ ' ' ~ .month ~ ' ' ~ .year ~ ' ' ~ .hour ~ ' ' ~ .minute ~ ' ' ~ .week ~ ' ' ~ .week} }
say now - $e;


done-testing;
