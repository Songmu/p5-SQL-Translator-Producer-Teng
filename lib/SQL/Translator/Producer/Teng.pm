package SQL::Translator::Producer::Teng;
use feature ':5.10';
use strict;
use warnings;

our $VERSION = "0.01";

use Text::Xslate;
use Data::Section::Simple;

sub tx {
    state $tx = Text::Xslate->new(
        type => 'text',
        path => [Data::Section::Simple::get_data_section]
    );
}

sub produce {
    my $translater = shift;
    my $schema = $translater->schema;

    my @tables;
    for my $table ($schema->get_tables) {

        my @pks;
        my @columns;
        for my $field ($table->get_fields) {
            push @columns, {
                name      => $field->name,
                type      => $field->sql_data_type,
                type_text => $field->data_type,
            };
            push @pks, $field->name if $field->is_primary_key;
        }

        push @tables, {
            name    => $table->name,
            pks     => \@pks,
            columns => \@columns,
        };
    }

    tx()->render('schema.tx', {
        tables => \@tables,
    });
}

1;
__DATA__
@@ schema.tx
use strict;
use warnings;
use Teng::Schema::Declare;

: for $tables -> $table {
table {
    name '<: $table.name :>';
    pk   qw/<: $table.pks.join(' ') :>/;
    columns
: for $table.columns -> $column {
        {
            name => '<: $column.name :>',
            type => '<: $column.type :>', # <: $column.type_text :>
        },
: }
    ;
};

: }
1;
__END__

=encoding utf-8

=head1 NAME

SQL::Translator::Producer::Teng - It's new $module

=head1 SYNOPSIS

    use SQL::Translator::Producer::Teng;

=head1 DESCRIPTION

SQL::Translator::Producer::Teng is ...

=head1 LICENSE

Copyright (C) Songmu.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Songmu E<lt>y.songmu@gmail.comE<gt>

=cut
