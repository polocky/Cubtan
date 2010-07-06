package Log::SpeedAnalyze::Result;
use warnings;
use strict;
use Log::SpeedAnalyze::Result::Tag;

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
    $self->{skip} = $result->{skip};
    $self->{code} = $result->{code};
    $self->{alert} = $config->{alert};

    for my $tag ( keys %{$result->{tag}} ){
        $self->{tag}{$tag} = Log::SpeedAnalyze::Result::Tag->new( $result->{tag}{$tag} );
    }
}

sub tag {
    my $self = shift;
    $self->{tag};
}

sub alert {shift->{alert} || 0 }
sub alert_count {shift->{alert_count} || 0 }
sub skip { shift->{skip} || 0 }

sub alert_ratio {
    my $self = shift;
    return 0 unless $self->alert_count;
    my $total = $self->code('200');
    int( $self->alert_count / $total * 100 ) ;
}
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
    my @keys = sort {
        $code->{$b} <=> $code->{$a}
            || length($b) <=> length($a)
            || $a cmp $b
    } keys %$code;
    return \@keys;
}

1;
