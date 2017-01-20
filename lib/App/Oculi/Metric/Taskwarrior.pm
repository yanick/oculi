package App::Oculi::Metric::Taskwarrior;

use 5.20.0;
use warnings;

use JSON;
use List::AllUtils qw/ sum pairmap /;
use List::UtilsBy qw/ partition_by /;

use App::Oculi::Has qw/ ro field fields array /;

use Moose;

extends 'App::Oculi::Metric';

use experimental 'signatures', 'postderef';

has ro array _tasks => 
    lazy => sub {
        open my $tw, '-|', 'task +READY export';
        my $tasks = from_json join '', <$tw>;
    },
    handles => {
        nbr_tasks => 'count',
        map_tasks => 'map',
    };

has field tasks => sub($self) { $self->nbr_tasks };

has field urgency => sub($self) { sum $self->map_tasks(sub{ $_->{urgency} } ) };

# Check if naming is in sync with influxdb. I think metric should be
# measurement?

# I want fields where it can return a hash(?) of values

=head2 fields

Attribute that returns a hash of fields for the measurement.

    has fields min_max => sub($self) {
        my $data = $self->data;
        return {
            min => min @$data,
            max => max @$data,
        };
    };

=cut

has fields priorities => sub($self) {
    +{
    ( map { ( "priority_$_" => 0 ) } qw/ M H L unprioritized / ),
    pairmap { "priority_$a" => scalar @$b }
    partition_by { $_ } 
        $self->map_tasks(sub{ $_->{priority} || 'unprioritized' })
    }
};

1;
