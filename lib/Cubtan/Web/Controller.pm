package Cubtan::Web::Controller;
use warnings;
use strict;
use Cubtan::DB::Service;
use Cubtan::DateTime;
use Cubtan::DateRange;
use Cubtan::Web::JqpLot;

sub dispatch_root {
    my $self = shift;
    $self->{file} = 'root';
    my $range_obj = $self->get_target_range();
    my $service_db = Cubtan::DB::Service->new( $self->driver );
    my $service_objs = $service_db->retrieve_all();
    my $service_fields = $self->get_service_fields;
    my $hash  = {};
    for(@$service_objs){
        $hash->{$_->name} = $_->get_chart_summary_log($range_obj , 'avg' );
    }
    $self->stash->{service_objs} = $service_objs;
    $self->stash->{service_fields} = $service_fields;

    my $avg_chart
        = Cubtan::Web::JqpLot->new({
            fields => $service_fields,
            range => $range_obj->range_array,
            data => $hash,
        })->create;

    $self->stash->{avg_chart} = $avg_chart;
    $self->stash->{range_obj} = $range_obj;

}

sub get_service_fields {
    my $self = shift;
    my $fields = {};
    for(@{$self->config->{service}}) {
        my $name = $_->{parser}{name} || 'unknown';
        $fields->{$name} = $_->{field} || { color =>'black',label =>'Unknown',comment =>"Unknown" };
    }
    return Cubtan::Fields->new($fields);
}


sub dispatch_service {
    my $self = shift;
    $self->{file} = 'service';
    my $service_id = $self->args->[0];
    my $service_db = Cubtan::DB::Service->new( $self->driver );
    my $service_obj = $service_db->lookup( $service_id) or die 'NOT FOUND';;
    $self->stash->{service_obj} = $service_obj;
}

sub get_target_range {
    my $self = shift;
    my $start = $self->req->param('start');
    my $end = $self->req->param('end');
    if( $start && $end ){
        my $start_obj;
        my $end_obj;
        {
            my ($year,$month ,$day ) = split('-',$start );
            $start_obj = Cubtan::DateTime->new( year => $year , month => $month , day => $day  );
        }
        {
            my ($year,$month ,$day ) = split('-',$end );
            $end_obj = Cubtan::DateTime->new( year => $year , month => $month , day => $day  );
        }
        return Cubtan::DateRange->new({start => $start_obj , end => $end_obj } );

    } else {
        return Cubtan::DateRange->new_from_yestarday();
    }
}

sub get_target_day {
    my $self = shift;
    my $ymd = $self->req->param('ymd');
    my $date;
    if( $ymd ){
        my ($year,$month,$day) = split('-',$ymd);
        $date = Cubtan::DateTime->new( year => $year , month => $month , day => $day );
    } else {
        $date = Cubtan::DateTime->yesterday;
    }
    return $date;
}

sub new {
    my $class = shift;
    my $args = shift;
    my $self = bless $args,$class;
    $self->{stash} = {};
    return $self;
}

sub driver { shift->{driver} }
sub args { shift->{args} }
sub req { shift->{req} }
sub res { shift->{res} }
sub file { shift->{file} }
sub config { shift->{config} }

sub stash { shift->{stash}  }

1;
