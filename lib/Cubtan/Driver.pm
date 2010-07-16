package Cubtan::Driver;
use warnings;
use strict;
use DBI;

sub new {
    my $class = shift;
    my $args = shift;
    my $self = bless {}, $class;
    my $dbh = DBI->connect($args->{dsn}, $args->{username}, $args->{password} , {
            PrintError => 1,
            AutoCommit => 1,
            }) ;
    $self->{dbh} = $dbh;
    return $self;
}

sub dbh { shift->{dbh} }

1;
