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

__END__

=head1 NAME

fetcher.pl

=head1 SYNOPSIS

 ./script/fetcher.pl --config conf/wiki_fetcher.pl
 ./script/fetcher.pl --config conf/wiki_fetcher.pl --arg '2010-05-10'

=cct
