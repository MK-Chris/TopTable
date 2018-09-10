use utf8;
package TopTable::Schema::Result::PageText;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::PageText

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

=head1 TABLE: C<page_text>

=cut

__PACKAGE__->table("page_text");

=head1 ACCESSORS

=head2 page_key

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 page_text

  data_type: 'longtext'
  is_nullable: 0

=head2 last_updated

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "page_key",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "page_text",
  { data_type => "longtext", is_nullable => 0 },
  "last_updated",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</page_key>

=back

=cut

__PACKAGE__->set_primary_key("page_key");


# Created by DBIx::Class::Schema::Loader v0.07046 @ 2018-09-01 15:50:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:okEGjdi6RdUvb2AfEv8kyg

#
# Enable automatic date handling
#
__PACKAGE__->add_columns(
    "last_updated",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 0, },
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
