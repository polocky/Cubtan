package Cubtan::Web::JqpLot;
use warnings;
use strict;
use Cubtan::Fields;
use Cubtan::Utils;

sub new {
    my $class = shift;
    my $args  = shift || {};
    bless $args ,$class;
}
sub create {
    my $self = shift;
    my @data_part = ();
    for my $field ( @{$self->fields->get_field_keys}){
        push @data_part , $self->create_data_part( $field ) ;
    }
    $self->{data_part} = Cubtan::Utils::obj2json( \@data_part );
    $self->{series_part} = Cubtan::Utils::obj2json( $self->create_series_part );

    $self;
}
sub get_data_part{
    shift->{data_part};
}
sub get_series_part {
    shift->{series_part};
}
sub fields { shift->{fields} }



sub create_data_part {
    my $self  = shift;
    my $target = shift;
    my $range = $self->{range};
    my $hash  = $self->{data};
    my @data = ();
    for my $date (@$range){
        push @data , [ $date , $hash->{$target}{$date} || 0 ];
    }
    return \@data;
}
sub create_series_part {
    my $self = shift;
    $self->fields->get_series();
}


1;

=head1 NAME

Cubtan::Web::JqpLog  - 

=head1 SYNOPSIS

 use Cubtan::Web::JqpLog;
 my $jqplog = Cubtan::Web::JqpLog->new(
    {
        fields => $fields,
        range => $range,
        data   => $data,
    }
 );

 my $chart_json = $jqplog->create();

=cut
