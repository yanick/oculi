package App::Oculi::Entry;

use 5.20.0;
use warnings;

use InfluxDB::LineProtocol qw/ data2line /;

use Moose;

use App::Oculi::Has qw/ /;

use experimental 'signatures';

has measurement => (
    is => 'ro',
    required => 1,
);

has tags => (
    is => 'rw',
    traits => [ 'Hash' ],
    default => sub { +{} },
    predicate => 'has_tags',
);

has timestamp => (
    is => 'rw',
    predicate => 'has_timestamp',
);

has fields => (
    is => 'rw',
    required => 1,
);

sub stringify($self) {
    data2line(
        $self->measurement,
        $self->fields,
        ( $self->tags ) x $self->has_tags,
    )
}

1;
