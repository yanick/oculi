package App::Oculi::Command::Gather;


use strict;
use warnings;

use MooseX::App::Command;

use YAML;
use Data::Printer;
use Class::Load qw/ try_load_class /;
use App::Oculi;

use 5.20.0;

option config => (
    is => 'ro',
    default => 'oculi.yml'
);

option verbose => (
    isa => 'Bool',
    is => 'rw',
    default => 0,
);

option dry_run => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
    trigger => sub { $_[0]->verbose(1) if $_[1] }
);

parameter checks => (
    is => 'ro',
    isa => 'ArrayRef',
);

has "oculi" => (
    isa => 'App::Oculi',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        App::Oculi->new(
            YAML::LoadFile( $self->config )
        );
    },
);

sub run {
    my $self = shift;

    for my $file ( @{ $self->checks } ) {
        say "loading '$file'..." if $self->verbose;

        my $content = YAML::LoadFile($file);
        my @checks = ref $content eq 'ARRAY' ? @$content : ( $content );

        for my $c ( @checks ) {
            $self->run_check($c);
        }
    }

}

sub run_check {
    my( $self, $config ) = @_;

    my $metric = delete $config->{metric};

    say "metric: $metric" if $self->verbose;

    my $module = "App::Oculi::Metric::$metric";
    try_load_class( $module ) or die "couldn't load $module";

    my $check = $module->new( oculi => $self->oculi, %$config );

    my $series = $check->series_label;

    say "series: $series" if $self->verbose;

    my $stats = $check->gather_stats;

    say p($stats) if $self->verbose;

    $self->record( $series => $stats ) unless $self->dry_run;
}

sub record {
    my( $self, $series, $stats ) = @_;

    # TODO right now we only accept a single point. Boring
    $self->oculi->write_points(
        data => {
            name => $series, 
            columns => [ keys %$stats ],
            points => [ [ values %$stats ] ]
        },
    );

}

1;

__END__




1;

__END__

use strict;
use warnings;



