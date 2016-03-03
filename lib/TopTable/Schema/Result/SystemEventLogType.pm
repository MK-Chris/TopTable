use utf8;
package TopTable::Schema::Result::SystemEventLogType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::SystemEventLogType

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

=head1 TABLE: C<system_event_log_types>

=cut

__PACKAGE__->table("system_event_log_types");

=head1 ACCESSORS

=head2 object_type

  data_type: 'varchar'
  is_nullable: 0
  size: 40

=head2 event_type

  data_type: 'varchar'
  is_nullable: 0
  size: 40

=head2 object_description

  data_type: 'varchar'
  is_nullable: 0
  size: 40

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 500

=head2 view_action_for_uri

  data_type: 'varchar'
  is_nullable: 1
  size: 500

=head2 plural_objects

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 public_event

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "object_type",
  { data_type => "varchar", is_nullable => 0, size => 40 },
  "event_type",
  { data_type => "varchar", is_nullable => 0, size => 40 },
  "object_description",
  { data_type => "varchar", is_nullable => 0, size => 40 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 500 },
  "view_action_for_uri",
  { data_type => "varchar", is_nullable => 1, size => 500 },
  "plural_objects",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "public_event",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</object_type>

=item * L</event_type>

=back

=cut

__PACKAGE__->set_primary_key("object_type", "event_type");

=head1 RELATIONS

=head2 system_event_logs

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLog>

=cut

__PACKAGE__->has_many(
  "system_event_logs",
  "TopTable::Schema::Result::SystemEventLog",
  {
    "foreign.event_type"  => "self.event_type",
    "foreign.object_type" => "self.object_type",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-02-12 23:11:17
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1rCXg3qyNXAS5LWQ95YMSw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
