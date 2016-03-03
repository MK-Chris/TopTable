use utf8;
package TopTable::Schema::Result::UserAgent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::UserAgent

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

=head1 TABLE: C<user_agents>

=cut

__PACKAGE__->table("user_agents");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 string

  data_type: 'text'
  is_nullable: 0

=head2 sha256_hash

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 first_seen

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 last_seen

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "string",
  { data_type => "text", is_nullable => 0 },
  "sha256_hash",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "first_seen",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "last_seen",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 sessions

Type: has_many

Related object: L<TopTable::Schema::Result::Session>

=cut

__PACKAGE__->has_many(
  "sessions",
  "TopTable::Schema::Result::Session",
  { "foreign.user_agent" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_ip_addresses_browsers

Type: has_many

Related object: L<TopTable::Schema::Result::UserIpAddressesBrowser>

=cut

__PACKAGE__->has_many(
  "user_ip_addresses_browsers",
  "TopTable::Schema::Result::UserIpAddressesBrowser",
  { "foreign.user_agent" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-04 12:04:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/DfPvt/OdFY7e4y1H8rmNg

#
# Enable automatic date handling
#
__PACKAGE__->add_columns(
    "first_seen",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 0, },
    "last_seen",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 0, }, # Don't set on update, as we need to do this manually, as this is the only field we update.
);


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
