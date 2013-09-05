use strict;
use warnings;
use xt::kwalitee::Test;

xt::kwalitee::Test::run(
  ['T/TO/TOBYINK/Platform-Windows-0.002.tar.gz', 0], # 2206
  ['T/TO/TOBYINK/Platform-Unix-0.002.tar.gz', 0], # 2264
  ['B/BO/BOOK/Acme-MetaSyntactic-errno-1.003.tar.gz', 0], # 2889
  ['A/AN/ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['T/TX/TXH/Template-Plugin-Filter-MinifyHTML-0.02.tar.gz', 0], # 3484
  ['L/LT/LTP/Game-Life-0.05.tar.gz', 0], # 6535
  ['P/PJ/PJB/Speech-Speakup-1.04.tar.gz', 0], # 7410
  ['J/JB/JBAZIK/Archive-Ar-1.15.tar.gz', 0], # 7983
  ['S/SU/SULLR/Net-SSLGlue-1.03.tar.gz', 0], # 8720
  ['S/SH/SHARYANTO/Term-ProgressBar-Color-0.00.tar.gz', 0], # 9746
);
