use utf8;
package TopTable::Schema::Result::MeetingAttendee;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::MeetingAttendee

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

=head1 TABLE: C<meeting_attendees>

=cut

__PACKAGE__->table("meeting_attendees");

=head1 ACCESSORS

=head2 meeting

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 person

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 apologies

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

If 1, this person sent their apologies rather than attended.

=cut

__PACKAGE__->add_columns(
  "meeting",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "person",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "apologies",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</meeting>

=item * L</person>

=back

=cut

__PACKAGE__->set_primary_key("meeting", "person");

=head1 RELATIONS

=head2 meeting

Type: belongs_to

Related object: L<TopTable::Schema::Result::Meeting>

=cut

__PACKAGE__->belongs_to(
  "meeting",
  "TopTable::Schema::Result::Meeting",
  { id => "meeting" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 person

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person",
  "TopTable::Schema::Result::Person",
  { id => "person" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-14 14:14:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FWWcEZCdrIpLqotvt28lUQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
