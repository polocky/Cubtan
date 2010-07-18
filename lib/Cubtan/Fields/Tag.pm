package Cubtan::Fields::Tag;
use warnings;
use strict;
use utf8;
use base qw(Cubtan::Fields);

sub get_field_keys {
    my @keys= sort {$a  <=> $b} keys %{shift->{fields}};
    return \@keys;
}

1;
