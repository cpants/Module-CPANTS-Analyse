use 5.008001;
use strict;
use warnings;
use ExtUtils::MakeMaker::CPANfile;

my $test_requires; # Decide between TEST_REQUIRES / BUILD_REQUIRES / PREREQ_PM
if ($ExtUtils::MakeMaker::VERSION >= 6.6303) {
	#
	# Good, we can use TEST_REQUIRES
	#
	$test_requires = 'TEST_REQUIRES';
} elsif ($ExtUtils::MakeMaker::VERSION >= 6.5503) {
	#
	# Not new enough - use BUILD_REQUIRES
	#
	$test_requires = 'BUILD_REQUIRES';
} else {
	#
	# Tool old version - use PREREQ_PM
	#
	$test_requires = 'PREREQ_PM';
}
my %test_requires = ( $test_requires => { 'Test::File' => 1.993 } );

WriteMakefile(
  NAME => 'Module::CPANTS::Analyse',
  AUTHOR => [
    'Thomas Klausner <domm@cpan.org>',
    'Kenichi Ishigaki <ishigaki@cpan.org>',
  ],
  ABSTRACT_FROM => 'lib/Module/CPANTS/Analyse.pm',
  VERSION_FROM => 'lib/Module/CPANTS/Analyse.pm',
  LICENSE => 'perl',

  META_MERGE => {
    resources => {
      homepage => 'https://cpants.cpanauthors.org',
      repository => 'https://github.com/cpants/Module-CPANTS-Analyse',
      bugtracker => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Module-CPANTS-Analyse',
    },
    keywords => [
      'CPANTS','kwalitee',
    ],
  },
  %test_requires,

  test => {TESTS => 't/*.t t/*/*.t'},
);
