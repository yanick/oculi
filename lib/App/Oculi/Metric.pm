package App::Oculi::Metric;

use 5.20.0;

use warnings;

use MooseX::App::Command;
extends 'App::Oculi';
with 'App::Oculi::Role::InfluxDB';

use experimental 'signatures', 'postderef';

use Module::Runtime qw/ use_module /;
use List::AllUtils qw/ pairgrep /;

use App::Oculi::Entry;

has metric => (
    is => 'ro',
    lazy => 1,
    default => sub($self) {
        my $name = ref $self;
        $name =~ s/.*:://;
        $name =~ s/(?<=.)(?=[A-Z])/_/g;
        lc $name;
    },
);

has tags => (
    is => 'rw',
    traits => [ 'Hash' ],
    lazy => 1,
    default => sub($self) { +{
        map { $_->name => $_->get_value($self) } grep { 
            $_->does('App::Oculi::Trait::Tag')
        } $self->meta->get_all_attributes
        }
    },
    handles => {
        all_tags => 'elements',
    },
);

has entries => (
    is => 'ro',
    lazy => 1,
    traits => [ 'Array' ],
    handles => { all_entries => 'elements' },
    default => sub($self) { 

        my %fields = map { $_->get_value($self)->%* } grep { 
            $_->does('App::Oculi::Trait::Fields')
        } $self->meta->get_all_attributes;

        %fields = ( %fields,
            pairgrep { defined $b }
            map { $_->name => $_->get_value($self) } grep { 
                $_->does('App::Oculi::Trait::Field')
            } $self->meta->get_all_attributes
        );

        return [ App::Oculi::Entry->new(
            measurement => $self->metric,
            tags        => $self->tags,
            fields      => \%fields,
        ) ];
    },
);

sub  _expand_entry ($self,$entry) {
    my( $tags, $fields ) = @$entry;

    return App::Oculi::Entry->new(
        measurement => $self->metric,
        tags => { $self->all_tags, %$tags },
        fields => $fields
    );
}

sub stringify($self) { join "\n", map { $_->stringify } 
    map {
        (ref $_ eq 'ARRAY') ? $self->_expand_entry($_) : $_ 
    }
    $self->all_entries 
}

after run => sub($self) {
    my $db = $self->influxdb or return;

    if( $db !~ /\// ) {
        $db = "localhost:8086/$db";
    }

    $db =~ s/\//\/write?db=/;
    $db = "http://$db";

    say "\nsending data to $db...";

    my $resp = use_module('HTTP::Tiny')->new->post(
        $db, { content => $self->stringify }
    );

    die sprintf "%s - %s\n", $resp->{status}, $resp->{reason}
        unless $resp->{success};
};

sub run($self) {
    say $self->stringify;
}

1;
