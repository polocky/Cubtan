#!/usr/local/bin/perl
use strict;
use warnings;
use FindBin::libs;
use Cubtan::Storage;
use Cubtan::Fetcher;
use Cubtan::Parser;
use Getopt::Long;
use DateTime;

my $config_file = '';
my $date = '';
my $name = '';
my $delete_log = 0 ;
GetOptions(
    "config=s" => \$config_file,
    "date=s" => \$date,
    "name=s" => \$name,
    "delete_log" => \$delete_log,
);

unless($date){
    my $now = DateTime->now( time_zone => 'local' );
    $now->subtract( days => 1 );
    $date = $now->ymd;

}
my $config = do($config_file);
my $storage = Cubtan::Storage->new( $config->{driver}  );

for my $service_config  (@{$config->{service}}) {
    next if ($name && $service_config->{parser}{name} ne $name);
    my $fetcher = Cubtan::Fetcher->new( { config => $service_config->{fetcher} } );
    # XXX $date = $args (this means , does not support logrotate format such as access_log.1 )
    # maybe spport it in the future or not.
    my $file = $fetcher->save_path->( $date );
    unless( -e $file ) {
        $file = $fetcher->fetch($date);
    } 
    my $parser = Cubtan::Parser->new({ config => $service_config->{parser} });
    my $result = $parser->parse( $file );
    unlink $file if $delete_log;
    $storage->store( $date, $result );
}
