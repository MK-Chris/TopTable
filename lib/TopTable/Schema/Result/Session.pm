use utf8;
package TopTable::Schema::Result::Session;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Session

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

=head1 TABLE: C<sessions>

=cut

__PACKAGE__->table("sessions");

=head1 ACCESSORS

=head2 id

  data_type: 'char'
  is_nullable: 0
  size: 72

=head2 data

  data_type: 'mediumtext'
  is_nullable: 1

=head2 expires

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 user

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 ip_address

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 user_agent

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 locale

  data_type: 'varchar'
  is_nullable: 1
  size: 6

=head2 view_online_page

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 view_online_display

  data_type: 'varchar'
  is_nullable: 1
  size: 300

=head2 view_online_link

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 hide_online

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 last_active

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 invalid_logins

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 last_invalid_login

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "char", is_nullable => 0, size => 72 },
  "data",
  { data_type => "mediumtext", is_nullable => 1 },
  "expires",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "user",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "ip_address",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "user_agent",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "locale",
  { data_type => "varchar", is_nullable => 1, size => 6 },
  "view_online_page",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "view_online_display",
  { data_type => "varchar", is_nullable => 1, size => 300 },
  "view_online_link",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "hide_online",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "last_active",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "invalid_logins",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "last_invalid_login",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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

=head2 user_agent

Type: belongs_to

Related object: L<TopTable::Schema::Result::UserAgent>

=cut

__PACKAGE__->belongs_to(
  "user_agent",
  "TopTable::Schema::Result::UserAgent",
  { id => "user_agent" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-02-12 10:35:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5rK06xuY+MdbrVgmljfTdg

use HTTP::BrowserDetect;

#
# Set the timezone to UTC
#
__PACKAGE__->add_columns(
    "last_active",
    { data_type => "datetime", timezone => "UTC" },
);

# Return the browser as an HTTP::BrowserDetect object
sub browser_detected {
  my ( $self ) = @_;
  
  return HTTP::BrowserDetect->new( $self->user_agent->string );
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
