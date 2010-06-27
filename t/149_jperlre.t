# This file is encoded in UTF-2.
die "This file is not encoded in UTF-2.\n" if q{あ} ne "\xe3\x81\x82";

use UTF2;
print "1..1\n";

eval q< '-' =~ /(あ[い-あ])/ >;
if ($@) {
    print "ok - 1 $^X 149_jperlre.t die ('-' =~ /あ[い-あ]/).\n";
}
else {
    print "not ok - 1 $^X 149_jperlre.t die ('-' =~ /あ[い-あ]/).\n";
}

__END__
