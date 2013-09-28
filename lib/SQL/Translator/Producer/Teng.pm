package SQL::Translator::Producer::Teng;
use 5.008001;
use strict;
use warnings;

our $VERSION = "0.01";

use Text::Xslate;
use Data::Section::Simple;
use DBI;
use SQL::Translator::Schema::Field;

my $tx;
sub tx {
    $tx ||= Text::Xslate->new(
        type => 'text',
        path => [Data::Section::Simple::get_data_section]
    );
}

sub produce {
    my $translator = shift;
    my $schema = $translator->schema;
    my $args = $translator->producer_args;
    my $package = $args->{package};

    # patching SQL::Translator::Schema::Field::type_mapping
    my %type_mapping = %SQL::Translator::Schema::Field::type_mapping;
    local %SQL::Translator::Schema::Field::type_mapping = (
        %type_mapping,
        bigint  => DBI::SQL_BIGINT,
        tinyint => DBI::SQL_TINYINT,
    );

    my @tables;
    for my $table ($schema->get_tables) {

        my @pks;
        my @columns;
        for my $field ($table->get_fields) {
            push @columns, {
                name      => $field->name,
                type      => _get_dbi_const($field->sql_data_type),
            };
            push @pks, $field->name if $field->is_primary_key;
        }

        push @tables, {
            name    => $table->name,
            pks     => \@pks,
            columns => \@columns,
        };
    }

    tx->render('schema.tx', {
        package => $package,
        tables  => \@tables,
    });
}

my %CONST_HASH;
sub _get_dbi_const {
    my $val = shift;

    unless (%CONST_HASH) {
        for my $const_key (@{ $DBI::EXPORT_TAGS{sql_types} }) {
            my $const_val = DBI->can($const_key)->();

            unless (exists $CONST_HASH{$const_val}) {
                $CONST_HASH{$const_val} = $const_key;
            }
        }
    }

    $CONST_HASH{$val};
}

1;
__DATA__
@@ schema.tx
: if $package {
package <: $package :>;
: }
use strict;
use warnings;
use DBI qw/:sql_types/;
use Teng::Schema::Declare;

: for $tables -> $table {
table {
    name '<: $table.name :>';
    pk   qw/<: $table.pks.join(' ') :>/;
    columns
: for $table.columns -> $column {
        {
            name => '<: $column.name :>',
            type => <: $column.type :>,
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
