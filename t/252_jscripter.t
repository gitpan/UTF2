# This file is encoded in UTF-2.
die "This file is not encoded in UTF-2.\n" if q{あ} ne "\xe3\x81\x82";

# use strict;
use UTF2;
print "1..1\n";

my $__FILE__ = __FILE__;

my $a = 'aaa_123_bbb_456_c_7_dd_89';
$a =~ s/[a-z]+_([0-9]+)/$1/g;
if ($a eq '123_456_7_89') {
    print "ok - 1 s///g (without 'use strict') ($a) $^X $__FILE__\n";
}
else {
    print "not ok - 1 s///g (without 'use strict') ($a) $^X $__FILE__\n";
}

__END__
