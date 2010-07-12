package Log::SpeedAnalyze::DB::Row::Service;
use warnings;
use strict;
use base qw(Log::SpeedAnalyze::DB::Row::Base);
use Log::SpeedAnalyze::DB::Tag;

sub new {
    my $class = shift;
    my $driver = shift;
    my $row = shift;
    my $self = bless { row => $row , driver => $driver } , $class;
    my $tag_db = Log::SpeedAnalyze::DB::Tag->new( $self );
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

1;
