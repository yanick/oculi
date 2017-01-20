package App::Oculi::Service::SSH;

use strict;
use warnings;

use Moose::Role;
use MooseX::MungeHas 'is_ro';

use Class::Load qw/ load_class /;

has ssh => ( lazy => 1, default => sub {
    my $self = shift;
    warn "really?";
    
    my $host_config = $self->config->{resources}{ $self->host };
    load_class('Net::OpenSSH')->new(
        $host_config->{host_address},
        user => $host_config->{ssh}{default_user}{username},
        password => $host_config->{ssh}{default_user}{password} 
    );

} );

1;



