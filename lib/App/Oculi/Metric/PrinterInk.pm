package App::Oculi::Metric::PrinterInk;

use 5.20.0;

use warnings;

use Web::Query;
use List::Util qw/ pairmap /;

use App::Oculi::Has qw/ ro field fields tag option /;

use Moose;
extends 'App::Oculi::Metric';

use experimental 'signatures', 'postderef';

has option tag printer => (
    required => 1,
    documentation => 'name of the printer',
);

has option address => (
    lazy => sub($self) { $self->printer },
    documentation => 
        "address of the printer, defaults to the 'printer' value"
);

has ro url => sub($self) {
    sprintf "http://%s/general/status.html", $self->address
};

has ro toner_levels => sub($self) {
    no warnings;  # height = 88px so =/= numerical

    return +{
        wq( $self->url )
            ->find( 'img.tonerremain' )
            ->map(sub {
                lc( $_->attr('alt') ) =>
                    sprintf "%.2f", $_->attr('height') / 55,
            })->@*
    };
};

has '+entries' => default => sub ($self) {
    return [ 
        pairmap { [ { color => $a } => { level => $b } ] }
                $self->toner_levels->%*
    ];
};

1;

__END__
