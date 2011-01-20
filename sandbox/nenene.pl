use strict;
use warnings;
use Nenene;

my $config = {
    data   => './data',
    output => './htdocs',
    stash  => {},
    template => {
        path       => ['./tmpl'],
        syntax => 'TTerse',
        header => ['header.tt2'],
        footer => ['footer.tt2'],
    },
};

my $nenene = Nenene->new( %$config );
$nenene->generate();
