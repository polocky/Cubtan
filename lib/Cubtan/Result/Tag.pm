package Cubtan::Result::Tag;
use warnings;
use strict;

sub new {
    my $class = shift;
    my $args = shift;
    my $self = bless $args , $class;
    $self->setup();
    return $self;
}

sub count { shift->{count} || 0 }
sub min { shift->{min}|| 0 }
sub max { shift->{max} || 0 }
sub total { shift->{total} || 0 }
sub alert_count { shift->{alert_count} || 0  }
sub alert_ratio { shift->{alert_ratio} }
sub ranges { shift->{ranges} }
sub range { shift->{range}{shift} || 0 }
sub avg { shift->{avg} || 0 }

sub setup {
    my $self = shift;
    $self->{alert_ratio} = $self->setup_alert_ratio;
    $self->{avg} = $self->setup_avg;
    $self->{ranges} = $self->setup_ranges;
}
sub setup_ranges {
    my $self = shift;
    my $range = $self->{range} || {};
    my @keys = sort { $a <=> $b } keys %$range;

    my @ranges = ();

    for(@keys){
        push @ranges , { start => $_  , count => $range->{$_} }
    }
    return \@ranges;
}

sub setup_avg{
    my $self = shift;
    return int ($self->total / $self->count * 100 ) / 100 ;
}
sub setup_alert_ratio{
    my $self = shift;
    return 0 unless $self->alert_count;
    int($self->alert_count / $self->count * 100 * 100 ) / 100 ;
}

1;

=head1 NAME

Cubtan::Result::Tag - Tag Obj.

=head1 METHOD

=head2 count

count of entry

=head2 min

min sec.

=head2 max

max sec.

=head2 total

total sec.

=head2 alert_count

alert count.

=head2 alert_ratio

alert ratio 

=head2 range($sec)

count or the target range.

=head2 ranges

return ranged count with array ref.

=cut
