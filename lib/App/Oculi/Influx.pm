package App::Oculi::Influx;

use strict;
use warnings;

use InfluxDB::LineProtocol qw(data2line line2data);
use LWP::UserAgent;
use Escape::Houdini qw/ escape_uri /;
use JSON;

use Moose;
use MooseX::MungeHas 'is_ro';

has host_address => ();
has database => ();

has agent => sub {
    LWP::UserAgent->new;
};

has url => sub {
    my $self = shift;
    
    'http://'. $self->host_address . ':8086/write?db=' . $self->database;
};

sub write {
    my( $self, @data ) = @_;

    $self->agent->post( $self->url, Content => data2line( @data ) );
} 

sub query {
    my $self = shift;
    my $url = 'http://'. $self->host_address . ':8086/query?db=' . $self->database . '&q=' .
        escape_uri( shift );

        from_json( $self->agent->get( $url )->content );
} 
1;



