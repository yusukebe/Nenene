package Nenene;
use Mouse;
use MouseX::Types::Path::Class;
use Plack::Request;
use Text::Hatena;
use Template;

our $VERSION = '0.01';

has 'dir' =>
  ( is => 'ro', isa => 'Path::Class::Dir', required => 1, coerce => 1 );
has 'template' =>
  ( is => 'ro', isa => 'Path::Class::File', required => 1, coerce => 1 );

sub handler {
    my $self = shift;
    return sub {
        my $env    = shift;
        my $req  = Plack::Request->new($env);
        my $html = $self->render();
        my $res;
        if ( $html ){
            $res = $req->new_response(200);
        }else{
            $res = $req->new_response(500);
        }
        $res->content_type('text/html');
        $res->body($html);
        return $res->finalize;
    };
}

sub render {
    my $self   = shift;
    my $handle = $self->dir->open;
    my $body;
    while ( my $file = $handle->read ) {
        $file = $self->dir->file($file);
        if( $file =~ /\.txt$/){
            my $section = $self->to_html( join('',$file->slurp()) );
            $body .= $section;
        }
    }
    my $template = Template->new();
    my $output;
    $template->process( $self->template->stringify, { body => $body }, \$output )
      or die $template->error;
    return $output;
}

sub to_html {
    my ($self, $text) = @_;
    my $html = Text::Hatena->parse($text);
    return $html;
}

1;
__END__

=head1 NAME

Nenene -

=head1 SYNOPSIS

  use Nenene;

=head1 DESCRIPTION

Nenene is

=head1 AUTHOR

Yusuke Wada E<lt>yusuke at kamawada.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
