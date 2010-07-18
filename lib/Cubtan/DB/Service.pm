package Cubtan::DB::Service;
use warnings;
use strict;
use base qw/Cubtan::DB::Base/;
use Cubtan::DB::Row::Service;

sub find_or_create {
    my $self = shift;
    my $name = shift;
    my $service_obj = $self->find( $name );
    if(!$service_obj){
        $service_obj = $self->create( $name );
    }
    return $service_obj;
}

sub lookup {
    my $self = shift;
    my $id = shift;
    my $driver = $self->driver;
    my $sth =$driver->dbh->prepare('SELECT * FROM service WHERE id = ?');
    $sth->execute($id);
    my $row = $sth->fetchrow_hashref;
    $sth->finish;
    if($row){
        return Cubtan::DB::Row::Service->new( $driver ,$row );
    }
    else {
        return;
    }
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
        return Cubtan::DB::Row::Service->new( $driver ,$row );
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

sub retrieve_all {
    my $self = shift;
    my $sth = $self->driver->dbh->prepare('SELECT * FROM service');
    $sth->execute();
    my @service_objs = ();
    while(my $row = $sth->fetchrow_hashref()){
        my $service_obj =Cubtan::DB::Row::Service->new($self->driver, $row);
        push @service_objs , $service_obj;
    }
    $sth->finish;
    return \@service_objs;
}


1;
