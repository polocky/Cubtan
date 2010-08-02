package Cubtan::Parser;

use warnings;
use strict;
use Cubtan::Result;
use IO::Uncompress::Gunzip;

sub new {
    my $class = shift;
    my $args = shift || {};
    my $self = bless {} , $class; 
    $self->setup($args);
    return $self;
}
sub setup {
    my $self=  shift;
    my $args = shift;
    my $config = $args->{config} || $args->{config_file} ;

    if( ref $config eq 'HASH' ) {
        $self->{config} = $config;
    }
    else {
        $self->{config} = do $config ;
    }

}

sub config_file {  warn 'deprecated' }
sub config { shift->{config} }
sub parse {
    my $self = shift;
    my $stuff = shift;
    my $result = {};
    my @stuffs = ref $stuff eq 'ARRAY' ? @$stuff : $stuff;
    for my $stuff (@stuffs){
        my $fh;
        if ( $stuff =~ /\.gz$/ ) {
            $fh = new IO::Uncompress::Gunzip $stuff or die $!;
        }
        elsif ( ref $stuff eq 'GLOB' ) {
            $fh = $stuff;
        }
        else {
            open( $fh, $stuff ) or  die "Can not open the $stuff";
        }
        while ( <$fh> ) {
            $self->analyze_line( $_ , $result );
        }
    }

    return Cubtan::Result->new( $result , $self->config ); 
}

sub ignore { 
    my $self = shift;
    my $row = shift;

    return 0 unless $self->config->{ignore_rule};
    for my $name ( keys %{$self->config->{ignore_rule}} ) {
        my $rule = $self->config->{ignore_rule}{$name}  ;
        if($row->{$name} =~ /$rule/){
            return 1;
        }
    }
    0;
}

sub tag { shift->config->{tag} || [] }
sub range { shift->config->{range} }
sub unit { shift->config->{unit} || '' }

sub parse_line {
    my $self = shift;
    my $line = shift;
    my $row = $self->formater->($line);
    return $row;
}
sub formater {
    my $self = shift;
    if( ref $self->config->{format} eq 'CODE' ) {
        return  $self->config->{format};
    }
    else {
        my $method = 'parse_' . $self->config->{format};
        return sub { $self->$method(shift) };
    }
}
sub analyze_line {
    my $self = shift;
    my $line = shift;
    my $result = shift;
    my $row = $self->parse_line($line);
    unless ( $row->{code} ){
        $result->{skip} ||=0;
        $result->{skip}++;
        return;
    }

    if ($self->ignore($row) ){
        $result->{ignore} ||=0;
        $result->{ignore}++;
        return ;
    }

    if( $self->unit eq '%D' ) {
        $row->{time} = $row->{time} / 1000000;
    }

    $result->{code}->{$row->{code}} ||= 0;
    $result->{code}->{$row->{code}} = $result->{code}->{$row->{code}}+1 ;

    if( $row->{code} >= 200 && $row->{code} < 400 ) {
        $result->{summary}{count} ||=0;
        $result->{summary}{total} ||=0;
        $result->{summary}{count}++;
        $result->{summary}{total}+= $row->{time};
        $result->{summary}{min} = $row->{time} if !$result->{summary}{min} or $result->{summary}{min} > $row->{time};
        $result->{summary}{max} = $row->{time} if !$result->{summary}{max} or $result->{summary}{max} < $row->{time};

        my $hour = $self->get_hour( $row->{date} );

        if( $self->alert < $row->{time} ) {
            $result->{alert_count} ||=0;
            $result->{alert_count}++;
        }

        for(@{$self->tag}){
            if( $row->{path} =~ $_->{rule} ) {
                $result->{tag}{$_->{name}}{count} ||=0;
                $result->{tag}{$_->{name}}{count}++;

                $result->{tag}{$_->{name}}{total} ||=0;
                $result->{tag}{$_->{name}}{total} += $row->{time};

                if( $self->alert < $row->{time} ) {
                    $result->{tag}{$_->{name}}{alert_count} ||=0;
                    $result->{tag}{$_->{name}}{alert_count}++;
                }


                my @range = reverse @{$self->range};
                for my $range (@range){
                    if ( $row->{time} > $range ){
                        $result->{tag}{$_->{name}}{range}{$range} ||=0;
                        $result->{tag}{$_->{name}}{range}{$range}++;
                        last;
                    }
                }


                if( $range[0] > $row->{time} ) {
                    $result->{tag}{$_->{name}}{range}{0} ||=0;
                    $result->{tag}{$_->{name}}{range}{0}++;
                }

                $result->{tag}{$_->{name}}{min} = $row->{time} if !$result->{tag}{$_->{name}}{min} or $result->{tag}{$_->{name}}{min} > $row->{time};
                $result->{tag}{$_->{name}}{max} = $row->{time} if !$result->{tag}{$_->{name}}{max} or $result->{tag}{$_->{name}}{max} < $row->{time};
            }
            
        }
    }
}

sub alert { shift->config->{alert} }


sub parse_combined {
    my $self = shift;
    my $line = shift;
    my $args = {};
($args->{ip},$args->{user},$args->{group},$args->{date},$args->{method},$args->{path},$args->{proto},$args->{code},$args->{bytes}, $args->{ref},$args->{ua} ,$args->{time}) 
= $line =~ m{^([0-9\.]+) ([a-zA-Z0-9\._-]+) ([a-zA-Z0-9\._-]+) \[([^\] ]+ \+\d+)\] \"([A-Z]+) ((?:[^"]|(?<=\\)\")*) (HTTP/\d\.\d)\" ([\d-]+) ([\d-]+) "((?:[^"]|(?<=\\)\")*)" "((?:[^"]|(?<=\\)\")*)" (\d+)$};
    return $args;
}

sub parse_common {
    my $self = shift;
    my $line = shift;
    my $args = {};
($args->{ip},$args->{user},$args->{group},$args->{date},$args->{method},$args->{path},$args->{proto},$args->{code},$args->{bytes},$args->{time}) 
= $line =~ m{^([0-9\.]+) ([a-zA-Z0-9\._-]+) ([a-zA-Z0-9\._-]+) \[([^\] ]+ \+\d+)\] \"([A-Z]+) ((?:[^"]|(?<=\\)\")*) (HTTP/\d\.\d)\" ([\d-]+) ([\d-]+) (\d+)$};
    return $args;
}

sub get_hour {
    my $self = shift;
    my $date = shift;
    my($hour) = $date =~ /\d+:(\d+):\d+:\d+/;
    return $hour;
}
1;

=head1 NAME

Cubtan::Parser

=head1 SYNOPSIS

 use Cubtan::Parser;
 my $parser = Cubtan::Parser->new( { config => 'conf.pl' } );
 my $result = $parser->parse( 'logs/access_log' );

 # conf.pl

 +{
    format => 'combined',
    unit => '%D',
    range => [ qw/0.2 0.3 0.4 0.5 1 2 3 4 5 10 30 50/],
    alert => '0.5',
    tag => [
        { name =>'all' , rule =>  qr/.*/ },
        { name =>'doc' , rule =>  qr/^\/[a-z0-9_]+\/d\// },
    ]
 }

=cut
