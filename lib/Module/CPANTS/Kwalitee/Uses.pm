package Module::CPANTS::Kwalitee::Uses;
use warnings;
use strict;
use File::Spec::Functions qw(catfile);
use Module::ExtractUse;
use Set::Scalar qw();
use Data::Dumper;
use version;

our $VERSION = '0.92';

# These equivalents should be reasonably well-known and, preferably,
# well-documented. Don't add obscure modules used by only one person
# or a few people, to keep the list relatively small and to encourage
# people to use a better equivalent.
# "use_(strict|warnings)" should fail if someone feels the need
# to add "use $1;" in the modules.
our @STRICT_EQUIV = qw( strict );
our @WARNINGS_EQUIV = qw( warnings );
our @STRICT_WARNINGS_EQUIV = qw(
  common::sense
  Any::Moose
  Catmandu::Sane Coat
  Dancer
  Mo
  Modern::Perl
  Moo Moo::Role
  Moose Moose::Role Moose::Exporter
  MooseX::Declare MooseX::Role::Parameterized MooseX::Types
  Mouse Mouse::Role
  perl5 perl5i::1 perl5i::2 perl5i::latest
  Role::Tiny
  strictures
);
# These modules require a flag to enforce strictness.
push @STRICT_WARNINGS_EQUIV, qw(
  Mojo::Base
  Spiffy
);

sub order { 100 }

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;
    
    my $distdir=$me->distdir;
    my $modules=$me->d->{modules};
    my $files=$me->d->{files_array};

    # NOTE: all files in xt/ should be ignored because they are
    # for authors only and their dependencies may not be (and
    # often are not) listed in meta files.
    my @tests=grep {m|^t\b.*\.t|} @$files;
    $me->d->{test_files} = \@tests;

    my @test_modules = map { my $m = $_; $m =~ s|/|::|g; $m =~ s|\.pm$||; $m } grep {m|^t\b.*\.pm$|} @$files;

    my %skip=map {$_->{module}=>1 } @$modules;
    my %uses;

    # used in modules
    foreach (@$modules) {
        my $p = Module::ExtractUse->new;
        my $file = catfile($distdir,$_->{file});
        $p->extract_use($file) if -f $file;
        $_->{uses} = $p->used;

        while (my ($mod,$cnt)=each%{$p->used}) {
            next if $skip{$mod};
            next if $mod =~ /::$/;  # see RT#35092
            next unless $mod =~ /^[A-Za-z0-9:_]+$/;
            $uses{$mod}{module} = $mod;
            $uses{$mod}{in_code} += $cnt;
            $uses{$mod}{evals_in_code} += $p->used_in_eval($mod) || 0;
        }
    }
    
    # used in tests
    foreach my $tf (@tests) {
        my $pt=Module::ExtractUse->new;
        my $file = catfile($distdir,$tf);
        $pt->extract_use($file) if -f $file && -s $file < 1_000_000; # skip very large test files

        while (my ($mod,$cnt)=each%{$pt->used}) {
            next if $skip{$mod};
            next if $mod =~ /::$/;  # see RT#35092
            next unless $mod =~ /^[A-Za-z0-9:_]+$/;
            if (@test_modules) {
                next if grep {/(?:^|::)$mod$/} @test_modules;
            }

            $uses{$mod}{module} = $mod;
            $uses{$mod}{in_tests} += $cnt;
            $uses{$mod}{evals_in_tests} += $pt->used_in_eval($mod) || 0;
        }
    }

    # used in Makefile.PL/Build.PL
    foreach my $f (grep /\b(?:Makefile|Build)\.PL$/, @{$me->d->{files_array} || []}) {
        my $p = Module::ExtractUse->new;
        my $file = catfile($distdir,$f);
        $p->extract_use($file) if -f $file;

        while (my ($mod,$cnt)=each%{$p->used}) {
            next if $skip{$mod};
            next if $mod =~ /::$/;  # see RT#35092
            next unless $mod =~ /^[A-Za-z0-9:_]+$/;
            $uses{$mod}{module} = $mod;
            $uses{$mod}{in_config} += $cnt;
            $uses{$mod}{evals_in_config} += $p->used_in_eval($mod) || 0;
        }
    }

    $me->d->{uses}=\%uses;
    return;
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators {
    return [
        {
            name=>'use_strict',
            error=>q{This distribution does not 'use strict;' (or its equivalents) in all of its modules. Note that this is not about the actual strictness of the modules. It's bad if nobody can tell whether the modules are strictly written or not, without reading the source code of your favorite clever module that actually enforces strictness. In other words, it's bad if someone feels the need to add 'use strict' to the modules.},
            remedy=>q{Add 'use strict' to all modules, or convince us that your favorite module is well-known enough and people can easily see the modules are strictly written.},
            code=>sub {
                my $d       = shift;
                my $modules = $d->{modules};
                my $uses    = $d->{uses};
                return 0 unless $modules && $uses;

                # There are lots of acceptable strict alternatives
                my $strict_equivalents = Set::Scalar->new->insert(@STRICT_EQUIV, @STRICT_WARNINGS_EQUIV);

                my $perl_version_with_implicit_stricture = version->new('5.011');
                my @no_strict;
                for my $module (@{ $modules }) {
                    next if grep {/^5\./ && version->parse($_) >= $perl_version_with_implicit_stricture} keys %{$module->{uses}};
                    push @no_strict, $module->{module} if $strict_equivalents
                        ->intersection(Set::Scalar->new(keys %{ $module->{uses} }))
                        ->is_empty;
                }
                if (@no_strict) {
                    $d->{error}{use_strict} = join ", ", @no_strict;
                    return 0;
                }
                return 1;
            },
            details=>sub {
                my $d = shift;
                return "The following modules don't use strict (or equivalents): " . $d->{error}{use_strict};
            },
        },
        {
            name=>'use_warnings',
            error=>q{This distribution does not 'use warnings;' in all of its modules. Note that this is not about that your modules actually warn when something bad happens. It's bad if nobody can tell if modules warns or not, without reading the source code of your favorite module that actually enforces warnings. In other words, it's bad if someone feels the need to add 'use warnings' to the modules.},
            is_extra=>1,
            remedy=>q{Add 'use warnings' to all modules (this will require perl > 5.6), or convince us that your favorite module is well-known enough and people can easily see the modules warn when something bad happens.},
            code=>sub {
                my $d       = shift;
                my $modules = $d->{modules};
                my $uses    = $d->{uses};
                return 0 unless $modules && $uses;

                my $warnings_equivalents = Set::Scalar->new->insert(@WARNINGS_EQUIV, @STRICT_WARNINGS_EQUIV);

                my @no_warnings;
                for my $module (@{ $modules }) {
                    push @no_warnings, $module->{module} if $warnings_equivalents
                        ->intersection(Set::Scalar->new(keys %{ $module->{uses} }))
                        ->is_empty;
                }
                if (@no_warnings) {
                    $d->{error}{use_warnings} = join ", ", @no_warnings;
                    return 0;
                }
                return 1;
            },
            details=>sub {
                my $d = shift;
                return "The following modules don't use warnings (or equivalents): " . $d->{error}{use_warnings};
            },
        },
    ];
}


q{Favourite record of the moment:
  Fat Freddys Drop: Based on a true story};

__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee::Uses - Checks which modules are used

=head1 SYNOPSIS

Check which modules are actually used in the code.

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<100>.

=head3 analyse

C<MCK::Uses> uses C<Module::ExtractUse> to find all C<use> statements in code (actual code and tests).

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * use_strict

=item * use_warnings

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

L<Thomas Klausner|https://metacpan.org/author/domm>

=head1 COPYRIGHT AND LICENSE

Copyright © 2003–2006, 2009 L<Thomas Klausner|https://metacpan.org/author/domm>

You may use and distribute this module according to the same terms
that Perl is distributed under.
