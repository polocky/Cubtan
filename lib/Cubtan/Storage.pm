package Cubtan::Storage;
use warnings;
use strict;
use Cubtan::Driver;
use Cubtan::DB::Service;

sub new {
    my $class  = shift;
    my $driver_args = shift;
    my $self = bless {},$class;
    $self->setup($driver_args);
    return $self;
}

sub setup {
    my $self = shift;
    my $driver_args = shift;
    my $driver = Cubtan::Driver->new( $driver_args );
    $self->{driver} = $driver;
    $self->{service_db} = Cubtan::DB::Service->new( $self->driver );
}

sub driver { shift->{driver} }
sub service_db { shift->{service_db} }

sub store {
    my $self = shift;
    my $date = shift;
    my $result = shift;
    my $service_obj = $self->service_db->find_or_create( $result->name );
    $self->insert_summary_log( $service_obj , $date , $result );
    $self->insert_status_log( $service_obj , $date , $result );
    for my $tag_name ( keys %{$result->tag} ) {
        my $tag_obj = $service_obj->get_tag_obj( $tag_name );
        $self->insert_tag_log( $date,$tag_obj,$result->tag->{$tag_name} );
        $self->insert_tag_range_log( $date,$tag_obj,$result->tag->{$tag_name} );
    }

}

sub insert_tag_range_log {
    my $self = shift;
    my $date = shift;
    my $tag_obj = shift;
    my $tag = shift;
    my $driver = $self->driver;
    $self->delete_tag_range_log( $tag_obj, $date);
    for ( @{$tag->ranges} ) {
        my $sth = $driver->dbh->prepare("INSERT INTO tag_range_log (tag_id,date,`range`,count,service_id ) VALUES ( ?,?,?,?,? )");
        $sth->execute( $tag_obj->id , $date , $_->{start} , $_->{count} , $tag_obj->service_id );
        $sth->finish;
    }

}

sub delete_tag_range_log {
    my $self = shift;
    my $tag_obj= shift;
    my $date   = shift;
    my $driver = $self->driver;
    my $sth = $driver->dbh->prepare("DELETE FROM tag_range_log WHERE tag_id = ? AND date = ?");
    $sth->execute(  $tag_obj->id , $date );
    $sth->finish;
}

sub insert_tag_log{
    my $self = shift;
    my $date = shift;
    my $tag_obj = shift;
    my $tag = shift;
    my $driver = $self->driver;
    $self->delete_tag_log( $tag_obj , $date );
    my $sth = $driver->dbh->prepare("INSERT INTO tag_log (tag_id,date,count,max,min,avg,alert_count,alert_ratio,service_id) VALUES ( ?,?,?,?,?,?,?,?,?)");
    $sth->execute( $tag_obj->id , $date , $tag->count,$tag->max,$tag->min,$tag->avg,$tag->alert_count,$tag->alert_ratio,$tag_obj->service_id );
    $sth->finish;
}
sub delete_tag_log {
    my $self = shift;
    my $tag_obj= shift;
    my $date   = shift;
    my $driver = $self->driver;
    my $sth = $driver->dbh->prepare("DELETE FROM tag_log WHERE tag_id = ? AND date = ?");
    $sth->execute(  $tag_obj->id , $date );
    $sth->finish;
}

sub insert_status_log {
    my $self   = shift;
    my $service_obj = shift;
    my $date   = shift;
    my $result = shift;
    my $driver = $self->driver;
    $self->delete_status_log( $service_obj , $date );
    for my $code (@{$result->code_list}){
        my $sth = $driver->dbh->prepare("INSERT INTO status_log (service_id,date,code,count) VALUES ( ?,?,?,? )");
        $sth->execute( $service_obj->id , $date , $code , $result->code($code) );
        $sth->finish;
    }

}

sub delete_status_log {
    my $self = shift;
    my $service_obj = shift;
    my $date   = shift;
    my $driver = $self->driver;
    my $sth = $driver->dbh->prepare("DELETE FROM status_log WHERE service_id = ? AND date = ?");
    $sth->execute(  $service_obj->id , $date );
    $sth->finish;

}

sub insert_summary_log {
    my $self   = shift;
    my $service_obj = shift;
    my $date   = shift;
    my $result = shift;
    my $driver = $self->driver;
    $self->delete_summary_log( $service_obj , $date  );
    my $sth = $driver->dbh->prepare("INSERT INTO summary_log (service_id,date,count,max,min,avg,alert,alert_count,alert_ratio,skip_count,ignore_count) VALUES (?, ?,?,?,?,?,?,?,?,?,?)");
    $sth->execute( $service_obj->id , $date , $result->count, $result->max,$result->min,$result->avg,$result->alert , $result->alert_count,$result->alert_ratio,$result->skip_count,$result->ignore_count );
    $sth->finish;
}
sub delete_summary_log {
    my $self   = shift;
    my $service_obj = shift;
    my $date   = shift;
    my $driver = $self->driver;
    my $sth = $driver->dbh->prepare("DELETE FROM summary_log WHERE service_id = ? AND date = ?");
    $sth->execute(  $service_obj->id , $date );
    $sth->finish;
}

1;

=head1 NAME

Cubtan::Storage - storage


=head1 NAME

 my $storage = Cubtan::Storage->new( { config => 'storage.pl' });

 $storage->store({
    service_id => 1,
    date => '2010-12-13',
    result => $result,
 });

=head1 SQL

create table service (
  id integer NOT NULL PRIMARY KEY,
  name varchar(255) NOT NULL,
  created_at datetime NOT NULL,
  updated_at timestamp NOT NULL,
  UNIQUE (name)
);

create table tag (
  id integer NOT NULL PRIMARY KEY,
  service_id integer unsigned NOT NULL,
  name varchar(255) NOT NULL,
  created_at datetime NOT NULL,
  updated_at timestamp NOT NULL,
  UNIQUE (service_id,name)
);

create table summary_log (
  id integer NOT NULL PRIMARY KEY,
  service_id integer NOT NULL,
  date date NOT NULL,
  count integer NOT NULL,
  max double NOT NULL,
  min double NOT NULL,
  avg double NOT NULL,
  alert double NOT NULL,
  alert_count integer NOT NULL,
  alert_ratio double NOT NULL,
  skip_count integer NOT NULL,
  ignore_count integer NOT NULL,
  UNIQUE (date,service_id )
);

create table summary_log_per_hour (
  id integer NOT NULL PRIMARY KEY,
  service_id integer NOT NULL,
  date date NOT NULL,
  hour integer NOT NULL,
  count integer NOT NULL,
  max double NOT NULL,
  min double NOT NULL,
  avg double NOT NULL,
  alert double NOT NULL,
  alert_count integer NOT NULL,
  alert_ratio double NOT NULL,
  skip_count integer NOT NULL,
  ignore_count integer NOT NULL,
  UNIQUE (date,hour,service_id )
);


create table status_log (
  id integer NOT NULL PRIMARY KEY,
  service_id integer NOT NULL,
  date date NOT NULL,
  code integer NOT NULL, 
  count integer NOT NULL,
  UNIQUE (date , service_id ,code)
);


create table tag_log (
  id integer NOT NULL PRIMARY KEY,
  tag_id integer NOT NULL, 
  date date NOT NULL,
  count integer NOT NULL,
  max double NOT NULL,
  min double NOT NULL,
  avg double NOT NULL,
  alert_count integer NOT NULL,
  alert_ratio double NOT NULL,
  service_id integer NOT NULL,
  UNIQUE (date,tag_id)
);

create table tag_range_log (
  id integer NOT NULL PRIMARY KEY,
  tag_id integer NOT NULL,
  date date NOT NULL,
  `range` double NOT NULL,  
  count integer NOT NULL,
  service_id integer NOT NULL,
  UNIQUE (tag_id,date,`range`)
);

=cut
