# This file is encoded in UTF-2.
die "This file is not encoded in UTF-2.\n" if q{あ} ne "\xe3\x81\x82";

use UTF2;
print "1..1\n";

my $__FILE__ = __FILE__;

$a = "ソアア";
if ($a =~ s/^ソ//) {
    print qq{ok - 1 "ソアア" =~ s/^ソ// $^X $__FILE__\n};
}
else {
    print qq{not ok - 1 "ソアア" =~ s/^ソ// $^X $__FILE__\n};
}

__END__
