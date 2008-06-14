use inc::Module::Install;

all_from 'lib/Class/DBI/Plugin/RetrieveFromSQL.pm';

requires 'Class::DBI'         => '3.0.11';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More';
author_tests 'xt';
use_test_base;
auto_include;
WriteAll;

