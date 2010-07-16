package Cubtan::DB::Base;
use warnings;
use strict;

sub new {
    my $class = shift;
    my $driver = shift;
    return bless { driver => $driver } , $class ;
}

sub driver { shift->{driver} }

1;
