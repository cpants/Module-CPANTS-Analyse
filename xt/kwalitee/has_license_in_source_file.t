use strict;
use warnings;
use xt::kwalitee::Test;

xt::kwalitee::Test::run(
  ['J/JJ/JJUDD/DBIx-Class-TimeStamp-HiRes-v1.0.0.tar.gz', 0], # 2596
  ['A/AN/ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['Y/YV/YVES/Sereal-0.360.tar.gz', 0], # 3537
  ['S/SM/SMUELLER/Math-SymbolicX-Complex-1.01.tar.gz', 0], # 4719
  ['I/IA/IAMCAL/Flickr-API-1.06.tar.gz', 0], # 5172

  # =head1 AUTHOR / COPYRIGHT / LICENSE
  ['B/BJ/BJOERN/AI-CRM114-0.01.tar.gz', 1],

  # has =head1 COPYRIGHT AND LICENSE without closing =cut
  ['D/DA/DAMI/DBIx-DataModel-2.39.tar.gz', 1],
);
