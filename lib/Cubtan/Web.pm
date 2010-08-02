package Cubtan::Web;
use warnings;
use strict;
use Plack::Builder;
use Cubtan::Driver;
use Cubtan::Web::Dispatcher;

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
    my $driver = Cubtan::Driver->new( $config->{driver} );
    my $dispatcher = Cubtan::Web::Dispatcher->new( { driver => $driver , view_home => $config->{view_home} , config => $config } );
    $self->{dispatcher} = $dispatcher;
    my $root_path = $config->{view_home};
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
        enable "Plack::Middleware::Static",
            path => qr{^/favicon\.ico$}, root => $self->root_path . 'static/image/';
        $self->dispatcher->dispatch, 
    };
}

1;
