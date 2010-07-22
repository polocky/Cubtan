package Cubtan::Driver;
use warnings;
use strict;
use DBI;

sub new {
    my $class = shift;
    my $args = shift || {};
    my $self = bless $args , $class;
    $self->{dbh} = $self->connect_db;
    return $self;
}

sub connect_db {
    my $self = shift;
    my $dbh = DBI->connect($self->{dsn}, $self->{username}, $self->{password} , {
            PrintError => 1,
            AutoCommit => 1,
            }) ;
    return $dbh;
}

sub dbh { 
    my $self = shift;
    unless( $self->{dbh} && $self->{dbh}->ping ) {
        $self->{dbh} = $self->connect_db;
    }

    return $self->{dbh};
}

1;
