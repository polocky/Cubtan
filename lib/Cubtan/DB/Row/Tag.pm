package Cubtan::DB::Row::Tag;
use warnings;
use strict;
use base qw(Cubtan::DB::Row::Base);
use Cubtan::Fields::Tag;

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

sub get_chart_tag_log {
    my $self = shift;
    my $range_obj = shift;
    my $key = shift || 'avg';

    my $sth = $self->driver->dbh->prepare("SELECT $key,date FROM tag_log WHERE tag_id = ? AND date >= ? AND date <= ?");
    $sth->execute( $self->id , $range_obj->start->ymd , $range_obj->end->ymd );
    my $log = {};
    while(my $row = $sth->fetchrow_hashref ) {
        $log->{$row->{date}} = $row->{$key};
    }
    $sth->finish;
    return $log ;

}

sub get_sample_tag_log {
    my $self = shift;
    my $range_obj = shift;
    my $sth = $self->driver->dbh->prepare("SELECT sum(count) FROM tag_log WHERE tag_id = ? AND date >= ? AND date <= ?");
    $sth->execute( $self->id , $range_obj->start->ymd , $range_obj->end->ymd );
    my $row = $sth->fetchrow_arrayref ;
    $sth->finish;
    return $row->[0];
}
sub get_tag_range_log_chart_obj {
    my $self = shift;
    my $range_obj = shift;
    my $sth = $self->driver->dbh->prepare("SELECT `range`,date,count FROM tag_range_log WHERE tag_id = ? AND date >= ? AND date <= ?");
    $sth->execute( $self->id , $range_obj->start->ymd , $range_obj->end->ymd );
    my $hash = {};
    my $hash2 = {};
    my $data = {};
    while(my $row = $sth->fetchrow_hashref ) {
        $data->{count}{$row->{range}}{$row->{date}} = $row->{count};
        $data->{max}{$row->{date}} ||= 0;
        $data->{max}{$row->{date}} += $row->{count};
    }
    $sth->finish;

    for my $range (keys %{$data->{count}} ){
        for my $date (keys %{$data->{count}{$range}} ){
            $hash->{$range}{$date} = int ( $data->{count}{$range}{$date} / $data->{max}{$date}  * 100 * 100 ) / 100;
            #$hash2->{$range}{$date} =  $data->{count}{$range}{$date};
        }
    }
    
    my @keys = keys %$hash;

    my $fields = {};
    for(@keys){
        $fields->{$_} = { label => $_ ,comment => '' };
    }
    my $fields_obj = Cubtan::Fields::Tag->new($fields);

    my $avg_chart
        = Cubtan::Web::JqpLot->new({
            fields => $fields_obj,
            range => $range_obj->range_array,
            data => $hash,
            #hash2 => $hash2,
        })->create;

}

1;
