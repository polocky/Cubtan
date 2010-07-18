package Cubtan::Utils;
use warnings;
use strict;
use JSON::Syck;

sub obj2json {
    local $JSON::Syck::ImplicitUnicode =1;
    return JSON::Syck::Dump(shift);
}

1;
