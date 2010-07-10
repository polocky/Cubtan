package Log::SpeedAnalyze::Fetcher;
use warnings;
use strict;
use Net::SCP;

sub new {
    my $class = shift;
    my $args = shift ;
    my $self = bless {},$class;
    $self->setup($args);
    return $self;
}

sub setup {
    my $self = shift;
    my $args = shift;
    my $config = do($args->{config});
    $self->{scp_args} = $config->{scp_args};
    $self->{log_path} = $config->{log_path};
    $self->{save_path} = $config->{save_path};
}

sub scp_args { shift->{scp_args} } 
sub log_path{ shift->{log_path} } 
sub save_path{ shift->{save_path} } 

sub fetch {
    my $self = shift;
    my $str = shift;
    my $scp = Net::SCP->new( $self->scp_args );
    $scp->get( $self->log_path->($str) , $self->save_path->($str) ) or die $scp->{errstr};
    return $self->save_path->($str);
}

1;

=head1 NAME

Log::SpeedAnalyze::Fetcher - fetcher.

=head1 SYNOPSIS

 my $fetcher = Log::SpeedAnalyze::Fetcher->new( { config => 'wiki_fetcher.pl' } );
 my $save_path = $fetcher->fetch('2003-12-15');

wiki_fetcher.pl
 +{
    scp_args => { host => '127.0.0.1' },
    log_path => sub {
        my $arg = shift; # 2004-12-15
        return sprintf('/usr/local/apache/log/access_log-%s',$arg);
    },
    save_path => sub {
        my $arg = shift;
        return sprintf('/tmp/wiki-access_log-%s',$arg);
    } 
 };

=cut
