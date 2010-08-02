package Cubtan::Fields::Basic;
use warnings;
use strict;

my %fields = (
    avg => {
        label => 'average'
    },
    arrival => {
        label => 'label',
    },
);

sub fields { $fields{shift} }

