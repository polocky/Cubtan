#!/usr/local/bin/perl
use strict;
use warnings;
use FindBin::libs;
use Log::SpeedAnalyze::Fetcher;
use Getopt::Long;
use DateTime;

my $config = '';
my $arg = '';
GetOptions(
    "config=s" => \$config,
    "arg=s" => \$arg,
);

unless($arg){
    my $now = DateTime->now( time_zone => 'local' );
    $now->subtract( days => 1 );
    $arg = $now->ymd;

}

my $fetcher = Log::SpeedAnalyze::Fetcher->new( { config => $config } );
$fetcher->fetch($arg);
