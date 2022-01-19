use utf8;
package TopTable::Schema::Result::Ban;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Ban

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

=head1 TABLE: C<bans>

=cut

__PACKAGE__->table("bans");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 banned_id

  data_type: 'varchar'
  is_nullable: 0
  size: 300

=head2 expires

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 banned_by

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 banned_by_name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 ban_access

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 ban_registration

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 ban_login

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 ban_contact

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 created

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
  "type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 20 },
  "banned_id",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "expires",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "banned_by",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "banned_by_name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "ban_access",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "ban_registration",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "ban_login",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "ban_contact",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "created",
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

=head2 banned_by

Type: belongs_to

Related object: L<TopTable::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "banned_by",
  "TopTable::Schema::Result::User",
  { id => "banned_by" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "RESTRICT",
  },
);

=head2 system_event_log_bans

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogBan>

=cut

__PACKAGE__->has_many(
  "system_event_log_bans",
  "TopTable::Schema::Result::SystemEventLogBan",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 type

Type: belongs_to

Related object: L<TopTable::Schema::Result::LookupBanType>

=cut

__PACKAGE__->belongs_to(
  "type",
  "TopTable::Schema::Result::LookupBanType",
  { id => "type" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-01-15 21:50:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:QlkzTyisyPohMSRjhYkOnQ

# Enable automatic date handling
__PACKAGE__->add_columns(
    "created",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 0, datetime_undef_if_invalid => 1, is_nullable => 0,},
);

=head2 check_and_delete

Performs the deletion of a ban.

=cut

sub check_and_delete {
  my ( $self ) = @_;
  my $error = [];
  
  # Delete
  my $ok = $self->delete unless scalar( @{ $error } );
  
  # Error if the delete was unsuccessful
  push(@{ $error }, {
    id => "admin.delete.error.database",
    parameters => $self->banned_id,
  }) unless $ok;
  
  return $error;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
