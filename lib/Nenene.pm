package Nenene;
use Mouse;
use MouseX::Types::Path::Class;
use Path::Class qw( file dir );
use Text::Xslate;
use Text::Markdown;
use Carp qw( croak );

has 'md' => (
    is => 'ro',
    isa => 'Text::Markdown',
    default => sub {
        return Text::Markdown->new();
    }
);

has 'output' => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    required => 1,
    coerce => 1
);

has 'data' => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    required => 1,
    coerce => 1
);

has 'stash' => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} }
);

has 'extention' => (
    is      => 'ro',
    isa     => 'Str',
    default => '.mkdn'
);

has 'template' => (
    is => 'ro',
    isa => 'HashRef',
    required => 1,
    auto_deref => 1
);

has 'tx' => (
    is => 'ro',
    isa => 'Text::Xslate',
    lazy_build => 1
);

no Mouse;

sub _build_tx {
    my $self = shift;
    return Text::Xslate->new( $self->template );
}

sub generate {
    my $self = shift;
    my $ext = $self->extention;
    for my $child ( $self->data->children() ){
        next unless $child =~ /$ext$/;
        $self->generate_html($child);
    }
}

sub generate_html {
    my ( $self, $path ) = @_;
    my $mkdn = $path->slurp();
    my $html = $self->md->markdown( $mkdn );
    $html = $self->tx->render_string($html, $self->stash);
    my $file = file( $self->html_path( $path ) );
    my $fh = $file->open('w') or croak "Can't write $file : $!";
    $fh->print($html);
}

sub html_path {
    my ( $self, $path ) = @_;
    my $data_dir   = $self->data;
    my $output_dir = $self->output;
    $path =~ s/$data_dir/$output_dir/;
    my $ext = $self->extention;
    $path =~ s/$ext/.html/;
    return $path;
}

__PACKAGE__->meta->make_immutable();
1;
