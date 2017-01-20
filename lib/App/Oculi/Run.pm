package App::Oculi::Run;

use 5.20.0;
use warnings;

use File::Serialize;

use MooseX::App::Command;

extends 'App::Oculi';

use experimental 'signatures', 'postderef';

parameter check => (
    is => 'ro',
    required => 1,
);

sub run($self) {
    my ( $check, $config ) = deserialize_file( $self->check )->%*;

    $check = "App::Oculi::Metric::" . ucfirst $check;
    $check =~ s/_(.)/uc $1/ge;

    use Module::Runtime qw/ use_module /;

    use_module($check)->new(
        %$config,
        $self->extra_argv->@*
    )->run;
}


1;
