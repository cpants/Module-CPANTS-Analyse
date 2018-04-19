use strict;
use warnings;
use Test::More;

# copied from what would be generated by Dist::Zilla::Plugin::Test::PodSpelling 2.007002
use Test::Spelling 0.12;
use Pod::Wordlist;


add_stopwords(<DATA>);
all_pod_files_spelling_ok( qw( lib t xt ) );
__DATA__
Brocard
CPANTS
Gábor
Klausner
Léon
Martín
Müller
Schwern
Steffen
Szabó
TODO
Utils
analyse
analysers
packageable
testdir
testfile
unextracted