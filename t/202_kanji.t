# This file is encoded in UTF-2.
die "This file is not encoded in UTF-2.\n" if q{あ} ne "\xe3\x81\x82";

use strict;
# use warnings;

use UTF2;
print "1..1\n";

my $__FILE__ = __FILE__;

if (1) {
    print "ok - 1 # SKIP $^X $__FILE__\n";
    exit;
}

mkdir('hoge', 0777);
open(FILE,'>hoge/テストソース.txt') || die "Can't open file: hoge/テストソース.txt\n";
print FILE "1\n";
close(FILE);

my($fileName) = glob("./hoge/*");
# if ($fileName =~ /\Qソース\E/) {
if ($fileName =~ /ソース/) {
    print "ok - 1 $^X $__FILE__\n";
}
else {
    print "not ok - 1 $^X $__FILE__\n";
}

unlink('hoge/テストソース.txt');
rmdir('hoge');

__END__

たとえば、./hoge配下に『テストソース.txt』というファイルがあったとします。
『[』を普通の文字扱いするために、『ソース』を\Qと\Eで囲んでみます。

◆その２：コードはshiftjis、処理はshiftjis、標準入出力はshiftjis

実行結果
C:\test>perl $0
Unmatch
./hoge/テストソース.txt

しかし、上記ではマッチしません。
なぜかというと、 /\Qソース\E/は、\Qより先に『ソース』文字列が評価されるので、
基本的に『[』をエスケープしたに過ぎません。

8/2(土) ■[Perlノート] シフトJIS漢字のファイル名にマッチしてみる
http://d.hatena.ne.jp/chaichanPaPa/20080802/1217660826
