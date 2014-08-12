use strict;
use warnings;
use xt::kwalitee::Test;

xt::kwalitee::Test::run(
  ['UNBIT/Net-uwsgi-1.1.tar.gz', 0], # 2409
  ['NIELSD/Speech-Google-0.5.tar.gz', 0], # 2907
  ['ANANSI/Anansi-Actor-0.04.tar.gz', 0], # 3157
  ['SCILLEY/POE/Component/IRC/Plugin/IRCDHelp-0.02.tar.gz', 0], # 3243
  ['ANANSI/Anansi-Library-0.02.tar.gz', 0], # 3365
  ['HITHIM/Socket-Mmsg-0.02.tar.gz', 0], # 3946
  ['CINDY/AnyEvent-HTTPD-CookiePatch-v0.1.0.tar.gz', 0, 1], # 4162
  ['BENNIE/ACME-KeyboardMarathon-1.15.tar.gz', 0], # 4479
  ['MLX/Algorithm-Damm-1.001.002.tar.gz', 0, 1], # 4537
  ['JOSEPHW/XML-Writer-0.545.tar.gz', 1],
);
