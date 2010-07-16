#!/usr/local/bin/perl
use strict;
use warnings;
use FindBin::libs;
use Cubtan::Web;
my $web = Cubtan::Web->new( 'conf/conf.pl' );
$web->run();
