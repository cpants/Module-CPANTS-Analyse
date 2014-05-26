use strict;
use warnings;
use Test::More tests => 8;
use Module::CPANTS::Analyse;
use CPAN::Meta::YAML;
use File::Temp;

my $dir = File::Temp::tempdir(CLEANUP => 1);

{
  write_metayml("$dir/META.yml");
  write_pmfile("$dir/Test.pm");

  my $mca = Module::CPANTS::Analyse->new({
    distdir => $dir,
    dist => $dir,
  });
  $mca->analyse;
  $mca->calc_kwalitee;
  ok !$mca->d->{kwalitee}{use_strict}, "use_strict fails correctly";
  ok !$mca->d->{kwalitee}{has_tests}, "has_tests fails correctly";
}

{
  write_metayml("$dir/META.yml", {
    x_cpants => {ignore => {
      use_strict => 'for some reason',
    }}
  });

  my $mca = Module::CPANTS::Analyse->new({
    distdir => $dir,
    dist => $dir,
  });
  $mca->analyse;
  $mca->calc_kwalitee;
  ok $mca->d->{kwalitee}{use_strict}, "use_strict is ignored (and treated as pass)";
  ok $mca->d->{error}{use_strict} && $mca->d->{error}{use_strict} =~ /Module::CPANTS::Analyse::Test/ && $mca->d->{error}{use_strict} =~ /ignored/, "error is not removed and marked as 'ignored'";
  ok !$mca->d->{kwalitee}{has_tests}, "has_tests fails correctly";
}

{
  write_metayml("$dir/META.yml", {
    x_cpants => {ignore => {
      use_strict => 'for some reason',
      has_tests => 'because I am so lazy',
    }}
  });

  my $mca = Module::CPANTS::Analyse->new({
    distdir => $dir,
    dist => $dir,
  });
  $mca->analyse;
  $mca->calc_kwalitee;
  ok $mca->d->{kwalitee}{use_strict}, "use_strict is ignored (and treated as pass)";
  ok $mca->d->{error}{use_strict} && $mca->d->{error}{use_strict} =~ /Module::CPANTS::Analyse::Test/ && $mca->d->{error}{use_strict} =~ /ignored/, "error is not removed and marked as 'ignored'";
  ok !$mca->d->{kwalitee}{has_tests}, "has_tests fails correctly regardless of the x_cpants";
  # note explain $mca->d;
}

unlink "$dir/META.yml";
unlink "$dir/Test.pm";

sub write_metayml {
  my ($file, $options) = @_;
  open my $fh, '>:utf8', $file or die "$!:$file"; ## no critic
  my $meta = {
    name => 'Module::CPANTS::Analyse::Test',
    abstract => 'test',
    author => ['A.U.Thor'],
    generated_by => 'hand',
    license => 'perl',
    'meta-spec' => {version => '1.4', url => 'http://module-build.sourceforge.net/META-spec-v1.4.html'},
    version => '0.01',
    %{$options || {}},
  };
  print $fh CPAN::Meta::YAML->new($meta)->write_string;
}

sub write_pmfile {
  my $file = shift;
  open my $fh, '>', $file or die "$!:$file";
  print $fh 'package ', 'Module::CPANTS::Analyse::Test;', "\n";
  print $fh "1;\n";
}

