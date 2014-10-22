# This file is encoded in UTF-2.
die "This file is not encoded in UTF-2.\n" if q{あ} ne "\xe3\x81\x82";

my $__FILE__ = __FILE__;

use UTF2;
print "1..2\n";

if ($^O !~ /\A (?: MSWin32 | NetWare | symbian | dos ) \z/oxms) {
    print "ok - 1 # SKIP $^X $0\n";
    print "ok - 2 # SKIP $^X $0\n";
    exit;
}

mkdir('directory',0777);
mkdir('D機能',0777);
open(FILE,'>D機能/file1.txt') || die "Can't open file: D機能/file1.txt\n";
print FILE "1\n";
close(FILE);
open(FILE,'>D機能/file2.txt') || die "Can't open file: D機能/file2.txt\n";
print FILE "1\n";
close(FILE);
open(FILE,'>D機能/file3.txt') || die "Can't open file: D機能/file3.txt\n";
print FILE "1\n";
close(FILE);

my $cwd1 = `chdir`;
eval {
    chdir('directory');
};
if ($@) {
    print "not ok - 1 chdir (1/2) $^X $__FILE__\n";
}
else {
    my $cwd2 = `chdir`;
    if ($cmd1 ne $cwd2) {
        print "ok - 1 chdir (1/2) $^X $__FILE__\n";
        chdir('..');
    }
    else {
        print "not ok - 1 chdir (1/2) $^X $__FILE__\n";
    }
}

# chdir must die
eval {
    my $dir = 'D機能';
    chdir($dir);
};
if ($@) {
    if ($] =~ /^5\.005/) {
        print "not ok - 2 chdir (2/2) $^X $__FILE__\n";
    }
    elsif ($] =~ /^5\.006/) {
        print "ok - 2 chdir (2/2) # SKIP $^X $__FILE__\n";
    }
    elsif ($] =~ /^5\.008/) {
        print "ok - 2 chdir (2/2) # SKIP $^X $__FILE__\n";
    }
    elsif ($] =~ /^5\.010/) {
        print "ok - 2 chdir (2/2) # SKIP $^X $__FILE__\n";
    }
    else {
        print "ok - 2 chdir (2/2) # SKIP $^X $__FILE__\n";
    }
}
else {
    if ($] =~ /^5\.005/) {
        print "ok - 2 chdir (2/2) $^X $__FILE__\n";
    }
    elsif ($] =~ /^5\.006/) {
        print "ok - 2 chdir (2/2) $^X $__FILE__\n";
    }
    elsif ($] =~ /^5\.008/) {
        print "ok - 2 chdir (2/2) $^X $__FILE__\n";
    }
    elsif ($] =~ /^5\.010/) {
        print "ok - 2 chdir (2/2) $^X $__FILE__\n";
    }
    else {
        print "ok - 2 chdir (2/2) $^X $__FILE__\n";
    }
}

unlink('D機能/file1.txt');
unlink('D機能/file2.txt');
unlink('D機能/file3.txt');
rmdir('directory');
rmdir('D機能');

__END__

