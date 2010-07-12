package Log::SpeedAnalyze::Storage;
use warnings;
use strict;
use Log::SpeedAnalyze::Driver;
use Log::SpeedAnalyze::DB::Service;

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
    my $driver = Log::SpeedAnalyze::Driver->new( $driver_args );
    $self->{driver} = $driver;
    $self->{service_db} = Log::SpeedAnalyze::DB::Service->new( $self->driver );
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
    for my $tag ( keys %{$result->tag} ) {
        my $tag_obj = $service_obj->get_tag_obj( $tag );
    }

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
    my $sth = $driver->dbh->prepare("INSERT INTO summary_log (service_id,date,count,alert,alert_count,alert_ratio,skip_count) VALUES ( ?,?,?,?,?,?,? )");
    $sth->execute( $service_obj->id , $date , $result->count, $result->alert , $result->alert_count,$result->alert_ratio,$result->skip_count);
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

Log::SpeedAnalyze::Storage - storage


=head1 NAME

 my $storage = Log::SpeedAnalyze::Storage->new( { config => 'storage.pl' });

 $storage->store({
    service_id => 1,
    date => '2010-12-13',
    result => $result,
 });

=head1 SQL

create table service (
  id int(10) unsigned NOT NULL auto_increment,
  name varchar(255) NOT NULL,
  created_at datetime NOT NULL,
  updated_at timestamp NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY name (name)
);

create table tag (
  id int(10) unsigned NOT NULL auto_increment,
  service_id int unsigned NOT NULL,
  name varchar(255) NOT NULL,
  created_at datetime NOT NULL,
  updated_at timestamp NOT NULL,
  PRIMARY KEY  (id),
  UNIQUE KEY servie_id_name (service_id,name)
);

create table summary_log (
  id int(10) unsigned NOT NULL auto_increment,
  service_id int unsigned NOT NULL,
  date date NOT NULL,
  count int unsigned NOT NULL,
  alert double unsigned NOT NULL,
  alert_count int unsigned NOT NULL,
  alert_ratio double unsigned NOT NULL,
  skip_count int unsigned NOT NULL,
  PRIMARY KEY  (id),
  UNIQUE KEY date_service_id (date,service_id )
);

create table status_log (
  id int(10) unsigned NOT NULL auto_increment,
  service_id int unsigned NOT NULL,
  date date NOT NULL,
  code int unsigned NOT NULL, 
  count int unsigned NOT NULL,
  PRIMARY KEY  (id),
  UNIQUE KEY date_service_id_code (date , service_id ,code)
);

create table tag_log (
  id int(10) unsigned NOT NULL auto_increment,
  tag_id int unsigned NOT NULL, 
  date date NOT NULL,
  count int unsigned NOT NULL,
  min double unsigned NOT NULL,
  avg double unsigned NOT NULL,
  alert_count int unsigned NOT NULL,
  alert_ratio double unsigned NOT NULL,
  service_id int unsigned NOT NULL,
  PRIMARY KEY  (id),
  UNIQUE KEY date_tag_id (date,tag_id)
);

create table tag_range_log (
  id int(10) unsigned NOT NULL auto_increment,
  tag_log_id int unsigned NOT NULL, 
  range double unsigned NOT NULL,  
  count int unsigned NOT NULL,
  service_id int unsigned NOT NULL,
  tag_id int unsigned NOT NULL,
  date date NOT NULL,
  PRIMARY KEY  (id),
  UNIQUE KEY tag_log_id_range (tag_log_id,range)
);

=cut


