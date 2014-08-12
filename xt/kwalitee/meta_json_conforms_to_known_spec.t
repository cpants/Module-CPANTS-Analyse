use strict;
use warnings;
use xt::kwalitee::Test;

xt::kwalitee::Test::run(
  ['DMAKI/XML-RSS-Liberal-0.04.tar.gz', 0],
  ['MLEHMANN/AnyEvent-DBus-0.31.tar.gz', 0],
  ['BARBIE/Template-Plugin-Lingua-EN-NameCase-0.01.tar.gz', 0],
  ['TOMO/src/Net-SMTPS-0.03.tar.gz', 0], # perl
  ['RSAVAGE/DBIx-Admin-CreateTable-2.08.tgz', 0], # artistic_2_0
  ['RJBS/Sub-Import-0.092800.tar.gz', 0],
  ['MARCEL/Permute-Named-1.100980.tar.gz', 0],
  ['KEEDI/Pod-Weaver-Section-Encoding-0.100830.tar.gz', 0],
  ['TIMB/PostgreSQL-PLPerl-Trace-1.001.tar.gz', 0],
  ['AVAR/Bot-Twatterhose-0.04.tar.gz', 0],
  ['TOBYINK/Return-Type-0.004.tar.gz', 0],
);
