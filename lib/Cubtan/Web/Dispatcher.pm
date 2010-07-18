package Cubtan::Web::Dispatcher;
use warnings;
use strict;
use Plack::Request;
use Plack::Response;
use Cubtan::Web::Controller;
use Cubtan::Fields;
use Text::MicroTemplate::Extended;


sub new {
    my $class = shift;
    my $args = shift;
    my $self = bless {}, $class;
    $self->setup( $args );
    return $self;
}

sub setup {
    my $self = shift;
    my $args = shift;
    $self->{driver} = $args->{driver};
    $self->{view_home} = $args->{view_home};
    my $method_maping = {
        '/service/(\d+)/' => 'dispatch_service',
        '/' => 'dispatch_root',
    };
    $self->{method_maping} = $method_maping;
    
    $self->{config} = $args->{config};
}

sub config { shift->{config}}
sub driver { shift->{driver} }
sub view_home { shift->{view_home} }

sub dispatch {
    my $self = shift;
    return sub {
        my  $env = shift;
        my $request = Plack::Request->new($env);
        my $path_info = $request->env->{PATH_INFO} ;
        my ($method_name,$args) =  $self->lookup( $path_info);
        my $res = Plack::Response->new(200);
        my $controller = Cubtan::Web::Controller->new({
            driver => $self->driver,
            req => $request, 
            res => $res,
            args => $args, 
            config => $self->config,
        });
        $controller->$method_name();

        my $mt = Text::MicroTemplate::Extended->new(
            include_path  => [ $self->view_home ],
            template_args => $controller->stash ,
        );

        my $body = $mt->render_file( $controller->file );
        $res->content_type('text/html') unless $res->content_type;
        $body ? $res->body($body) : $res->body(':-)');
        return $res->finalize;
    }
}

sub lookup {
    my $self = shift;
    my $path_info = shift;
    for my $regexp (keys %{$self->{method_maping}}){
        if( my (@args) = $path_info =~ /$regexp/ ) {
            return ($self->{method_maping}{$regexp} , \@args );
        }
    }
    return ('root',[]);
}

1;
