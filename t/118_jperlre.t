# This file is encoded in UTF-2.
die "This file is not encoded in UTF-2.\n" if q{あ} ne "\xe3\x81\x82";

use UTF2;
print "1..1\n";

my $__FILE__ = __FILE__;

if ('あいq' =~ /(あい{1,}いう)/) {
    print "not ok - 1 $^X $__FILE__ not ('あいq' =~ /あい{1,}いう/).\n";
}
else {
    print "ok - 1 $^X $__FILE__ not ('あいq' =~ /あい{1,}いう/).\n";
}

__END__
