package App::Oculi::Service;

use 5.10.0;

use strict;
use warnings;

use Moose::Role;

before '_process_options' => sub {
    my ( $class, $name, $options ) = @_;

    my $service = delete $options->{service} or return;

    my %args = ref $service eq 'ARRAY' ? ( map { $_ => $_ } @$service )
             : ref $service eq 'HASH' ? %$service
             : ( $service => $service );

    if( keys %args == 1 and ref( (values %args)[0] ) ) {
        $name = keys %args;
        %args = %{ (values %args)[0] };
    }
 
    $options->{is}        ||= 'ro';
    $options->{lazy}      ||= 1;
    $options->{default}   ||= sub {
        my $self = shift;

        my %x = %args;
        $_ = $self->$_ for values %x;

        $self->get_service( $name => \%x );
    };
 
};

1;

__END__
