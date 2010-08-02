package Cubtan::Fields;
use warnings;
use strict;
use utf8;

sub new { 
    my $class = shift;
    my $fields = shift || {};
    return bless { fields => $fields },$class;
}

sub field { 
    my $self = shift;
    my $name = shift;
    if( my $field = $self->{fields}{$name}) {
        return $field;
    }
    else {
        return {
            label => 'unknown',
        };
    }
}

sub get_field_keys {
    my @keys= sort keys %{shift->{fields}};
    return \@keys;
}

sub get_series {
    my $self = shift;
    my $keys  = $self->get_field_keys;
    my @data = ();
    for(@$keys) {
        my $field = {
            label => $self->field($_)->{label},
        };
        push @data , $field;
    }
    return \@data;
}

sub get_label {
    my $self = shift;
    my $key = shift;
    my $field = $self->field($key);
    return $field->{label};
}

sub get_html_label {
    my $self = shift;
    my $key = shift;
    my $field = $self->field($key);
    return $field->{label};
}

1;
