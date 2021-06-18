unit module DateTimeFmt;
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/date.html
use nqp;

my int constant PAD-SPACE  = 0;
my int constant PAD-ZERO   = 1;
my int constant PAD-PLUS   = 2;
my int constant NO-PAD     = 3;
my int constant UPPERCASE  = 4;
my int constant LOWERCASE  = 5;
my int constant LOCAL-E    = 6;
my int constant LOCAL-O    = 7;

# Strings needed for day/month formatting
#my constant a_fmt = nqp::list('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat','Sun');
my constant a_fmt = nqp::list('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday','Sunday');
#my constant b_fmt = nqp::list('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
my constant b_fmt = nqp::list('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September',
                           'October', 'November', 'December');
constant modifiers = nqp::hash('0', PAD-ZERO, '_', PAD-SPACE, '+', PAD-PLUS, '-', NO-PAD, '^', UPPERCASE, '#', LOWERCASE);
# Needs to be done matching a string in case of a combining character like 2̃
# Side effect: easier value calculation
constant padding = nqp::hash('0', 0, '1', 1, '2', 2, '3', 3, '4', 4, '5', 5, '6', 6, '7', 7, '8', 8, '9', 9);

# Helper sub that handles padding and transformations.
sub inner-fmt(str $text, int $modifier, int $padding) {
    nqp::iseq_i($modifier, NO-PAD)
        ?? $text
        !! nqp::iseq_i($modifier, PAD-ZERO)
            ?? nqp::stmts(
                    (my int $pad-width = nqp::sub_i($padding,nqp::chars($text))),
                    nqp::concat(nqp::x('0',nqp::if(nqp::islt_i($pad-width,0),0,$pad-width)), $text))
            !! nqp::iseq_i($modifier, PAD-SPACE)
                ?? nqp::stmts(
                        ($pad-width = nqp::sub_i($padding,nqp::chars($text))),
                        nqp::concat(nqp::x(' ',nqp::if(nqp::islt_i($pad-width,0),0,$pad-width)), $text))
                !! nqp::iseq_i($modifier, PAD-PLUS)
                    ?? nqp::concat(nqp::if(nqp::islt_i(nqp::chars($text),4),'','+'), $text)
                    !! nqp::iseq_i($modifier, UPPERCASE)
                        ?? nqp::uc($text)
                        !! nqp::iseq_i($modifier, LOWERCASE)
                            ?? nqp::lc($text)
                            !! '' # return blank if bad modifier
}
# Nano is not a POSIX one, but is a common extension found.
# Its formatting is done radically different from others.
sub fmt-nano(DateTime $d, int $width) {
    my num $s = $d.?second // 0;
    nqp::substr(
        nqp::sprintf(
            nqp::join('',nqp::list('%.',nqp::coerce_is($width),'f')),
            nqp::list(nqp::sub_n($s,nqp::floor_n($s)))),
        2,
        $width)
}

# The default widths here mostly follow what everyone else does.
# Default padding is always zero, unless specified differently by the formatter
# Check that negative years format correctly
my constant formats = nqp::hash(
    'a', nqp::list( NO-PAD,    0, { nqp::without(nqp::substr(nqp::atpos(a_fmt, nqp::sub_i(nqp::unbox_i(.day-of-week), 1)),0,3),'') } ),
    'A', nqp::list( NO-PAD,    0, { nqp::without(nqp::atpos(a_fmt, nqp::sub_i(nqp::unbox_i(.day-of-week), 1)),'') } ),
    'b', nqp::list( NO-PAD,    0, { nqp::without(nqp::substr(nqp::atpos(b_fmt, nqp::sub_i(nqp::unbox_i(.month), 1)),0,3),'') } ),
    'B', nqp::list( NO-PAD,    0, { nqp::without(nqp::atpos(b_fmt, nqp::sub_i(nqp::unbox_i(.month), 1)),'') } ),
    'c', nqp::list( NO-PAD,    0, *.fmt('%a %b %e %H:%M:%S %Y') ),
    'C', nqp::list( PAD-ZERO,  2, { nqp::coerce_is(nqp::div_i(nqp::unbox_i(.year),100)) } ),
    'd', nqp::list( PAD-ZERO,  2, *.day.Str ),
    'D', nqp::list( NO-PAD,    0, *.fmt('%m/%d/%y') ),
    'e', nqp::list( PAD-SPACE, 2, *.day.Str ),
    # Mainly defined in Python's, explicitly defined as microseconds that are left padded.
    # We use 'f' as perl uses 'F' for a different one
    'f', nqp::list( PAD-ZERO,  6, { my $s := *.second; nqp::sprintf('%0.0f',nqp::mul_n(nqp::sub_n($s,nqp::floor_n($s)),1000000)) }),
    'F', nqp::list( NO-PAD,    0, *.fmt('%+4Y-%m-%d') ),
    # g/G are non-POSIX
    'g', nqp::list( PAD-SPACE, 2, { nqp::coerce_is(nqp::div_i(nqp::unbox_i(*.week-year),100)) } ),
    'G', nqp::list( PAD-SPACE, 2, *.week-year.Str ),
    'h', nqp::list( NO-PAD,    0, { nqp::without(nqp::atpos(b_fmt, nqp::sub_i(nqp::unbox_i(.month), 1)),'') } ),
    'H', nqp::list( PAD-ZERO,  2, { nqp::stmts( (my $h := nqp::without(.?hour,0,.hour)),nqp::coerce_is($h))}),
    'I', nqp::list( PAD-ZERO,  2, { nqp::stmts( (my $h := nqp::mod_i(nqp::without(.?hour,0,.hour),12)),nqp::coerce_is($h ?? $h !! 12))}),
    'j', nqp::list( PAD-ZERO,  3, *.day-of-year.Str ),
    # k and l are non-POSIX but common
    'k', nqp::list( PAD-SPACE, 2, { nqp::stmts( (my $h := nqp::without(.?hour,0,.hour)),nqp::coerce_is($h))}),
    'l', nqp::list( PAD-SPACE, 2, { nqp::stmts( (my $h := nqp::mod_i(nqp::without(.?hour,0,.hour),12)),nqp::coerce_is($h ?? $h !! 12))}),
    # Ruby (and a few others) use L for mi*LL*iseconds
    'L', nqp::list( PAD-ZERO,  6, { my $s := *.second; nqp::sprintf('%0.0f',nqp::mul_n(nqp::sub_n($s,nqp::floor_n($s)),1000)) }),
    'm', nqp::list( PAD-ZERO,  2, *.month.Str ),
    'M', nqp::list( PAD-ZERO,  2, { nqp::stmts((my $m := nqp::without(.?minute,0,.minute)),nqp::coerce_is($m))}),
    'n', nqp::list( PAD-ZERO,  2, {"\n"} ),
    #'N' is special cased, because the width functions as a max, rather than a minimum width
    'p', nqp::list( PAD-ZERO,  2, { nqp::stmts((my $h := nqp::without(.?hour,0,.hour)),(nqp::islt_i($h,12) ?? 'AM' !! 'PM'))}),
    # Not POSIX, but common
    'P', nqp::list( PAD-ZERO,  2, { nqp::stmts((my $h := nqp::without(.?hour,0,.hour)),(nqp::islt_i($h,12) ?? 'am' !! 'pm'))}),
    'r', nqp::list( NO-PAD,    0, *.fmt('%I:%M:%S %p') ),
    # Not POSIX, but common
    'R', nqp::list( NO-PAD,    0, *.fmt('%H:%M') ),
    'S', nqp::list( PAD-ZERO,  2, { nqp::stmts((my $s := nqp::without(.?second,0,.second)),nqp::coerce_is(nqp::coerce_ni($s)))}),
    't', nqp::list( NO-PAD,    0, {"\t"} ),
    'T', nqp::list( NO-PAD,    0, *.fmt('%H:%M:%S') ),
    'u', nqp::list( PAD-ZERO,  2, { nqp::coerce_is(.day-of-week) }),
    'U', nqp::list( PAD-ZERO,  2, { nqp::coerce_is(nqp::div_i(nqp::sub_i(nqp::add_i(.day-of-year,6),nqp::mod_i(.day-of-week,7)),7))  }),
    'V', nqp::list( PAD-ZERO,  2, { nqp::coerce_is(.week-number) }),
    'w', nqp::list( PAD-ZERO,  2, { nqp::coerce_is(nqp::mod_i(.day-of-week,7)) }),
    'W', nqp::list( PAD-ZERO,  2, { nqp::coerce_is(nqp::div_i(nqp::sub_i(nqp::add_i(.day-of-year,6),nqp::mod_i(nqp::add_i(.day-of-week,6),7)),7))  }),
    'x', nqp::list( NO-PAD,    0, *.fmt('%m/%d/%y') ),
    'X', nqp::list( NO-PAD,    0, *.fmt('%H:%M:%S') ),
    'y', nqp::list( PAD-ZERO,  2, { nqp::coerce_is(nqp::mod_i(.year,100)) }),
    'Y', nqp::list( PAD-ZERO,  4, *.year.Str ),
    'Z', nqp::list( NO-PAD,    0, { nqp::without(.?tz-abbr,'',.tz-abbr)}),
    '%', nqp::list( NO-PAD,    0, {'%'} ),
    # Not POSIX, but common
    '+', nqp::list( NO-PAD,    0, *.fmt('%a %b %e %H:%M:%S %Z %Y') )
);

my method fmt ($in) is export {
    my str $fmt-str = nqp::unbox_s($in);
    my int $pos = 0;
    my     $out := nqp::list_s();
    my int $max = nqp::chars($fmt-str);

    while nqp::isne_i(-1,(my int $new = nqp::index($fmt-str,'%',$pos))) {
        my int $modifier = -1;
        my int $width    = -1;
        my str $char;
        #my int $local    = -1; unused in current implementation, see note below when parsing

        # Add the literal text up to the '%'
        nqp::push_s($out,nqp::substr($fmt-str, $pos, $new - $pos));
        $pos = $new;     # Move up $pos, but advance our temporary location
        $new = $new + 1; # Advance temporary

        # Check that we can get another character, and then see if it's a modifier
        nqp::if(nqp::islt_i($new, $max),
            nqp::stmts(
                # We can
                ($char = nqp::substr($fmt-str, $new, 1)),
                nqp::if(nqp::existskey(modifiers, $char),
                    # It is a modifier
                    nqp::stmts(
                        ($modifier = nqp::atkey(modifiers, $char)),
                        ($new = nqp::add_i($new, 1)),
                        (nqp::isge_i($new, $max)
                                ?? (nqp::null)
                                !! ($char = nqp::substr($fmt-str,$new,1)))))));

        # Check if there's a padding value, double check end of string
        nqp::if(nqp::islt_i($new,$max),
            nqp::stmts(
                ($char = nqp::substr($fmt-str, $new, 1)),
                nqp::if(nqp::existskey(padding, $char),
                    nqp::stmts(
                        ($width = nqp::atkey(padding, $char)),
                        ($new = nqp::add_i($new,1)),
                        nqp::while(
                            nqp::stmts(
                                ($char = nqp::substr($fmt-str,$new,1)),
                                nqp::existskey(padding, $char)),
                            nqp::stmts(
                                ($width = nqp::mul_i($width,10)),
                                ($width = nqp::add_i($width,nqp::atkey(padding, $char))),
                                ($new = nqp::add_i($new,1))))))));

        # POSIX/C provide for localized versions formatters, indicated
        # by the prefix of an E or an O.  We only provide the POSIX locale,
        # so we just parse past it if we find it.
        nqp::if(nqp::islt_i($new,$max),
            nqp::stmts(
                ($char = nqp::substr($fmt-str, $new, 1)),
                nqp::if(nqp::iseq_s($char,'E'),
                    nqp::stmts(
                        ($new = nqp::add_i($new,1)),
                        #`[($local = LOCAL-E)]),
                    nqp::if(nqp::iseq_s($char,'O'),
                        nqp::stmts(
                            ($new = nqp::add_i($new,1)),
                            #`[($local = LOCAL-O)])))));

        nqp::if(nqp::islt_i($new,$max),
            nqp::stmts(
                ($char = nqp::substr($fmt-str, $new, 1)),
                nqp::if(nqp::existskey(formats, $char),
                    nqp::stmts(
                        (my $format := nqp::atkey(formats,$char)),
                        nqp::if(nqp::iseq_i($modifier,-1),($modifier = nqp::atpos($format,0))),
                        nqp::if(nqp::iseq_i($width,   -1),($width    = nqp::atpos($format,1))),
                        nqp::push_s(
                            $out,
                            nqp::call(
                                nqp::getlex('&inner-fmt'), # this sub could be manually inlined here
                                nqp::call(nqp::atpos($format,2),self),
                                $modifier,
                                $width)),
                        ($new = nqp::add_i($new,1))),
                    nqp::if(nqp::iseq_s($char,'N'),
                        nqp::stmts( # Special case fractional seconds because they format differently
                            nqp::say("is equal to N?"),
                            nqp::push_s(
                                $out,
                                nqp::call(
                                    nqp::getlex('&fmt-nano'),
                                    self,
                                    (nqp::iseq_i($width,-1),9,$width))), # default to 9 for *n*anoseconds
                            ($new = nqp::add_i($new,1))),
                        # Bad format.  POSIX/ISO C lists as undefined behavior.
                        # Implementations are split on how to best handle this.
                        # Some include the %, some only the text after it.
                        # I've seen several justifications for both, but most convincing
                        # to me is that if someone unintentionally has a bad format, the
                        # presence of a % indicates a syntax error.  A % that was
                        # mistakenly not escaped will still display as (likely) intended.
                        nqp::push_s($out,nqp::substr($fmt-str,$pos, nqp::sub_i($new,$pos)))))),
            nqp::push_s($out,nqp::substr($fmt-str, $pos)));
        $pos = $new;
    };

    # Add the rest of the format string if we are not at the end.
    nqp::if(
        nqp::isne_i(nqp::chars($fmt-str),$pos),
        nqp::push_s($out, nqp::substr($fmt-str, $pos))
    );
    nqp::join('',$out);
}

Date.^add_fallback:
        anon sub ($,$name) { $name eq 'fmt' },
        anon sub ($,$) { &fmt };


DateTime.^add_fallback:
        anon sub ($,$name) { $name eq 'fmt' },
        anon sub ($,$) { &fmt };

