use strict;
use warnings;
use xt::kwalitee::Test;

xt::kwalitee::Test::run(
  ['J/JJ/JJUDD/DBIx-Class-TimeStamp-HiRes-v1.0.0.tar.gz', 0], # 2596
  ['A/AN/ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['S/SM/SMUELLER/Math-SymbolicX-Complex-1.01.tar.gz', 0], # 4719
  ['I/IA/IAMCAL/Flickr-API-1.06.tar.gz', 0], # 5172

  # =head1 AUTHOR / COPYRIGHT / LICENSE
  ['B/BJ/BJOERN/AI-CRM114-0.01.tar.gz', 1],

  # has =head1 COPYRIGHT AND LICENSE without closing =cut
  ['D/DA/DAMI/DBIx-DataModel-2.39.tar.gz', 1],

  # has =head1 LICENSE followed by =head1 COPYRIGHT
  ['Y/YS/YSASAKI/App-pfswatch-0.08.tar.gz', 1],

  # ignore inc/Devel/CheckLib
  ['D/DJ/DJERIUS/Lua-API-0.02.tar.gz', 1],

  # https://github.com/cpants/www-cpants/issues/44
  ['NEILB/Business-CCCheck-0.09.tar.gz', 1],
);
