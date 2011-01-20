use Plack::App::File;
my $app = Plack::App::File->new(root => "./htdocs")->to_app;
