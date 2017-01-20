package App::Oculi::Service::Influx;

use strict;
use warnings;

use App::Oculi::Influx;

use Moose::Role;

has influx => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $db = $self->config->{influx}{database};
        my $host = $self->config->{resources}{$self->config->{influx}{host}};
        App::Oculi::Influx->new(
            host_address => $host->{host_address},
            database => $db,
        );
    },
);

1;
