#!/usr/bin/perl 

use strict;
use warnings;

use 5.20.0;

package Imap {
    use Moose;

    has [ qw/ host user password / ] => ( required => 1, is => 'ro' );
}

use Bread::Board;


my $c = container 'oculi' =>  as {
    container config => as {
        container enkidu => as {
            service host => '192.168.0.103';
            container imap => as {
                container users => as {
                    container yanick => as {
                        service password => 'meh'
                    };
                };
            };
        };
    };

    container imap => [ 'Info' ] => as {
        service 'imap' => (
            dependencies => {
                server => depends_on('Info/server'),
                user => depends_on('Info/user'),
            },
            block => sub {
                my $s = shift;

                my( $server, $user ) = map { $s->param($_) } qw/ server user /;

                my $config = $s->fetch("/config/$server");

                warn $config->fetch('host')->value;
                warn $config->fetch("imap/users/$user/password")->value;

                return Imap->new(
                    host => $s->param('server'),
                    user => $s->param('user'),
                    password => $s->param('config')->{services}{
                        $s->param('server') }{imap}{ $s->param('user') }{password}
                );
            }
        )
    };
};

use Data::Printer;
my $info = container 'Info' => as {
    service server => 'enkidu';
    service user => 'yanick';
};

my $imap = $c->fetch('/imap')->create( Info => $info )->resolve( service => 'imap' );

p $imap;
