use strict;
use warnings;
use Test::More;
use xt::lint::Test;


xt::lint::Test::run(

  # only experimental tests fail, and they should be ignored usually
  ['PAWAPAWA/Lingua-JA-NormalizeText-0.26.tar.gz', sub {
    my $result = shift;
    like $result => qr/Congratulations/;
    unlike $result => qr/failed Kwalitee tests/i;
    unlike $result => qr/Failed optional Kwalitee/i;
    unlike $result => qr/Failed experimental Kwalitee tests/;
    unlike $result => qr/\* metayml_has_provides/;
  }, {
    experimental => 0,
  }],

  # only experimental tests fail, but they should be shown
  # if --experimental flag is set

  ['PAWAPAWA/Lingua-JA-NormalizeText-0.26.tar.gz', sub {
    my $result = shift;
    unlike $result => qr/Congratulations/;
    unlike $result => qr/failed Kwalitee tests/i;
    unlike $result => qr/Failed optional Kwalitee/i;
    like $result => qr/Failed experimental Kwalitee tests/;
    like $result => qr/\* metayml_has_provides/;
  }, {
    experimental => 1,
  }],
);

done_testing;
