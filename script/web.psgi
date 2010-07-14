#!/usr/local/bin/perl
use strict;
use warnings;
use FindBin::libs;
use Log::SpeedAnalyze::Web;
my $web = Log::SpeedAnalyze::Web->new( 'conf/conf.pl' );
$web->run();
