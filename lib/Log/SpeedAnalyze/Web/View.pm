package Log::SpeedAnalyze::Web::View;
use warnings;
use strict;
use Text::MicroTemplate::Extended;

sub new {
    my $class = shift;
    my $args  = shift;
    my $self = bless {}, $class;
    $self->setup($args);
    return $self; 
}
sub setup {
    my $self = shift;
    my $args = shift;
    my $obj = Text::MicroTemplate::Extended->new(%$args);
    $self->{obj} = $obj;
}
sub render_file {
    my $self = shift;
    $self->{obj}->render_file(@_);
}

1;
