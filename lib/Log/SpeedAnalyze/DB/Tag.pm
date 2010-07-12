package Log::SpeedAnalyze::DB::Tag;
use warnings;
use strict;
use base qw/Log::SpeedAnalyze::DB::Base/;
use Log::SpeedAnalyze::DB::Row::Tag;

sub new {
    my $class = shift;
    my $service_obj = shift;
    return bless { driver => $service_obj->driver , service_obj => $service_obj } , $class ;
}

sub service_obj { shift->{service_obj} }
sub find_or_create {
    my $self = shift;
    my $name = shift;
    my $tag_obj = $self->find( $name );
    if(!$tag_obj){
        $tag_obj = $self->create( $name );
    }
    return $tag_obj;
}

sub find {
    my $self = shift;
    my $name = shift;
    my $driver = $self->driver;
    my $sth =$driver->dbh->prepare('SELECT * FROM tag WHERE service_id = ? AND name = ?');
    $sth->execute($self->service_obj->id , $name);
    my $row = $sth->fetchrow_hashref;
    $sth->finish;
    if($row){
        return Log::SpeedAnalyze::DB::Row::Tag->new( $self->service_obj ,$row );
    }
    else {
        return;
    }
}

sub create {
    my $self = shift;
    my $name = shift;
    my $driver = $self->driver;
    my $sth =$driver->dbh->prepare('INSERT INTO tag (service_id, name, created_at, updated_at) VALUES ( ?, ?, NOW(), NOW() )');
    $sth->execute($self->service_obj->id , $name);
    $sth->finish;
    return $self->find($name);
}


1;
