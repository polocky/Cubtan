package Log::SpeedAnalyze::Web::Controller;
use warnings;
use strict;
use Log::SpeedAnalyze::DB::Service;


sub dispatch_root {
    my $self = shift;
    $self->{file} = 'root';
    my $service_db = Log::SpeedAnalyze::DB::Service->new( $self->driver );
    my $service_objs = $service_db->retrieve_all();
    $self->stash->{service_objs} = $service_objs;
}


sub dispatch_service {
    my $self = shift;
    $self->{file} = 'service';
}


sub new {
    my $class = shift;
    my $args = shift;
    my $self = bless $args,$class;
    return $self;
}

sub driver { shift->{driver} }
sub args { shift->{args} }
sub req { shift->{req} }
sub res { shift->{res} }
sub file { shift->{file} }

sub stash { 
    my $self = shift;
    my $key = shift;
    my $data = shift;
    if(defined $data){
        $self->{stash}{$key} = $data;
    }
    elsif($key) {
        return $self->{stash}{$key} ;
    }
    else {
        return $self->{stash} || {};
    }
}

1;
