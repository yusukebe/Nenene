package Nenene;
use Mouse;
use MouseX::Types::Path::Class;
use Path::Class qw( file dir );
use Text::Xslate;
use Text::Markdown;
use Try::Tiny;
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

has 'files' => (
    is => 'rw',
    isa => 'ArrayRef',
    auto_deref => 1,
);

no Mouse;

sub _build_tx {
    my $self = shift;
    return Text::Xslate->new( $self->template );
}

sub _build_files {
    my $self = shift;
    $self->loop_dir( $self->data );
}

sub loop_dir {
    my ( $self, $dir ) = @_;
    my @children;
    my $ext = $self->extention;
    for my $child ( $dir->children() ){
        $self->loop_dir($child) if $child->is_dir;
        next unless $child =~ /$ext$/;
        push @children, $child;
    }
    my @files = ($self->files,@children);
    $self->files( \@files );
}

sub generate {
    my $self = shift;
    $self->_build_files();
    for my $file ( $self->files ){
        $self->generate_html($file);
    }
}

sub generate_html {
    my ( $self, $path ) = @_;
    my $mkdn = $path->slurp();
    my $html = $self->md->markdown( $mkdn );
    $html = $self->tx->render_string($html, $self->stash);
    my $file = file( $self->html_path( $path ) );
    my $fh;
    try {
        $fh = $file->open('w');
    }catch{
        dir( $file->parent->mkpath )->mkpath();
        $fh = $file->open('w');
    };
    warn "Create: " . $file . "\n";
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
