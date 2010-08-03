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

sub setup {
    my $self = shift;
    my $result = shift;
    my $config = shift;
    $self->{alert_count} = $result->{alert_count};
    $self->{skip} = $result->{skip} ;
    $self->{ignore} = $result->{ignore} ;
    $self->{code} = $result->{code};
    $self->{alert} = $config->{alert};

    $self->{min} = $result->{summary}{min};
    $self->{max} = $result->{summary}{max};
    $self->{count} = $result->{summary}{count};
    if($self->count) {
        $self->{avg} = int ($result->{summary}{total} / $self->count * 100 ) / 100 ;
    }
    else {
        $self->{avg} = 0;
    }

    unless ($config->{name}) {
        warn 'new feature: should set name option';
    }

    $self->{name} = $config->{name} || 'unknown';

    for my $tag ( keys %{$result->{tag}} ){
        $self->{tag}{$tag} = Cubtan::Result::Tag->new( $result->{tag}{$tag} );
    }

    if($result->{hourly}){
        my @hourly = ();
        for(0..23){
            my $hour = sprintf('%02d',$_);
            push @hourly ,Cubtan::Result->new($result->{hourly}{$hour} || {} ,$config );
        }
        $self->{hourly} = \@hourly;
    }
}

sub hourly { shift->{hourly} || [] }
sub name { shift->{name} }
sub tag {
    my $self = shift;
    $self->{tag} || {};
}

sub alert {shift->{alert} || 0 }
sub alert_count {shift->{alert_count} || 0 }
sub skip { shift->{skip} || 0 }
sub ignore_count { shift->{ignore} || 0 }
sub min { shift->{min} || 0 }
sub max { shift->{max} || 0 }
sub avg { shift->{avg} || 0  }

*skip_count = *skip;

sub alert_ratio {
    my $self = shift;
    return 0 unless $self->alert_count;
    my $total = $self->code('200');
    if($total){
        int( $self->alert_count / $total * 100 ) ;
    }
    else {
        return 0;
    }
}
sub count { shift->{count} || 0 }
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


1;
