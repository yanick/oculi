package App::Oculi::Has;

use 5.20.0;
use warnings;

use Carp;

use parent 'Exporter::Tiny';

use experimental 'signatures', 'postderef';

our @EXPORT_OK = qw/ ro field fields tag option array /;

sub common($name,@attr) {
    @attr = ( lazy => 1, default => @attr ) if @attr == 1;

    if( @attr % 2 ) {
        croak "odd number of arguments for attribute '$name': ", join ' ', @attr;
    }

    my %attr = @attr;
    $attr{traits} ||= [];

    if( ref $attr{lazy} ) {
        $attr{default} = $attr{lazy};
        $attr{lazy} = 1;
    }

    no warnings 'uninitialized';

    $attr{predicate} = 'has_'.$name if $attr{predicate} == 1;

    return $name => %attr;
}

sub ro($name, @attr) {
    my(undef,%attr) = common $name, @attr ;
    return $name => is => 'ro', %attr;
}

sub array($name, @attr) {
    my (undef, %attr ) = common($name, @attr);

    push $attr{traits}->@*, 'Array';

    return $name => %attr;
}

sub tag($name, @attr) {
    my (undef, %attr ) = ro($name, @attr);

    push $attr{traits}->@*, 'App::Oculi::Trait::Tag';

    return $name => %attr;
}

sub option($name,@attr) {
    my (undef, %attr ) = ro($name, @attr);
    push $attr{traits}->@*, 'MooseX::App::Meta::Role::Attribute::Option';
    return $name => cmd_type => 'option', %attr;
}

sub field($name, @attr) {
    my (undef, %attr ) = ro($name, @attr);

    push $attr{traits}->@*, 'App::Oculi::Trait::Field';

    return $name => %attr;
}

sub fields($name, @attr) {
    my (undef, %attr ) = ro($name, @attr);

    push $attr{traits}->@*, 'App::Oculi::Trait::Fields';

    return $name => %attr;
}


1;
