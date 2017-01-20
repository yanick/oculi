package App::Oculi::Metric::DiskUsage;

use 5.20.0;

use warnings;

use Net::OpenSSH;

use App::Oculi::Has qw/ ro field fields tag option /;

use Moose;
extends 'App::Oculi::Metric';

use experimental 'signatures', 'postderef';

has option tag host => (
    required => 1,
    documentation => 'target host',
);

has option command => (
    documentation => 'command to extract disk usage',
    default => 'df -B MB',
);

has ro partitions => sub($self) {
    my $ssh = Net::OpenSSH->new($self->host);
    die "Couldn't establish SSH connection: ". $ssh->error if $ssh->error;
 
    my @out = $ssh->capture($self->command);
    die "remote ls command failed: " . $ssh->error if $ssh->error;

    my @partitions = map {
        +{
            partition => $_->[0],
            total_mb => $_->[1] =~ s/MB//r,
            used_mb => $_->[2] =~ s/MB//r,
            available_mb => $_->[3] =~ s/MB//r,
            used_percent => $_->[4] =~ s/%//r,
            mount => $_->[5],
        }
    } map { [ split ] } grep { m#^/dev# } @out;

    return \@partitions;
};


has '+entries' => default => sub ($self) {

    return [
        map { [  { $_->%{ qw/ partition mount / } },
                { $_->%{ qw/ total_mb used_mb available_mb used_percent / } },
        ] } $self->partitions->@*
    ];

};

1;

__END__
