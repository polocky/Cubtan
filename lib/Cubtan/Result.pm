package Cubtan::Result;
use warnings;
use strict;
use Cubtan::Result::Tag;

sub new {
    my $class = shift;
    my $result = shift;
    my $config = shift;
    my $self = bless {}, $class ;
    $self->setup( $result , $config );
    return $self;
}

sub very_slow { shift->{very_slow}; }
sub setup {
    my $self = shift;
    my $result = shift;
    my $config = shift;
    $self->{alert_count} = $result->{alert_count};
    $self->{skip} = $result->{skip} ;
    $self->{ignore} = $result->{ignore} ;
    $self->{code} = $result->{code};
    $self->{alert} = $config->{alert};
    $self->{very_slow} = $config->{very_slow} || 0;

    $self->{min} = $result->{summary}{min};
    $self->{max} = $result->{summary}{max};
    $self->{avg} = int ($result->{summary}{total} / $result->{summary}{count} * 100 ) / 100 ;

    unless ($config->{name}) {
        warn 'new feature: should set name option';
    }

    $self->{name} = $config->{name} || 'unkown';

    if($self->{very_slow} ) {
        $self->{very_slow_hourly} = $result->{very_slow}{hour};
        $self->{very_slow_logs} = $result->{very_slow}{logs};
        $self->{very_slow_count} = $result->{very_slow}{count};
    }

    for my $tag ( keys %{$result->{tag}} ){
        $self->{tag}{$tag} = Cubtan::Result::Tag->new( $result->{tag}{$tag} );
    }
}

sub name { shift->{name} }
sub tag {
    my $self = shift;
    $self->{tag};
}

sub alert {shift->{alert} || 0 }
sub alert_count {shift->{alert_count} || 0 }
sub skip { shift->{skip} || 0 }
sub ignore_count { shift->{ignore} || 0 }
sub min { shift->{min} }
sub max { shift->{max} }
sub avg { shift->{avg} }

*skip_count = *skip;

sub alert_ratio {
    my $self = shift;
    return 0 unless $self->alert_count;
    my $total = $self->code('200');
    int( $self->alert_count / $total * 100 ) ;
}
sub count { shift->code(200) }
sub code { 
    my $self = shift;
    my $code = shift;
    return $code 
        ? $self->{code}{$code} || 0
        : $self->{code}
        ;
}

sub code_list {
    my $self = shift;
    my $code = $self->code;
    my @keys = sort { $a <=> $b } keys %$code;
    return \@keys;
}

sub very_slow_hourly {
    my $self = shift;
    my $hour = sprintf("%02d",shift);
    return $self->{very_slow_hourly}{$hour} || 0 ;
}

sub very_slow_count { shift->{very_slow_count} || 0 }
sub very_slow_logs { shift->{very_slow_logs} || [] }

1;