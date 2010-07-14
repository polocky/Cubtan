package Log::SpeedAnalyze::Range;
use warnings;
use strict;

sub new {
    my $class = shift;
    my $self = shift;
    return bless $self , $class;
}

sub new_from_now {
    my $class = shift;
    my $self = bless {}, $class;

    #TODO now()
    return $self;


}

sub start { shift->{start} }
sub end { shift->{end} }

1;
