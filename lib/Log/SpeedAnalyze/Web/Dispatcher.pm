package Log::SpeedAnalyze::Web::Dispatcher;
use warnings;
use strict;
use Plack::Request;
use Plack::Response;
use Log::SpeedAnalyze::Web::Controller;


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
    $self->{view} = $args->{view};
    my $method_maping = {
        '/service/(\d+)/' => 'dispatch_service',
        '/' => 'dispatch_root',
    };
    $self->{method_maping} = $method_maping;
}

sub driver { shift->{driver} }
sub view { shift->{view} }

sub dispatch {
    my $self = shift;
    return sub {
        my  $env = shift;
        my $request = Plack::Request->new($env);
        my $path_info = $request->env->{PATH_INFO} ;
        my ($method_name,$args) =  $self->lookup( $path_info);
        my $res = Plack::Response->new(200);
        my $controller = Log::SpeedAnalyze::Web::Controller->new({
            driver => $self->driver,
            req => $request, 
            res => $res,
            args => $args, 
        });
        $controller->$method_name();
        my $body = $self->view->render_file( $controller->file ,$controller->stash );
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
