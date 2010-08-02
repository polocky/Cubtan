package Cubtan::DB::Row::Service;
use warnings;
use strict;
use base qw(Cubtan::DB::Row::Base);
use Cubtan::DB::Tag;

sub new {
    my $class = shift;
    my $driver = shift;
    my $row = shift;
    my $self = bless { row => $row , driver => $driver } , $class;
    my $tag_db = Cubtan::DB::Tag->new( $self );
    $self->{tag_db} = $tag_db;
    return $self;
}
sub tag_db{ shift->{tag_db} }

sub id { shift->{row}{id} }
sub name { shift->{row}{name} }
sub created_at{ shift->{row}{created_at} }
sub updated_at{ shift->{row}{updated_at} }

sub get_tag_obj {
    my $self = shift;
    my $name = shift;
    return $self->tag_db->find_or_create( $name );
}

sub get_tag_objs {
    my $self = shift;
    return $self->tag_db->retrieve_all();
}

sub get_chart_summary_log {
    my $self = shift;
    my $range_obj = shift;
    my $key = shift || 'avg';

    my $sth = $self->driver->dbh->prepare("SELECT $key,date FROM summary_log WHERE service_id = ? AND date >= ? AND date <= ?");
    $sth->execute( $self->id , $range_obj->start->ymd , $range_obj->end->ymd );
    my $log = {};
    while(my $row = $sth->fetchrow_hashref ) {
        $log->{$row->{date}} = $row->{$key};
    }
    $sth->finish;
    return $log ;
}
sub get_chart_summary_log_per_hour {
    my $self = shift;
    my $range_obj = shift;
    my $key = shift || 'avg';

    my $sth = $self->driver->dbh->prepare("SELECT avg($key) $key ,hour FROM summary_log_per_hour WHERE service_id = ? AND date >= ? AND date <= ? GROUP BY hour");
    $sth->execute( $self->id , $range_obj->start->ymd , $range_obj->end->ymd );
    my $log = {};
    while(my $row = $sth->fetchrow_hashref ) {
        $log->{$row->{hour}} = $row->{$key};
    }
    $sth->finish;
    return $log ;
}

sub get_sample_summary_log {
    my $self = shift;
    my $range_obj = shift;

    my $sth = $self->driver->dbh->prepare("SELECT sum(count) FROM summary_log WHERE service_id = ? AND date >= ? AND date <= ?");
    $sth->execute( $self->id , $range_obj->start->ymd , $range_obj->end->ymd );
    my $row = $sth->fetchrow_arrayref;
    $sth->finish;
    return $row->[0];
}
1;
