package #
  Module::CPANTS::TestAnalyse;

use strict;
use warnings;
use Carp;
use base 'Exporter';
use File::Temp qw/tempdir/;
use File::Path;
use File::Spec::Functions qw/splitpath/;
use Cwd;
use Module::CPANTS::Analyse;
use CPAN::Meta::YAML;
use Test::More;

our @EXPORT = (qw/
  test_distribution
    write_file
    write_pmfile
  write_metayml
/, @Test::More::EXPORT);

sub test_distribution (&) {
  my $code = shift;

  my $cwd = cwd;

  my $dir = tempdir(CLEANUP => 1);

  my $mca = Module::CPANTS::Analyse->new({
    dist => $dir,
    distdir => $dir,
  });

  note "tests under $dir";
  eval { $code->($mca, $dir) };
  ok !$@, "no errors";

  chdir $cwd;
  rmtree $dir;
}

sub write_file {
  my ($path, $content) = @_;
  my ($vol, $dir, $file) = splitpath($path);
  $dir = "$vol$dir" if $vol;
  mkpath $dir unless -d $dir;
  open my $fh, '>:encoding(utf8)', $path or croak "Can't open $path: $!";
  print $fh $content;
  note "wrote to $path";
}

sub write_pmfile {
  my ($path, $content) = @_;
  my @lines = ('package '.'Module::CPANTS::Analyse::Test');
  push @lines, $content if defined $content;
  push @lines, '1';
  write_file($path, join ";\n", @lines, "");
}

sub write_metayml {
  my ($path, $args) = @_;
  my $meta = {
    name => 'Module::CPANTS::Analyse::Test',
    abstract => 'test',
    author => ['A.U.Thor'],
    generated_by => 'hand',
    license => 'perl',
    'meta-spec' => {version => '1.4', url => 'http://module-build.sourceforge.net/META-spec-v1.4.html'},
    version => '0.01',
    %{$args || {}},
  };
  write_file($path, CPAN::Meta::YAML->new($meta)->write_string);
}

1;
