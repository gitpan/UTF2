# This file is encoded in UTF-2.
die "This file is not encoded in UTF-2.\n" if q{あ} ne "\xe3\x81\x82";

use strict;
# use warnings;

use UTF2;
print "1..1\n";

my $__FILE__ = __FILE__;

if ($^O !~ /\A (?: MSWin32 | NetWare | symbian | dos ) \z/oxms) {
    print "ok - 1 # SKIP $^X $__FILE__\n";
    exit;
}

mkdir('hoge', 0777);
open(FILE,'>hoge/テストソース.txt') || die "Can't open file: hoge/テストソース.txt\n";
print FILE "1\n";
close(FILE);

my($fileName) = glob("./hoge/*");
my $wk = 'ソース';
if ($fileName =~ /\Q$wk\E/) {
    print "ok - 1 $^X $__FILE__\n";
}
else {
    print "not ok - 1 $^X $__FILE__\n";
}

unlink('hoge/テストソース.txt');
rmdir('hoge');

__END__

たとえば、./hoge配下に『テストソース.txt』というファイルがあったとします。
変数展開しないようにシングルクォート『my $wk = 'ソース';』にしてみます。

◆その４：コードはshiftjis、処理はshiftjis、標準入出力はshiftjis

実行結果
C:\test>perl $0
Match
./hoge/テストソース.txt
今度は、上手く行きました。

8/2(土) ■[Perlノート] シフトJIS漢字のファイル名にマッチしてみる
http://d.hatena.ne.jp/chaichanPaPa/20080802/1217660826
