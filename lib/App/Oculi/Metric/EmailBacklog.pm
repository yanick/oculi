package App::Oculi::Metric::EmailBacklog;

use 5.20.0;
use warnings;

use Net::IMAP::Client;
use List::AllUtils qw/ pairmap /;

use App::Oculi::Has qw/ tag ro option /;
use App::Oculi::Entry;

use Moose;
extends 'App::Oculi::Metric';

use experimental 'signatures', 'postderef';

has option address => (
    required => 1,
);

has tag user => sub($self) {
    (split '@', $self->address)[0];
};

has tag host => sub($self) {
    (split '@', $self->address)[1];
};

has option password => (
    required => 1,
);

has option mailboxes => (
    isa     => 'ArrayRef',
    default => sub { [ 'inbox' ] },
);

has ro imap => sub($self) {

    my $client = Net::IMAP::Client->new(
        server          => $self->host,
        user            => $self->user,
        pass            => $self->password,
        ssl             => 1,
        ssl_verify_peer => 0,
    );

    $client->login;

    return $client;
};

has '+entries' => (
    default => sub ($self) {
    return [
        pairmap { 
            App::Oculi::Entry->new(
                measurement => $self->metric,
                tags => { $self->tags->%*, mailbox => $a },
                fields => {
                    total => $b->{MESSAGES},
                    new   => $b->{UNSEEN},
                    old   => $b->{MESSAGES} - $b->{UNSEEN},
                }
            )
        }
        map { $_ => $self->imap->status( $_ ) }
            $self->mailboxes->@*
    ];
}
);

1;
