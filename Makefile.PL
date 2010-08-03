use inc::Module::Install;
name 'Cubtan';
all_from 'lib/Cubtan.pm';

# fetcher
requires (
        'FindBin::libs' => 0,
        'Net::SCP' => 0,
        'DateTime' => 0,
        );

# report
requires (
        'Text::SimpleTable' => 0,
        );

# store.
requires (
        'DBI' => 0,
        'DBD::SQLite' => 0,
        );

# web
requires (
        'Plack' => 0,
        #'Starman' => 0,
        'JSON::Syck' => 0,
        'Text::MicroTemplate::Extended' => 0,
        );

tests 't/*.t';

test_requires 'Test::More';
auto_include;
WriteAll;
