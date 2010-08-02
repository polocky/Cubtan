use inc::Module::Install;
name 'Cubtan';
all_from 'lib/Cubtan.pm';

# store.
requires (
    'DBI' => 0,
    'DBD::SQLite' => 0,
);

tests 't/*.t';

test_requires 'Test::More';
auto_include;
WriteAll;
