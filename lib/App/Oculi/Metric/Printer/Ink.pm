package App::Oculi::Metric::Printer::Ink;

use 5.10.0;

use strict;
use warnings;

use Web::Query;

use Moose;

with 'App::Oculi::Metric';

has printer => (
    traits => [ 'App::Oculi::SeriesIdentifier' ],
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has host => (
    traits => [ 'App::Oculi::Service' ],
    service => { resource => 'printer' },
);


sub gather_stats {
    my $self = shift;

    my $url = sprintf "http://%s/general/status.html", $self->host;

    my %stats;
    wq($url)->find( 'img.tonerremain' )->each(sub{
        no warnings;  # height = 88px so =/= numerical
        $stats{  $_->attr('alt') } =  $_->attr('height') / 50;
    });

    return \%stats;
}

1;

__END__
