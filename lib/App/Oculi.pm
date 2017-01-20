use 5.20.0;
use warnings;

package App::Oculi;

use MooseX::App qw/Config/;

app_namespace 'App::Oculi::Metric';

package App::Oculi::Trait::Tag    { use Moose::Role }
package App::Oculi::Trait::Field  { use Moose::Role }
package App::Oculi::Trait::Fields { use Moose::Role }

1;

__END__



