requires 'DBI';
requires 'Data::Section::Simple';
requires 'SQL::Translator::Schema::Field';
requires 'Text::Xslate';
requires 'perl', '5.008001';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
};

on test => sub {
    requires 'File::Temp';
    requires 'SQL::Translator';
    requires 'Teng';
    requires 'Test::More';
    requires 'Test::Requires';
    requires 'parent';

    recommends 'Test::mysqld';
};
