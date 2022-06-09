use utf8;
package TopTable::Schema::Result::InvalidLogin;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::InvalidLogin

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

=head1 TABLE: C<invalid_logins>

=cut

__PACKAGE__->table("invalid_logins");

=head1 ACCESSORS

=head2 ip_address

  data_type: 'varchar'
  is_nullable: 0
  size: 40

=head2 invalid_logins

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 last_invalid_login

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "ip_address",
  { data_type => "varchar", is_nullable => 0, size => 40 },
  "invalid_logins",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "last_invalid_login",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</ip_address>

=back

=cut

__PACKAGE__->set_primary_key("ip_address");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-04 12:04:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+9R+LOVWNiCWG1eUnZ01nw

__PACKAGE__->add_columns(
    "last_invalid_login",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 1, datetime_undef_if_invalid => 1, is_nullable => 0,},
);


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
