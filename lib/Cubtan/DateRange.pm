package Cubtan::DateRange;
use warnings;
use strict;
use Cubtan::DateTime;

sub new {
    my $class = shift;
    my $self = shift;
    return bless $self , $class;
}

sub new_from_yestarday {
    my $class = shift;
    my $date = Cubtan::DateTime->yesterday;
    my $start = $date->clone->set_day(1);
    my $end  = Cubtan::DateTime->last_day_of_month( year => $start->year, month => $start->month );
    return $class->new( { start => $start ,end => $end } );
}

sub start { shift->{start} }
sub end { shift->{end} }

sub range_array{
    my $self = shift;
    my @range = ();
    my $current = $self->start->clone;
    while(1){
        last if $current > $self->end;
        push @range , sprintf( "%d-%02d-%02d" , $current->year ,$current->month , $current->day );
        $current->add( days => 1);
    }
    return \@range;

}

1;
