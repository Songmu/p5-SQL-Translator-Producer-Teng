use strict;
use warnings;
use utf8;
use Test::More;
use t::Util::Schema;
use SQL::Translator::Producer::Teng;

my $translator = t::Util::Schema->translator;
my $direct    = SQL::Translator::Producer::Teng::produce($translator);
my $translate = $translator->translate(to => 'Teng');
is $direct, $translate;

note $direct;

done_testing;
