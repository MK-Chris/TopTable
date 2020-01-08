use utf8;
package TopTable::Schema::Result::SystemEventLogNews;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::SystemEventLogNews

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<system_event_log_news>

=cut

__PACKAGE__->table("system_event_log_news");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 system_event_log_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 object_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 300

Only used if there is no ID (i.e., if the club was deleted and is not available).

=head2 log_updated

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 number_of_edits

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

Used if the event is for an edit.

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "system_event_log_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "object_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "log_updated",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "number_of_edits",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 object

Type: belongs_to

Related object: L<TopTable::Schema::Result::NewsArticle>

=cut

__PACKAGE__->belongs_to(
  "object",
  "TopTable::Schema::Result::NewsArticle",
  { id => "object_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "CASCADE",
  },
);

=head2 system_event_log

Type: belongs_to

Related object: L<TopTable::Schema::Result::SystemEventLog>

=cut

__PACKAGE__->belongs_to(
  "system_event_log",
  "TopTable::Schema::Result::SystemEventLog",
  { id => "system_event_log_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-01-08 00:07:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DtaAxYSUrY9+GDgSvgJuGg

#
# Enable automatic date handling
#
__PACKAGE__->add_columns(
    "log_updated",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 1, datetime_undef_if_invalid => 1, is_nullable => 0, },
);


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
