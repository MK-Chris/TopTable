use utf8;
package TopTable::Schema::Result::AverageFilter;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::AverageFilter

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

=head1 TABLE: C<average_filters>

=cut

__PACKAGE__->table("average_filters");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 show_active

  data_type: 'tinyint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=head2 show_loan

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 show_inactive

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 criteria_field

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 operator

  data_type: 'varchar'
  is_nullable: 1
  size: 2

=head2 criteria

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 criteria_type

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 user

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

Ties the filter to a user so users can create their own; NULL = a system filter, appears for all users.

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "url_key",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "show_active",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "show_loan",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "show_inactive",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "criteria_field",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "operator",
  { data_type => "varchar", is_nullable => 1, size => 2 },
  "criteria",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "criteria_type",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "user",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_user>

=over 4

=item * L</name>

=item * L</user>

=back

=cut

__PACKAGE__->add_unique_constraint("name_user", ["name", "user"]);

=head2 C<url_key>

=over 4

=item * L</url_key>

=back

=cut

__PACKAGE__->add_unique_constraint("url_key", ["url_key"]);

=head1 RELATIONS

=head2 system_event_log_average_filters

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogAverageFilter>

=cut

__PACKAGE__->has_many(
  "system_event_log_average_filters",
  "TopTable::Schema::Result::SystemEventLogAverageFilter",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user

Type: belongs_to

Related object: L<TopTable::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "TopTable::Schema::Result::User",
  { id => "user" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-01-27 11:59:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:W27QNH8tr2kmJWlcmFb4dw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
