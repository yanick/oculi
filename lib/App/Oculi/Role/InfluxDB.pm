package App::Oculi::Role::InfluxDB;

use Moose::Role;

use App::Oculi::Has qw/ option /;


has option influxdb => (
    documentation => 'push the data to this influx instance',
    is      => 'ro',
    isa     => 'Str',
    predicate => 1,
);


1;
