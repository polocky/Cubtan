package Log::SpeedAnalyze::DB::Row::Tag;
use warnings;
use strict;
use base qw(Log::SpeedAnalyze::DB::Row::Base);

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


1;
