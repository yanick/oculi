package App::Oculi::Metric::Webpage;

use 5.20.0;
use warnings;

use HTTP::Tiny;
use Timer::Simple;

use App::Oculi::Has qw/ ro tag option field /;

use Moose;
extends 'App::Oculi::Metric';

use experimental 'signatures', 'postderef';

has option tag url => ( 
    documentation => 'url of the monitored webpage',
    required      => 1,
);

has option content => (
    documentation => 'list of regular expressions to be found in the page',
    isa           => 'ArrayRef',
    lazy          => sub { [] },
);

has field status => sub($self) {
    $self->response->{status};
};

has field is_live => sub($self) {
    $self->error ? 'FALSE' : 'TRUE';
};

has field response_time => sub($self) {
    $self->timer->elapsed;
};

has field error => sub($self) {
    my $response = $self->response;
    return 'GET failed' unless $response->{success};

    for my $re ( $self->content->@* ) {
        return "body doesn't match $re" unless $response->{content} =~ /$re/;
    }

    return;
};


has ro agent => sub { HTTP::Tiny->new };

has ro timer => sub { Timer::Simple->new };

before response_time => sub { $_[0]->response };

has ro response => sub ($self) {
    $self->timer;
    $self->agent->get( $self->url );
};


1;
