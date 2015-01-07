use strict;
use warnings;

package App::Oculi;

use 5.10.0;

use strict;
use warnings;

use Moose;

use Bread::Board;
use Class::Load qw/ load_class /;

has [ qw/ influx resources / ] => (
    isa => 'HashRef',
    is => 'ro',
    required => 1,
);

has influxdb => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        
        $self->get_service( influxdb => $self->influx );
    }
);

has board => (
    is => 'ro',
    lazy => 1,
    builder => '_build_board',
);

sub _build_board {
    my $self = shift;
    
    my $c = container 'resources' => as {
        service config => block => sub { $self->{resources} };
    };

    my $services = container 'services' => as { };

    $services->add_sub_container( $self->$_ ) for qw/
        imap_container
        host_container
        influxdb_container
    /;

    $c->add_sub_container($services);

    return $c;
}

sub host_container {
    container host => [ 'Args' ] => as {
        service 'object' => (
            dependencies => {
                resource => depends_on('Args/resource'),
                config => depends_on('/config'),
            },
            block => sub {
                my $s = shift;
                $s->param('config')->{$s->param('resource')}{host};
            }
        )
    };
}

sub influxdb_container {
    container influxdb => [ 'Args' ] => as {
        service 'object' => (
            dependencies => {
                server => depends_on('Args/server'),
                database => depends_on('Args/database'),
                user   => depends_on('Args/user'),
                config => depends_on('/config'),
            },
            block => sub {
                my $s = shift;

                my( $server, $user, $database, $config ) = map { $s->param($_) } qw/
                    server user database config
                /;

                $config = $config->{$server};

                load_class( 'InfluxDB' );

                return InfluxDB->new(
                    host => $config->{host},
                    username => $user,
                    password => $config->{influxdb}{users}{$user}{password},
                    database => $database,
                );
            }
        )
    };
};

sub imap_container {
    container imap => [ 'Args' ] => as {
        service 'object' => (
            dependencies => {
                server => depends_on('Args/server'),
                user   => depends_on('Args/user'),
                config => depends_on('/config'),
            },
            block => sub {
                my $s = shift;

                my( $server, $user, $config ) = map { $s->param($_) } qw/
                    server user config
                /;

                $config = $config->{$server};

                load_class( 'Net::IMAP::Client' );

                my $client = Net::IMAP::Client->new(
                    server => $config->{host},
                    user => $user,
                    pass => $config->{imap}{users}{$user}{password},
                    ssl => 1,
                    ssl_verify_peer => 0,
                );

                $client->login;

                return $client;
            }
        )
    };
}


sub get_service {
    my( $self, $service, $args ) = @_;

    my $c = Bread::Board::Container->new(name => 'Args' );

    while( my($k,$v)  = each %$args ) {
        $c->add_service( Bread::Board::Literal->new( name => $k, value => $v));
    }

    return $self->board->fetch( "/services/$service" )->create( Args => $c )->resolve(
        service => 'object'
    );

}

sub write_points{
    my( $self, @args ) = @_;
    $self->influxdb->write_points(@args) or die $self->influxdb->errstr;
}

1;

__END__



