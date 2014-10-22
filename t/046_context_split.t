# This file is encoded in UTF-2.
die "This file is not encoded in UTF-2.\n" if q{あ} ne "\xe3\x81\x82";

use UTF2;
print "1..3\n";

my $__FILE__ = __FILE__;

$text = 'ＩＯ．ＳＹＳ：２２５５５８：９５－１０－０３：－ａ－ｓｈ：ｏｐｔｉｏｎａｌ';

# 7.7 split演算子(リストコンテキスト)
@_ = split(/：/, $text);
if (join('', map {"($_)"} @_) eq "(ＩＯ．ＳＹＳ)(２２５５５８)(９５－１０－０３)(－ａ－ｓｈ)(ｏｐｔｉｏｎａｌ)") {
    print qq{ok - 1 \@_ = split(/：/, \$text); $^X $__FILE__\n};
}
else {
    print qq{not ok - 1 \@_ = split(/：/, \$text); $^X $__FILE__\n};
}

# 7.7 split演算子(スカラコンテキスト)
$a = split(/：/, $text);
if (join('', map {"($_)"} @_) eq "(ＩＯ．ＳＹＳ)(２２５５５８)(９５－１０－０３)(－ａ－ｓｈ)(ｏｐｔｉｏｎａｌ)") {
    print qq{ok - 2 \$a = split(/：/, \$text); $^X $__FILE__\n};
}
else {
    print qq{not ok - 2 \$a = split(/：/, \$text); $^X $__FILE__\n};
}

# 7.7 split演算子(voidコンテキスト)
split(/：/, $text);
if (join('', map {"($_)"} @_) eq "(ＩＯ．ＳＹＳ)(２２５５５８)(９５－１０－０３)(－ａ－ｓｈ)(ｏｐｔｉｏｎａｌ)") {
    print qq{ok - 3 (void) split(/：/, \$text); $^X $__FILE__\n};
}
else {
    print qq{not ok - 3 (void) split(/：/, \$text); $^X $__FILE__\n};
}

__END__
