package Module::CPANTS::Kwalitee;
use 5.006;
use strict;
use warnings;
use base qw(Class::Accessor);
use Carp;

our $VERSION = '0.97_07';
$VERSION =~ s/_//; ## no critic

__PACKAGE__->mk_accessors(qw(generators _gencache _genhashcache _available _total));

sub import {
    my $class = shift;
    my %search_path = map {(/^Module::CPANTS::/ ? $_ : "Module::CPANTS::$_") => 1 } @_;
    $search_path{'Module::CPANTS::Kwalitee'} = 1;
    require Module::Pluggable;
    Module::Pluggable->import(search_path => [keys %search_path]);
}

sub new {
    my $class=shift;
    my $me=bless {},$class;
    
    my %generators;
    foreach my $gen ($me->plugins) {
        ## no critic (ProhibitStringyEval)
        eval "require $gen";
        croak qq{cannot load $gen: $@} if $@;
        $generators{$gen}= [ $gen->order, $gen ];
    }
    # sort by 'order' first, then name
    my @generators=sort {
        $generators{$a}->[0] <=> $generators{$b}->[0]
            ||
        $generators{$a}->[1] cmp $generators{$b}->[1]
    } keys %generators;
    $me->generators(\@generators);
    $me->_gencache({});
    return $me;
}

sub get_indicators {
    my $self=shift;
    my $type = shift || 'all';
    
    $type='is_extra' if $type eq 'optional';
    $type='is_experimental' if $type eq 'experimental';

    my $indicators;
    if ($self->_gencache->{$type}) {
        $indicators=$self->_gencache->{$type};
    } else {
        my @aggregators;
        foreach my $gen (@{$self->generators}) {
            foreach my $ind (@{$gen->kwalitee_indicators}) {
                if ($type eq 'all'
                    || ($type eq 'core' && !$ind->{is_extra} && !$ind->{is_experimental}) 
                    || $ind->{$type}) {
                    $ind->{defined_in}=$gen;
                    if ($ind->{aggregating}) {
                        push @aggregators, $ind;
                        next;
                    }
                    push(@$indicators,$ind); 
                }
            }
        }
        push @$indicators, @aggregators;
        $self->_gencache->{$type}=$indicators;
    }
    return wantarray ? @$indicators : $indicators;
}

sub get_indicators_hash {
    my $self=shift;

    my $indicators;
    if ($self->_genhashcache) {
        $indicators=$self->_genhashcache;
    } else {
        foreach my $gen (@{$self->generators}) {
            foreach my $ind (@{$gen->kwalitee_indicators}) {
                $ind->{defined_in}=$gen;
                $indicators->{$ind->{name}}=$ind;
            }
        }
        $self->_genhashcache($indicators);
    }
    return $indicators;
}

sub available_kwalitee {
    my $self=shift;

    my $mem=$self->_available;
    return $mem if $mem;

    my $available;
    foreach my $g ($self->get_indicators) {
        $available++ unless $g->{is_extra} || $g->{is_experimental};
    }
    $self->_available($available);
}

sub total_kwalitee {
    my $self=shift;

    my $mem=$self->_total;
    return $mem if $mem;
    
    my $available;
    foreach my $g ($self->get_indicators) {
        $available++ unless $g->{is_experimental};
    }

    $self->_total($available);
}

sub _indicator_names {
    my ($self, $coderef) = @_;
    my @names = map { $_->{name} } grep {$coderef->($_)} $self->get_indicators;
    return wantarray ? @names : \@names;
}

sub all_indicator_names { shift->_indicator_names(sub {1}) }

sub core_indicator_names {
    shift->_indicator_names(sub {
        !$_->{is_extra} && !$_->{is_experimental}
    });
}

sub optional_indicator_names {
    shift->_indicator_names(sub {$_->{is_extra}});
}

sub experimental_indicator_names {
    shift->_indicator_names(sub {$_->{is_experimental}});
}

q{Favourite record of the moment:
  Jahcoozi: Pure Breed Mongrel};

__END__

=encoding UTF-8

=head1 NAME

Module::CPANTS::Kwalitee - Interface to Kwalitee generators

=head1 SYNOPSIS

  my $mck=Module::CPANTS::Kwalitee->new;
  my @generators=$mck->generators;

=head1 DESCRIPTION

=head2 Methods

=head3 new

Plain old constructor.

Loads all Plugins.

=head3 get_indicators

Get the list of all Kwalitee indicators, either as an ARRAY or ARRAYREF.

=head3 get_indicators_hash

Get the list of all Kwalitee indicators as an HASHREF.

=head3 core_indicator_names

Get a list of core indicator names (NOT the whole indicator HASHREF).

=head3 optional_indicator_names

Get a list of optional indicator names (NOT the whole indicator HASHREF).

=head3 experimental_indicator_names

Get a list of experimental indicator names (NOT the whole indicator HASHREF).

=head3 all_indicator_names

Get a list of all indicator names (NOT the whole indicator HASHREF).

=head3 available_kwalitee

Get the number of available kwalitee points

=head3 total_kwalitee

Get the total number of kwalitee points. This is bigger the available_kwalitee as some kwalitee metrics are marked as 'extra' (e.g. C<is_prereq>).

=head1 SEE ALSO

L<Module::CPANTS::Analyse>

=head1 AUTHOR

L<Thomas Klausner|https://metacpan.org/author/domm>

=head1 COPYRIGHT AND LICENSE

Copyright © 2003–2006, 2009 L<Thomas Klausner|https://metacpan.org/author/domm>

You may use and distribute this module according to the same terms
that Perl is distributed under.
