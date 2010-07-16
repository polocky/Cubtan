package Cubtan::DB::Row::Tag;
use warnings;
use strict;
use base qw(Cubtan::DB::Row::Base);

sub new {
    my $class = shift;
    my $service_obj = shift;
    my $row = shift;
    my $self = bless { row => $row , driver => $service_obj->driver , service_obj => $service_obj } , $class;
    return $self;
}

sub id { shift->{row}{id} }
sub name { shift->{row}{name} }
sub created_at{ shift->{row}{created_at} }
sub updated_at{ shift->{row}{updated_at} }
sub service_id { shift->{row}{service_id} }
sub service_obj { shift->{service_obj} }

sub get_summary {
    my $self = shift;
    my $range = shift;
    my $sth = $self->driver->dbh->prepare('SELECT * FROM summary_log WHERE date between ? AND ? AND service_id = ?');
    $sth->executre($range->start,$range->end,$self->service_obj->id);
    my $hash = $sth->fetchall_hashref('date');
    $sth->finish;
    return $hash;
}

1;
