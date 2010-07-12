package Log::SpeedAnalyze::DB::Service;
use warnings;
use strict;
use base qw/Log::SpeedAnalyze::DB::Base/;
use Log::SpeedAnalyze::DB::Row::Service;

sub find_or_create {
    my $self = shift;
    my $name = shift;
    my $service_obj = $self->find( $name );
    if(!$service_obj){
        $service_obj = $self->create( $name );
    }
    return $service_obj;
}

sub find {
    my $self = shift;
    my $name = shift;
    my $driver = $self->driver;
    my $sth =$driver->dbh->prepare('SELECT * FROM service WHERE name = ?');
    $sth->execute($name);
    my $row = $sth->fetchrow_hashref;
    $sth->finish;
    if($row){
        return Log::SpeedAnalyze::DB::Row::Service->new( $driver ,$row );
    }
    else {
        return;
    }
}

sub create {
    my $self = shift;
    my $name = shift;
    my $driver = $self->driver;
    my $sth =$driver->dbh->prepare('INSERT INTO service (name ,created_at ,updated_at) VALUES ( ?  , NOW() , NOW() )');
    $sth->execute($name);
    $sth->finish;
    return $self->find($name);
}


1;
