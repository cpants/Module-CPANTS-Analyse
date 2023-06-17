use strict;
use warnings;
use FindBin;
use Test::More;

BEGIN {
  plan skip_all => "set RELEASE_TESTING to true to test" unless $ENV{RELEASE_TESTING};

  eval {require Parse::LocalDistribution; 1} or plan skip_all => "requires Parse::LocalDistribution";
}

local $Parse::PMFile::ALLOW_DEV_VERSION = 1;
my $provides = Parse::LocalDistribution->new->parse("$FindBin::Bin/../");

my $dist_version;

for my $module (keys %$provides) {
  my $version = $provides->{$module}{version};
  next unless defined $version;
  $dist_version ||= $version;
  is $dist_version => $version, "$module: $version";
}

done_testing;
