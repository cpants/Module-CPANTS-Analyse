use strict;
use warnings;
use xt::kwalitee::Test;

xt::kwalitee::Test::run(
  ['T/TO/TOBYINK/Platform-Windows-0.002.tar.gz', 0], # 2206
  ['T/TO/TOBYINK/Platform-Unix-0.002.tar.gz', 0], # 2264
  ['B/BO/BOOK/Acme-MetaSyntactic-errno-1.003.tar.gz', 0], # 2889
  ['C/CO/COOLMEN/Test-More-Color-0.04.tar.gz', 0], # 2963
  ['A/AN/ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['H/HI/HITHIM/Socket-Mmsg-0.02.tar.gz', 0], # 3946
  ['C/CO/COOLMEN/Test-Mojo-More-0.04.tar.gz', 0], # 4301
  ['M/MU/MUGENKEN/Bundle-Unicheck-0.02.tar.gz', 0], # 4596
  ['S/SM/SMUELLER/Math-SymbolicX-Complex-1.01.tar.gz', 0], # 4719
  ['C/CH/CHENRYN/Nagios-Plugin-ByGmond-0.01.tar.gz', 0], # 5159
);
