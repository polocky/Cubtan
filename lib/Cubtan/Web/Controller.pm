package Cubtan::Web::Controller;
use warnings;
use strict;
use Cubtan::DB::Service;
use Cubtan::DateTime;
use Cubtan::DateRange;

sub dispatch_service_hourly {
    my $self = shift;
    $self->{file} = 'service/hourly';
    my $range_obj   = $self->get_target_range();
    my $service_id  = $self->args->[0];
    my $service_obj = Cubtan::DB::Service->new( $self->driver )->lookup( $service_id) or die 'NOT FOUND';
    my $tag_objs    = $service_obj->get_tag_objs();
    my $summary     = {};
    for my $tag_obj ( @$tag_objs ) {
        $summary->{$tag_obj->name} = $tag_obj->get_chart_tag_log_per_hour( $range_obj , 'avg' );
    }
    $summary->{summary} = $service_obj->get_chart_summary_log_per_hour( $range_obj, 'avg' );

    # make line for tag_obj
    my @lines;
    for my $hour ( 0..23 ) {
        my @data = $hour;
        for my $tag_obj ( @$tag_objs ) {
            push @data, $summary->{$tag_obj->name}->{$hour} || 0;
        }
        push @data, $summary->{summary}->{$hour} || 0;

        my $line = join ',', @data;
        push @lines, $line;
    }

    my $tag_fields = $self->get_tag_fields( $self->get_service_config( $service_obj ),
                                            [ { name => 'summary',  label => 'Summary' } ] );
    $self->stash->{service_obj} = $service_obj;
    $self->stash->{range_obj}   = $range_obj;
    $self->stash->{tag_fields}  = $tag_fields;
    $self->stash->{tag_objs}    = $tag_objs;
    $self->stash->{summary}     = $summary;
    $self->stash->{lines}       = \@lines;
}

sub dispatch_service {
    my $self = shift;
    $self->{file} = 'service';
    my $range_obj      = $self->get_target_range();
    my $service_id     = $self->args->[0];
    my $service_obj    = Cubtan::DB::Service->new( $self->driver )->lookup( $service_id ) or die 'NOT FOUND';
    my $tag_objs       = $service_obj->get_tag_objs();
    my $summary        = {};
    my $sample         = {};
    my %tag_range_of;
    for my $tag_obj ( @$tag_objs ) {
        $summary->{$tag_obj->name} = $tag_obj->get_chart_tag_log($range_obj , 'avg' );
        $sample->{$tag_obj->name} = $tag_obj->get_sample_tag_log($range_obj );

        # make line for range per tag_obj.
        my $tag_range_log = $tag_obj->get_tag_range_log($range_obj);
        for my $date ( @{ $range_obj->range_array } ) {
            my @data = $date;
            my @ranges = sort { $a <=> $b } keys %$tag_range_log;
            for my $range ( @ranges ) {
                push @data, $tag_range_log->{ $range }->{ $date } || 0;
            }
            my $line = join ',', @data;
            push @{ $tag_range_of{ $tag_obj->name }->{ lines } }, $line;
            push @{ $tag_range_of{ $tag_obj->name }->{ ranges } }, @ranges;
        }
    }

    # make line for tag_obj
    my @lines;
    for my $date ( @{ $range_obj->range_array } ) {
        my @data = $date;
        for my $tag_obj (@$tag_objs) {
            push @data, $summary->{$tag_obj->name}->{$date} || 0;
        }
        my $line = join ',', @data;
        push @lines, $line;
    }

    $self->stash->{service_obj}  = $service_obj;
    $self->stash->{range_obj}    = $range_obj;
    $self->stash->{sample}       = $sample;
    $self->stash->{tag_fields}   = $self->get_tag_fields( $self->get_service_config( $service_obj ) );
    $self->stash->{tag_objs}     = $tag_objs;
    $self->stash->{summary}      = $summary;
    $self->stash->{lines}        = \@lines;
    $self->stash->{tag_range_of} = \%tag_range_of;
}

sub dispatch_root {
    my $self = shift;
    $self->{file} = 'root';

    my $range_obj      = $self->get_target_range();
    my $service_fields = $self->get_service_fields;
    my $service_objs   = Cubtan::DB::Service->new( $self->driver )->retrieve_all();
    my $summary        = {};
    my $sample         = {};

    for my $service_obj ( @$service_objs ) {
        $summary->{$service_obj->name} = $service_obj->get_chart_summary_log($range_obj , 'avg');
        $sample->{$service_obj->name}  = $service_obj->get_sample_summary_log($range_obj);
    }

    my @lines;
    for my $date ( @{ $range_obj->range_array } ) {
        my @data = $date;
        for my $service_obj (@$service_objs) {
            push @data, $summary->{$service_obj->name}->{$date} || 0;
        }
        my $line = join ',', @data;
        push @lines, $line;
    }

    $self->stash->{service_objs}   = $service_objs;
    $self->stash->{service_fields} = $service_fields;
    $self->stash->{sample}         = $sample;
    $self->stash->{summary}        = $summary;
    $self->stash->{lines}          = \@lines;
    $self->stash->{range_obj}      = $range_obj;
}


sub get_service_fields {
    my $self = shift;
    my $fields = {};
    for(@{$self->config->{service}}) {
        my $name = $_->{parser}{name} || 'unknown';
        $fields->{$name} = $_->{field} || { label =>'Unknown' };
    }
    return Cubtan::Fields->new($fields);
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

sub get_service_config {
    my $self = shift;
    my $service_obj = shift;
    for( @{$self->config->{service}} ){
        if( $_->{parser}{name} eq $service_obj->name ) {
            return $_;
        }
    }

    return {};
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

sub get_tag_fields {
    my $self = shift;
    my $service_config = shift;
    my $addition = shift || [];
    my $fields = {};
    for( @{$service_config->{parser}{tag}} ){
        $fields->{$_->{name}} = {  label => $_->{label}  } ;
    }
    for(@$addition){
        $fields->{$_->{name}} = {  label => $_->{label}  } ;
    }
    return Cubtan::Fields->new($fields);
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
