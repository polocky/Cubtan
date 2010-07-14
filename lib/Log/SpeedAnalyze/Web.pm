package Log::SpeedAnalyze::Web;
use warnings;
use strict;
use Plack::Builder;
use Log::SpeedAnalyze::Driver;
use Log::SpeedAnalyze::Web::Dispatcher;
use Log::SpeedAnalyze::Web::View;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->setup(shift);
    return $self;
}

sub setup {
    my $self = shift;
    my $config_file = shift;
    my $config = do ( $config_file );
    my $driver = Log::SpeedAnalyze::Driver->new( $config->{driver} );
    my $view = Log::SpeedAnalyze::Web::View->new( $config->{view} );
    my $dispatcher = Log::SpeedAnalyze::Web::Dispatcher->new( { driver => $driver , view => $view } );
    $self->{dispatcher} = $dispatcher;
    my $root_path = $config->{view}{include_path}[0];
    $self->{root_path} = $root_path;
    1;
}
sub dispatcher {shift->{dispatcher} }
sub root_path { shift->{root_path} }

sub run {
    my $self = shift;
    builder {
        enable "Plack::Middleware::Static",
            path => qr{^/static/}, root => $self->root_path;
        $self->dispatcher->dispatch, 
    };
}

1;
