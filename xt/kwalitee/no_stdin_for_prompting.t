use strict;
use warnings;
use xt::kwalitee::Test;

xt::kwalitee::Test::run(
  ['G/GM/GMCCAR/Jabber-SimpleSend-0.03.tar.gz', 0], # 3455
  ['S/SP/SPEEVES/Apache-AuthenNIS-0.13.tar.gz', 0], # 4517
  ['S/SP/SPEEVES/Apache2-AuthenSmb-0.01.tar.gz', 0], # 5219
  ['K/KR/KROW/DBIx-Password-1.9.tar.gz', 0], # 5478
  ['G/GE/GEOTIGER/Data-Fax-0.02.tar.gz', 0], # 5944
  ['G/GE/GEOTIGER/CGI-Getopt-0.13.tar.gz', 0], # 6014
  ['S/SP/SPEEVES/Apache2-AuthNetLDAP-0.01.tar.gz', 0], # 6855
  ['S/SP/SPEEVES/Apache-AuthNetLDAP-0.29.tar.gz', 0], # 6952
  ['A/AM/AMALTSEV/XAO-MySQL-1.02.tar.gz', 0], # 7242
  ['B/BH/BHODGES/Mail-IMAPFolderSearch-0.03.tar.gz', 0], # 7326
);
