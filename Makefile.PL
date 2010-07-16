use inc::Module::Install;
name 'Cubtan';
all_from 'lib/Cubtan.pm';

# requires '';

tests 't/*.t';

test_requires 'Test::More';
auto_include;
WriteAll;
