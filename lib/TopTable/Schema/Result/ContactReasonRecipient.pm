use utf8;
package TopTable::Schema::Result::ContactReasonRecipient;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::ContactReasonRecipient

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

=head1 TABLE: C<contact_reason_recipients>

=cut

__PACKAGE__->table("contact_reason_recipients");

=head1 ACCESSORS

=head2 contact_reason

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 person

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "contact_reason",
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
);

=head1 PRIMARY KEY

=over 4

=item * L</contact_reason>

=item * L</person>

=back

=cut

__PACKAGE__->set_primary_key("contact_reason", "person");

=head1 RELATIONS

=head2 contact_reason

Type: belongs_to

Related object: L<TopTable::Schema::Result::ContactReason>

=cut

__PACKAGE__->belongs_to(
  "contact_reason",
  "TopTable::Schema::Result::ContactReason",
  { id => "contact_reason" },
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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-01-08 16:54:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:md9Twog+4CigiQMQMpSBpg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
