package App::Oculi::Metric::Email::Backlog;

use strict;
use warnings;

use Moose;

with 'App::Oculi::Metric';

my $i = 0;
has $_ => (
    traits => [ qw/ App::Oculi::SeriesIdentifier / ],
    isa => 'Str',
    is => 'ro',
    required => 1,
    series_index => $i++,
) for qw/ server user mailbox /;

has imap => (
    traits => [ 'App::Oculi::Service' ],
    service => [ qw/ server user / ],
);

sub gather_stats {
    my $self = shift;

    return {
        emails => $self->imap->status( $self->mailbox )->{MESSAGES}
    };
}

1;
