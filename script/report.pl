#!/usr/local/bin/perl
use strict;
use warnings;
use FindBin::libs;
use Cubtan::Parser;
use Text::SimpleTable;
use Getopt::Long;

my $config_file = '';
my @log_files = (); 

GetOptions(
    "config=s" => \$config_file,
    "log=s" => \@log_files,
);

my $parser = Cubtan::Parser->new( { config_file => $config_file } );
my $result = $parser->parse( \@log_files );

my $h = Text::SimpleTable->new([20,'KEY'],[20,'VALUE']);
$h->row('count', $result->count );
$h->row('max', $result->max);
$h->row('min', $result->min);
$h->row('avg', $result->avg);
$h->row('alert', $result->alert .' sec');
$h->row('alert_count', $result->alert_count);
$h->row('alert_ratio', $result->alert_ratio .'%');
$h->row('skip', $result->skip_count );
$h->row('ignore', $result->ignore_count  );
$h->hr;
for(@{$result->code_list}){
$h->row( $_ , $result->code($_) );
}
print $h->draw;

my $tag = $result->tag;
for my $key ( keys %$tag ) {
    my $obj = $tag->{$key}; 
    my $t = Text::SimpleTable->new([20, $key ],[20]);
    $t->row( 'count', $obj->count );
    $t->row( 'min', $obj->min . ' sec' );
    $t->row( 'max', $obj->max . ' sec' );
    $t->row( 'avg', $obj->avg . ' sec' );
    $t->row( 'alert count', $obj->alert_count );
    $t->row( 'alert ratio', $obj->alert_ratio .' %' );
    $t->hr;

    for(@{$obj->ranges} ) {
        $t->row( $_->{start} . ' sec' ,$_->{count} );
    }
    print $t->draw;
}


=head1 NAME

script/report.pl --config conf/wiki.pl --log var/log1 -- var/log2

=cut
