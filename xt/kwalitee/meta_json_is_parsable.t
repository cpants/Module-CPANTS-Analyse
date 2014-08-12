use strict;
use warnings;
use xt::kwalitee::Test;

xt::kwalitee::Test::run(
  ['JOHND/Data-Properties-YAML-0.04.tar.gz', 0], # \r
  ['WINFINIT/Catalyst-Plugin-ModCluster-0.02.tar.gz', 0], # \t
  ['SHURD/DMTF-CIM-WSMan-v0.09.tar.gz', 0],
  ['RFREIMUTH/RandomJungle-0.05.tar.gz', 0],
  ['PFAUT/VMS-Time-0_1.zip', 0],
  ['MAXS/Palm-MaTirelire-1.12.tar.gz', 0], # \x{fffd}
  ['JHTHORSEN/Convos-0.6.tar.gz', 0],
);
