package Log::SpeedAnalyze::Parser;

use warnings;
use strict;
use Log::SpeedAnalyze::Result;

sub new {
    my $class = shift;
    my $args = shift || {};
    my $self = bless $args, $class; 
    my $config = do $self->{config_file} ;
    $self->{config} = $config;
    return $self;
}
sub config_file { shift->{config_file} }
sub config { shift->{config} }
sub parse {
    my $self = shift;
    my $file = shift;
    my $result = {};
    my @files = ref $file eq 'ARRAY' ? @$file : $file;
    for(@files){
        open( FH , $_) or  die "Can not open the $_";
        while(<FH>){
            $self->analyze_line( $_ , $result );
        }
        close(FH);
    }

    return Log::SpeedAnalyze::Result->new( $result , $self->config ); 
}

sub tag { shift->config->{tag} || [] }
sub range { shift->config->{range} }
sub unit { shift->config->{unit} || '' }

sub very_slow { shift->config->{very_slow} || 0 } 

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


    if( $self->unit eq '%D' ) {
        $row->{time} = $row->{time} / 1000000;
    }

    $result->{code}->{$row->{code}} ||= 0;
    $result->{code}->{$row->{code}} = $result->{code}->{$row->{code}}+1 ;

    if( $row->{code} == 200) {
        my $hour = $self->get_hour( $row->{date} );

        
        if ( $self->very_slow && $row->{time} > $self->very_slow ){
            $result->{very_slow}{count}||=0;
            $result->{very_slow}{count}++;
            $result->{very_slow}{hour}{$hour} ||=0;
            $result->{very_slow}{hour}{$hour}++;
            $result->{very_slow}{logs} ||= ();
            push @{$result->{very_slow}{logs}} , $line ;
        }


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

Log::SpeedAnalyze::Parser

=head1 SYNOPSIS

 use Log::SpeedAnalyze::Parser;
 my $parser = Log::SpeedAnalyze::Parser->new( { config_file => 'conf.pl' } );
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
