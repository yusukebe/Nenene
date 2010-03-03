use inc::Module::Install;
name 'Nenene';
all_from 'lib/Nenene.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
