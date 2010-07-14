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
    my $service_id = $self->args->[0];
    my $service_db = Log::SpeedAnalyze::DB::Service->new( $self->driver );
    my $service_obj = $service_db->lookup( $service_id) or die 'NOT FOUND';;
    $self->stash->{service_obj} = $service_obj;
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

sub stash { shift->{stash}  }

1;
