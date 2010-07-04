package Log::SpeedAnalyze::Result::Tag;
use warnings;
use strict;

sub new {
    my $class = shift;
    my $args = shift;
    return bless $args , $class;
}

sub count { shift->{count} }
sub min { shift->{mini} }
sub max { shift->{max} }
sub range { shift->{range} }
sub total { shift->{total} }
sub alert_count { shift->{alert_count} || 0  }

sub alert_ratio {
    my $self = shift;
    return 0 unless $self->alert_count;
    int( $self->alert_count / $self->count * 100 ) ;
}

1;
