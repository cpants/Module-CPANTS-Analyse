package #
  xt::lint::Test;

use strict;
use warnings;
use FindBin;
use Test::More;

BEGIN {
  eval { require WorePAN };
  plan skip_all => "requires WorePAN" if $@ or $WorePAN::VERSION < 0.09;
}

sub run {
  my (@tests) = @_;

  for my $test (@tests) {
    my ($path, $expected, $options) = @$test;
    $options ||= {};

    my $worepan = WorePAN->new(
      root => "$FindBin::Bin/tmp",
      files => [$test->[0]],
      no_indices => 1,
      use_backpan => 1,
      no_network => 0,
      cleanup => 1,
    );
    my $file = $worepan->file($test->[0]);

    my $cmd = "$^X $FindBin::Bin/../../bin/cpants_lint.pl";

    $cmd .= " --experimental" if $options->{experimental};

    my $result = `$cmd $file`;

    if (ref $expected eq ref sub {}) {
      $expected->($result) or note $result;
    } else {
      like $result => qr/$expected/ or note $result;
    }
  }

}

1;
