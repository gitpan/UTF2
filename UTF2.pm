package UTF2;
######################################################################
#
# UTF2 - "Yet Another JPerl" Source code filter to escape UTF-2
#
#                  http://search.cpan.org/dist/UTF2/
#
# Copyright (c) 2008, 2009, 2010 INABA Hitoshi <ina@cpan.org>
#
######################################################################

use 5.00503;
use Eutf2;

# 12.3. Delaying use Until Runtime
# in Chapter 12. Packages, Libraries, and Modules
# of ISBN 0-596-00313-7 Perl Cookbook, 2nd Edition.
# (and so on)

BEGIN { eval q{ use vars qw($VERSION) } }

$VERSION = sprintf '%d.%02d', q$Revision: 0.52 $ =~ m/(\d+)/oxmsg;

# poor Symbol.pm - substitute of real Symbol.pm
BEGIN {
    my $genpkg = "Symbol::";
    my $genseq = 0;
    sub gensym () {
        my $name = "GEN" . $genseq++;
        my $ref = \*{$genpkg . $name};
        delete $$genpkg{$name};
        $ref;
    }
}

BEGIN {
    eval { require strict;   'strict'  ->import; };
#   eval { require warnings; 'warnings'->import; };
}

# P.714 29.2.39. flock
# in Chapter 29: Functions
# of ISBN 0-596-00027-8 Programming Perl Third Edition.

sub LOCK_SH() {1}
sub LOCK_EX() {2}
sub LOCK_UN() {8}
sub LOCK_NB() {4}

local $^W = 1;

# P.707 29.2.33. exec
# in Chapter 29: Functions
# of ISBN 0-596-00027-8 Programming Perl Third Edition.

$| = 1;

BEGIN {
    if ($^X =~ m/ jperl /oxmsi) {
        die __FILE__, ": need perl(not jperl) 5.00503 or later. (\$^X==$^X)";
    }
}

sub import() {}
sub unimport() {}
sub UTF2::escape_script;

# regexp of character
my $your_char = q{(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[\x00-\xFF]};
my $qq_char   = qr/\\c[\x40-\x5F]|\\?(?:$your_char)/oxms;
my  $q_char   = qr/$your_char/oxms;

# P.1023 Appendix W.9 Multibyte Anchoring
# of ISBN 1-56592-224-7 CJKV Information Processing

my $your_gap = q{\G(?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[\x00-\x7F])*?};

BEGIN { eval q{ use vars qw($nest) } }

# regexp of nested parens in qqXX

# P.340 Matching Nested Constructs with Embedded Code
# in Chapter 7: Perl
# of ISBN 0-596-00289-0 Mastering Regular Expressions, Second edition

my $qq_paren   = qr{(?{local $nest=0}) (?>(?:
                    \\c[\x40-\x5F] | \\? (?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF] | \\ [\x00-\xFF] |
                    [^()] |
                             \(  (?{$nest++}) |
                             \)  (?(?{$nest>0})(?{$nest--})|(?!)))*) (?(?{$nest!=0})(?!))
                 }xms;
my $qq_brace   = qr{(?{local $nest=0}) (?>(?:
                    \\c[\x40-\x5F] | \\? (?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF] | \\ [\x00-\xFF] |
                    [^{}] |
                             \{  (?{$nest++}) |
                             \}  (?(?{$nest>0})(?{$nest--})|(?!)))*) (?(?{$nest!=0})(?!))
                 }xms;
my $qq_bracket = qr{(?{local $nest=0}) (?>(?:
                    \\c[\x40-\x5F] | \\? (?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF] | \\ [\x00-\xFF] |
                    [^[\]] |
                             \[  (?{$nest++}) |
                             \]  (?(?{$nest>0})(?{$nest--})|(?!)))*) (?(?{$nest!=0})(?!))
                 }xms;
my $qq_angle   = qr{(?{local $nest=0}) (?>(?:
                    \\c[\x40-\x5F] | \\? (?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF] | \\ [\x00-\xFF] |
                    [^<>] |
                             \<  (?{$nest++}) |
                             \>  (?(?{$nest>0})(?{$nest--})|(?!)))*) (?(?{$nest!=0})(?!))
                 }xms;
my $qq_scalar  = qr{(?: \{ (?:$qq_brace)*? \} |
                       (?: ::)? (?:
                             [a-zA-Z_][a-zA-Z_0-9]*
                       (?: ::[a-zA-Z_][a-zA-Z_0-9]* )* (?: \[ (?: \$\[ | \$\] | $qq_char )*? \] | \{ (?:$qq_brace)*? \} )*
                                         (?: (?: -> )? (?: \[ (?: \$\[ | \$\] | $qq_char )*? \] | \{ (?:$qq_brace)*? \} ) )*
                   ))
                 }xms;
my $qq_variable = qr{(?: \{ (?:$qq_brace)*? \} |
                        (?: ::)? (?:
                              [0-9]+            |
                              [^a-zA-Z_0-9\[\]] |
                              ^[A-Z]            |
                              [a-zA-Z_][a-zA-Z_0-9]*
                        (?: ::[a-zA-Z_][a-zA-Z_0-9]* )* (?: \[ (?: \$\[ | \$\] | $qq_char )*? \] | \{ (?:$qq_brace)*? \} )*
                                          (?: (?: -> )? (?: \[ (?: \$\[ | \$\] | $qq_char )*? \] | \{ (?:$qq_brace)*? \} ) )*
                    ))
                  }xms;

# regexp of nested parens in qXX
my $q_paren    = qr{(?{local $nest=0}) (?>(?:
                    (?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF] |
                    [^()] |
                             \(  (?{$nest++}) |
                             \)  (?(?{$nest>0})(?{$nest--})|(?!)))*) (?(?{$nest!=0})(?!))
                 }xms;
my $q_brace    = qr{(?{local $nest=0}) (?>(?:
                    (?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF] |
                    [^{}] |
                             \{  (?{$nest++}) |
                             \}  (?(?{$nest>0})(?{$nest--})|(?!)))*) (?(?{$nest!=0})(?!))
                 }xms;
my $q_bracket  = qr{(?{local $nest=0}) (?>(?:
                    (?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF] |
                    [^[\]] |
                             \[  (?{$nest++}) |
                             \]  (?(?{$nest>0})(?{$nest--})|(?!)))*) (?(?{$nest!=0})(?!))
                 }xms;
my $q_angle    = qr{(?{local $nest=0}) (?>(?:
                    (?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF] |
                    [^<>] |
                             \<  (?{$nest++}) |
                             \>  (?(?{$nest>0})(?{$nest--})|(?!)))*) (?(?{$nest!=0})(?!))
                 }xms;

# P.854 31.17. use re
# in Chapter 31. Pragmatic Modules
# of ISBN 0-596-00027-8 Programming Perl Third Edition.

my $use_re_eval = qq{};
my $m_matched   = q{@Eutf2::m_matched};
my $s_matched   = q{@Eutf2::s_matched};

my $tr_variable   = '';   # variable of tr///
my $sub_variable  = '';   # variable of s///
my $bind_operator = '';   # =~ or !~
BEGIN { eval q{ use vars qw($slash) } }
                          # when 'm//', '/' means regexp match 'm//' and '?' means regexp match '??'
                          # when 'div', '/' means division operator and '?' means conditional operator (condition ? then : else)
my @heredoc = ();         # here document
my @heredoc_delimiter = ();
my $here_script = '';     # here script
my $function_ord;         # ord()   to ord()   or UTF2::ord()
my $function_ord_;        # ord     to ord     or UTF2::ord_
my $function_reverse;     # reverse to reverse or UTF2::reverse

my $ignore_modules = join('|', qw(
    utf8
    I18N::Japanese
    I18N::Collate
    I18N::JExt
    File::DosGlob
    Wildcard
    Japanese
));

# in Chapter 8: Standard Modules
# of ISBN 0-596-00241-6 Perl in a Nutshell, Second Edition

my $standard_modules = join('|', qw(
    AnyDBM_File
    Attribute::Handlers
    attributes
    attrs
    AutoLoader
    AutoSplit
    autouse
    B
    B::Asmdata
    B::Assembler
    B::Bblock
    B::Bytecode
    B::C
    B::CC
    B::Concise
    B::Debug
    B::Deparse
    B::Disassembler
    B::Lint
    B::Showlex
    B::Stackobj
    B::Terse
    B::Xref
    base
    Benchmark
    bigint
    bignum
    bigrat
    blib
    bytes
    ByteLoader
    Carp
    CGI
    CGI::Apache
    CGI::Carp
    CGI::Cookie
    CGI::Fast
    CGI::Pretty
    CGI::Push
    CGI::Switch
    charnames
    Class::ISA
    Class::Struct
    Config
    constant
    CPAN
    CPAN::FirstTime
    CPAN::Nox
    Cwd
    Data::Dumper
    DB
    DB_File
    Devel::DProf
    Devel::PPPort
    Devel::SelfStubber
    diagnostics
    Digest
    Digest::MD5
    DirHandle
    Dumpvalue
    DynaLoader
    encoding
    English
    Env
    Errno
    Exporter
    ExtUtils::Command
    ExtUtils::Command::MM
    ExtUtils::Constant
    ExtUtils::Embed
    ExtUtils::Install
    ExtUtils::Installed
    ExtUtils::Liblist
    ExtUtils::MakeMaker
    ExtUtils::Manifest
    ExtUtils::Miniperl
    ExtUtils::Mkbootstrap
    ExtUtils::Mksymlists
    ExtUtils::MM
    ExtUtils::MM_Any
    ExtUtils::MM_BeOS
    ExtUtils::MM_DOS
    ExtUtils::MM_NW5
    ExtUtils::MM_OS2
    ExtUtils::MM_Unix
    ExtUtils::MM_UWIN
    ExtUtils::MM_VMS
    ExtUtils::MM_Win32
    ExtUtils::MY
    ExtUtils::Packlist
    ExtUtils::testlib
    Fatal
    Fcntl
    fields
    File::Basename
    File::CheckTree
    File::Compare
    File::Copy
    File::DosGlob
    File::Find
    File::Path
    File::Spec
    File::Spec::Cygwin
    File::Spec::Mac
    File::Spec::OS2
    File::Spec::Unix
    File::Spec::VMS
    File::Spec::Win32
    File::stat
    File::Temp
    FileCache
    FileHandle
    Filter::Simple 
    Filter::Util::Call
    FindBin
    GDBM_File
    Getopt::Long
    Getopt::Std
    Hash::Util
    I18N::Collate
    I18N::Langinfo
    I18N::LangTags
    I18N::LangTags::List
    if
    integer
    IO
    IO::File
    IO::Handle
    IO::Pipe
    IO::Seekable
    IO::Select
    IO::Socket
    IPC::Msg
    IPC::Open2
    IPC::Open3
    IPC::Semaphore
    IPC::SysV
    less
    lib
    List::Util
    locale
    Math::BigFloat
    Math::BigInt
    Math::BigInt::Calc
    Math::BigRat
    Math::Complex
    Math::Trig
    MIME::Base64
    MIME::QuotedPrint
    NDBM_File
    Net::Cmd
    Net::Config
    Net::Domain
    Net::FTP
    Net::hostent
    Net::netent
    Net::Netrc
    Net::NNTP
    Net::Ping
    Net::POP3
    Net::protoent
    Net::servent
    Net::SMTP
    Net::Time
    O
    ODBM_File
    Opcode
    ops
    overload
    PerlIO
    PerlIO::Scalar
    PerlIO::Via
    Pod::Functions
    Pod::Html
    Pod::ParseLink
    Pod::Text
    POSIX
    re
    Safe
    Scalar::Util
    SDBM_File
    Search::Dict
    SelectSaver
    SelfLoader
    Shell
    sigtrap
    Socket
    sort
    Storable
    strict
    subs
    Switch
    Symbol
    Sys::Hostname
    Sys::Syslog
    Term::Cap
    Term::Complete
    Term::ReadLine
    Test
    Test::Builder
    Test::Harness
    Test::More
    Test::Simple
    Text::Abbrev
    Text::Balanced
    Text::ParseWords
    Text::Soundex
    Text::Tabs
    Text::Wrap
    Thread
    Thread::Queue
    Thread::Semaphore
    Thread::Signal
    Thread::Specific
    Tie::Array
    Tie::StdArray
    Tie::File
    Tie::Handle
    Tie::Hash
    Tie::Memoize 
    Tie::RefHash
    Tie::Scalar
    Tie::SubstrHash
    Time::gmtime
    Time::HiRes
    Time::Local
    Time::localtime
    Time::tm
    UNIVERSAL
    User::grent
    User::pwent
    utf8
    vars
    vmsish
    XS::Typemap
));

# when this script is main program
if ($0 eq __FILE__) {

    # show usage
    unless (@ARGV) {
        die <<END;
$0: usage

perl $0 UTF-2_script.pl > Escaped_script.pl.e
END
    }

    print UTF2::escape_script($ARGV[0]);
    exit 0;
}

my $__PACKAGE__ = __PACKAGE__;
my $__FILE__    = __FILE__;
my($package,$filename,$line,$subroutine,$hasargs,$wantarray,$evaltext,$is_require,$hints,$bitmask) = caller 0;

# called any package not main
if ($package ne 'main') {
    die <<END;
$__FILE__: escape by manually command '$^X $__FILE__ "$filename" > "$__PACKAGE__::$filename"'
and rewrite "use $package;" to "use $__PACKAGE__::$package;" of script "$0".
END
}

# delete escaped script always while debug
if (exists $ENV{'SJIS_DEBUG'}) {
#   print STDERR "$__FILE__: delete $filename.e (\$ENV{'SJIS_DEBUG'}=$ENV{'SJIS_DEBUG'})\n";

    unlink "$filename.e";
}

my $e_mtime   = (stat("$filename.e"))[9];
my $mtime     = (stat($filename))[9];
my $__mtime__ = (stat($__FILE__))[9];
if ((not -e("$filename.e")) or ($e_mtime < $mtime) or ($mtime < $__mtime__)) {
    my $fh = gensym();
    open($fh, ">$filename.e") or die "$__FILE__: Can't write open file: $filename.e";
    if (exists $ENV{'SJIS_NONBLOCK'}) {

        # 7.18. Locking a File
        # in Chapter 7. File Access
        # of ISBN 0-596-00313-7 Perl Cookbook, 2nd Edition.
        # (and so on)

        eval q{
            unless (flock($fh, LOCK_EX | LOCK_NB)) {
                warn "$__FILE__: Can't immediately write-lock the file: $filename.e";
                exit;
            }
        };
    }
    else {
        eval q{ flock($fh, LOCK_EX) };
    }

    my $e_script = UTF2::escape_script($filename);
    print {$fh} $e_script;

    my $mode = (stat($filename))[2] & 0777;
    chmod $mode, "$filename.e";
    close($fh) or die "$__FILE__: Can't close file: $filename.e";
}

# P.565 23.1.2. Cleaning Up Your Environment
# in Chapter 23: Security
# of ISBN 0-596-00027-8 Programming Perl Third Edition.

# local $ENV{'PATH'} = '.';
local @ENV{qw(IFS CDPATH ENV BASH_ENV)};

my $fh = gensym();
open($fh, "$filename.e") or die "$__FILE__: Can't read open file: $filename.e";
if (exists $ENV{'SJIS_NONBLOCK'}) {
    eval q{
        unless (flock($fh, LOCK_SH | LOCK_NB)) {
            warn "$__FILE__: Can't immediately read-lock the file: $filename.e";
            exit;
        }
    };
}
else {
    eval q{ flock($fh, LOCK_SH) };
}

# DOS-like system
if ($^O =~ /\A (?: MSWin32 | NetWare | symbian | dos ) \z/oxms) {
    exit system map {m/ $your_gap [ ] /oxms ? qq{"$_"} : $_} $^X, "$filename.e", @ARGV;
}

# UNIX like system
else {
    exit system map { escapeshellcmd($_) }                   $^X, "$filename.e", @ARGV;
}

# escape shell command line
sub escapeshellcmd {
    my($word) = @_;
    $word =~ s/([\t\n\r\x20!"#$%&'()*+;<=>?\[\\\]^`{|}~\x7F\xFF])/\\$1/g;
    return $word;
}

# escape UTF-2 script
sub UTF2::escape_script {
    my($script) = @_;
    my $e_script = '';

    # read UTF-2 script
    my $fh = gensym();
    open($fh, $script) or die "$__FILE__: Can't open file: $script";
    local $/ = undef; # slurp mode
    $_ = <$fh>;
    close($fh) or die "$__FILE__: Can't close file: $script";

    if (m/^ use Eutf2(?:\s+[0-9\.]*)?\s*; $/oxms) {
        return $_;
    }
    else {

        # #! shebang line
        if (s/\A(#!.+?\n)//oms) {
            my $head = $1;
            $head =~ s/\bjperl\b/perl/gi;
            $e_script .= $head;
        }

        # DOS-like system header
        if (s/\A(\@rem\s*=\s*'.*?'\s*;\s*\n)//oms) {
            my $head = $1;
            $head =~ s/\bjperl\b/perl/gi;
            $e_script .= $head;
        }

        # P.618 Generating Perl in Other Languages
        # in Chapter 24: Common Practices
        # of ISBN 0-596-00027-8 Programming Perl Third Edition.

        if (s/(.*^#\s*line\s+\d+(?:\s+"(?:$q_char)+?")?\s*\n)//oms) {
            my $head = $1;
            $head =~ s/\bjperl\b/perl/gi;
            $e_script .= $head;
        }

        # P.210 5.10.3.3. Match-time code evaluation
        # in Chapter 5: Pattern Matching
        # of ISBN 0-596-00027-8 Programming Perl Third Edition.

        $e_script .= sprintf("use Eutf2 %s;\n%s", $Eutf2::VERSION, $use_re_eval); # require run-time routines version

        # use UTF2 version qw(ord reverse);
        $function_ord     = 'ord';
        $function_ord_    = 'ord';
        $function_reverse = 'reverse';
        if (s/^ \s* use \s+ UTF2 \s* ([^;]*) ; \s* \n? $//oxms) {

            # require version
            my $list = $1;
            if ($list =~ s/\A ([0-9]+(?:\.[0-9]*)) \s* //oxms) {
                my $version = $1;
                if ($version > $VERSION) {
                    die "$__FILE__: version $version required--this is only version $VERSION";
                }
            }

            # demand ord and reverse
            if ($list !~ m/\A \s* \z/oxms) {
                local $@;
                my @list = eval $list;
                for (@list) {
                    $function_ord     = 'UTF2::ord'     if m/\A ord \z/oxms;
                    $function_ord_    = 'UTF2::ord_'    if m/\A ord \z/oxms;
                    $function_reverse = 'UTF2::reverse' if m/\A reverse \z/oxms;
                }
            }
        }
    }

    $slash = 'm//';

    # Yes, I studied study yesterday.

    # P.359 The Study Function
    # in Chapter 7: Perl
    # of ISBN 0-596-00289-0 Mastering Regular Expressions, Second edition

    study $_;

    # while all script

    # one member of Tag-team
    #
    # P.315 "Tag-team" matching with /gc
    # in Chapter 7: Perl
    # of ISBN 0-596-00289-0 Mastering Regular Expressions, Second edition

    while (not /\G \z/oxgc) { # member
        $e_script .= escape();
    }

    return $e_script;
}

# escape UTF-2 part of script
sub escape {

# \n output here document

    # another member of Tag-team
    #
    # P.315 "Tag-team" matching with /gc
    # in Chapter 7: Perl
    # of ISBN 0-596-00289-0 Mastering Regular Expressions, Second edition

    if (/\G ( \n ) /oxgc) { # another member (and so on)
        my $heredoc = '';
        if (scalar(@heredoc_delimiter) >= 1) {
            $slash = 'm//';

            $heredoc = join '', @heredoc;
            @heredoc = ();

            # skip here document
            for my $heredoc_delimiter (@heredoc_delimiter) {
                /\G .*? \n $heredoc_delimiter \n/xmsgc;
            }
            @heredoc_delimiter = ();

            $here_script = '';
        }
        return "\n" . $heredoc;
    }

# ignore space, comment
    elsif (/\G (\s+|\#.*) /oxgc) { return $1; }

# if (, elsif (, unless (, while (, until (, given ( and when (

    # given, when
    #
    # P.225 The given Statement
    # in Chapter 15: Smart Matching and given-when
    # of ISBN 978-0-596-52010-6 Learning Perl, Fifth Edition

    elsif (/\G ( (?: if | elsif | unless | while | until | given | when ) \s* \( ) /oxgc) {
        $slash = 'm//';
        return $1;
    }

# scalar variable ($scalar = ...) =~ tr///;
# scalar variable ($scalar = ...) =~ s///;

    # state
    #
    # P.68 Persistent, Private Variables
    # in Chapter 4: Subroutines
    # of ISBN 978-0-596-52010-6 Learning Perl, Fifth Edition
    # (and so on)

    elsif (/\G ( \( \s* (?: local \b | my \b | our \b | state \b )? \s* \$ $qq_scalar ) /oxgc) {
        my $e_string = e_string($1);

        if (/\G ( \s* = $qq_paren \) ) ( \s* (?: =~ | !~ ) \s* ) (?= (?: tr|y) \b ) /oxgc) {
            $tr_variable = $e_string . e_string($1);
            $bind_operator = $2;
            $slash = 'm//';
            return '';
        }
        elsif (/\G ( \s* = $qq_paren \) ) ( \s* (?: =~ | !~ ) \s* ) (?= s \b ) /oxgc) {
            $sub_variable = $e_string . e_string($1);
            $bind_operator = $2;
            $slash = 'm//';
            return '';
        }
        else {
            $slash = 'div';
            return $e_string;
        }
    }

# scalar variable $scalar =~ tr///;
# scalar variable $scalar =~ s///;
    elsif (/\G ( \$ $qq_scalar ) /oxgc) {
        my $scalar = e_string($1);

        if (/\G ( \s* (?: =~ | !~ ) \s* ) (?= (?: tr|y) \b ) /oxgc) {
            $tr_variable = $scalar;
            $bind_operator = $1;
            $slash = 'm//';
            return '';
        }
        elsif (/\G ( \s* (?: =~ | !~ ) \s* ) (?= s \b ) /oxgc) {
            $sub_variable = $scalar;
            $bind_operator = $1;
            $slash = 'm//';
            return '';
        }
        else {
            $slash = 'div';
            return $scalar;
        }
    }

    # end of statement
    elsif (/\G ( [,;] ) /oxgc) {
        $slash = 'm//';

        # clear tr/// variable
        $tr_variable  = '';

        # clear s/// variable
        $sub_variable  = '';

        $bind_operator = '';

        return $1;
    }

# bareword
    elsif (/\G ( \{ \s* (?: tr|index|rindex|reverse) \s* \} ) /oxmsgc) {
        return $1;
    }

# $0 --> $0
    elsif (/\G ( \$ 0 ) /oxmsgc) {
        $slash = 'div';
        return $1;
    }
    elsif (/\G ( \$ \{ \s* 0 \s* \} ) /oxmsgc) {
        $slash = 'div';
        return $1;
    }

# $$ --> $$
    elsif (/\G ( \$ \$ ) (?![\w\{]) /oxmsgc) {
        $slash = 'div';
        return $1;
    }

# $1, $2, $3 --> $2, $3, $4
    elsif (/\G \$ ([1-9][0-9]*) /oxmsgc) {
        $slash = 'div';
        return '${Eutf2::capture(' . $1 . ')}';
    }
    elsif (/\G \$ \{ \s* ([1-9][0-9]*) \s* \} /oxmsgc) {
        $slash = 'div';
        return '${Eutf2::capture(' . $1 . ')}';
    }

# $$foo[ ... ] --> $ $foo->[ ... ]
    elsif (/\G \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \[ .+? \] ) /oxmsgc) {
        $slash = 'div';
        return '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
    }

# $$foo{ ... } --> $ $foo->{ ... }
    elsif (/\G \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \{ .+? \} ) /oxmsgc) {
        $slash = 'div';
        return '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
    }

# $$foo
    elsif (/\G \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) /oxmsgc) {
        $slash = 'div';
        return '${Eutf2::capture(' . $1 . ')}';
    }

# ${ foo }
    elsif (/\G \$ \s* \{ ( \s* [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* \s* ) \} /oxmsgc) {
        $slash = 'div';
        return '${' . $1 . '}';
    }

# ${ ... }
    elsif (/\G \$ \s* \{ \s* ( $qq_brace ) \s* \} /oxmsgc) {
        $slash = 'div';
        return '${Eutf2::capture(' . $1 . ')}';
    }

# variable or function
    #                  $ @ % & *     $ #
    elsif (/\G ( (?: [\$\@\%\&\*] | \$\# | -> | \b sub \b) \s* (?: split|chop|index|rindex|lc|uc|chr|ord|reverse|tr|y|q|qq|qx|qw|m|s|qr|glob|lstat|opendir|stat|unlink|chdir) ) \b /oxmsgc) {
        $slash = 'div';
        return $1;
    }
    #                $ $ $ $ $ $ $ $ $ $ $ $ $ $ $
    #                $ @ # \ ' " ` / ? ( ) [ ] < >
    elsif (/\G ( \$[\$\@\#\\\'\"\`\/\?\(\)\[\]\<\>] ) /oxmsgc) {
        $slash = 'div';
        return $1;
    }

# while (<FILEHANDLE>)
    elsif (/\G \b (while \s* \( \s* <[\$]?[A-Za-z_][A-Za-z_0-9]*> \s* \)) \b /oxgc) {
        return $1;
    }

# while (<WILDCARD>) --- glob

    # avoid "Error: Runtime exception" of perl version 5.005_03

    elsif (/\G \b while \s* \( \s* < ((?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[^>\0\a\e\f\n\r\t])+?) > \s* \) \b /oxgc) {
        return 'while ($_ = Eutf2::glob("' . $1 . '"))';
    }

# while (glob)
    elsif (/\G \b while \s* \( \s* glob \s* \) /oxgc) {
        return 'while ($_ = Eutf2::glob_)';
    }

# while (glob(WILDCARD))
    elsif (/\G \b while \s* \( \s* glob \b /oxgc) {
        return 'while ($_ = Eutf2::glob';
    }

# doit if, doit unless, doit while, doit until, doit for
    elsif (m{\G \b ( if | unless | while | until | for ) \b }oxgc) { $slash = 'm//'; return $1;  }

# functions of package Eutf2
    elsif (m{\G \b (CORE::(?:split|chop|index|rindex|lc|uc|chr|ord|reverse)) \b }oxgc) { $slash = 'm//'; return $1;    }
    elsif (m{\G \b chop \b          (?! \s* => )              }oxgc) { $slash = 'm//'; return   'Eutf2::chop';         }
    elsif (m{\G \b UTF2::index \b   (?! \s* => )              }oxgc) { $slash = 'm//'; return   'UTF2::index';         }
    elsif (m{\G \b index \b         (?! \s* => )              }oxgc) { $slash = 'm//'; return   'Eutf2::index';        }
    elsif (m{\G \b UTF2::rindex \b  (?! \s* => )              }oxgc) { $slash = 'm//'; return   'UTF2::rindex';        }
    elsif (m{\G \b rindex \b        (?! \s* => )              }oxgc) { $slash = 'm//'; return   'Eutf2::rindex';       }
    elsif (m{\G \b chr   (?= \s+[A-Za-z_]|\s*['"`\$\@\&\*\(]) }oxgc) { $slash = 'm//'; return   'Eutf2::chr';                }
    elsif (m{\G \b ord   (?= \s+[A-Za-z_]|\s*['"`\$\@\&\*\(]) }oxgc) { $slash = 'div'; return   $function_ord;               }
    elsif (m{\G \b glob  (?= \s+[A-Za-z_]|\s*['"`\$\@\&\*\(]) }oxgc) { $slash = 'm//'; return   'Eutf2::glob';               }
    elsif (m{\G \b chr \b     (?! \s* => )                    }oxgc) { $slash = 'm//'; return   'Eutf2::chr_';               }
    elsif (m{\G \b ord \b     (?! \s* => )                    }oxgc) { $slash = 'div'; return   $function_ord_;              }
    elsif (m{\G \b glob \b    (?! \s* => )                    }oxgc) { $slash = 'm//'; return   'Eutf2::glob_';              }
    elsif (m{\G \b reverse \b (?! \s* => )                    }oxgc) { $slash = 'm//'; return   $function_reverse;           }

# split
    elsif (m{\G \b (split) \b (?! \s* => ) }oxgc) {
        $slash = 'm//';

        my $e = 'Eutf2::split';

        while (/\G ( \s+ | \( | \#.* ) /oxgc) {
            $e .= $1;
        }

# end of split
        if    (/\G (?= [,;\)\}\]] )          /oxgc) { return $e;                 }

# split scalar value
        elsif (/\G ( [\$\@\&\*] $qq_scalar ) /oxgc) { return $e . e_string($1);  }

# split literal space
        elsif (/\G \b qq       (\#) [ ] (\#) /oxgc) { return $e . qq  {qq$1 $2}; }
        elsif (/\G \b qq (\s*) (\() [ ] (\)) /oxgc) { return $e . qq{$1qq$2 $3}; }
        elsif (/\G \b qq (\s*) (\{) [ ] (\}) /oxgc) { return $e . qq{$1qq$2 $3}; }
        elsif (/\G \b qq (\s*) (\[) [ ] (\]) /oxgc) { return $e . qq{$1qq$2 $3}; }
        elsif (/\G \b qq (\s*) (\<) [ ] (\>) /oxgc) { return $e . qq{$1qq$2 $3}; }
        elsif (/\G \b qq (\s*) (\S) [ ] (\2) /oxgc) { return $e . qq{$1qq$2 $3}; }
        elsif (/\G \b q        (\#) [ ] (\#) /oxgc) { return $e . qq   {q$1 $2}; }
        elsif (/\G \b q  (\s*) (\() [ ] (\)) /oxgc) { return $e . qq {$1q$2 $3}; }
        elsif (/\G \b q  (\s*) (\{) [ ] (\}) /oxgc) { return $e . qq {$1q$2 $3}; }
        elsif (/\G \b q  (\s*) (\[) [ ] (\]) /oxgc) { return $e . qq {$1q$2 $3}; }
        elsif (/\G \b q  (\s*) (\<) [ ] (\>) /oxgc) { return $e . qq {$1q$2 $3}; }
        elsif (/\G \b q  (\s*) (\S) [ ] (\2) /oxgc) { return $e . qq {$1q$2 $3}; }
        elsif (/\G                ' [ ] '    /oxgc) { return $e . qq     {' '};  }
        elsif (/\G                " [ ] "    /oxgc) { return $e . qq     {" "};  }

# split qq//
        elsif (/\G \b (qq) \b /oxgc) {
            if (/\G (\#) ((?:$qq_char)*?) (\#) /oxgc)                        { return $e . e_split('qr',$1,$3,$2,'');   } # qq# #  --> qr # #
            else {
                while (not /\G \z/oxgc) {
                    if    (/\G (\s+|\#.*)                             /oxgc) { $e .= $1; }
                    elsif (/\G (\()          ((?:$qq_paren)*?)   (\)) /oxgc) { return $e . e_split('qr',$1,$3,$2,'');   } # qq ( ) --> qr ( )
                    elsif (/\G (\{)          ((?:$qq_brace)*?)   (\}) /oxgc) { return $e . e_split('qr',$1,$3,$2,'');   } # qq { } --> qr { }
                    elsif (/\G (\[)          ((?:$qq_bracket)*?) (\]) /oxgc) { return $e . e_split('qr',$1,$3,$2,'');   } # qq [ ] --> qr [ ]
                    elsif (/\G (\<)          ((?:$qq_angle)*?)   (\>) /oxgc) { return $e . e_split('qr',$1,$3,$2,'');   } # qq < > --> qr < >
                    elsif (/\G ([*\-:?\\^|]) ((?:$qq_char)*?)    (\1) /oxgc) { return $e . e_split('qr','{','}',$2,''); } # qq | | --> qr { }
                    elsif (/\G (\S)          ((?:$qq_char)*?)    (\1) /oxgc) { return $e . e_split('qr',$1,$3,$2,'');   } # qq * * --> qr * *
                }
                die "$__FILE__: Can't find string terminator anywhere before EOF";
            }
        }

# split qr//
        elsif (/\G \b (qr) \b /oxgc) {
            if (/\G (\#) ((?:$qq_char)*?) (\#) ([imosxp]*) /oxgc)                        { return $e . e_split  ('qr',$1,$3,$2,$4);   } # qr# #
            else {
                while (not /\G \z/oxgc) {
                    if    (/\G (\s+|\#.*)                                         /oxgc) { $e .= $1; }
                    elsif (/\G (\()          ((?:$qq_paren)*?)   (\)) ([imosxp]*) /oxgc) { return $e . e_split  ('qr',$1, $3, $2,$4); } # qr ( )
                    elsif (/\G (\{)          ((?:$qq_brace)*?)   (\}) ([imosxp]*) /oxgc) { return $e . e_split  ('qr',$1, $3, $2,$4); } # qr { }
                    elsif (/\G (\[)          ((?:$qq_bracket)*?) (\]) ([imosxp]*) /oxgc) { return $e . e_split  ('qr',$1, $3, $2,$4); } # qr [ ]
                    elsif (/\G (\<)          ((?:$qq_angle)*?)   (\>) ([imosxp]*) /oxgc) { return $e . e_split  ('qr',$1, $3, $2,$4); } # qr < >
                    elsif (/\G (\')          ((?:$qq_char)*?)    (\') ([imosxp]*) /oxgc) { return $e . e_split_q('qr',$1, $3, $2,$4); } # qr ' '
                    elsif (/\G ([*\-:?\\^|]) ((?:$qq_char)*?)    (\1) ([imosxp]*) /oxgc) { return $e . e_split  ('qr','{','}',$2,$4); } # qr | | --> qr { }
                    elsif (/\G (\S)          ((?:$qq_char)*?)    (\1) ([imosxp]*) /oxgc) { return $e . e_split  ('qr',$1, $3, $2,$4); } # qr * *
                }
                die "$__FILE__: Can't find string terminator anywhere before EOF";
            }
        }

# split q//
        elsif (/\G \b (q) \b /oxgc) {
            if (/\G (\#) ((?:\\\#|\\\\|$q_char)*?) (\#) /oxgc)                    { return $e . e_split_q('qr',$1,$3,$2,'');   } # q# #  --> qr # #
            else {
                while (not /\G \z/oxgc) {
                    if    (/\G (\s+|\#.*)                                  /oxgc) { $e .= $1; }
                    elsif (/\G (\() ((?:\\\\|\\\)|\\\(|$q_paren)*?)   (\)) /oxgc) { return $e . e_split_q('qr',$1,$3,$2,'');   } # q ( ) --> qr ( )
                    elsif (/\G (\{) ((?:\\\\|\\\}|\\\{|$q_brace)*?)   (\}) /oxgc) { return $e . e_split_q('qr',$1,$3,$2,'');   } # q { } --> qr { }
                    elsif (/\G (\[) ((?:\\\\|\\\]|\\\[|$q_bracket)*?) (\]) /oxgc) { return $e . e_split_q('qr',$1,$3,$2,'');   } # q [ ] --> qr [ ]
                    elsif (/\G (\<) ((?:\\\\|\\\>|\\\<|$q_angle)*?)   (\>) /oxgc) { return $e . e_split_q('qr',$1,$3,$2,'');   } # q < > --> qr < >
                    elsif (/\G ([*\-:?\\^|])       ((?:$q_char)*?)    (\1) /oxgc) { return $e . e_split_q('qr','{','}',$2,''); } # q | | --> qr { }
                    elsif (/\G (\S) ((?:\\\\|\\\1|     $q_char)*?)    (\1) /oxgc) { return $e . e_split_q('qr',$1,$3,$2,'');   } # q * * --> qr * *
                }
                die "$__FILE__: Can't find string terminator anywhere before EOF";
            }
        }

# split m//
        elsif (/\G \b (m) \b /oxgc) {
            if (/\G (\#) ((?:$qq_char)*?) (\#) ([cgimosxp]*) /oxgc)                        { return $e . e_split  ('qr',$1,$3,$2,$4);   } # m# #  --> qr # #
            else {
                while (not /\G \z/oxgc) {
                    if    (/\G (\s+|\#.*)                                           /oxgc) { $e .= $1; }
                    elsif (/\G (\()          ((?:$qq_paren)*?)   (\)) ([cgimosxp]*) /oxgc) { return $e . e_split  ('qr',$1, $3, $2,$4); } # m ( ) --> qr ( )
                    elsif (/\G (\{)          ((?:$qq_brace)*?)   (\}) ([cgimosxp]*) /oxgc) { return $e . e_split  ('qr',$1, $3, $2,$4); } # m { } --> qr { }
                    elsif (/\G (\[)          ((?:$qq_bracket)*?) (\]) ([cgimosxp]*) /oxgc) { return $e . e_split  ('qr',$1, $3, $2,$4); } # m [ ] --> qr [ ]
                    elsif (/\G (\<)          ((?:$qq_angle)*?)   (\>) ([cgimosxp]*) /oxgc) { return $e . e_split  ('qr',$1, $3, $2,$4); } # m < > --> qr < >
                    elsif (/\G (\')          ((?:$qq_char)*?)    (\') ([cgimosxp]*) /oxgc) { return $e . e_split_q('qr',$1, $3, $2,$4); } # m ' ' --> qr ' '
                    elsif (/\G ([*\-:?\\^|]) ((?:$qq_char)*?)    (\1) ([cgimosxp]*) /oxgc) { return $e . e_split  ('qr','{','}',$2,$4); } # m | | --> qr { }
                    elsif (/\G (\S)          ((?:$qq_char)*?)    (\1) ([cgimosxp]*) /oxgc) { return $e . e_split  ('qr',$1, $3, $2,$4); } # m * * --> qr * *
                }
                die "$__FILE__: Search pattern not terminated";
            }
        }

# split ''
        elsif (/\G (\') /oxgc) {
            my $q_string = '';
            while (not /\G \z/oxgc) {
                if    (/\G (\\\\)    /oxgc) { $q_string .= $1; }
                elsif (/\G (\\\')    /oxgc) { $q_string .= $1; }                               # splitqr'' --> split qr''
                elsif (/\G \'        /oxgc)                                                    { return $e . e_split_q(q{ qr},"'","'",$q_string,''); } # ' ' --> qr ' '
                elsif (/\G ($q_char) /oxgc) { $q_string .= $1; }
            }
            die "$__FILE__: Can't find string terminator anywhere before EOF";
        }

# split ""
        elsif (/\G (\") /oxgc) {
            my $qq_string = '';
            while (not /\G \z/oxgc) {
                if    (/\G (\\\\)    /oxgc) { $qq_string .= $1; }
                elsif (/\G (\\\")    /oxgc) { $qq_string .= $1; }                              # splitqr"" --> split qr""
                elsif (/\G \"        /oxgc)                                                    { return $e . e_split(q{ qr},'"','"',$qq_string,''); } # " " --> qr " "
                elsif (/\G ($q_char) /oxgc) { $qq_string .= $1; }
            }
            die "$__FILE__: Can't find string terminator anywhere before EOF";
        }

# split //
        elsif (/\G (\/) /oxgc) {
            my $regexp = '';
            while (not /\G \z/oxgc) {
                if    (/\G (\\\\)           /oxgc) { $regexp .= $1; }
                elsif (/\G (\\\/)           /oxgc) { $regexp .= $1; }                          # splitqr// --> split qr//
                elsif (/\G \/ ([cgimosxp]*) /oxgc)                                             { return $e . e_split(q{ qr}, '/','/',$regexp,$1); } # / / --> qr / /
                elsif (/\G ($q_char)        /oxgc) { $regexp .= $1; }
            }
            die "$__FILE__: Search pattern not terminated";
        }
    }

# tr/// or y///

    # about [cdsbB]* (/B modifier)
    #
    # P.559 appendix C
    # of ISBN 4-89052-384-7 Programming perl
    # (Japanese title is: Perl puroguramingu)

    elsif (/\G \b (tr|y) \b /oxgc) {
        my $ope = $1;

        #        $1   $2               $3   $4               $5   $6
        if (/\G (\#) ((?:$qq_char)*?) (\#) ((?:$qq_char)*?) (\#) ([cdsbB]*) /oxgc) { # tr# # #
            my @tr = ($tr_variable,$2);
            return e_tr(@tr,'',$4,$6);
        }
        else {
            my $e = '';
            while (not /\G \z/oxgc) {
                if    (/\G (\s+|\#.*)                  /oxgc) { $e .= $1; }
                elsif (/\G (\() ((?:$qq_paren)*?) (\)) /oxgc) {
                    my @tr = ($tr_variable,$2);
                    while (not /\G \z/oxgc) {
                        if    (/\G (\s+|\#.*)                               /oxgc) { $e .= $1; }
                        elsif (/\G (\() ((?:$qq_paren)*?)   (\)) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr ( ) ( )
                        elsif (/\G (\{) ((?:$qq_brace)*?)   (\}) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr ( ) { }
                        elsif (/\G (\[) ((?:$qq_bracket)*?) (\]) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr ( ) [ ]
                        elsif (/\G (\<) ((?:$qq_angle)*?)   (\>) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr ( ) < >
                        elsif (/\G (\S) ((?:$qq_char)*?)    (\1) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr ( ) * *
                    }
                    die "$__FILE__: Transliteration replacement not terminated";
                }
                elsif (/\G (\{) ((?:$qq_brace)*?) (\}) /oxgc) {
                    my @tr = ($tr_variable,$2);
                    while (not /\G \z/oxgc) {
                        if    (/\G (\s+|\#.*)                               /oxgc) { $e .= $1; }
                        elsif (/\G (\() ((?:$qq_paren)*?)   (\)) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr { } ( )
                        elsif (/\G (\{) ((?:$qq_brace)*?)   (\}) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr { } { }
                        elsif (/\G (\[) ((?:$qq_bracket)*?) (\]) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr { } [ ]
                        elsif (/\G (\<) ((?:$qq_angle)*?)   (\>) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr { } < >
                        elsif (/\G (\S) ((?:$qq_char)*?)    (\1) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr { } * *
                    }
                    die "$__FILE__: Transliteration replacement not terminated";
                }
                elsif (/\G (\[) ((?:$qq_bracket)*?) (\]) /oxgc) {
                    my @tr = ($tr_variable,$2);
                    while (not /\G \z/oxgc) {
                        if    (/\G (\s+|\#.*)                               /oxgc) { $e .= $1; }
                        elsif (/\G (\() ((?:$qq_paren)*?)   (\)) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr [ ] ( )
                        elsif (/\G (\{) ((?:$qq_brace)*?)   (\}) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr [ ] { }
                        elsif (/\G (\[) ((?:$qq_bracket)*?) (\]) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr [ ] [ ]
                        elsif (/\G (\<) ((?:$qq_angle)*?)   (\>) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr [ ] < >
                        elsif (/\G (\S) ((?:$qq_char)*?)    (\1) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr [ ] * *
                    }
                    die "$__FILE__: Transliteration replacement not terminated";
                }
                elsif (/\G (\<) ((?:$qq_angle)*?) (\>) /oxgc) {
                    my @tr = ($tr_variable,$2);
                    while (not /\G \z/oxgc) {
                        if    (/\G (\s+|\#.*)                               /oxgc) { $e .= $1; }
                        elsif (/\G (\() ((?:$qq_paren)*?)   (\)) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr < > ( )
                        elsif (/\G (\{) ((?:$qq_brace)*?)   (\}) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr < > { }
                        elsif (/\G (\[) ((?:$qq_bracket)*?) (\]) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr < > [ ]
                        elsif (/\G (\<) ((?:$qq_angle)*?)   (\>) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr < > < >
                        elsif (/\G (\S) ((?:$qq_char)*?)    (\1) ([cdsbB]*) /oxgc) { return e_tr(@tr,$e,$2,$4); } # tr < > * *
                    }
                    die "$__FILE__: Transliteration replacement not terminated";
                }
                #           $1   $2               $3   $4               $5   $6
                elsif (/\G (\S) ((?:$qq_char)*?) (\1) ((?:$qq_char)*?) (\1) ([cdsbB]*) /oxgc) { # tr * * *
                    my @tr = ($tr_variable,$2);
                    return e_tr(@tr,'',$4,$6);
                }
            }
            die "$__FILE__: Transliteration pattern not terminated";
        }
    }

# qq//
    elsif (/\G \b (qq) \b /oxgc) {
        my $ope = $1;

#       if (/\G (\#) ((?:$qq_char)*?) (\#) /oxgc) { return e_qq($ope,$1,$3,$2); } # qq# #
        if (/\G (\#) /oxgc) {                                                     # qq# #
            my $qq_string = '';
            while (not /\G \z/oxgc) {
                if    (/\G (\\\\)     /oxgc) { $qq_string .= $1;                     }
                elsif (/\G (\\\#)     /oxgc) { $qq_string .= $1;                     }
                elsif (/\G (\#)       /oxgc) { return e_qq($ope,'#','#',$qq_string); }
                elsif (/\G ($qq_char) /oxgc) { $qq_string .= $1;                     }
            }
            die "$__FILE__: Can't find string terminator anywhere before EOF";
        }

        else {
            my $e = '';
            while (not /\G \z/oxgc) {
                if    (/\G (\s+|\#.*)                  /oxgc) { $e .= $1; }

#               elsif (/\G (\() ((?:$qq_paren)*?) (\)) /oxgc) { return $e . e_qq($ope,$1,$3,$2); } # qq ( )
                elsif (/\G (\() /oxgc) {                                                           # qq ( )
                    my $qq_string = '';
                    local $nest = 1;
                    while (not /\G \z/oxgc) {
                        if    (/\G (\\\\)     /oxgc) { $qq_string .= $1;                          }
                        elsif (/\G (\\\))     /oxgc) { $qq_string .= $1;                          }
                        elsif (/\G (\()       /oxgc) { $qq_string .= $1; $nest++;                 }
                        elsif (/\G (\))       /oxgc) {
                            if (--$nest == 0)        { return $e . e_qq($ope,'(',')',$qq_string); }
                            else                     { $qq_string .= $1;                          }
                        }
                        elsif (/\G ($qq_char) /oxgc) { $qq_string .= $1;                          }
                    }
                    die "$__FILE__: Can't find string terminator anywhere before EOF";
                }

#               elsif (/\G (\{) ((?:$qq_brace)*?) (\}) /oxgc) { return $e . e_qq($ope,$1,$3,$2); } # qq { }
                elsif (/\G (\{) /oxgc) {                                                           # qq { }
                    my $qq_string = '';
                    local $nest = 1;
                    while (not /\G \z/oxgc) {
                        if    (/\G (\\\\)     /oxgc) { $qq_string .= $1;                          }
                        elsif (/\G (\\\})     /oxgc) { $qq_string .= $1;                          }
                        elsif (/\G (\{)       /oxgc) { $qq_string .= $1; $nest++;                 }
                        elsif (/\G (\})       /oxgc) {
                            if (--$nest == 0)        { return $e . e_qq($ope,'{','}',$qq_string); }
                            else                     { $qq_string .= $1;                          }
                        }
                        elsif (/\G ($qq_char) /oxgc) { $qq_string .= $1;                          }
                    }
                    die "$__FILE__: Can't find string terminator anywhere before EOF";
                }

#               elsif (/\G (\[) ((?:$qq_bracket)*?) (\]) /oxgc) { return $e . e_qq($ope,$1,$3,$2); } # qq [ ]
                elsif (/\G (\[) /oxgc) {                                                             # qq [ ]
                    my $qq_string = '';
                    local $nest = 1;
                    while (not /\G \z/oxgc) {
                        if    (/\G (\\\\)     /oxgc) { $qq_string .= $1;                          }
                        elsif (/\G (\\\])     /oxgc) { $qq_string .= $1;                          }
                        elsif (/\G (\[)       /oxgc) { $qq_string .= $1; $nest++;                 }
                        elsif (/\G (\])       /oxgc) {
                            if (--$nest == 0)        { return $e . e_qq($ope,'[',']',$qq_string); }
                            else                     { $qq_string .= $1;                          }
                        }
                        elsif (/\G ($qq_char) /oxgc) { $qq_string .= $1;                          }
                    }
                    die "$__FILE__: Can't find string terminator anywhere before EOF";
                }

#               elsif (/\G (\<) ((?:$qq_angle)*?) (\>) /oxgc) { return $e . e_qq($ope,$1,$3,$2); } # qq < >
                elsif (/\G (\<) /oxgc) {                                                           # qq < >
                    my $qq_string = '';
                    local $nest = 1;
                    while (not /\G \z/oxgc) {
                        if    (/\G (\\\\)     /oxgc) { $qq_string .= $1;                          }
                        elsif (/\G (\\\>)     /oxgc) { $qq_string .= $1;                          }
                        elsif (/\G (\<)       /oxgc) { $qq_string .= $1; $nest++;                 }
                        elsif (/\G (\>)       /oxgc) {
                            if (--$nest == 0)        { return $e . e_qq($ope,'<','>',$qq_string); }
                            else                     { $qq_string .= $1;                          }
                        }
                        elsif (/\G ($qq_char) /oxgc) { $qq_string .= $1;                          }
                    }
                    die "$__FILE__: Can't find string terminator anywhere before EOF";
                }

#               elsif (/\G (\S) ((?:$qq_char)*?) (\1) /oxgc) { return $e . e_qq($ope,$1,$3,$2); } # qq * *
                elsif (/\G (\S) /oxgc) {                                                          # qq * *
                    my $delimiter = $1;
                    my $qq_string = '';
                    while (not /\G \z/oxgc) {
                        if    (/\G (\\\\)             /oxgc) { $qq_string .= $1;                                        }
                        elsif (/\G (\\\Q$delimiter\E) /oxgc) { $qq_string .= $1;                                        }
                        elsif (/\G (\Q$delimiter\E)   /oxgc) { return $e . e_qq($ope,$delimiter,$delimiter,$qq_string); }
                        elsif (/\G ($qq_char)         /oxgc) { $qq_string .= $1;                                        }
                    }
                    die "$__FILE__: Can't find string terminator anywhere before EOF";
                }
            }
            die "$__FILE__: Can't find string terminator anywhere before EOF";
        }
    }

# qr//
    elsif (/\G \b (qr) \b /oxgc) {
        my $ope = $1;
        if (/\G (\#) ((?:$qq_char)*?) (\#) ([imosxp]*) /oxgc) { # qr# # #
            return e_qr($ope,$1,$3,$2,$4);
        }
        else {
            my $e = '';
            while (not /\G \z/oxgc) {
                if    (/\G (\s+|\#.*)                                         /oxgc) { $e .= $1; }
                elsif (/\G (\()          ((?:$qq_paren)*?)   (\)) ([imosxp]*) /oxgc) { return $e . e_qr  ($ope,$1, $3, $2,$4); } # qr ( )
                elsif (/\G (\{)          ((?:$qq_brace)*?)   (\}) ([imosxp]*) /oxgc) { return $e . e_qr  ($ope,$1, $3, $2,$4); } # qr { }
                elsif (/\G (\[)          ((?:$qq_bracket)*?) (\]) ([imosxp]*) /oxgc) { return $e . e_qr  ($ope,$1, $3, $2,$4); } # qr [ ]
                elsif (/\G (\<)          ((?:$qq_angle)*?)   (\>) ([imosxp]*) /oxgc) { return $e . e_qr  ($ope,$1, $3, $2,$4); } # qr < >
                elsif (/\G (\')          ((?:$qq_char)*?)    (\') ([imosxp]*) /oxgc) { return $e . e_qr_q($ope,$1, $3, $2,$4); } # qr ' '
                elsif (/\G ([*\-:?\\^|]) ((?:$qq_char)*?)    (\1) ([imosxp]*) /oxgc) { return $e . e_qr  ($ope,'{','}',$2,$4); } # qr | | --> qr { }
                elsif (/\G (\S)          ((?:$qq_char)*?)    (\1) ([imosxp]*) /oxgc) { return $e . e_qr  ($ope,$1, $3, $2,$4); } # qr * *
            }
            die "$__FILE__: Can't find string terminator anywhere before EOF";
        }
    }

# qw//
    elsif (/\G \b (qw) \b /oxgc) {
        my $ope = $1;
        if (/\G (\#) (.*?) (\#) /oxmsgc) { # qw# #
            return e_qw($ope,$1,$3,$2);
        }
        else {
            my $e = '';
            while (not /\G \z/oxgc) {
                if    (/\G (\s+|\#.*)                            /oxgc)   { $e .= $1; }

                elsif (/\G (\()          ([^(]*?)           (\)) /oxmsgc) { return $e . e_qw($ope,$1,$3,$2); } # qw ( )
                elsif (/\G (\()          ((?:$q_paren)*?)   (\)) /oxmsgc) { return $e . e_qw($ope,$1,$3,$2); } # qw ( )

                elsif (/\G (\{)          ([^{]*?)           (\}) /oxmsgc) { return $e . e_qw($ope,$1,$3,$2); } # qw { }
                elsif (/\G (\{)          ((?:$q_brace)*?)   (\}) /oxmsgc) { return $e . e_qw($ope,$1,$3,$2); } # qw { }

                elsif (/\G (\[)          ([^[]*?)           (\]) /oxmsgc) { return $e . e_qw($ope,$1,$3,$2); } # qw [ ]
                elsif (/\G (\[)          ((?:$q_bracket)*?) (\]) /oxmsgc) { return $e . e_qw($ope,$1,$3,$2); } # qw [ ]

                elsif (/\G (\<)          ([^<]*?)           (\>) /oxmsgc) { return $e . e_qw($ope,$1,$3,$2); } # qw < >
                elsif (/\G (\<)          ((?:$q_angle)*?)   (\>) /oxmsgc) { return $e . e_qw($ope,$1,$3,$2); } # qw < >

                elsif (/\G ([\x21-\x3F]) (.*?)              (\1) /oxmsgc) { return $e . e_qw($ope,$1,$3,$2); } # qw * *
                elsif (/\G (\S)          ((?:$q_char)*?)    (\1) /oxmsgc) { return $e . e_qw($ope,$1,$3,$2); } # qw * *
            }
            die "$__FILE__: Can't find string terminator anywhere before EOF";
        }
    }

# qx//
    elsif (/\G \b (qx) \b /oxgc) {
        my $ope = $1;
        if (/\G (\#) ((?:$qq_char)*?) (\#) /oxgc) { # qx# #
            return e_qq($ope,$1,$3,$2);
        }
        else {
            my $e = '';
            while (not /\G \z/oxgc) {
                if    (/\G (\s+|\#.*)                    /oxgc) { $e .= $1; }
                elsif (/\G (\() ((?:$qq_paren)*?)   (\)) /oxgc) { return $e . e_qq($ope,$1,$3,$2); } # qx ( )
                elsif (/\G (\{) ((?:$qq_brace)*?)   (\}) /oxgc) { return $e . e_qq($ope,$1,$3,$2); } # qx { }
                elsif (/\G (\[) ((?:$qq_bracket)*?) (\]) /oxgc) { return $e . e_qq($ope,$1,$3,$2); } # qx [ ]
                elsif (/\G (\<) ((?:$qq_angle)*?)   (\>) /oxgc) { return $e . e_qq($ope,$1,$3,$2); } # qx < >
                elsif (/\G (\') ((?:$qq_char)*?)    (\') /oxgc) { return $e . e_q ($ope,$1,$3,$2); } # qx ' '
                elsif (/\G (\S) ((?:$qq_char)*?)    (\1) /oxgc) { return $e . e_qq($ope,$1,$3,$2); } # qx * *
            }
            die "$__FILE__: Can't find string terminator anywhere before EOF";
        }
    }

# q//
    elsif (/\G \b (q) \b /oxgc) {
        my $ope = $1;

#       if (/\G (\#) ((?:\\\#|\\\\|$q_char)*?) (\#) /oxgc) { return e_q($ope,$1,$3,$2); } # q# #

        # avoid "Error: Runtime exception" of perl version 5.005_03
        # (and so on)

        if (/\G (\#) /oxgc) {                                                             # q# #
            my $q_string = '';
            while (not /\G \z/oxgc) {
                if    (/\G (\\\\)    /oxgc) { $q_string .= $1;                    }
                elsif (/\G (\\\#)    /oxgc) { $q_string .= $1;                    }
                elsif (/\G (\#)      /oxgc) { return e_q($ope,'#','#',$q_string); }
                elsif (/\G ($q_char) /oxgc) { $q_string .= $1;                    }
            }
            die "$__FILE__: Can't find string terminator anywhere before EOF";
        }

        else {
            my $e = '';
            while (not /\G \z/oxgc) {
                if    (/\G (\s+|\#.*)                           /oxgc) { $e .= $1; }

#               elsif (/\G (\() ((?:\\\)|\\\\|$q_paren)*?) (\)) /oxgc) { return $e . e_q($ope,$1,$3,$2); } # q ( )
                elsif (/\G (\() /oxgc) {                                                                   # q ( )
                    my $q_string = '';
                    local $nest = 1;
                    while (not /\G \z/oxgc) {
                        if    (/\G (\\\\)    /oxgc) { $q_string .= $1;                         }
                        elsif (/\G (\\\))    /oxgc) { $q_string .= $1;                         }
                        elsif (/\G (\\\()    /oxgc) { $q_string .= $1;                         }
                        elsif (/\G (\()      /oxgc) { $q_string .= $1; $nest++;                }
                        elsif (/\G (\))      /oxgc) {
                            if (--$nest == 0)       { return $e . e_q($ope,'(',')',$q_string); }
                            else                    { $q_string .= $1;                         }
                        }
                        elsif (/\G ($q_char) /oxgc) { $q_string .= $1;                         }
                    }
                    die "$__FILE__: Can't find string terminator anywhere before EOF";
                }

#               elsif (/\G (\{) ((?:\\\}|\\\\|$q_brace)*?) (\}) /oxgc) { return $e . e_q($ope,$1,$3,$2); } # q { }
                elsif (/\G (\{) /oxgc) {                                                                   # q { }
                    my $q_string = '';
                    local $nest = 1;
                    while (not /\G \z/oxgc) {
                        if    (/\G (\\\\)    /oxgc) { $q_string .= $1;                         }
                        elsif (/\G (\\\})    /oxgc) { $q_string .= $1;                         }
                        elsif (/\G (\\\{)    /oxgc) { $q_string .= $1;                         }
                        elsif (/\G (\{)      /oxgc) { $q_string .= $1; $nest++;                }
                        elsif (/\G (\})      /oxgc) {
                            if (--$nest == 0)       { return $e . e_q($ope,'{','}',$q_string); }
                            else                    { $q_string .= $1;                         }
                        }
                        elsif (/\G ($q_char) /oxgc) { $q_string .= $1;                         }
                    }
                    die "$__FILE__: Can't find string terminator anywhere before EOF";
                }

#               elsif (/\G (\[) ((?:\\\]|\\\\|$q_bracket)*?) (\]) /oxgc) { return $e . e_q($ope,$1,$3,$2); } # q [ ]
                elsif (/\G (\[) /oxgc) {                                                                     # q [ ]
                    my $q_string = '';
                    local $nest = 1;
                    while (not /\G \z/oxgc) {
                        if    (/\G (\\\\)    /oxgc) { $q_string .= $1;                         }
                        elsif (/\G (\\\])    /oxgc) { $q_string .= $1;                         }
                        elsif (/\G (\\\[)    /oxgc) { $q_string .= $1;                         }
                        elsif (/\G (\[)      /oxgc) { $q_string .= $1; $nest++;                }
                        elsif (/\G (\])      /oxgc) {
                            if (--$nest == 0)       { return $e . e_q($ope,'[',']',$q_string); }
                            else                    { $q_string .= $1;                         }
                        }
                        elsif (/\G ($q_char) /oxgc) { $q_string .= $1;                         }
                    }
                    die "$__FILE__: Can't find string terminator anywhere before EOF";
                }

#               elsif (/\G (\<) ((?:\\\>|\\\\|$q_angle)*?) (\>) /oxgc) { return $e . e_q($ope,$1,$3,$2); } # q < >
                elsif (/\G (\<) /oxgc) {                                                                   # q < >
                    my $q_string = '';
                    local $nest = 1;
                    while (not /\G \z/oxgc) {
                        if    (/\G (\\\\)    /oxgc) { $q_string .= $1;                         }
                        elsif (/\G (\\\>)    /oxgc) { $q_string .= $1;                         }
                        elsif (/\G (\\\<)    /oxgc) { $q_string .= $1;                         }
                        elsif (/\G (\<)      /oxgc) { $q_string .= $1; $nest++;                }
                        elsif (/\G (\>)      /oxgc) {
                            if (--$nest == 0)       { return $e . e_q($ope,'<','>',$q_string); }
                            else                    { $q_string .= $1;                         }
                        }
                        elsif (/\G ($q_char) /oxgc) { $q_string .= $1;                         }
                    }
                    die "$__FILE__: Can't find string terminator anywhere before EOF";
                }

#               elsif (/\G (\S) ((?:\\\1|\\\\|$q_char)*?) (\1) /oxgc) { return $e . e_q($ope,$1,$3,$2); } # q * *
                elsif (/\G (\S) /oxgc) {                                                                  # q * *
                    my $delimiter = $1;
                    my $q_string = '';
                    while (not /\G \z/oxgc) {
                        if    (/\G (\\\\)             /oxgc) { $q_string .= $1;                                       }
                        elsif (/\G (\\\Q$delimiter\E) /oxgc) { $q_string .= $1;                                       }
                        elsif (/\G (\Q$delimiter\E)   /oxgc) { return $e . e_q($ope,$delimiter,$delimiter,$q_string); }
                        elsif (/\G ($q_char)          /oxgc) { $q_string .= $1;                                       }
                    }
                    die "$__FILE__: Can't find string terminator anywhere before EOF";
                }
            }
            die "$__FILE__: Can't find string terminator anywhere before EOF";
        }
    }

# m//
    elsif (/\G \b (m) \b /oxgc) {
        my $ope = $1;
        if (/\G (\#) ((?:$qq_char)*?) (\#) ([cgimosxp]*) /oxgc) { # m# #
            return e_qr($ope,$1,$3,$2,$4);
        }
        else {
            my $e = '';
            while (not /\G \z/oxgc) {
                if    (/\G (\s+|\#.*)                                           /oxgc) { $e .= $1; }
                elsif (/\G (\()          ((?:$qq_paren)*?)   (\)) ([cgimosxp]*) /oxgc) { return $e . e_qr  ($ope,$1, $3, $2,$4); } # m ( )
                elsif (/\G (\{)          ((?:$qq_brace)*?)   (\}) ([cgimosxp]*) /oxgc) { return $e . e_qr  ($ope,$1, $3, $2,$4); } # m { }
                elsif (/\G (\[)          ((?:$qq_bracket)*?) (\]) ([cgimosxp]*) /oxgc) { return $e . e_qr  ($ope,$1, $3, $2,$4); } # m [ ]
                elsif (/\G (\<)          ((?:$qq_angle)*?)   (\>) ([cgimosxp]*) /oxgc) { return $e . e_qr  ($ope,$1, $3, $2,$4); } # m < >
                elsif (/\G (\')          ((?:$qq_char)*?)    (\') ([cgimosxp]*) /oxgc) { return $e . e_qr_q($ope,$1, $3, $2,$4); } # m ' '
                elsif (/\G ([*\-:?\\^|]) ((?:$qq_char)*?)    (\1) ([cgimosxp]*) /oxgc) { return $e . e_qr  ($ope,'{','}',$2,$4); } # m | | --> m { }
                elsif (/\G (\S)          ((?:$qq_char)*?)    (\1) ([cgimosxp]*) /oxgc) { return $e . e_qr  ($ope,$1, $3, $2,$4); } # m * *
            }
            die "$__FILE__: Search pattern not terminated";
        }
    }

# s///

    # about [cegimosxp]* (/cg modifier)
    #
    # P.67 Pattern-Matching Operators
    # of ISBN 0-596-00241-6 Perl in a Nutshell, Second Edition.

    elsif (/\G \b (s) \b /oxgc) {
        my $ope = $1;

        #        $1   $2               $3   $4               $5   $6
        if (/\G (\#) ((?:$qq_char)*?) (\#) ((?:$qq_char)*?) (\#) ([cegimosxp]*) /oxgc) { # s# # #
            return e_sub($sub_variable,$1,$2,$3,$3,$4,$5,$6);
        }
        else {
            my $e = '';
            while (not /\G \z/oxgc) {
                if (/\G (\s+|\#.*) /oxgc) { $e .= $1; }
                elsif (/\G (\() ((?:$qq_paren)*?) (\)) /oxgc) {
                    my @s = ($1,$2,$3);
                    while (not /\G \z/oxgc) {
                        if    (/\G (\s+|\#.*)                                   /oxgc) { $e .= $1; }
                        #           $1   $2                  $3   $4
                        elsif (/\G (\() ((?:$qq_paren)*?)   (\)) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\{) ((?:$qq_brace)*?)   (\}) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\[) ((?:$qq_bracket)*?) (\]) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\<) ((?:$qq_angle)*?)   (\>) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\') ((?:$qq_char)*?)    (\') ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\$) ((?:$qq_char)*?)    (\$) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\:) ((?:$qq_char)*?)    (\:) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\@) ((?:$qq_char)*?)    (\@) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\S) ((?:$qq_char)*?)    (\1) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                    }
                    die "$__FILE__: Substitution replacement not terminated";
                }
                elsif (/\G (\{) ((?:$qq_brace)*?) (\}) /oxgc) {
                    my @s = ($1,$2,$3);
                    while (not /\G \z/oxgc) {
                        if    (/\G (\s+|\#.*)                                   /oxgc) { $e .= $1; }
                        #           $1   $2                  $3   $4
                        elsif (/\G (\() ((?:$qq_paren)*?)   (\)) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\{) ((?:$qq_brace)*?)   (\}) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\[) ((?:$qq_bracket)*?) (\]) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\<) ((?:$qq_angle)*?)   (\>) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\') ((?:$qq_char)*?)    (\') ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\$) ((?:$qq_char)*?)    (\$) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\:) ((?:$qq_char)*?)    (\:) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\@) ((?:$qq_char)*?)    (\@) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\S) ((?:$qq_char)*?)    (\1) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                    }
                    die "$__FILE__: Substitution replacement not terminated";
                }
                elsif (/\G (\[) ((?:$qq_bracket)*?) (\]) /oxgc) {
                    my @s = ($1,$2,$3);
                    while (not /\G \z/oxgc) {
                        if    (/\G (\s+|\#.*)                                   /oxgc) { $e .= $1; }
                        #           $1   $2                  $3   $4
                        elsif (/\G (\() ((?:$qq_paren)*?)   (\)) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\{) ((?:$qq_brace)*?)   (\}) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\[) ((?:$qq_bracket)*?) (\]) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\<) ((?:$qq_angle)*?)   (\>) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\') ((?:$qq_char)*?)    (\') ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\$) ((?:$qq_char)*?)    (\$) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\S) ((?:$qq_char)*?)    (\1) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                    }
                    die "$__FILE__: Substitution replacement not terminated";
                }
                elsif (/\G (\<) ((?:$qq_angle)*?) (\>) /oxgc) {
                    my @s = ($1,$2,$3);
                    while (not /\G \z/oxgc) {
                        if    (/\G (\s+|\#.*)                                   /oxgc) { $e .= $1; }
                        #           $1   $2                  $3   $4
                        elsif (/\G (\() ((?:$qq_paren)*?)   (\)) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\{) ((?:$qq_brace)*?)   (\}) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\[) ((?:$qq_bracket)*?) (\]) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\<) ((?:$qq_angle)*?)   (\>) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\') ((?:$qq_char)*?)    (\') ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\$) ((?:$qq_char)*?)    (\$) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\:) ((?:$qq_char)*?)    (\:) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\@) ((?:$qq_char)*?)    (\@) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                        elsif (/\G (\S) ((?:$qq_char)*?)    (\1) ([cegimosxp]*) /oxgc) { return e_sub($sub_variable,@s,$1,$2,$3,$4); }
                    }
                    die "$__FILE__: Substitution replacement not terminated";
                }
                #           $1   $2               $3   $4               $5   $6
                elsif (/\G (\') ((?:$qq_char)*?) (\') ((?:$qq_char)*?) (\') ([cegimosxp]*) /oxgc) {
                    return e_sub($sub_variable,$1,$2,$3,$3,$4,$5,$6);
                }
                #           $1            $2               $3   $4               $5   $6
                elsif (/\G ([*\-:?\\^|]) ((?:$qq_char)*?) (\1) ((?:$qq_char)*?) (\1) ([cegimosxp]*) /oxgc) {
                    return e_sub($sub_variable,'{',$2,'}','{',$4,'}',$6); # s | | | --> s { } { }
                }
                #           $1   $2               $3   $4               $5   $6
                elsif (/\G (\$) ((?:$qq_char)*?) (\1) ((?:$qq_char)*?) (\1) ([cegimosxp]*) /oxgc) {
                    return e_sub($sub_variable,$1,$2,$3,$3,$4,$5,$6);
                }
                #           $1   $2               $3   $4               $5   $6
                elsif (/\G (\S) ((?:$qq_char)*?) (\1) ((?:$qq_char)*?) (\1) ([cegimosxp]*) /oxgc) {
                    return e_sub($sub_variable,$1,$2,$3,$3,$4,$5,$6);
                }
            }
            die "$__FILE__: Substitution pattern not terminated";
        }
    }


# ''
    elsif (/\G (?<![\w\$\@\%\&\*]) (\') /oxgc) {
        my $q_string = '';
        while (not /\G \z/oxgc) {
            if    (/\G (\\\\)    /oxgc)            { $q_string .= $1;                   }
            elsif (/\G (\\\')    /oxgc)            { $q_string .= $1;                   }
            elsif (/\G \'        /oxgc)            { return e_q('', "'","'",$q_string); }
            elsif (/\G ($q_char) /oxgc)            { $q_string .= $1;                   }
        }
        die "$__FILE__: Can't find string terminator anywhere before EOF";
    }

# ""
    elsif (/\G (\") /oxgc) {
        my $qq_string = '';
        while (not /\G \z/oxgc) {
            if    (/\G (\\\\)    /oxgc)            { $qq_string .= $1;                    }
            elsif (/\G (\\\")    /oxgc)            { $qq_string .= $1;                    }
            elsif (/\G \"        /oxgc)            { return e_qq('', '"','"',$qq_string); }
            elsif (/\G ($q_char) /oxgc)            { $qq_string .= $1;                    }
        }
        die "$__FILE__: Can't find string terminator anywhere before EOF";
    }

# ``
    elsif (/\G (\`) /oxgc) {
        my $qx_string = '';
        while (not /\G \z/oxgc) {
            if    (/\G (\\\\)    /oxgc)            { $qx_string .= $1;                    }
            elsif (/\G (\\\`)    /oxgc)            { $qx_string .= $1;                    }
            elsif (/\G \`        /oxgc)            { return e_qq('', '`','`',$qx_string); }
            elsif (/\G ($q_char) /oxgc)            { $qx_string .= $1;                    }
        }
        die "$__FILE__: Can't find string terminator anywhere before EOF";
    }

# //   --- not divide operator (num / num), not defined-or
    elsif (($slash eq 'm//') and /\G (\/) /oxgc) {
        my $regexp = '';
        while (not /\G \z/oxgc) {
            if    (/\G (\\\\)           /oxgc)     { $regexp .= $1;                       }
            elsif (/\G (\\\/)           /oxgc)     { $regexp .= $1;                       }
            elsif (/\G \/ ([cgimosxp]*) /oxgc)     { return e_qr('', '/','/',$regexp,$1); }
            elsif (/\G ($q_char)        /oxgc)     { $regexp .= $1;                       }
        }
        die "$__FILE__: Search pattern not terminated";
    }

# ??   --- not conditional operator (condition ? then : else)
    elsif (($slash eq 'm//') and /\G (\?) /oxgc) {
        my $regexp = '';
        while (not /\G \z/oxgc) {
            if    (/\G (\\\\)           /oxgc)     { $regexp .= $1;                       }
            elsif (/\G (\\\?)           /oxgc)     { $regexp .= $1;                       }
            elsif (/\G \? ([cgimosxp]*) /oxgc)     { return e_qr('', '?','?',$regexp,$1); }
            elsif (/\G ($q_char)        /oxgc)     { $regexp .= $1;                       }
        }
        die "$__FILE__: Search pattern not terminated";
    }

# << (bit shift)   --- not here document
    elsif (/\G ( << \s* ) (?= [0-9\$\@\&] ) /oxgc) { $slash = 'm//'; return $1;           }

# <<'HEREDOC'
    elsif (/\G ( << '([a-zA-Z_0-9]*)' ) /oxgc) {
        $slash = 'm//';
        my $here_quote = $1;
        my $delimiter  = $2;

        # get here document
        if ($here_script eq '') {
            $here_script = CORE::substr $_, pos $_;
            $here_script =~ s/.*?\n//oxm;
        }
        if ($here_script =~ s/\A (.*?) \n $delimiter \n //xms) {
            push @heredoc, $1 . qq{\n$delimiter\n};
            push @heredoc_delimiter, $delimiter;
        }
        else {
            die "$__FILE__: Can't find string terminator $delimiter anywhere before EOF";
        }
        return $here_quote;
    }

# <<\HEREDOC

    # P.66 2.6.6. "Here" Documents
    # in Chapter 2: Bits and Pieces
    # of ISBN 0-596-00027-8 Programming Perl Third Edition.

    elsif (/\G ( << \\([a-zA-Z_0-9]+) ) /oxgc) {
        $slash = 'm//';
        my $here_quote = $1;
        my $delimiter  = $2;

        # get here document
        if ($here_script eq '') {
            $here_script = CORE::substr $_, pos $_;
            $here_script =~ s/.*?\n//oxm;
        }
        if ($here_script =~ s/\A (.*?) \n $delimiter \n //xms) {
            push @heredoc, $1 . qq{\n$delimiter\n};
            push @heredoc_delimiter, $delimiter;
        }
        else {
            die "$__FILE__: Can't find string terminator $delimiter anywhere before EOF";
        }
        return $here_quote;
    }

# <<"HEREDOC"
    elsif (/\G ( << "([a-zA-Z_0-9]*)" ) /oxgc) {
        $slash = 'm//';
        my $here_quote = $1;
        my $delimiter  = $2;

        # get here document
        if ($here_script eq '') {
            $here_script = CORE::substr $_, pos $_;
            $here_script =~ s/.*?\n//oxm;
        }
        if ($here_script =~ s/\A (.*?) \n $delimiter \n //xms) {
            push @heredoc, e_heredoc($1) . qq{\n$delimiter\n};
            push @heredoc_delimiter, $delimiter;
        }
        else {
            die "$__FILE__: Can't find string terminator $delimiter anywhere before EOF";
        }
        return $here_quote;
    }

# <<HEREDOC
    elsif (/\G ( << ([a-zA-Z_0-9]+) ) /oxgc) {
        $slash = 'm//';
        my $here_quote = $1;
        my $delimiter  = $2;

        # get here document
        if ($here_script eq '') {
            $here_script = CORE::substr $_, pos $_;
            $here_script =~ s/.*?\n//oxm;
        }
        if ($here_script =~ s/\A (.*?) \n $delimiter \n //xms) {
            push @heredoc, e_heredoc($1) . qq{\n$delimiter\n};
            push @heredoc_delimiter, $delimiter;
        }
        else {
            die "$__FILE__: Can't find string terminator $delimiter anywhere before EOF";
        }
        return $here_quote;
    }

# <<`HEREDOC`
    elsif (/\G ( << `([a-zA-Z_0-9]*)` ) /oxgc) {
        $slash = 'm//';
        my $here_quote = $1;
        my $delimiter  = $2;

        # get here document
        if ($here_script eq '') {
            $here_script = CORE::substr $_, pos $_;
            $here_script =~ s/.*?\n//oxm;
        }
        if ($here_script =~ s/\A (.*?) \n $delimiter \n //xms) {
            push @heredoc, e_heredoc($1) . qq{\n$delimiter\n};
            push @heredoc_delimiter, $delimiter;
        }
        else {
            die "$__FILE__: Can't find string terminator $delimiter anywhere before EOF";
        }
        return $here_quote;
    }

# <<= <=> <= < operator
    elsif (/\G (<<=|<=>|<=|<) (?= \s* [A-Za-z_0-9'"`\$\@\&\*\(\+\-] )/oxgc) {
        return $1;
    }

# <FILEHANDLE>
    elsif (/\G (<[\$]?[A-Za-z_][A-Za-z_0-9]*>) /oxgc) {
        return $1;
    }

# <WILDCARD> --- glob

    # avoid "Error: Runtime exception" of perl version 5.005_03

    elsif (/\G < ((?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[^>\0\a\e\f\n\r\t])+?) > /oxgc) {
        return 'Eutf2::glob("' . $1 . '")';
    }

# __DATA__
    elsif (/\G ^ ( __DATA__ \n .*) \z /oxmsgc) { return $1; }

# __END__
    elsif (/\G ^ ( __END__  \n .*) \z /oxmsgc) { return $1; }

# \cD Control-D

    # P.68 2.6.8. Other Literal Tokens
    # in Chapter 2: Bits and Pieces
    # of ISBN 0-596-00027-8 Programming Perl Third Edition.

    elsif (/\G   ( \cD         .*) \z /oxmsgc) { return $1; }

# \cZ Control-Z
    elsif (/\G   ( \cZ         .*) \z /oxmsgc) { return $1; }

    # any operator before div
    elsif (/\G (
            -- | \+\+ |
            [\)\}\]]

            ) /oxgc) { $slash = 'div'; return $1; }

    # any operator before m//

    # //, //= (defined-or)
    #
    # P.164 Logical Operators
    # in Chapter 10: More Control Structures
    # of ISBN 978-0-596-52010-6 Learning Perl, Fifth Edition
    # (and so on)

    # ~~
    #
    # P.221 The Smart Match Operator
    # in Chapter 15: Smart Matching and given-when
    # of ISBN 978-0-596-52010-6 Learning Perl, Fifth Edition
    # (and so on)

    elsif (/\G (

            !~~ | !~ | != | ! |
            %= | % |
            &&= | && | &= | & |
            -= | -> | - |
            : |
            <<= | <=> | <= | < |
            == | => | =~ | = |
            >>= | >> | >= | > |
            \*\*= | \*\* | \*= | \* |
            \+= | \+ |
            \.\.\. | \.\. | \.= | \. |
            \/\/= | \/\/ |
            \/= | \/ |
            \? |
            \\ |
            \^= | \^ |
            \b x= |
            \|\|= | \|\| | \|= | \| |
            ~~ | ~ |
            \b(?: and | cmp | eq | ge | gt | le | lt | ne | not | or | xor | x )\b |
            \b(?: print )\b |

            [,;\(\{\[]

            ) /oxgc) { $slash = 'm//'; return $1; }

    # other any character
    elsif (/\G ($q_char) /oxgc) { $slash = 'div'; return $1; }

    # system error
    else {
        die "$__FILE__: oops, this shouldn't happen!";
    }
}

# escape UTF-2 string
sub e_string {
    my($string) = @_;
    my $e_string = '';

    local $slash = 'm//';

    # P.1024 Appendix W.10 Multibyte Processing
    # of ISBN 1-56592-224-7 CJKV Information Processing
    # (and so on)

    my @char = $string =~ m/ \G (\\?(?:$q_char)) /oxmsg;

    # without { ... }
    if (not (grep(m/\A \{ \z/xms, @char) and grep(m/\A \} \z/xms, @char))) {
        if ($string !~ /<</oxms) {
            return $string;
        }
    }

E_STRING_LOOP:
    while ($string !~ /\G \z/oxgc) {

# bareword
        if ($string =~ /\G ( \{ \s* (?: tr|index|rindex|reverse) \s* \} ) /oxmsgc) {
            $e_string .= $1;
            $slash = 'div';
        }

# $0 --> $0
        elsif ($string =~ /\G ( \$ 0 ) /oxmsgc) {
            $e_string .= $1;
            $slash = 'div';
        }
        elsif ($string =~ /\G ( \$ \{ \s* 0 \s* \} ) /oxmsgc) {
            $e_string .= $1;
            $slash = 'div';
        }

# $$ --> $$
        elsif ($string =~ /\G ( \$ \$ ) (?![\w\{]) /oxmsgc) {
            $e_string .= $1;
            $slash = 'div';
        }

# $1, $2, $3 --> $2, $3, $4
        elsif ($string =~ /\G \$ ([1-9][0-9]*) /oxmsgc) {
            $e_string .= '${Eutf2::capture(' . $1 . ')}';
            $slash = 'div';
        }
        elsif ($string =~ /\G \$ \{ \s* ([1-9][0-9]*) \s* \} /oxmsgc) {
            $e_string .= '${Eutf2::capture(' . $1 . ')}';
            $slash = 'div';
        }

# $$foo[ ... ] --> $ $foo->[ ... ]
        elsif ($string =~ /\G \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \[ .+? \] ) /oxmsgc) {
            $e_string .= '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
            $slash = 'div';
        }

# $$foo{ ... } --> $ $foo->{ ... }
        elsif ($string =~ /\G \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \{ .+? \} ) /oxmsgc) {
            $e_string .= '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
            $slash = 'div';
        }

# $$foo
        elsif ($string =~ /\G \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) /oxmsgc) {
            $e_string .= '${Eutf2::capture(' . $1 . ')}';
            $slash = 'div';
        }

# ${ foo }
        elsif ($string =~ /\G \$ \s* \{ ( \s* [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* \s* ) \} /oxmsgc) {
            $e_string .= '${' . $1 . '}';
            $slash = 'div';
        }

# ${ ... }
        elsif ($string =~ /\G \$ \s* \{ \s* ( $qq_brace ) \s* \} /oxmsgc) {
            $e_string .= '${Eutf2::capture(' . $1 . ')}';
            $slash = 'div';
        }

# variable or function
        #                             $ @ % & *     $ #
        elsif ($string =~ /\G ( (?: [\$\@\%\&\*] | \$\# | -> | \b sub \b) \s* (?: split|chop|index|rindex|lc|uc|chr|ord|reverse|tr|y|q|qq|qx|qw|m|s|qr|glob|lstat|opendir|stat|unlink|chdir) ) \b /oxmsgc) {
            $e_string .= $1;
            $slash = 'div';
        }
        #                           $ $ $ $ $ $ $ $ $ $ $ $ $ $ $
        #                           $ @ # \ ' " ` / ? ( ) [ ] < >
        elsif ($string =~ /\G ( \$[\$\@\#\\\'\"\`\/\?\(\)\[\]\<\>] ) /oxmsgc) {
            $e_string .= $1;
            $slash = 'div';
        }

# functions of package Eutf2
        elsif ($string =~ m{\G \b (CORE::(?:split|chop|index|rindex|lc|uc|chr|ord|reverse)) \b }oxgc) { $e_string .= $1;     $slash = 'm//'; }
        elsif ($string =~ m{\G \b chop \b                                    }oxgc) { $e_string .=   'Eutf2::chop';          $slash = 'm//'; }
        elsif ($string =~ m{\G \b UTF2::index \b                             }oxgc) { $e_string .=   'UTF2::index';          $slash = 'm//'; }
        elsif ($string =~ m{\G \b index \b                                   }oxgc) { $e_string .=   'Eutf2::index';         $slash = 'm//'; }
        elsif ($string =~ m{\G \b UTF2::rindex \b                            }oxgc) { $e_string .=   'UTF2::rindex';         $slash = 'm//'; }
        elsif ($string =~ m{\G \b rindex \b                                  }oxgc) { $e_string .=   'Eutf2::rindex';        $slash = 'm//'; }
        elsif ($string =~ m{\G \b chr   (?= \s+[A-Za-z_]|\s*['"`\$\@\&\*\(]) }oxgc) { $e_string .=   'Eutf2::chr';               $slash = 'm//'; }
        elsif ($string =~ m{\G \b ord   (?= \s+[A-Za-z_]|\s*['"`\$\@\&\*\(]) }oxgc) { $e_string .=   $function_ord;              $slash = 'div'; }
        elsif ($string =~ m{\G \b glob  (?= \s+[A-Za-z_]|\s*['"`\$\@\&\*\(]) }oxgc) { $e_string .=   'Eutf2::glob';              $slash = 'm//'; }
        elsif ($string =~ m{\G \b chr \b                                     }oxgc) { $e_string .=   'Eutf2::chr_';              $slash = 'm//'; }
        elsif ($string =~ m{\G \b ord \b                                     }oxgc) { $e_string .=   $function_ord_;             $slash = 'div'; }
        elsif ($string =~ m{\G \b glob \b                                    }oxgc) { $e_string .=   'Eutf2::glob_';             $slash = 'm//'; }
        elsif ($string =~ m{\G \b reverse \b                                 }oxgc) { $e_string .=   $function_reverse;          $slash = 'm//'; }

# split
        elsif ($string =~ m{\G \b (split) \b (?! \s* => ) }oxgc) {
            $slash = 'm//';

            my $e_string = 'Eutf2::split';

            while ($string =~ /\G ( \s+ | \( | \#.* ) /oxgc) {
                $e_string .= $1;
            }

# end of split
            if    ($string =~ /\G (?= [,;\)\}\]] )          /oxgc) { return $e_string;                               }

# split scalar value
            elsif ($string =~ /\G ( [\$\@\&\*] $qq_scalar ) /oxgc) { $e_string .= e_string($1);  next E_STRING_LOOP; }

# split literal space
            elsif ($string =~ /\G \b qq       (\#) [ ] (\#) /oxgc) { $e_string .= qq  {qq$1 $2}; next E_STRING_LOOP; }
            elsif ($string =~ /\G \b qq (\s*) (\() [ ] (\)) /oxgc) { $e_string .= qq{$1qq$2 $3}; next E_STRING_LOOP; }
            elsif ($string =~ /\G \b qq (\s*) (\{) [ ] (\}) /oxgc) { $e_string .= qq{$1qq$2 $3}; next E_STRING_LOOP; }
            elsif ($string =~ /\G \b qq (\s*) (\[) [ ] (\]) /oxgc) { $e_string .= qq{$1qq$2 $3}; next E_STRING_LOOP; }
            elsif ($string =~ /\G \b qq (\s*) (\<) [ ] (\>) /oxgc) { $e_string .= qq{$1qq$2 $3}; next E_STRING_LOOP; }
            elsif ($string =~ /\G \b qq (\s*) (\S) [ ] (\2) /oxgc) { $e_string .= qq{$1qq$2 $3}; next E_STRING_LOOP; }
            elsif ($string =~ /\G \b q        (\#) [ ] (\#) /oxgc) { $e_string .= qq   {q$1 $2}; next E_STRING_LOOP; }
            elsif ($string =~ /\G \b q  (\s*) (\() [ ] (\)) /oxgc) { $e_string .= qq {$1q$2 $3}; next E_STRING_LOOP; }
            elsif ($string =~ /\G \b q  (\s*) (\{) [ ] (\}) /oxgc) { $e_string .= qq {$1q$2 $3}; next E_STRING_LOOP; }
            elsif ($string =~ /\G \b q  (\s*) (\[) [ ] (\]) /oxgc) { $e_string .= qq {$1q$2 $3}; next E_STRING_LOOP; }
            elsif ($string =~ /\G \b q  (\s*) (\<) [ ] (\>) /oxgc) { $e_string .= qq {$1q$2 $3}; next E_STRING_LOOP; }
            elsif ($string =~ /\G \b q  (\s*) (\S) [ ] (\2) /oxgc) { $e_string .= qq {$1q$2 $3}; next E_STRING_LOOP; }
            elsif ($string =~ /\G                ' [ ] '    /oxgc) { $e_string .= qq     {' '};  next E_STRING_LOOP; }
            elsif ($string =~ /\G                " [ ] "    /oxgc) { $e_string .= qq     {" "};  next E_STRING_LOOP; }

# split qq//
            elsif ($string =~ /\G \b (qq) \b /oxgc) {
                if ($string =~ /\G (\#) ((?:$qq_char)*?) (\#) /oxgc)                        { $e_string .= e_split('qr',$1,$3,$2,'');   next E_STRING_LOOP; } # qq# #  --> qr # #
                else {
                    while ($string !~ /\G \z/oxgc) {
                        if    ($string =~ /\G (\s+|\#.*)                             /oxgc) { $e_string .= $1; }
                        elsif ($string =~ /\G (\()          ((?:$qq_paren)*?)   (\)) /oxgc) { $e_string .= e_split('qr',$1,$3,$2,'');   next E_STRING_LOOP; } # qq ( ) --> qr ( )
                        elsif ($string =~ /\G (\{)          ((?:$qq_brace)*?)   (\}) /oxgc) { $e_string .= e_split('qr',$1,$3,$2,'');   next E_STRING_LOOP; } # qq { } --> qr { }
                        elsif ($string =~ /\G (\[)          ((?:$qq_bracket)*?) (\]) /oxgc) { $e_string .= e_split('qr',$1,$3,$2,'');   next E_STRING_LOOP; } # qq [ ] --> qr [ ]
                        elsif ($string =~ /\G (\<)          ((?:$qq_angle)*?)   (\>) /oxgc) { $e_string .= e_split('qr',$1,$3,$2,'');   next E_STRING_LOOP; } # qq < > --> qr < >
                        elsif ($string =~ /\G ([*\-:?\\^|]) ((?:$qq_char)*?)    (\1) /oxgc) { $e_string .= e_split('qr','{','}',$2,''); next E_STRING_LOOP; } # qq | | --> qr { }
                        elsif ($string =~ /\G (\S)          ((?:$qq_char)*?)    (\1) /oxgc) { $e_string .= e_split('qr',$1,$3,$2,'');   next E_STRING_LOOP; } # qq * * --> qr * *
                    }
                    die "$__FILE__: Can't find string terminator anywhere before EOF";
                }
            }

# split qr//
            elsif ($string =~ /\G \b (qr) \b /oxgc) {
                if ($string =~ /\G (\#) ((?:$qq_char)*?) (\#) ([imosxp]*) /oxgc)                        { $e_string .= e_split  ('qr',$1,$3,$2,$4);   next E_STRING_LOOP; } # qr# #
                else {
                    while ($string !~ /\G \z/oxgc) {
                        if    ($string =~ /\G (\s+|\#.*)                                         /oxgc) { $e_string .= $1; }
                        elsif ($string =~ /\G (\()          ((?:$qq_paren)*?)   (\)) ([imosxp]*) /oxgc) { $e_string .= e_split  ('qr',$1, $3, $2,$4); next E_STRING_LOOP; } # qr ( )
                        elsif ($string =~ /\G (\{)          ((?:$qq_brace)*?)   (\}) ([imosxp]*) /oxgc) { $e_string .= e_split  ('qr',$1, $3, $2,$4); next E_STRING_LOOP; } # qr { }
                        elsif ($string =~ /\G (\[)          ((?:$qq_bracket)*?) (\]) ([imosxp]*) /oxgc) { $e_string .= e_split  ('qr',$1, $3, $2,$4); next E_STRING_LOOP; } # qr [ ]
                        elsif ($string =~ /\G (\<)          ((?:$qq_angle)*?)   (\>) ([imosxp]*) /oxgc) { $e_string .= e_split  ('qr',$1, $3, $2,$4); next E_STRING_LOOP; } # qr < >
                        elsif ($string =~ /\G (\')          ((?:$qq_char)*?)    (\') ([imosxp]*) /oxgc) { $e_string .= e_split_q('qr',$1, $3, $2,$4); next E_STRING_LOOP; } # qr ' '
                        elsif ($string =~ /\G ([*\-:?\\^|]) ((?:$qq_char)*?)    (\1) ([imosxp]*) /oxgc) { $e_string .= e_split  ('qr','{','}',$2,$4); next E_STRING_LOOP; } # qr | | --> qr { }
                        elsif ($string =~ /\G (\S)          ((?:$qq_char)*?)    (\1) ([imosxp]*) /oxgc) { $e_string .= e_split  ('qr',$1, $3, $2,$4); next E_STRING_LOOP; } # qr * *
                    }
                    die "$__FILE__: Can't find string terminator anywhere before EOF";
                }
            }

# split q//
            elsif ($string =~ /\G \b (q) \b /oxgc) {
                if ($string =~ /\G (\#) ((?:\\\#|\\\\|$q_char)*?) (\#) /oxgc)                    { $e_string .= e_split_q('qr',$1,$3,$2,'');   next E_STRING_LOOP; } # q# #  --> qr # #
                else {
                    while ($string !~ /\G \z/oxgc) {
                        if    ($string =~ /\G (\s+|\#.*)                                  /oxgc) { $e_string .= $1; }
                        elsif ($string =~ /\G (\() ((?:\\\\|\\\)|\\\(|$q_paren)*?)   (\)) /oxgc) { $e_string .= e_split_q('qr',$1,$3,$2,'');   next E_STRING_LOOP; } # q ( ) --> qr ( )
                        elsif ($string =~ /\G (\{) ((?:\\\\|\\\}|\\\{|$q_brace)*?)   (\}) /oxgc) { $e_string .= e_split_q('qr',$1,$3,$2,'');   next E_STRING_LOOP; } # q { } --> qr { }
                        elsif ($string =~ /\G (\[) ((?:\\\\|\\\]|\\\[|$q_bracket)*?) (\]) /oxgc) { $e_string .= e_split_q('qr',$1,$3,$2,'');   next E_STRING_LOOP; } # q [ ] --> qr [ ]
                        elsif ($string =~ /\G (\<) ((?:\\\\|\\\>|\\\<|$q_angle)*?)   (\>) /oxgc) { $e_string .= e_split_q('qr',$1,$3,$2,'');   next E_STRING_LOOP; } # q < > --> qr < >
                        elsif ($string =~ /\G ([*\-:?\\^|])       ((?:$q_char)*?)    (\1) /oxgc) { $e_string .= e_split_q('qr','{','}',$2,''); next E_STRING_LOOP; } # q | | --> qr { }
                        elsif ($string =~ /\G (\S) ((?:\\\\|\\\1|     $q_char)*?)    (\1) /oxgc) { $e_string .= e_split_q('qr',$1,$3,$2,'');   next E_STRING_LOOP; } # q * * --> qr * *
                    }
                    die "$__FILE__: Can't find string terminator anywhere before EOF";
                }
            }

# split m//
            elsif ($string =~ /\G \b (m) \b /oxgc) {
                if ($string =~ /\G (\#) ((?:$qq_char)*?) (\#) ([cgimosxp]*) /oxgc)                        { $e_string .= e_split  ('qr',$1,$3,$2,$4);   next E_STRING_LOOP; } # m# #  --> qr # #
                else {
                    while ($string !~ /\G \z/oxgc) {
                        if    ($string =~ /\G (\s+|\#.*)                                           /oxgc) { $e_string .= $1; }
                        elsif ($string =~ /\G (\()          ((?:$qq_paren)*?)   (\)) ([cgimosxp]*) /oxgc) { $e_string .= e_split  ('qr',$1, $3, $2,$4); next E_STRING_LOOP; } # m ( ) --> qr ( )
                        elsif ($string =~ /\G (\{)          ((?:$qq_brace)*?)   (\}) ([cgimosxp]*) /oxgc) { $e_string .= e_split  ('qr',$1, $3, $2,$4); next E_STRING_LOOP; } # m { } --> qr { }
                        elsif ($string =~ /\G (\[)          ((?:$qq_bracket)*?) (\]) ([cgimosxp]*) /oxgc) { $e_string .= e_split  ('qr',$1, $3, $2,$4); next E_STRING_LOOP; } # m [ ] --> qr [ ]
                        elsif ($string =~ /\G (\<)          ((?:$qq_angle)*?)   (\>) ([cgimosxp]*) /oxgc) { $e_string .= e_split  ('qr',$1, $3, $2,$4); next E_STRING_LOOP; } # m < > --> qr < >
                        elsif ($string =~ /\G (\')          ((?:$qq_char)*?)    (\') ([cgimosxp]*) /oxgc) { $e_string .= e_split_q('qr',$1, $3, $2,$4); next E_STRING_LOOP; } # m ' ' --> qr ' '
                        elsif ($string =~ /\G ([*\-:?\\^|]) ((?:$qq_char)*?)    (\1) ([cgimosxp]*) /oxgc) { $e_string .= e_split  ('qr','{','}',$2,$4); next E_STRING_LOOP; } # m | | --> qr { }
                        elsif ($string =~ /\G (\S)          ((?:$qq_char)*?)    (\1) ([cgimosxp]*) /oxgc) { $e_string .= e_split  ('qr',$1, $3, $2,$4); next E_STRING_LOOP; } # m * * --> qr * *
                    }
                    die "$__FILE__: Search pattern not terminated";
                }
            }

# split ''
            elsif ($string =~ /\G (\') /oxgc) {
                my $q_string = '';
                while ($string !~ /\G \z/oxgc) {
                    if    ($string =~ /\G (\\\\)    /oxgc) { $q_string .= $1; }
                    elsif ($string =~ /\G (\\\')    /oxgc) { $q_string .= $1; } # splitqr'' --> split qr''
                    elsif ($string =~ /\G \'        /oxgc)                      { $e_string .= e_split_q(q{ qr},"'","'",$q_string,''); next E_STRING_LOOP; } # ' ' --> qr ' '
                    elsif ($string =~ /\G ($q_char) /oxgc) { $q_string .= $1; }
                }
                die "$__FILE__: Can't find string terminator anywhere before EOF";
            }

# split ""
            elsif ($string =~ /\G (\") /oxgc) {
                my $qq_string = '';
                while ($string !~ /\G \z/oxgc) {
                    if    ($string =~ /\G (\\\\)    /oxgc) { $qq_string .= $1; }
                    elsif ($string =~ /\G (\\\")    /oxgc) { $qq_string .= $1; } # splitqr"" --> split qr""
                    elsif ($string =~ /\G \"        /oxgc)                       { $e_string .= e_split(q{ qr},'"','"',$qq_string,''); next E_STRING_LOOP; } # " " --> qr " "
                    elsif ($string =~ /\G ($q_char) /oxgc) { $qq_string .= $1; }
                }
                die "$__FILE__: Can't find string terminator anywhere before EOF";
            }

# split //
            elsif ($string =~ /\G (\/) /oxgc) {
                my $regexp = '';
                while ($string !~ /\G \z/oxgc) {
                    if    ($string =~ /\G (\\\\)           /oxgc) { $regexp .= $1; }
                    elsif ($string =~ /\G (\\\/)           /oxgc) { $regexp .= $1; } # splitqr// --> split qr//
                    elsif ($string =~ /\G \/ ([cgimosxp]*) /oxgc)                    { $e_string .= e_split(q{ qr}, '/','/',$regexp,$1); next E_STRING_LOOP; } # / / --> qr / /
                    elsif ($string =~ /\G ($q_char)        /oxgc) { $regexp .= $1; }
                }
                die "$__FILE__: Search pattern not terminated";
            }
        }

# qq//
        elsif ($string =~ /\G \b (qq) \b /oxgc) {
            my $ope = $1;
            if ($string =~ /\G (\#) ((?:$qq_char)*?) (\#) /oxgc) { # qq# #
                $e_string .= e_qq($ope,$1,$3,$2);
            }
            else {
                my $e = '';
                while ($string !~ /\G \z/oxgc) {
                    if    ($string =~ /\G (\s+|\#.*)                    /oxgc) { $e .= $1; }
                    elsif ($string =~ /\G (\() ((?:$qq_paren)*?)   (\)) /oxgc) { $e_string .= $e . e_qq($ope,$1,$3,$2); next E_STRING_LOOP; } # qq ( )
                    elsif ($string =~ /\G (\{) ((?:$qq_brace)*?)   (\}) /oxgc) { $e_string .= $e . e_qq($ope,$1,$3,$2); next E_STRING_LOOP; } # qq { }
                    elsif ($string =~ /\G (\[) ((?:$qq_bracket)*?) (\]) /oxgc) { $e_string .= $e . e_qq($ope,$1,$3,$2); next E_STRING_LOOP; } # qq [ ]
                    elsif ($string =~ /\G (\<) ((?:$qq_angle)*?)   (\>) /oxgc) { $e_string .= $e . e_qq($ope,$1,$3,$2); next E_STRING_LOOP; } # qq < >
                    elsif ($string =~ /\G (\S) ((?:$qq_char)*?)    (\1) /oxgc) { $e_string .= $e . e_qq($ope,$1,$3,$2); next E_STRING_LOOP; } # qq * *
                }
                die "$__FILE__: Can't find string terminator anywhere before EOF";
            }
        }

# qx//
        elsif ($string =~ /\G \b (qx) \b /oxgc) {
            my $ope = $1;
            if ($string =~ /\G (\#) ((?:$qq_char)*?) (\#) /oxgc) { # qx# #
                $e_string .= e_qq($ope,$1,$3,$2);
            }
            else {
                my $e = '';
                while ($string !~ /\G \z/oxgc) {
                    if    ($string =~ /\G (\s+|\#.*)                    /oxgc) { $e .= $1; }
                    elsif ($string =~ /\G (\() ((?:$qq_paren)*?)   (\)) /oxgc) { $e_string .= $e . e_qq($ope,$1,$3,$2); next E_STRING_LOOP; } # qx ( )
                    elsif ($string =~ /\G (\{) ((?:$qq_brace)*?)   (\}) /oxgc) { $e_string .= $e . e_qq($ope,$1,$3,$2); next E_STRING_LOOP; } # qx { }
                    elsif ($string =~ /\G (\[) ((?:$qq_bracket)*?) (\]) /oxgc) { $e_string .= $e . e_qq($ope,$1,$3,$2); next E_STRING_LOOP; } # qx [ ]
                    elsif ($string =~ /\G (\<) ((?:$qq_angle)*?)   (\>) /oxgc) { $e_string .= $e . e_qq($ope,$1,$3,$2); next E_STRING_LOOP; } # qx < >
                    elsif ($string =~ /\G (\') ((?:$qq_char)*?)    (\') /oxgc) { $e_string .= $e . e_q ($ope,$1,$3,$2); next E_STRING_LOOP; } # qx ' '
                    elsif ($string =~ /\G (\S) ((?:$qq_char)*?)    (\1) /oxgc) { $e_string .= $e . e_qq($ope,$1,$3,$2); next E_STRING_LOOP; } # qx * *
                }
                die "$__FILE__: Can't find string terminator anywhere before EOF";
            }
        }

# q//
        elsif ($string =~ /\G \b (q) \b /oxgc) {
            my $ope = $1;
            if ($string =~ /\G (\#) ((?:\\\#|\\\\|$q_char)*?) (\#) /oxgc) { # q# #
                $e_string .= e_q($ope,$1,$3,$2);
            }
            else {
                my $e = '';
                while ($string !~ /\G \z/oxgc) {
                    if    ($string =~ /\G (\s+|\#.*)                                  /oxgc) { $e .= $1; }
                    elsif ($string =~ /\G (\() ((?:\\\\|\\\)|\\\(|$q_paren)*?)   (\)) /oxgc) { $e_string .= $e . e_q($ope,$1,$3,$2); next E_STRING_LOOP; } # q ( )
                    elsif ($string =~ /\G (\{) ((?:\\\\|\\\}|\\\{|$q_brace)*?)   (\}) /oxgc) { $e_string .= $e . e_q($ope,$1,$3,$2); next E_STRING_LOOP; } # q { }
                    elsif ($string =~ /\G (\[) ((?:\\\\|\\\]|\\\[|$q_bracket)*?) (\]) /oxgc) { $e_string .= $e . e_q($ope,$1,$3,$2); next E_STRING_LOOP; } # q [ ]
                    elsif ($string =~ /\G (\<) ((?:\\\\|\\\>|\\\<|$q_angle)*?)   (\>) /oxgc) { $e_string .= $e . e_q($ope,$1,$3,$2); next E_STRING_LOOP; } # q < >
                    elsif ($string =~ /\G (\S) ((?:\\\\|\\\1|     $q_char)*?)    (\1) /oxgc) { $e_string .= $e . e_q($ope,$1,$3,$2); next E_STRING_LOOP; } # q * *
                }
                die "$__FILE__: Can't find string terminator anywhere before EOF";
            }
        }

# ''
        elsif ($string =~ /\G (?<![\w\$\@\%\&\*]) (\') ((?:\\\'|\\\\|$q_char)*?) (\') /oxgc) { $e_string .= e_q('',$1,$3,$2);  }

# ""
        elsif ($string =~ /\G (\") ((?:$qq_char)*?) (\") /oxgc)                              { $e_string .= e_qq('',$1,$3,$2); }

# ``
        elsif ($string =~ /\G (\`) ((?:$qq_char)*?) (\`) /oxgc)                              { $e_string .= e_qq('',$1,$3,$2); }

# <<= <=> <= < operator
        elsif ($string =~ /\G (<<=|<=>|<=|<) (?= \s* [A-Za-z_0-9'"`\$\@\&\*\(\+\-] )/oxgc)   { $e_string .= $1;                }

# <FILEHANDLE>
        elsif ($string =~ /\G (<[\$]?[A-Za-z_][A-Za-z_0-9]*>) /oxgc)                         { $e_string .= $1;                }

# <WILDCARD>   --- glob
        elsif ($string =~ /\G < ((?:$q_char)+?) > /oxgc) {
            $e_string .= 'Eutf2::glob("' . $1 . '")';
        }

# << (bit shift)   --- not here document
        elsif ($string =~ /\G ( << \s* ) (?= [0-9\$\@\&] ) /oxgc) { $slash = 'm//'; $e_string .= $1; }

# <<'HEREDOC'
        elsif ($string =~ /\G ( << '([a-zA-Z_0-9]*)' ) /oxgc) {
            $slash = 'm//';
            my $here_quote = $1;
            my $delimiter  = $2;

            # get here document
            if ($here_script eq '') {
                $here_script = CORE::substr $_, pos $_;
                $here_script =~ s/.*?\n//oxm;
            }
            if ($here_script =~ s/\A (.*?) \n $delimiter \n //xms) {
                push @heredoc, $1 . qq{\n$delimiter\n};
                push @heredoc_delimiter, $delimiter;
            }
            else {
                die "$__FILE__: Can't find string terminator $delimiter anywhere before EOF";
            }
            $e_string .= $here_quote;
        }

# <<\HEREDOC
        elsif ($string =~ /\G ( << \\([a-zA-Z_0-9]+) ) /oxgc) {
            $slash = 'm//';
            my $here_quote = $1;
            my $delimiter  = $2;

            # get here document
            if ($here_script eq '') {
                $here_script = CORE::substr $_, pos $_;
                $here_script =~ s/.*?\n//oxm;
            }
            if ($here_script =~ s/\A (.*?) \n $delimiter \n //xms) {
                push @heredoc, $1 . qq{\n$delimiter\n};
                push @heredoc_delimiter, $delimiter;
            }
            else {
                die "$__FILE__: Can't find string terminator $delimiter anywhere before EOF";
            }
            $e_string .= $here_quote;
        }

# <<"HEREDOC"
        elsif ($string =~ /\G ( << "([a-zA-Z_0-9]*)" ) /oxgc) {
            $slash = 'm//';
            my $here_quote = $1;
            my $delimiter  = $2;

            # get here document
            if ($here_script eq '') {
                $here_script = CORE::substr $_, pos $_;
                $here_script =~ s/.*?\n//oxm;
            }
            if ($here_script =~ s/\A (.*?) \n $delimiter \n //xms) {
                push @heredoc, e_heredoc($1) . qq{\n$delimiter\n};
                push @heredoc_delimiter, $delimiter;
            }
            else {
                die "$__FILE__: Can't find string terminator $delimiter anywhere before EOF";
            }
            $e_string .= $here_quote;
        }

# <<HEREDOC
        elsif ($string =~ /\G ( << ([a-zA-Z_0-9]+) ) /oxgc) {
            $slash = 'm//';
            my $here_quote = $1;
            my $delimiter  = $2;

            # get here document
            if ($here_script eq '') {
                $here_script = CORE::substr $_, pos $_;
                $here_script =~ s/.*?\n//oxm;
            }
            if ($here_script =~ s/\A (.*?) \n $delimiter \n //xms) {
                push @heredoc, e_heredoc($1) . qq{\n$delimiter\n};
                push @heredoc_delimiter, $delimiter;
            }
            else {
                die "$__FILE__: Can't find string terminator $delimiter anywhere before EOF";
            }
            $e_string .= $here_quote;
        }

# <<`HEREDOC`
        elsif ($string =~ /\G ( << `([a-zA-Z_0-9]*)` ) /oxgc) {
            $slash = 'm//';
            my $here_quote = $1;
            my $delimiter  = $2;

            # get here document
            if ($here_script eq '') {
                $here_script = CORE::substr $_, pos $_;
                $here_script =~ s/.*?\n//oxm;
            }
            if ($here_script =~ s/\A (.*?) \n $delimiter \n //xms) {
                push @heredoc, e_heredoc($1) . qq{\n$delimiter\n};
                push @heredoc_delimiter, $delimiter;
            }
            else {
                die "$__FILE__: Can't find string terminator $delimiter anywhere before EOF";
            }
            $e_string .= $here_quote;
        }

        # any operator before div
        elsif ($string =~ /\G (
            -- | \+\+ |
            [\)\}\]]

            ) /oxgc) { $slash = 'div'; $e_string .= $1; }

        # any operator before m//
        elsif ($string =~ /\G (

            !~~ | !~ | != | ! |
            %= | % |
            &&= | && | &= | & |
            -= | -> | - |
            : |
            <<= | <=> | <= | < |
            == | => | =~ | = |
            >>= | >> | >= | > |
            \*\*= | \*\* | \*= | \* |
            \+= | \+ |
            \.\.\. | \.\. | \.= | \. |
            \/\/= | \/\/ |
            \/= | \/ |
            \? |
            \\ |
            \^= | \^ |
            \b x= |
            \|\|= | \|\| | \|= | \| |
            ~~ | ~ |
            \b(?: and | cmp | eq | ge | gt | le | lt | ne | not | or | xor | x )\b |
            \b(?: print )\b |

            [,;\(\{\[]

            ) /oxgc) { $slash = 'm//'; $e_string .= $1; }

        # other any character
        elsif ($string =~ /\G ($q_char) /oxgc) { $e_string .= $1; }

        # system error
        else {
            die "$__FILE__: oops, this shouldn't happen!";
        }
    }

    return $e_string;
}

#
# classic character class ( . \D \S \W \d \s \w \H \V \h \v )
#
sub classic_character_class {
    my($char,$modifier) = @_;

    return {
        '.'  => ($modifier =~ /s/) ?
                '(?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[\x00-\xFF])' :
                '(?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[^\x0A])',
        '\D' => '(?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[^0-9])',
        '\S' => '(?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[^\x09\x0A\x0C\x0D\x20])',
        '\W' => '(?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[^0-9A-Z_a-z])',
        '\d' => '[0-9]',
                 # \t  \n  \f  \r space
        '\s' => '[\x09\x0A\x0C\x0D\x20]',
        '\w' => '[0-9A-Z_a-z]',

        # \h \v \H \V
        #
        # P.114 Character Class Shortcuts
        # in Chapter 7: In the World of Regular Expressions
        # of ISBN 978-0-596-52010-6 Learning Perl, Fifth Edition

        '\H' => '(?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[^\x09\x20])',
        '\V' => '(?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[^\x0C\x0A\x0D])',
        '\h' => '[\x09\x20]',
        '\v' => '[\x0C\x0A\x0D]',

    }->{$char};
}

#
# escape transliteration (tr/// or y///)
#
sub e_tr {
    my($variable,$charclass,$e,$charclass2,$modifier) = @_;
    my $e_tr = '';
    $modifier ||= '';

    $slash = 'div';

    # quote character class 1
    $charclass  = q_tr($charclass);

    # quote character class 2
    $charclass2 = q_tr($charclass2);

    # /b /B modifier
    if ($modifier =~ tr/bB//d) {
        if ($variable eq '') {
            $e_tr = qq{tr$charclass$e$charclass2$modifier};
        }
        else {
            $e_tr = qq{$variable${bind_operator}tr$charclass$e$charclass2$modifier};
        }
    }
    else {
        if ($variable eq '') {
            $e_tr = qq{Eutf2::tr(\$_,      ' =~ ',          $charclass,$e$charclass2,'$modifier')};
        }
        else {
            $e_tr = qq{Eutf2::tr($variable,'$bind_operator',$charclass,$e$charclass2,'$modifier')};
        }
    }

    # clear tr/// variable
    $tr_variable = '';
    $bind_operator = '';

    return $e_tr;
}

#
# quote for escape transliteration (tr/// or y///)
#
sub q_tr {
    my($charclass) = @_;

    # quote character class
    if ($charclass !~ m/'/oxms) {
        return e_q('',  "'", "'", $charclass); # --> q' '
    }
    elsif ($charclass !~ m{/}oxms) {
        return e_q('q',  '/', '/', $charclass); # --> q/ /
    }
    elsif ($charclass !~ m/\#/oxms) {
        return e_q('q',  '#', '#', $charclass); # --> q# #
    }
    elsif ($charclass !~ m/[\<\>]/oxms) {
        return e_q('q', '<', '>', $charclass); # --> q< >
    }
    elsif ($charclass !~ m/[\(\)]/oxms) {
        return e_q('q', '(', ')', $charclass); # --> q( )
    }
    elsif ($charclass !~ m/[\{\}]/oxms) {
        return e_q('q', '{', '}', $charclass); # --> q{ }
    }
    else {
        for my $char (qw( ! " $ % & * + . : = ? @ ^ ` | ~ ), "\x00".."\x1F", "\x7F", "\xFF") {
            if ($charclass !~ m/\Q$char\E/xms) {
                return e_q('q', $char, $char, $charclass);
            }
        }
    }

    return e_q('q', '{', '}', $charclass);
}

#
# escape q string (q//, '')
#
sub e_q {
    my($ope,$delimiter,$end_delimiter,$string) = @_;

    $slash = 'div';

    return join '', $ope, $delimiter, $string, $end_delimiter;
}

#
# escape qq string (qq//, "", qx//, ``)
#
sub e_qq {
    my($ope,$delimiter,$end_delimiter,$string) = @_;

    $slash = 'div';

    my $metachar = qr/[\@\\\|]/oxms; # '|' is for qx//, ``, open() and system()

    # escape character
    my @char = $string =~ m{ \G (
        \$ \s* \d+                 |
        \$ \s* \{ \s* \d+ \s* \}   |
        \$ \$ (?![\w\{])           |
        \$ \s* \$ \s* $qq_variable |
        \\?(?:$q_char)
    )}oxmsg;

    for (my $i=0; $i <= $#char; $i++) {
        if (0) {
        }

        # $0 --> $0
        elsif ($char[$i] =~ m/\A \$ 0 \z/oxms) {
        }
        elsif ($char[$i] =~ m/\A \$ \{ \s* 0 \s* \} \z/oxms) {
        }

        # $$ --> $$
        elsif ($char[$i] =~ m/\A \$\$ \z/oxms) {
        }

        # $1, $2, $3 --> $2, $3, $4
        elsif ($char[$i] =~ m/\A \$ ([1-9][0-9]*) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }
        elsif ($char[$i] =~ m/\A \$ \{ \s* ([1-9][0-9]*) \s* \} \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }

        # $$foo[ ... ] --> $ $foo->[ ... ]
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \[ (?:$qq_bracket)*? \] ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
        }

        # $$foo{ ... } --> $ $foo->{ ... }
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \{ (?:$qq_brace)*? \} ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
        }

        # $$foo
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }

        # ${ foo } --> ${ foo }
        elsif ($char[$i] =~ m/\A \$ \s* \{ \s* [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* \s* \} \z/oxms) {
        }

        # ${ ... }
        elsif ($char[$i] =~ m/\A \$ \s* \{ \s* ( .+ ) \s* \} \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }
    }

    # return string
    return     join '', $ope, $delimiter, @char,                               $end_delimiter;
}

#
# escape qw string (qw//)
#
sub e_qw {
    my($ope,$delimiter,$end_delimiter,$string) = @_;

    $slash = 'div';

    # choice again delimiter
    my %octet = map {$_ => 1} ($string =~ m/\G ([\x00-\xFF]) /oxmsg);
    if (not $octet{$end_delimiter}) {
        return join '', $ope, $delimiter, $string, $end_delimiter;
    }
    elsif (not $octet{')'}) {
        return join '', $ope, '(',        $string, ')';
    }
    elsif (not $octet{'}'}) {
        return join '', $ope, '{',        $string, '}';
    }
    elsif (not $octet{']'}) {
        return join '', $ope, '[',        $string, ']';
    }
    elsif (not $octet{'>'}) {
        return join '', $ope, '<',        $string, '>';
    }
    else {
        for my $char (qw( ! " $ % & * + - . / : = ? @ ^ ` | ~ ), "\x00".."\x1F", "\x7F", "\xFF") {
            if (not $octet{$char}) {
                return join '', $ope,      $char, $string, $char;
            }
        }
    }

    # qw/AAA BBB C'CC/ --> ('AAA', 'BBB', 'C\'CC')
    my @string = CORE::split(/\s+/, $string);
    for my $string (@string) {
        my @octet = $string =~ m/\G ([\x00-\xFF]) /oxmsg;
        for my $octet (@octet) {
            if ($octet =~ m/\A (['\\]) \z/oxms) {
                $octet = '\\' . $1;
            }
        }
        $string = join '', @octet;
    }
    return join '', '(', (join ', ', map { "'$_'" } @string), ')';
}

#
# escape here document (<<"HEREDOC", <<HEREDOC, <<`HEREDOC`)
#
sub e_heredoc {
    my($string) = @_;

    $slash = 'm//';

    my $metachar = qr/[\@\\|]/oxms; # '|' is for <<`HEREDOC`

    # escape character
    my @char = $string =~ m{ \G (
        \$ \s* \d+                 |
        \$ \s* \{ \s* \d+ \s* \}   |
        \$ \$ (?![\w\{])           |
        \$ \s* \$ \s* $qq_variable |
        \\?(?:$q_char)
    )}oxmsg;

    for (my $i=0; $i <= $#char; $i++) {
        if (0) {
        }

        # $0 --> $0
        elsif ($char[$i] =~ m/\A \$ 0 \z/oxms) {
        }
        elsif ($char[$i] =~ m/\A \$ \{ \s* 0 \s* \} \z/oxms) {
        }

        # $$ --> $$
        elsif ($char[$i] =~ m/\A \$\$ \z/oxms) {
        }

        # $1, $2, $3 --> $2, $3, $4
        elsif ($char[$i] =~ m/\A \$ ([1-9][0-9]*) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }
        elsif ($char[$i] =~ m/\A \$ \{ \s* ([1-9][0-9]*) \s* \} \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }

        # $$foo[ ... ] --> $ $foo->[ ... ]
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \[ (?:$qq_bracket)*? \] ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
        }

        # $$foo{ ... } --> $ $foo->{ ... }
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \{ (?:$qq_brace)*? \} ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
        }

        # $$foo
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }

        # ${ foo } --> ${ foo }
        elsif ($char[$i] =~ m/\A \$ \s* \{ \s* [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* \s* \} \z/oxms) {
        }

        # ${ ... }
        elsif ($char[$i] =~ m/\A \$ \s* \{ \s* ( .+ ) \s* \} \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }
    }

    # return string
    return     join '', @char;
}

#
# escape regexp (m//, qr//)
#
sub e_qr {
    my($ope,$delimiter,$end_delimiter,$string,$modifier) = @_;
    $modifier ||= '';

    $slash = 'div';

    my $metachar = qr/[\@\\|[\]{^]/oxms;

    # split regexp
    my @char = $string =~ m{\G(
        \\  [0-7]{2,3}             |
        \\x [0-9A-Fa-f]{1,2}       |
        \\c [\x40-\x5F]            |
        \\  (?:$q_char)            |
        [\$\@] $qq_variable        |
        \$ \s* \d+                 |
        \$ \s* \{ \s* \d+ \s* \}   |
        \$ \$ (?![\w\{])           |
        \$ \s* \$ \s* $qq_variable |
        \[\:\^ [a-z]+ \:\]         |
        \[\:   [a-z]+ \:\]         |
        \[\^                       |
        \(\?                       |
            (?:$q_char)
    )}oxmsg;

    # choice again delimiter
    if ($delimiter =~ m/ [\@:] /oxms) {
        my %octet = map {$_ => 1} @char;
        if (not $octet{')'}) {
            $delimiter     = '(';
            $end_delimiter = ')';
        }
        elsif (not $octet{'}'}) {
            $delimiter     = '{';
            $end_delimiter = '}';
        }
        elsif (not $octet{']'}) {
            $delimiter     = '[';
            $end_delimiter = ']';
        }
        elsif (not $octet{'>'}) {
            $delimiter     = '<';
            $end_delimiter = '>';
        }
        else {
            for my $char (qw( ! " $ % & * + - . / = ? ^ ` | ~ ), "\x00".."\x1F", "\x7F", "\xFF") {
                if (not $octet{$char}) {
                    $delimiter     = $char;
                    $end_delimiter = $char;
                    last;
                }
            }
        }
    }

    # unescape character
    for (my $i=0; $i <= $#char; $i++) {
        if (0) {
        }

        # join separated multiple octet
        elsif ($char[$i] =~ m/\A (?: \\ [0-7]{2,3} | \\x [0-9A-Fa-f]{1,2}) \z/oxms) {
            if (   ($i+3 <= $#char) and (grep(m/\A (?: \\ [0-7]{2,3} | \\x [0-9A-Fa-f]{1,2}) \z/oxms, @char[$i+1..$i+3]) == 3) and (eval(sprintf '"%s%s%s%s"', @char[$i..$i+3]) =~ m/\A $q_char \z/oxms)) {
                $char[$i] .= join '', splice @char, $i+1, 3;
            }
            elsif (($i+2 <= $#char) and (grep(m/\A (?: \\ [0-7]{2,3} | \\x [0-9A-Fa-f]{1,2}) \z/oxms, @char[$i+1..$i+2]) == 2) and (eval(sprintf '"%s%s%s"',   @char[$i..$i+2]) =~ m/\A $q_char \z/oxms)) {
                $char[$i] .= join '', splice @char, $i+1, 2;
            }
            elsif (($i+1 <= $#char) and (grep(m/\A (?: \\ [0-7]{2,3} | \\x [0-9A-Fa-f]{1,2}) \z/oxms, $char[$i+1      ]) == 1) and (eval(sprintf '"%s%s"',     @char[$i..$i+1]) =~ m/\A $q_char \z/oxms)) {
                $char[$i] .= join '', splice @char, $i+1, 1;
            }
        }

        # open character class [...]
        elsif ($char[$i] eq '[') {
            my $left = $i;
            while (1) {
                if (++$i > $#char) {
                    die "$__FILE__: unmatched [] in regexp";
                }
                if ($char[$i] eq ']') {
                    my $right = $i;

                    # [...]
                    splice @char, $left, $right-$left+1, Eutf2::charlist_qr(@char[$left+1..$right-1], $modifier);

                    $i = $left;
                    last;
                }
            }
        }

        # open character class [^...]
        elsif ($char[$i] eq '[^') {
            my $left = $i;
            while (1) {
                if (++$i > $#char) {
                    die "$__FILE__: unmatched [] in regexp";
                }
                if ($char[$i] eq ']') {
                    my $right = $i;

                    # [^...]
                    splice @char, $left, $right-$left+1, Eutf2::charlist_not_qr(@char[$left+1..$right-1], $modifier);

                    $i = $left;
                    last;
                }
            }
        }

        # rewrite character class or escape character
        elsif (my $char = classic_character_class($char[$i],$modifier)) {
            $char[$i] = $char;
        }

        # /i modifier
        elsif ($char[$i] =~ m/\A [A-Za-z] \z/oxms) {
        }

        # $0 --> $0
        elsif ($char[$i] =~ m/\A \$ 0 \z/oxms) {
        }
        elsif ($char[$i] =~ m/\A \$ \{ \s* 0 \s* \} \z/oxms) {
        }

        # $$ --> $$
        elsif ($char[$i] =~ m/\A \$\$ \z/oxms) {
        }

        # $1, $2, $3 --> $2, $3, $4
        elsif ($char[$i] =~ m/\A \$ ([1-9][0-9]*) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }
        elsif ($char[$i] =~ m/\A \$ \{ \s* ([1-9][0-9]*) \s* \} \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }

        # $$foo[ ... ] --> $ $foo->[ ... ]
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \[ (?:$qq_bracket)*? \] ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
        }

        # $$foo{ ... } --> $ $foo->{ ... }
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \{ (?:$qq_brace)*? \} ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
        }

        # $$foo
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }

        # ${ foo }
        elsif ($char[$i] =~ m/\A \$ \s* \{ ( \s* [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* \s* ) \} \z/oxms) {
        }

        # ${ ... }
        elsif ($char[$i] =~ m/\A \$ \s* \{ \s* ( .+ ) \s* \} \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }

        # $scalar or @array
        elsif ($char[$i] =~ m/\A [\$\@].+ /oxms) {
            $char[$i] = e_string($char[$i]);
        }

        # quote character before ? + * {
        elsif (($i >= 1) and ($char[$i] =~ m/\A [\?\+\*\{] \z/oxms)) {
            if ($char[$i-1] !~ m/\A (?:[\x00-\xFF]|\\[0-7]{2,3}|\\x[0-9-A-Fa-f]{1,2}) \z/oxms) {
                $char[$i-1] = '(?:' . $char[$i-1] . ')';
            }
        }
    }

    # make regexp string
    return     join '', $ope, $delimiter, "$your_gap(?:", @char,                               ')', $m_matched, $end_delimiter, $modifier;
}

#
# escape regexp (m'', qr'')
#
sub e_qr_q {
    my($ope,$delimiter,$end_delimiter,$string,$modifier) = @_;
    $modifier ||= '';

    $slash = 'div';

    # split regexp
    my @char = $string =~ m{\G(
        \[\:\^ [a-z]+ \:\] |
        \[\:   [a-z]+ \:\] |
        \[\^               |
        [$@/\\]            |
        \\?    (?:$q_char)
    )}oxmsg;

    # unescape character
    for (my $i=0; $i <= $#char; $i++) {
        if (0) {
        }

        # open character class [...]
        elsif ($char[$i] eq '[') {
            my $left = $i;
            while (1) {
                if (++$i > $#char) {
                    die "$__FILE__: unmatched [] in regexp";
                }
                if ($char[$i] eq ']') {
                    my $right = $i;

                    # [...]
                    splice @char, $left, $right-$left+1, Eutf2::charlist_qr(@char[$left+1..$right-1], $modifier);

                    $i = $left;
                    last;
                }
            }
        }

        # open character class [^...]
        elsif ($char[$i] eq '[^') {
            my $left = $i;
            while (1) {
                if (++$i > $#char) {
                    die "$__FILE__: unmatched [] in regexp";
                }
                if ($char[$i] eq ']') {
                    my $right = $i;

                    # [^...]
                    splice @char, $left, $right-$left+1, Eutf2::charlist_not_qr(@char[$left+1..$right-1], $modifier);

                    $i = $left;
                    last;
                }
            }
        }

        # escape $ @ / and \
        elsif ($char[$i] =~ m{\A [$@/\\] \z}oxms) {
            $char[$i] = '\\' . $char[$i];
        }

        # rewrite character class or escape character
        elsif (my $char = classic_character_class($char[$i],$modifier)) {
            $char[$i] = $char;
        }

        # /i modifier
        elsif ($char[$i] =~ m/\A [A-Za-z] \z/oxms) {
        }

        # quote character before ? + * {
        elsif (($i >= 1) and ($char[$i] =~ m/\A [\?\+\*\{] \z/oxms)) {
            if ($char[$i-1] !~ m/\A [\x00-\xFF] \z/oxms) {
                $char[$i-1] = '(?:' . $char[$i-1] . ')';
            }
        }
    }

    $delimiter     = '/';
    $end_delimiter = '/';
    return join '', $ope, $delimiter, "$your_gap(?:", @char, ')', $m_matched, $end_delimiter, $modifier;
}

#
# escape regexp (s/here//)
#
sub e_s1 {
    my($ope,$delimiter,$end_delimiter,$string,$modifier) = @_;
    $modifier ||= '';

    $slash = 'div';

    my $metachar = qr/[\@\\|[\]{^]/oxms;

    # split regexp
    my @char = $string =~ m{\G(
        \\g \s* \{ \s* - \s* [1-9][0-9]* \s* \} |
        \\g \s* \{ \s*       [1-9][0-9]* \s* \} |
        \\g \s*              [1-9][0-9]*        |
        \\                   [1-9][0-9]*        |
        \\  [0-7]{2,3}                          |
        \\x [0-9A-Fa-f]{1,2}                    |
        \\c [\x40-\x5F]                         |
        \\  (?:$q_char)                         |
        [\$\@] $qq_variable                     |
        \$ \s* \d+                              |
        \$ \s* \{ \s* \d+ \s* \}                |
        \$ \$ (?![\w\{])                        |
        \$ \s* \$ \s* $qq_variable              |
        \[\:\^ [a-z]+ \:\]                      |
        \[\:   [a-z]+ \:\]                      |
        \[\^                                    |
        \(\?                                    |
            (?:$q_char)
    )}oxmsg;

    # choice again delimiter
    if ($delimiter =~ m/ [\@:] /oxms) {
        my %octet = map {$_ => 1} @char;
        if (not $octet{')'}) {
            $delimiter     = '(';
            $end_delimiter = ')';
        }
        elsif (not $octet{'}'}) {
            $delimiter     = '{';
            $end_delimiter = '}';
        }
        elsif (not $octet{']'}) {
            $delimiter     = '[';
            $end_delimiter = ']';
        }
        elsif (not $octet{'>'}) {
            $delimiter     = '<';
            $end_delimiter = '>';
        }
        else {
            for my $char (qw( ! " $ % & * + - . / = ? ^ ` | ~ ), "\x00".."\x1F", "\x7F", "\xFF") {
                if (not $octet{$char}) {
                    $delimiter     = $char;
                    $end_delimiter = $char;
                    last;
                }
            }
        }
    }

    # count '('
    my $parens = grep { $_ eq '(' } @char;

    # unescape character
    for (my $i=0; $i <= $#char; $i++) {
        if (0) {
        }

        # join separated multiple octet
        elsif ($char[$i] =~ m/\A (?: \\ [0-7]{2,3} | \\x [0-9A-Fa-f]{1,2}) \z/oxms) {
            if (   ($i+3 <= $#char) and (grep(m/\A (?: \\ [0-7]{2,3} | \\x [0-9A-Fa-f]{1,2}) \z/oxms, @char[$i+1..$i+3]) == 3) and (eval(sprintf '"%s%s%s%s"', @char[$i..$i+3]) =~ m/\A $q_char \z/oxms)) {
                $char[$i] .= join '', splice @char, $i+1, 3;
            }
            elsif (($i+2 <= $#char) and (grep(m/\A (?: \\ [0-7]{2,3} | \\x [0-9A-Fa-f]{1,2}) \z/oxms, @char[$i+1..$i+2]) == 2) and (eval(sprintf '"%s%s%s"',   @char[$i..$i+2]) =~ m/\A $q_char \z/oxms)) {
                $char[$i] .= join '', splice @char, $i+1, 2;
            }
            elsif (($i+1 <= $#char) and (grep(m/\A (?: \\ [0-7]{2,3} | \\x [0-9A-Fa-f]{1,2}) \z/oxms, $char[$i+1      ]) == 1) and (eval(sprintf '"%s%s"',     @char[$i..$i+1]) =~ m/\A $q_char \z/oxms)) {
                $char[$i] .= join '', splice @char, $i+1, 1;
            }
        }

        # open character class [...]
        elsif ($char[$i] eq '[') {
            my $left = $i;
            while (1) {
                if (++$i > $#char) {
                    die "$__FILE__: unmatched [] in regexp";
                }
                if ($char[$i] eq ']') {
                    my $right = $i;

                    # [...]
                    splice @char, $left, $right-$left+1, Eutf2::charlist_qr(@char[$left+1..$right-1], $modifier);

                    $i = $left;
                    last;
                }
            }
        }

        # open character class [^...]
        elsif ($char[$i] eq '[^') {
            my $left = $i;
            while (1) {
                if (++$i > $#char) {
                    die "$__FILE__: unmatched [] in regexp";
                }
                if ($char[$i] eq ']') {
                    my $right = $i;

                    # [^...]
                    splice @char, $left, $right-$left+1, Eutf2::charlist_not_qr(@char[$left+1..$right-1], $modifier);

                    $i = $left;
                    last;
                }
            }
        }

        # rewrite character class or escape character
        elsif (my $char = classic_character_class($char[$i],$modifier)) {
            $char[$i] = $char;
        }

        # /i modifier
        elsif ($char[$i] =~ m/\A [A-Za-z] \z/oxms) {
        }

        # \0 --> \0
        elsif ($char[$i] =~ m/\A \\ \s* 0 \z/oxms) {
        }

        # \g{N}, \g{-N}
        #
        # P.108 Using Simple Patterns
        # in Chapter 7: In the World of Regular Expressions
        # of ISBN 978-0-596-52010-6 Learning Perl, Fifth Edition

        # \g{-1}, \g{-2}, \g{-3} --> \g{-1}, \g{-2}, \g{-3}
        elsif ($char[$i] =~ m/\A \\g \s* \{ \s* - \s* ([1-9][0-9]*) \s* \} \z/oxms) {
        }

        # \g{1}, \g{2}, \g{3} --> \g{2}, \g{3}, \g{4}
        elsif ($char[$i] =~ m/\A \\g \s* \{ \s* ([1-9][0-9]*) \s* \} \z/oxms) {
            if ($1 <= $parens) {
                $char[$i] = '\\g{' . ($1 + 1) . '}';
            }
        }

        # \g1, \g2, \g3 --> \g2, \g3, \g4
        elsif ($char[$i] =~ m/\A \\g \s* ([1-9][0-9]*) \z/oxms) {
            if ($1 <= $parens) {
                $char[$i] = '\\g' . ($1 + 1);
            }
        }

        # \1, \2, \3 --> \2, \3, \4
        elsif ($char[$i] =~ m/\A \\ \s* ([1-9][0-9]*) \z/oxms) {
            if ($1 <= $parens) {
                $char[$i] = '\\' . ($1 + 1);
            }
        }

        # $0 --> $0
        elsif ($char[$i] =~ m/\A \$ 0 \z/oxms) {
        }
        elsif ($char[$i] =~ m/\A \$ \{ \s* 0 \s* \} \z/oxms) {
        }

        # $$ --> $$
        elsif ($char[$i] =~ m/\A \$\$ \z/oxms) {
        }

        # $1, $2, $3 --> $2, $3, $4
        elsif ($char[$i] =~ m/\A \$ ([1-9][0-9]*) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }
        elsif ($char[$i] =~ m/\A \$ \{ \s* ([1-9][0-9]*) \s* \} \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }

        # $$foo[ ... ] --> $ $foo->[ ... ]
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \[ (?:$qq_bracket)*? \] ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
        }

        # $$foo{ ... } --> $ $foo->{ ... }
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \{ (?:$qq_brace)*? \} ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
        }

        # $$foo
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }

        # ${ foo }
        elsif ($char[$i] =~ m/\A \$ \s* \{ ( \s* [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* \s* ) \} \z/oxms) {
        }

        # ${ ... }
        elsif ($char[$i] =~ m/\A \$ \s* \{ \s* ( .+ ) \s* \} \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }

        # $scalar or @array
        elsif ($char[$i] =~ m/\A [\$\@].+ /oxms) {
            $char[$i] = e_string($char[$i]);
        }

        # quote character before ? + * {
        elsif (($i >= 1) and ($char[$i] =~ m/\A [\?\+\*\{] \z/oxms)) {
            if ($char[$i-1] !~ m/\A (?:[\x00-\xFF]|\\[0-7]{2,3}|\\x[0-9-A-Fa-f]{1,2}) \z/oxms) {
                $char[$i-1] = '(?:' . $char[$i-1] . ')';
            }
        }
    }

    # make regexp string
    return     join '', $ope, $delimiter, "($your_gap)(?:", @char,                               ')', $s_matched, $end_delimiter, $modifier;
}

#
# escape regexp (s'here'')
#
sub e_s1_q {
    my($ope,$delimiter,$end_delimiter,$string,$modifier) = @_;
    $modifier ||= '';

    $slash = 'div';

    # split regexp
    my @char = $string =~ m{\G(
        \[\:\^ [a-z]+ \:\] |
        \[\:   [a-z]+ \:\] |
        \[\^               |
        [$@/\\]            |
        \\?    (?:$q_char)
    )}oxmsg;

    # unescape character
    for (my $i=0; $i <= $#char; $i++) {
        if (0) {
        }

        # open character class [...]
        elsif ($char[$i] eq '[') {
            my $left = $i;
            while (1) {
                if (++$i > $#char) {
                    die "$__FILE__: unmatched [] in regexp";
                }
                if ($char[$i] eq ']') {
                    my $right = $i;

                    # [...]
                    splice @char, $left, $right-$left+1, Eutf2::charlist_qr(@char[$left+1..$right-1], $modifier);

                    $i = $left;
                    last;
                }
            }
        }

        # open character class [^...]
        elsif ($char[$i] eq '[^') {
            my $left = $i;
            while (1) {
                if (++$i > $#char) {
                    die "$__FILE__: unmatched [] in regexp";
                }
                if ($char[$i] eq ']') {
                    my $right = $i;

                    # [^...]
                    splice @char, $left, $right-$left+1, Eutf2::charlist_not_qr(@char[$left+1..$right-1], $modifier);

                    $i = $left;
                    last;
                }
            }
        }

        # escape $ @ / and \
        elsif ($char[$i] =~ m{\A [$@/\\] \z}oxms) {
            $char[$i] = '\\' . $char[$i];
        }

        # rewrite character class or escape character
        elsif (my $char = classic_character_class($char[$i],$modifier)) {
            $char[$i] = $char;
        }

        # /i modifier
        elsif ($char[$i] =~ m/\A [A-Za-z] \z/oxms) {
        }

        # quote character before ? + * {
        elsif (($i >= 1) and ($char[$i] =~ m/\A [\?\+\*\{] \z/oxms)) {
            if ($char[$i-1] !~ m/\A [\x00-\xFF] \z/oxms) {
                $char[$i-1] = '(?:' . $char[$i-1] . ')';
            }
        }
    }

    $delimiter     = '/';
    $end_delimiter = '/';
    return join '', $ope, $delimiter, "($your_gap)(?:", @char, ')', $s_matched, $end_delimiter, $modifier;
}

#
# escape regexp (s''here')
#
sub e_s2_q {
    my($ope,$delimiter,$end_delimiter,$string) = @_;

    $slash = 'div';

    my @char = $string =~ m/ \G ([$@\/\\]|$q_char) /oxmsg;
    for (my $i=0; $i <= $#char; $i++) {
        if (0) {
        }

        # escape $ @ / and \
        elsif ($char[$i] =~ m{\A [$@/\\] \z}oxms) {
            $char[$i] = '\\' . $char[$i];
        }
    }

    return join '', $ope, $delimiter, @char,   $end_delimiter;
}

#
# escape regexp (s/here/and here/modifier)
#
sub e_sub {
    my($variable,$delimiter1,$pattern,$end_delimiter1,$delimiter2,$replacement,$end_delimiter2,$modifier) = @_;
    $modifier ||= '';

    if ($variable eq '') {
        $variable      = '$_';
        $bind_operator = ' =~ ';
    }

    $slash = 'div';

    # P.128 Start of match (or end of previous match): \G
    # in Chapter 3: Overview of Regular Expression Features and Flavors
    # P.312 Iterative Matching: Scalar Context, with /g
    # in Chapter 7: Perl
    # of ISBN 0-596-00272-6 Mastering Regular Expressions, Second edition 

    my $e_modifier = $modifier =~ tr/e//d;

    my $my = '';
    if ($variable =~ s/\A \( \s* ( (?: local \b | my \b | our \b | state \b )? .+ ) \) \z/$1/oxms) {
        $my = $variable;
        $variable =~ s/ (?: local \b | my \b | our \b | state \b ) \s* //oxms;
        $variable =~ s/ = .+ \z//oxms;
    }

    (my $variable_basename = $variable) =~ s/ [\[\{].* \z//oxms;
    $variable_basename =~ s/ \s+ \z//oxms;

    # quote replacement string
    my $q_replacement = '';
    if ($delimiter2 eq "'") {
        $q_replacement = e_s2_q('qq', '/',         '/',             $replacement);
    }
    else {
        $q_replacement = e_qq  ('qq', $delimiter2, $end_delimiter2, $replacement);
    }

    # escape replacement string
    my $e_replacement = '';
    if ($q_replacement !~ m/'/oxms) {
        $e_replacement = e_q('',  "'", "'", $q_replacement); # --> q' '
    }
    elsif ($q_replacement !~ m{/}oxms) {
        $e_replacement = e_q('q',  '/', '/', $q_replacement); # --> q/ /
    }
    elsif ($q_replacement !~ m/\#/oxms) {
        $e_replacement = e_q('q',  '#', '#', $q_replacement); # --> q# #
    }
    elsif ($q_replacement !~ m/[\<\>]/oxms) {
        $e_replacement = e_q('q', '<', '>', $q_replacement); # --> q< >
    }
    elsif ($q_replacement !~ m/[\(\)]/oxms) {
        $e_replacement = e_q('q', '(', ')', $q_replacement); # --> q( )
    }
    elsif ($q_replacement !~ m/[\{\}]/oxms) {
        $e_replacement = e_q('q', '{', '}', $q_replacement); # --> q{ }
    }
    else {
        for my $char (qw( ! " $ % & * + . : = ? @ ^ ` | ~ ), "\x00".."\x1F", "\x7F", "\xFF") {
            if ($q_replacement !~ m/\Q$char\E/xms) {
                $e_replacement = e_q('q', $char, $char, $q_replacement);
                last;
            }
        }
    }

    my $local = '';
    if ($variable_basename =~ /::/) {
        $local = 'local';
    }
    else{
        $local = 'my';
    }

    # s///g
    my $sub;
    if ($modifier =~ m/g/oxms) {

        $sub = sprintf(
            #      1  2       3  4              5 6 7   8  9         10  1112  13      14           15          16      17     18          19       20    21      22
            q<eval{%s %s_n=0; %s %s_a=''; while(%s%s%s){%s %s_r=eval %s; %s%s="%s_a${1}%s_r$'"; pos(%s)=length "%s_a${1}%s_r"; %s_a=substr(%s,0,pos(%s)); %s_n++} %s_n}>,

            $local,                                                                       #  1
                $variable_basename,                                                       #  2
            $local,                                                                       #  3
                $variable_basename,                                                       #  4
            $variable,                                                                    #  5
            $bind_operator,                                                               #  6
            ($delimiter1 eq "'") ?                                                        #  7
            e_s1_q('m', $delimiter1, $end_delimiter1, $pattern, $modifier) :              #  :
            e_s1  ('m', $delimiter1, $end_delimiter1, $pattern, $modifier),               #  :
            $local,                                                                       #  8
                $variable_basename,                                                       #  9
            $e_replacement,                                                               # 10
            sprintf('%s_r=eval %s_r; ', $variable_basename, $variable_basename) x $e_modifier, # 11
            $variable,                                                                    # 12
                $variable_basename,                                                       # 13
                $variable_basename,                                                       # 14
            $variable,                                                                    # 15
                $variable_basename,                                                       # 16
                $variable_basename,                                                       # 17
                $variable_basename,                                                       # 18
            $variable,                                                                    # 19
            $variable,                                                                    # 20
                $variable_basename,                                                       # 21
                $variable_basename,                                                       # 22
        );
    }

    # s///
    else {
        $sub = sprintf(
            #  1 2 3          4  5         6   7 8       9
            q<(%s%s%s) ? eval{%s %s_r=eval %s; %s%s="${1}%s_r$'"; 1 } : ''>,

            $variable,                                                                    # 1
            $bind_operator,                                                               # 2
            ($delimiter1 eq "'") ?                                                        # 3
            e_s1_q('m', $delimiter1, $end_delimiter1, $pattern, $modifier) :              # :
            e_s1  ('m', $delimiter1, $end_delimiter1, $pattern, $modifier),               # :
            $local,                                                                       # 4
                $variable_basename,                                                       # 5
            $e_replacement,                                                               # 6
            sprintf('%s_r=eval %s_r; ', $variable_basename, $variable_basename) x $e_modifier, # 7
            $variable,                                                                    # 8
                $variable_basename,                                                       # 9
        );
    }

    # (my $foo = $bar) =~ s///   -->   (my $foo = $bar, eval { ... })[1]
    if ($my ne '') {
        $sub = "($my, $sub)[1]";
    }

    # clear s/// variable
    $sub_variable = '';
    $bind_operator = '';

    return $sub;
}

#
# escape regexp of split qr//
#
sub e_split {
    my($ope,$delimiter,$end_delimiter,$string,$modifier) = @_;
    $modifier ||= '';

    $slash = 'div';

    my $metachar = qr/[\@\\|[\]{^]/oxms;

    # split regexp
    my @char = $string =~ m{\G(
        \\  [0-7]{2,3}             |
        \\x [0-9A-Fa-f]{1,2}       |
        \\c [\x40-\x5F]            |
        \\  (?:$q_char)            |
        [\$\@] $qq_variable        |
        \$ \s* \d+                 |
        \$ \s* \{ \s* \d+ \s* \}   |
        \$ \$ (?![\w\{])           |
        \$ \s* \$ \s* $qq_variable |
        \[\:\^ [a-z]+ \:\]         |
        \[\:   [a-z]+ \:\]         |
        \[\^                       |
        \(\?                       |
            (?:$q_char)
    )}oxmsg;

    # unescape character
    for (my $i=0; $i <= $#char; $i++) {
        if (0) {
        }

        # join separated multiple octet
        elsif ($char[$i] =~ m/\A (?: \\ [0-7]{2,3} | \\x [0-9A-Fa-f]{1,2}) \z/oxms) {
            if (   ($i+3 <= $#char) and (grep(m/\A (?: \\ [0-7]{2,3} | \\x [0-9A-Fa-f]{1,2}) \z/oxms, @char[$i+1..$i+3]) == 3) and (eval(sprintf '"%s%s%s%s"', @char[$i..$i+3]) =~ m/\A $q_char \z/oxms)) {
                $char[$i] .= join '', splice @char, $i+1, 3;
            }
            elsif (($i+2 <= $#char) and (grep(m/\A (?: \\ [0-7]{2,3} | \\x [0-9A-Fa-f]{1,2}) \z/oxms, @char[$i+1..$i+2]) == 2) and (eval(sprintf '"%s%s%s"',   @char[$i..$i+2]) =~ m/\A $q_char \z/oxms)) {
                $char[$i] .= join '', splice @char, $i+1, 2;
            }
            elsif (($i+1 <= $#char) and (grep(m/\A (?: \\ [0-7]{2,3} | \\x [0-9A-Fa-f]{1,2}) \z/oxms, $char[$i+1      ]) == 1) and (eval(sprintf '"%s%s"',     @char[$i..$i+1]) =~ m/\A $q_char \z/oxms)) {
                $char[$i] .= join '', splice @char, $i+1, 1;
            }
        }

        # open character class [...]
        elsif ($char[$i] eq '[') {
            my $left = $i;
            while (1) {
                if (++$i > $#char) {
                    die "$__FILE__: unmatched [] in regexp";
                }
                if ($char[$i] eq ']') {
                    my $right = $i;

                    # [...]
                    splice @char, $left, $right-$left+1, Eutf2::charlist_qr(@char[$left+1..$right-1], $modifier);

                    $i = $left;
                    last;
                }
            }
        }

        # open character class [^...]
        elsif ($char[$i] eq '[^') {
            my $left = $i;
            while (1) {
                if (++$i > $#char) {
                    die "$__FILE__: unmatched [] in regexp";
                }
                if ($char[$i] eq ']') {
                    my $right = $i;

                    # [^...]
                    splice @char, $left, $right-$left+1, Eutf2::charlist_not_qr(@char[$left+1..$right-1], $modifier);

                    $i = $left;
                    last;
                }
            }
        }

        # rewrite character class or escape character
        elsif (my $char = classic_character_class($char[$i],$modifier)) {
            $char[$i] = $char;
        }

        # P.794 29.2.161. split
        # in Chapter 29: Functions
        # of ISBN 0-596-00027-8 Programming Perl Third Edition.
        # said "The //m modifier is assumed when you split on the pattern /^/",
        # but perl5.008 is not so. Therefore, this software adds //m.
        # (and so on)

        # split(m/^/) --> split(m/^/m)
        elsif (($char[$i] eq '^') and ($modifier !~ m/m/oxms)) {
            $modifier .= 'm';
        }

        # /i modifier
        elsif ($char[$i] =~ m/\A ([A-Za-z]) \z/oxms) {
        }

        # $0 --> $0
        elsif ($char[$i] =~ m/\A \$ 0 \z/oxms) {
        }
        elsif ($char[$i] =~ m/\A \$ \{ \s* 0 \s* \} \z/oxms) {
        }

        # $$ --> $$
        elsif ($char[$i] =~ m/\A \$\$ \z/oxms) {
        }

        # $1, $2, $3 --> $2, $3, $4
        elsif ($char[$i] =~ m/\A \$ ([1-9][0-9]*) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }
        elsif ($char[$i] =~ m/\A \$ \{ \s* ([1-9][0-9]*) \s* \} \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }

        # $$foo[ ... ] --> $ $foo->[ ... ]
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \[ (?:$qq_bracket)*? \] ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
        }

        # $$foo{ ... } --> $ $foo->{ ... }
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) ( \{ (?:$qq_brace)*? \} ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . '->' . $2 . ')}';
        }

        # $$foo
        elsif ($char[$i] =~ m/\A \$ ( \$ [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* ) \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }

        # ${ foo }
        elsif ($char[$i] =~ m/\A \$ \s* \{ ( \s* [A-Za-z_][A-Za-z0-9_]*(?: ::[A-Za-z_][A-Za-z0-9_]*)* \s* ) \} \z/oxms) {
        }

        # ${ ... }
        elsif ($char[$i] =~ m/\A \$ \s* \{ \s* ( .+ ) \s* \} \z/oxms) {
            $char[$i] = '${Eutf2::capture(' . $1 . ')}';
        }

        # $scalar or @array
        elsif ($char[$i] =~ m/\A [\$\@].+ /oxms) {
            $char[$i] = e_string($char[$i]);
        }

        # quote character before ? + * {
        elsif (($i >= 1) and ($char[$i] =~ m/\A [\?\+\*\{] \z/oxms)) {
            if ($char[$i-1] !~ m/\A (?:[\x00-\xFF]|\\[0-7]{2,3}|\\x[0-9-A-Fa-f]{1,2}) \z/oxms) {
                $char[$i-1] = '(?:' . $char[$i-1] . ')';
            }
        }
    }

    # make regexp string
    return     join '', $ope, $delimiter, @char,                               $end_delimiter, $modifier;
}

#
# escape regexp of split qr''
#
sub e_split_q {
    my($ope,$delimiter,$end_delimiter,$string,$modifier) = @_;
    $modifier ||= '';

    $slash = 'div';

    # split regexp
    my @char = $string =~ m{\G(
        \[\:\^ [a-z]+ \:\] |
        \[\:   [a-z]+ \:\] |
        \[\^               |
        \\?    (?:$q_char)
    )}oxmsg;

    # unescape character
    for (my $i=0; $i <= $#char; $i++) {
        if (0) {
        }

        # open character class [...]
        elsif ($char[$i] eq '[') {
            my $left = $i;
            while (1) {
                if (++$i > $#char) {
                    die "$__FILE__: unmatched [] in regexp";
                }
                if ($char[$i] eq ']') {
                    my $right = $i;

                    # [...]
                    splice @char, $left, $right-$left+1, Eutf2::charlist_qr(@char[$left+1..$right-1], $modifier);

                    $i = $left;
                    last;
                }
            }
        }

        # open character class [^...]
        elsif ($char[$i] eq '[^') {
            my $left = $i;
            while (1) {
                if (++$i > $#char) {
                    die "$__FILE__: unmatched [] in regexp";
                }
                if ($char[$i] eq ']') {
                    my $right = $i;

                    # [^...]
                    splice @char, $left, $right-$left+1, Eutf2::charlist_not_qr(@char[$left+1..$right-1], $modifier);

                    $i = $left;
                    last;
                }
            }
        }

        # rewrite character class or escape character
        elsif (my $char = classic_character_class($char[$i],$modifier)) {
            $char[$i] = $char;
        }

        # split(m/^/) --> split(m/^/m)
        elsif (($char[$i] eq '^') and ($modifier !~ m/m/oxms)) {
            $modifier .= 'm';
        }

        # /i modifier
        elsif ($char[$i] =~ m/\A ([A-Za-z]) \z/oxms) {
        }

        # quote character before ? + * {
        elsif (($i >= 1) and ($char[$i] =~ m/\A [\?\+\*\{] \z/oxms)) {
            if ($char[$i-1] !~ m/\A [\x00-\xFF] \z/oxms) {
                $char[$i-1] = '(?:' . $char[$i-1] . ')';
            }
        }
    }

    return join '', $ope, $delimiter, @char, $end_delimiter, $modifier;
}

1;

__END__

=pod

=head1 NAME

UTF2 - "Yet Another JPerl" Source code filter to escape UTF-2

=head1 SYNOPSIS

  use UTF2;
  use UTF2 version;         --- require version
  use UTF2 qw(ord reverse); --- demand enhanced feature of ord and reverse
  use UTF2 version qw(ord reverse);

  functions:
    UTF2::ord(...);
    UTF2::reverse(...);
    UTF2::length(...);
    UTF2::substr(...);
    UTF2::index(...);
    UTF2::rindex(...);

  # "no UTF2;" not supported

  or

  C:\>perl UTF2.pm UTF-2_script.pl > Escaped_script.pl.e

  UTF-2_script.pl  --- script written in UTF-2
  Escaped_script.pl.e --- escaped script

=head1 ABSTRACT

Let's start with a bit of history: jperl 4.019+1.3 introduced UTF-2 support.
You could apply chop() and regexps even to complex CJK characters.

JPerl in CPAN Perl Ports (Binary Distributions)

http://www.cpan.org/ports/index.html#jperl

said,

  As of Perl 5.8.0 it is suggested that instead of JPerl (which is
  based on a quite old release of Perl) you should just use Perl 5.8.0,
  since it can do all that JPerl did, and more.

But is it really so?

In this country, UTF-2 is widely used on mainframe I/O, the personal computer,
and the cellular phone. This software treats UTF-2 directly. Therefor there is
not UTF8 flag.

Shall we escape from the encode problem?

=head1 Yet Another Future Of

JPerl is very useful software. -- Oops, note, this "JPerl" means Japanized or
Japanese Perl, so is unrelated to Java and JVM. Therefore, I named this software
better, fitter UTF2.

Now, the last version of JPerl is 5.005_04 and is not maintained now.

Japanization modifier WATANABE Hirofumi said,

  "Because WATANABE am tired I give over maintaing JPerl."

at Slide #15: "The future of JPerl" of

L<ftp://ftp.oreilly.co.jp/pcjp98/watanabe/jperlconf.ppt>

in The Perl Confernce Japan 1998.

When I heard it, I thought that someone excluding me would maintain JPerl.
And I slept every night hanging a sock. Night and day, I kept having hope.
After 10 years, I noticed that white beard exists in the sock :-)

This software is a source code filter to escape Perl script encoded by UTF-2
given from STDIN or command line parameter. The character code is never converted
by escaping the script. Neither the value of the character nor the length of the
character string change even if it escapes.

What's this software good for ...

=over 2

=item * Possible to handle raw UTF-2 values

=item * Backward compatibility of data, script and how to

=item * No UTF8 flag, perlunitut and perluniadvice

=item * No C programming (for maintain JPerl)

=item * Independent from binary file (CPU, OS, perl version, 32bit/64bit)

=back

Let's make yet another future by JPerl's future.

=head1 BASIC IDEA

I discovered this mail again recently.

[Tokyo.pm] jus Benkyoukai

http://mail.pm.org/pipermail/tokyo-pm/1999-September/001854.html

save as: SJIS.pm

  package SJIS;
  use Filter::Util::Call;
  sub multibyte_filter {
      my $status;
      if (($status = filter_read()) > 0 ) {
          s/([\x81-\x9f\xe0-\xef])([\x40-\x7e\x80-\xfc])/
              sprintf("\\x%02x\\x%02x",ord($1),ord($2))
          /eg;
      }
      $status;
  }
  sub import {
      filter_add(\&multibyte_filter);
  }
  1;

I am glad that I could confirm my idea is not so wrong.

=head1 SOFTWARE COMPOSITION

   UTF2.pm          --- source code filter to escape UTF-2
   Eutf2.pm         --- run-time routines for UTF2.pm
   perl58.bat       --- find and run perl5.8  without %PATH% settings
   perl510.bat      --- find and run perl5.10 without %PATH% settings
   perl512.bat      --- find and run perl5.12 without %PATH% settings
   perl64.bat       --- find and run perl64   without %PATH% settings

=head1 CHARACTER CLASSES

The character classes are redefined as follows to backward compatibility.

  ---------------------------------------------------------------------------
  escape        class
  ---------------------------------------------------------------------------
  \d            [0-9]
  \s            [\x09\x0A\x0C\x0D\x20]
  \w            [0-9A-Z_a-z]
  \D            (?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[^0-9])
  \S            (?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[^\x09\x0A\x0C\x0D\x20])
  \W            (?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[^0-9A-Z_a-z])
  \h            [\x09\x20]
  \v            [\x0C\x0A\x0D]
  \H            (?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[^\x09\x20])
  \V            (?:(?:[\xC2-\xDF]|[\xE0-\xE0][\xA0-\xBF]|[\xE1-\xEC][\x80-\xBF]|[\xED-\xED][\x80-\x9F]|[\xEE-\xEF][\x80-\xBF]|[\xF0-\xF0][\x90-\xBF][\x80-\xBF]|[\xF1-\xF3][\x80-\xBF][\x80-\xBF]|[\xF4-\xF4][\x80-\x8F][\x80-\xBF])[\x00-\xFF]|[^\x0C\x0A\x0D])
  ---------------------------------------------------------------------------

=head1 JPerl COMPATIBLE FUNCTIONS

The following functions function as much as JPerl.
A part of function in the script is written and changes by this software.

=over 2

=item * handle multiple octet string in single quote

=item * handle multiple octet string in double quote

=item * handle multiple octet regexp in single quote

=item * handle multiple octet regexp in double quote

=item * chop --> Eutf2::chop

=item * split --> Eutf2::split

=item * length

=item * substr

=item * index --> Eutf2::index

=item * rindex --> Eutf2::rindex

=item * pos

=item * ord (when no import)

=item * reverse (when no import)

=item * tr/// or y/// --> Eutf2::tr

/b and /B modifier can also be used.

=item * require --> require

=item * use Perl::Module @list; --> BEGIN { require 'Perl/Module.pm'; Perl::Module->import(@list) if Perl::Module->can('import'); }

=item * use Perl::Module (); --> BEGIN { require 'Perl/Module.pm'; }

=back

=head1 JPerl UPPER COMPATIBLE FUNCTIONS

The following functions are enhanced more than JPerl.

=over 2

=item * chr --> Eutf2::chr or Eutf2::chr_

multiple octet code can also be handled.

=item * glob --> Eutf2::glob or Eutf2::glob_

  @glob = Eutf2::glob($string);
  @glob = Eutf2::glob_;

Eutf2::glob provides a portable enhanced DOS-like globbing for the UTF2 software.
Eutf2::glob lets you use wildcards in directory paths, is case-insensitive, and
accepts both backslashes and forward slashes (although you may have to double the
backslashes).

From a Perl script:

use UTF2;
@perlfiles = glob  "..\pe?l/*.p?";
print <..\pe?l/*.p?>;

a tilde ("~") expands to the current user's home directory.
support chr(0x5C) ended path on MSWin32.

=item * ord --> UTF2::ord or UTF2::ord_

multiple octet code can also be handled when "use UTF2 qw(ord);".
It means not compatible with JPerl.

=item * reverse --> UTF2::reverse

multiple octet code can also be handled in scalar context when "use UTF2 qw(reverse);".
It means not compatible with JPerl.

=back

=head1 CHARACTER ORIENTED FUNCTIONS

=item Order of Character

  $ord = UTF2::ord($string);

  This function returns the numeric value (ASCII or UTF-2) of the first character
  of $string. The return value is always unsigned.

=item Reverse list or string

  @reverse = UTF2::reverse(@list);
  $reverse = UTF2::reverse(@list);

  In list context, this function returns a list value consisting of the elements of
  @list in the opposite order. The function can be used to create descending
  sequences:

  for (UTF2::reverse(1 .. 10)) { ... }

  Because of the way hashes flatten into lists when passed as a @list, reverse can
  also be used to invert a hash, presuming the values are unique:

  %barfoo = UTF2::reverse(%foobar);

  In scalar context, the function concatenates all the elements of LIST and then
  returns the reverse of that resulting string, character by character.

=item length by UTF-2 character

  $length = UTF2::length($string);
  $length = UTF2::length();

  This function returns the length in characters of the scalar value $string. If
  $string is omitted, it returns the UTF2::length of $_.

  Do not try to use length to find the size of an array or hash. Use scalar @array
  for the size of an array, and scalar keys %hash for the number of key/value pairs
  in a hash. (The scalar is typically omitted when redundant.)

  To find the length of a string in bytes rather than characters, say:

  $blen = length $string;

  or

  $blen = CORE::length $string;

=item substr by UTF-2 character

  $substr = UTF2::substr($string,$offset,$length,$replacement);
  $substr = UTF2::substr($string,$offset,$length);
  $substr = UTF2::substr($string,$offset);

  This function extracts a substring out of the string given by $string and returns
  it. The substring is extracted starting at $offset characters from the front of
  the string.
  If $offset is negative, the substring starts that far from the end of the string
  instead. If $length is omitted, everything to the end of the string is returned.
  If $length is negative, the length is calculated to leave that many characters off
  the end of the string. Otherwise, $length indicates the length of the substring to
  extract, which is sort of what you'd expect.

  An alternative to using UTF2::substr as an lvalue is to specify the $replacement
  string as the fourth argument. This allows you to replace parts of the $string and
  return what was there before in one operation, just as you can with splice. The next
  example also replaces the last character of $var with "Curly" and puts that replaced
  character into $oldstr: 

  $oldstr = UTF2::substr($var, -1, 1, "Curly");

  If you assign something shorter than the length of your substring, the string will
  shrink, and if you assign something longer than the length, the string will grow to
  accommodate it. To keep the string the same length, you may need to pad or chop your
  value using sprintf or the x operator. If you attempt to assign to an unallocated
  area past the end of the string, UTF2::substr raises an exception.

  To prepend the string "Larry" to the current value of $_, use:

  UTF2::substr($var, 0, 0, "Larry");

  To instead replace the first character of $_ with "Moe", use:

  UTF2::substr($var, 0, 1, "Moe");

  And finally, to replace the last character of $var with "Curly", use:

  UTF2::substr($var, -1, 1, "Curly");

=item index by UTF-2 character

  $index = UTF2::index($string,$substring,$offset);
  $index = UTF2::index($string,$substring);

  This function searches for one string within another. It returns the position of
  the first occurrence of $substring in $string. The $offset, if specified, says how
  many characters from the start to skip before beginning to look. Positions are
  based at 0. If the substring is not found, the function returns one less than the
  base, ordinarily -1. To work your way through a string, you might say:

  $pos = -1;
  while (($pos = UTF2::index($string, $lookfor, $pos)) > -1) {
      print "Found at $pos\n";
      $pos++;
  }

=item rindex by UTF-2 character

  $rindex = UTF2::rindex($string,$substring,$position);
  $rindex = UTF2::rindex($string,$substring);

  This function works just like UTF2::index except that it returns the position of
  the last occurrence of $substring in $string (a reverse index). The function
  returns -1 if not $substring is found. $position, if specified, is the rightmost
  position that may be returned. To work your way through a string backward, say:

  $pos = UTF2::length($string);
  while (($pos = UTF2::rindex($string, $lookfor, $pos)) >= 0) {
      print "Found at $pos\n";
      $pos--;
  }

=back

=head1 ENVIRONMENT VARIABLE

 This software uses the flock function for exclusive control. The execution of the
 program is blocked until it becomes possible to read or write the file.
 You can have it not block in the flock function by defining environment variable
 SJIS_NONBLOCK.
 
 Example:
 
   SET SJIS_NONBLOCK=1
 
 (The value '1' doesn't have the meaning)

=head1 BUGS AND LIMITATIONS

Please patches and report problems to author are welcome.

=over 2

=item * format

Function "format" can't handle multiple octet code same as original Perl.

=item * /o modifier of m/$re/o, s/$re/foo/o and qr/$re/o

/o modifier doesn't do operation the same as the expectation on perl5.6.1.
The latest value of variable $re is used as a regular expression.

=back

=head1 AUTHOR

INABA Hitoshi E<lt>ina@cpan.orgE<gt>

This project was originated by INABA Hitoshi.
For any questions, use E<lt>ina@cpan.orgE<gt> so we can share
this file.

=head1 LICENSE AND COPYRIGHT

This software is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=head1 MY GOAL

P.401 See chapter 15: Unicode
of ISBN 0-596-00027-8 Programming Perl Third Edition.

Before the introduction of Unicode support in perl, The eq operator
just compared the byte-strings represented by two scalars. Beginning
with perl 5.8, eq compares two byte-strings with simultaneous
consideration of the UTF8 flag.

This change consequentially made a big gap between a past script and
new script. Both scripts cannot re-use the code mutually any longer.
Because a new method puts a strain in the programmer, it will still take
time to replace all the in existence scripts.

The biggest problem of new method is that the UTF8 flag can't synchronize
to real encode of string. Thus you must debug about UTF8 flag, before
your script. How to solve it by returning to a past method, I will quote
page 402 of Programming Perl, 3rd ed. again.

Ideally, I'd like to achieve these five Goals:

=over 2

=item Goal #1:

Old byte-oriented programs should not spontaneously break on the old
byte-oriented data they used to work on.

It has already been achieved by UTF-2 designed for combining with
old byte-oriented ASCII.

=item Goal #2:

Old byte-oriented programs should magically start working on the new
character-oriented data when appropriate.

Still now, 1 octet is counted with 1 by embedded functions length,
substr, index, rindex and pos that handle length and position of string.
In this part, there is no change. The length of 1 character of 2 octet
code is 2.

On the other hand, the regular expression in the script is added the
multibyte anchoring processing with this software, instead of you.

figure of Goal #1 and Goal #2.

                               GOAL#1  GOAL#2
                        (a)     (b)     (c)     (d)     (e)
      +--------------+-------+-------+-------+-------+-------+
      | data         |  Old  |  Old  |  New  |  Old  |  New  |
      +--------------+-------+-------+-------+-------+-------+
      | script       |  Old  |      Old      |      New      |
      +--------------+-------+---------------+---------------+
      | interpreter  |  Old  |              New              |
      +--------------+-------+-------------------------------+
      Old --- Old byte-oriented
      New --- New character-oriented

There is a combination from (a) to (e) in data, script and interpreter
of old and new. Let's add the Encode module and this software did not
exist at time of be written this document and JPerl did exist.

                        (a)     (b)     (c)     (d)     (e)
                                      JPerl           Encode,UTF2
      +--------------+-------+-------+-------+-------+-------+
      | data         |  Old  |  Old  |  New  |  Old  |  New  |
      +--------------+-------+-------+-------+-------+-------+
      | script       |  Old  |      Old      |      New      |
      +--------------+-------+---------------+---------------+
      | interpreter  |  Old  |              New              |
      +--------------+-------+-------------------------------+
      Old --- Old byte-oriented
      New --- New character-oriented

The reason why JPerl is very excellent is that it is at the position of
(c). That is, it is not necessary to do a special description to the
script to process new character-oriented string.

Contrasting is Encode module and describing "use UTF2;" on this software,
in this case, a new description is necessary.

=item Goal #3:

Programs should run just as fast in the new character-oriented mode
as in the old byte-oriented mode.

It is impossible. Because the following time is necessary.

(1) Time of escape script for old byte-oriented perl.

(2) Time of processing regular expression by escaped script while
    multibyte anchoring.

=item Goal #4:

Perl should remain one language, rather than forking into a
byte-oriented Perl and a character-oriented Perl.

JPerl forked the perl interpreter so as not to fork the Perl language.
But the Perl core team might not hope for the perl interpreter's
divergence.

A character-oriented Perl is not necessary to make it specially,
because a byte-oriented Perl can already treat the binary data.
This software is only an application program of Perl, a filter program.
If perl can be executed, this software will be able to be executed.

And when you solve the problem by the perl script, the perl community
will support you.

=item Goal #5:

JPerl users will be able to maintain JPerl by Perl.

--- maybe, and sure.

=back

Back when Programming Perl, 3rd ed. was written, UTF8 flag was not born
and Perl is designed to make the easy jobs easy. This software provide
programming environment like at that time.

=head1 SEE ALSO

 Programming Perl, Second Edition
 By Larry Wall, Tom Christiansen, Randal L. Schwartz
 January 1900 (really so?)
 Pages: 670
 ISBN 10: 1-56592-149-6 | ISBN 13: 9781565921498
 http://oreilly.com/catalog/9781565921498/

 Programming Perl, Third Edition
 By Larry Wall, Tom Christiansen, Jon Orwant
 Third Edition  July 2000
 Pages: 1104
 ISBN 10: 0-596-00027-8 | ISBN 13:9780596000271
 http://www.oreilly.com/catalog/pperl3/index.html

 Perl Cookbook, Second Edition
 By Tom Christiansen, Nathan Torkington
 Second Edition  August 2003
 Pages: 964
 ISBN 10: 0-596-00313-7 | ISBN 13: 9780596003135
 http://oreilly.com/catalog/9780596003135/index.html

 Perl in a Nutshell, Second Edition
 By Stephen Spainhour, Ellen Siever, Nathan Patwardhan
 Second Edition  June 2002
 Pages: 760
 Series: In a Nutshell
 ISBN 10: 0-596-00241-6 | ISBN 13: 9780596002411
 http://oreilly.com/catalog/9780596002411/index.html

 Learning Perl on Win32 Systems
 By Randal L. Schwartz, Erik Olson, Tom Christiansen
 August 1997
 Pages: 306
 ISBN 10: 1-56592-324-3 | ISBN 13: 9781565923249
 http://oreilly.com/catalog/9781565923249/

 Learning Perl, Fifth Edition
 By Randal L. Schwartz, Tom Phoenix, brian d foy
 June 2008
 Pages: 352
 Print ISBN:978-0-596-52010-6 | ISBN 10: 0-596-52010-7
 Ebook ISBN:978-0-596-10316-3 | ISBN 10: 0-596-10316-6
 http://oreilly.com/catalog/9780596520113/

 Perl RESOURCE KIT UNIX EDITION
 Futato, Irving, Jepson, Patwardhan, Siever
 ISBN 10: 1-56592-370-7

 Understanding Japanese Information Processing
 By Ken Lunde
 January 1900
 Pages: 470
 ISBN 10: 1-56592-043-0 | ISBN 13: 9781565920439
 http://oreilly.com/catalog/9781565920439/

 CJKV Information Processing
 Chinese, Japanese, Korean & Vietnamese Computing
 By Ken Lunde
 First Edition  January 1999
 Pages: 1128
 ISBN 10: 1-56592-224-7 | ISBN 13:9781565922242
 http://www.oreilly.com/catalog/cjkvinfo/index.html
 ISBN 4-87311-108-0
 http://www.oreilly.co.jp/books/4873111080/

 Mastering Regular Expressions, Second Edition
 By Jeffrey E. F. Friedl
 Second Edition  July 2002
 Pages: 484
 ISBN 10: 0-596-00289-0 | ISBN 13: 9780596002893
 http://oreilly.com/catalog/9780596002893/index.html

 Mastering Regular Expressions, Third Edition
 By Jeffrey E. F. Friedl
 Third Edition  August 2006
 Pages: 542
 ISBN 10: 0-596-52812-4 | ISBN 13:9780596528126
 http://www.oreilly.com/catalog/regex3/index.html
 ISBN 978-4-87311-359-3
 http://www.oreilly.co.jp/books/9784873113593/

 PERL PUROGURAMINGU
 Larry Wall, Randal L.Schwartz, Yoshiyuki Kondo
 December 1997
 ISBN 4-89052-384-7
 http://www.context.co.jp/~cond/books/old-books.html

 JIS KANJI JITEN
 Kouji Shibano
 Pages: 1456
 ISBN 4-542-20129-5
 http://www.webstore.jsa.or.jp/lib/lib.asp?fn=/manual/mnl01_12.htm

 UNIX MAGAZINE
 1993 Aug
 Pages: 172
 T1008901080816 ZASSHI 08901-8
 http://ascii.asciimw.jp/books/magazines/unix.shtml
 
 Yet Another JPerl family
 http://search.cpan.org/dist/Big5Plus/
 http://search.cpan.org/dist/EUCJP/
 http://search.cpan.org/dist/GB18030/
 http://search.cpan.org/dist/HP15/
 http://search.cpan.org/dist/INFORMIXV6ALS/
 http://search.cpan.org/dist/UTF2/
 http://search.cpan.org/dist/UHC/
 http://search.cpan.org/dist/UTF2/
 http://search.cpan.org/dist/jacode/

=head1 ACKNOWLEDGEMENTS

This software was made referring to software and the document that the
following hackers or persons had made. 
I am thankful to all persons.

 Rick Yamashita, Shift_JIS
 ttp://furukawablog.spaces.live.com/Blog/cns!1pmWgsL289nm7Shn7cS0jHzA!2225.entry
 (add 'h' at head)

 Larry Wall, Perl
 http://www.perl.org/

 Kazumasa Utashiro, jcode.pl
 ftp://ftp.iij.ad.jp/pub/IIJ/dist/utashiro/perl/

 Jeffrey E. F. Friedl, Mastering Regular Expressions
 http://www.oreilly.com/catalog/regex/index.html

 SADAHIRO Tomoyuki, The right way of using Shift_JIS
 http://homepage1.nifty.com/nomenclator/perl/shiftjis.htm

 Yukihiro "Matz" Matsumoto, YAPC::Asia2006 Ruby on Perl(s)
 http://www.rubyist.net/~matz/slides/yapc2006/

 jscripter, For jperl users
 http://homepage1.nifty.com/kazuf/jperl.html

 Bruce., Unicode in Perl
 http://www.rakunet.org/TSNET/TSabc/18/546.html

 Hiroaki Izumi, Perl5.8/Perl5.10 is not useful on the Windows.
 http://www.aritia.org/hizumi/perl/perlwin.html

 TSUKAMOTO Makio, Perl memo/file path of Windows
 http://digit.que.ne.jp/work/wiki.cgi?Perl%E3%83%A1%E3%83%A2%2FWindows%E3%81%A7%E3%81%AE%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%83%91%E3%82%B9

 chaichanPaPa, Matching Shift_JIS file name
 http://d.hatena.ne.jp/chaichanPaPa/20080802/1217660826

 SUZUKI Norio, Jperl
 http://homepage2.nifty.com/kipp/perl/jperl/

 WATANABE Hirofumi, Jperl
 http://search.cpan.org/~watanabe/
 ftp://ftp.oreilly.co.jp/pcjp98/watanabe/jperlconf.ppt

 Dan Kogai, Encode module
 http://search.cpan.org/dist/Encode/

 Juerd, Perl Unicode Advice
 http://juerd.nl/site.plp/perluniadvice

 Tokyo-pm archive
 http://mail.pm.org/pipermail/tokyo-pm/
 http://mail.pm.org/pipermail/tokyo-pm/1999-September/001844.html
 http://mail.pm.org/pipermail/tokyo-pm/1999-September/001854.html

 ruby-list
 http://blade.nagaokaut.ac.jp/ruby/ruby-list/index.shtml
 http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/2440
 http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/2446
 http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/2569
 http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/9427
 http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/9431
 http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/10500
 http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/10501
 http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/10502
 http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/12385
 http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/12392
 http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/12393
 http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-list/19156

=cut

