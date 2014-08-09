use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Module::CPANTS::TestAnalyse;

test_distribution {
  my ($mca, $dir) = @_;
  write_file("$dir/MANIFEST", <<"EOF");
lib/Module/CPANTS/Analyse/Test.pm
MANIFEST
EOF
  write_pmfile("$dir/lib/Module/CPANTS/Analyse/Test.pm");

  my $stash = $mca->run;
  is $stash->{manifest_matches_dist} => 1, "manifest matches dist";
};

test_distribution {
  my ($mca, $dir) = @_;
  write_pmfile("$dir/lib/Module/CPANTS/Analyse/Test.pm");

  my $stash = $mca->run;
  is $stash->{manifest_matches_dist} => 0, "manifest does not match dist";
  like $stash->{error}{manifest_matches_dist} => qr/^Cannot find MANIFEST/, "proper error message";
};

test_distribution {
  my ($mca, $dir) = @_;
  write_file("$dir/MANIFEST", <<"EOF");
eg/demo.pl
lib/Module/CPANTS/Analyse/Test.pm
MANIFEST
EOF
  write_pmfile("$dir/lib/Module/CPANTS/Analyse/Test.pm");
  write_file("$dir/TODO", "TODO!");

  my $stash = $mca->run;
  is $stash->{manifest_matches_dist} => 0, "manifest does not match dist";
  my @errors = @{ $stash->{error}{manifest_matches_dist} || [] };
  ok grep /^Missing in MANIFEST: TODO/, @errors;
  ok grep /^Missing in Dist: eg\/demo\.pl/, @errors;
};

done_testing;
