# This file is encoded in UTF-2.
die "This file is not encoded in UTF-2.\n" if q{あ} ne "\xe3\x81\x82";

my $__FILE__ = __FILE__;

use UTF2;
print "1..1\n";

if ($^O !~ /\A (?: MSWin32 | NetWare | symbian | dos ) \z/oxms) {
    print "ok - 1 # SKIP $^X $0\n";
    exit;
}

open(FILE,'>F機能') || die "Can't open file: F機能\n";
print FILE "1\n";
close(FILE);

# utime
if (utime(time(),time(),'F機能')) {
    print "ok - 1 utime $^X $__FILE__\n";
}
else {
    print "not ok - 1 utime: $! $^X $__FILE__\n";
}

unlink('F機能');

__END__
