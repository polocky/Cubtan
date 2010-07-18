package Cubtan::Fields::Basic;
use warnings;
use strict;

my %fields = (
    avg => {
        color => 'yellow',
        label => 'average'
        comment => 'average',
    },
    arrival => {
        color => 'green',
        label => 'label',
        comment => 'comment',
    },
);

sub fields { $fields{shift} }

