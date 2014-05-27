package Module::CPANTS::Kwalitee::MetaYML;
use warnings;
use strict;
use File::Spec::Functions qw(catfile);
use CPAN::Meta::YAML;
use CPAN::Meta::Validator;
use List::Util qw/first/;

our $VERSION = '0.93_01';
$VERSION = eval $VERSION; ## no critic

sub order { 10 }

my $JSON_CLASS;

##################################################################
# Analyse
##################################################################

sub analyse {
    my $class=shift;
    my $me=shift;
    my $distdir=$me->distdir;
    my $meta_yml=catfile($distdir,'META.yml');

    # META.yml is not always the most preferred meta file,
    # but test it anyway because it may be broken sometimes.
    if (-f $meta_yml) {
        eval {
            my $yaml = _slurp_utf8($meta_yml, $me);
            my $meta = CPAN::Meta::YAML->read_string($yaml) or die CPAN::Meta::YAML->errstr;
            # Broken META.yml may return a "YAML 1.0" string first.
            # eg. M/MH/MHASCH/Date-Gregorian-0.07.tar.gz
            if (@$meta > 1 or ref $meta->[0] ne ref {}) {
                $me->d->{meta_yml}=first { ref $_ eq ref {} } @$meta;
                $me->d->{error}{metayml_is_parsable}="multiple parts found in META.yml";
            } else {
                $me->d->{meta_yml}=$meta->[0];
                $me->d->{metayml_is_parsable}=1;
            }
        };
        if (my $error = $@) {
            $error =~ s/ at \S+ line \d+.+$//s;
            $me->d->{error}{metayml_is_parsable}=$error;
        }
    } else {
        $me->d->{error}{metayml_is_parsable}="META.yml was not found";
    }

    # If there's no META.yml, or META.yml has some errors,
    # check META.json.
    if (!$me->d->{meta_yml}) {
        unless ($JSON_CLASS) {
            for (qw/JSON::XS JSON::PP/) {
                if (eval "require $_; 1;") { ## no critic
                    $JSON_CLASS = $_;
                    last;
                }
            }
        }

        my $meta_json = catfile($distdir,'META.json');
        if ($JSON_CLASS && -f $meta_json) {
            eval {
                my $json = _slurp_utf8($meta_json, $me);
                my $meta = $JSON_CLASS->new->utf8->decode($json);
                $me->d->{meta_yml} = $meta;
                $me->d->{metayml_is_parsable} = 1;
            };
            if ($@) {
                $me->d->{error}{metajson_is_parsable} = $@;
            }
        }
    }

    # If we still don't have meta data, try MYMETA.yml as we may be
    # testing a local distribution.
    if (!$me->d->{meta_yml}) {
        my $mymeta_yml = catfile($distdir, 'MYMETA.yml');
        if (-f $mymeta_yml) {
            eval {
                my $yaml = _slurp_utf8($mymeta_yml, $me);
                my $meta = CPAN::Meta::YAML->read_string($yaml) or die CPAN::Meta::YAML->errstr;
                $me->d->{meta_yml}=first { ref $_ eq ref {} } @$meta;
                $me->d->{metayml_is_parsable} = 1;
            };
        }
    }

    # Should we still try MYMETA.json?

    my $meta = $me->d->{meta_yml};
    return unless $meta && ref $meta eq ref {};

    my $spec = eval { CPAN::Meta::Validator->new($meta) };
    if ($@ or !$spec->is_valid) {
        $me->d->{error}{metayml_conforms_to_known_spec} = $@ ? $@ : join ';', sort $spec->errors;
    }

    $me->d->{dynamic_config} = $meta->{dynamic_config} ? 1 : 0;
}

sub _slurp_utf8 {
    my ($file, $me) = @_;
    my $warning;
    local $SIG{__WARN__} = sub { $warning = shift };
    open my $fh, '<:encoding(UTF-8)', $file or die "$file: $!"; ## no critic
    local $/;
    my $content = <$fh>;
    if ($warning) {
        $warning =~ s/ at .+? line \d+.*$//s;
        $me->d->{error}{metayml_is_parsable} = $warning;
    }
    return $content;
}

##################################################################
# Kwalitee Indicators
##################################################################

sub kwalitee_indicators{
    return [
        {
            name=>'metayml_is_parsable',
            error=>q{The META.yml file of this distribution could not be parsed by the version of CPAN::Meta::YAML.pm CPANTS is using.},
            remedy=>q{If you don't have one, add a META.yml file. Else, upgrade your YAML generator so it produces valid YAML.},
            code=>sub {
                my $d = shift;
                !$d->{error}{metayml_is_parsable} && $d->{metayml_is_parsable} ? 1 : 0
            },
            details=>sub {
                my $d = shift;
                $d->{error}{metayml_is_parsable};
            },
        },
        {
            name=>'metayml_has_provides',
            is_experimental=>1,
            error=>q{This distribution does not have a list of provided modules defined in META.yml.},
            remedy=>q{Add all modules contained in this distribution to the META.yml field 'provides'. Module::Build does this automatically for you.},
            code=>sub { 
                my $d=shift;
                return 1 if $d->{meta_yml} && $d->{meta_yml}{provides};
                return 0;
            },
            details=>sub {
                my $d = shift;
                return "No META.yml." unless $d->{meta_yml};
                return q{No "provides" was found in META.yml.};
            },
        },
        {
            name=>'metayml_conforms_to_known_spec',
            error=>q{META.yml does not conform to any recognised META.yml Spec.},
            remedy=>q{Take a look at the META.yml Spec at http://module-build.sourceforge.net/META-spec-v1.4.html (for version 1.4) or http://search.cpan.org/perldoc?CPAN::Meta::Spec (for version 2), and change your META.yml accordingly.},
            code=>sub {
                my $d=shift;
                return 0 if $d->{error}{metayml_is_parsable};
                return 0 if $d->{error}{metayml_conforms_to_known_spec};
                return 1;
            },
            details=>sub {
                my $d = shift;
                return "No META.yml." unless $d->{meta_yml};
                return "META.yml is broken." unless $d->{metayml_is_parsable};
                return $d->{error}{metayml_conforms_to_known_spec};
            },
        },
        {
            name=>'metayml_declares_perl_version',
            error=>q{This distribution does not declare the minimum perl version in META.yml.},
            is_extra=>1,
            remedy=>q{If you are using Build.PL define the {requires}{perl} = VERSION field. If you are using MakeMaker (Makefile.PL) you should upgrade ExtUtils::MakeMaker to 6.48 and use MIN_PERL_VERSION parameter. Perl::MinimumVersion can help you determine which version of Perl your module needs.},
            code=>sub { 
                my $d=shift;
                my $yaml=$d->{meta_yml};
                return ref $yaml->{requires} eq ref {} && $yaml->{requires}{perl} ? 1 : 0;
            },
            details=>sub {
                my $d = shift;
                my $yaml = $d->{meta_yml};
                return "No META.yml." unless $yaml;
                return q{No "requires" was found in META.yml.} unless ref $yaml->{requires} eq ref {};
                return q{No "perl" subkey was found in META.yml.} unless $yaml->{requires}{perl};
            },
        },
    ];
}

q{Barbies Favourite record of the moment:
  Nine Inch Nails: Year Zero};

__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee::MetaYML - Checks data available in META.yml

=head1 SYNOPSIS

Checks various pieces of information in META.yml

=head1 DESCRIPTION

=head2 Methods

=head3 order

Defines the order in which Kwalitee tests should be run.

Returns C<10>. MetaYML should be checked earlier than Files to
handle no_index correctly.

=head3 analyse

C<MCK::MetaYML> checks C<META.yml>.

=head3 kwalitee_indicators

Returns the Kwalitee Indicators datastructure.

=over

=item * metayml_is_parsable

=item * metayml_has_provides

=item * metayml_conforms_to_known_spec

=item * metayml_declares_perl_version

=back

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

L<Thomas Klausner|https://metacpan.org/author/domm>
and L<Gábor Szabó|https://metacpan.org/author/szabgab>

=head1 COPYRIGHT AND LICENSE

Copyright © 2003–2009 L<Thomas Klausner|https://metacpan.org/author/domm>

Copyright © 2006–2008 L<Gábor Szabó|https://metacpan.org/author/szabgab>

You may use and distribute this module according to the same terms
that Perl is distributed under.
