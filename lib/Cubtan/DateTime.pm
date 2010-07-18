package Cubtan::DateTime;
use strict;
use base qw( DateTime );
our $DEFAULT_TIMEZONE = DateTime::TimeZone->new(name => 'local');

sub new {
    my ( $class, %opts ) = @_;
    $opts{ time_zone } ||= $DEFAULT_TIMEZONE;
    return $class->SUPER::new( %opts );
}

sub now {
    my($class, %opt) = @_;
    my $self = $class->SUPER::now();
    my $tz = $opt{timezone} || $DEFAULT_TIMEZONE || 'local';
    $self->set_time_zone($tz);
    $self->set_hour(0);
    $self->set_minute(0);
    $self->set_second(0);
    $self->set_nanosecond(0);
}

sub yesterday {
    my ( $class,%opt) = @_;
    my $now = $class->now( %opt );
    return $now->subtract( days => 1 );
}

1;
