use inc::Module::Install;
name 'Log-SpeedAnalyze';
all_from 'lib/Log/SpeedAnalyze.pm';

# requires '';

tests 't/*.t';

test_requires 'Test::More';
auto_include;
WriteAll;
