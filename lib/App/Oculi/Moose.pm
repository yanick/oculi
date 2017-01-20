package App::Oculi::Moose;

use Moose;
require MooseX::App::Command;

use experimental 'signatures';

Moose::Exporter->setup_import_methods(
    with_meta => [ 'tag' ],
    also => [ 'Moose', 'MooseX::App::Command' ],
);

sub tag($meta,$name) {
    warn @_;
    my $name = 'bozo';
    $DB::single = 1;
    
    $meta->add_attribute( $name => 
        is => 'rw',
    );
};

1;
