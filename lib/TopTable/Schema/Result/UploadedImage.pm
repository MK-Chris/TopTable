use utf8;
package TopTable::Schema::Result::UploadedImage;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::UploadedImage

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

=head1 TABLE: C<uploaded_images>

=cut

__PACKAGE__->table("uploaded_images");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 filename

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 mime_type

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 uploaded

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 viewed_count

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 deleted

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
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
  "filename",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "mime_type",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "uploaded",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "viewed_count",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "deleted",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
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

=head2 system_event_log_images

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogImage>

=cut

__PACKAGE__->has_many(
  "system_event_log_images",
  "TopTable::Schema::Result::SystemEventLogImage",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-04 12:04:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Z+yM9t8MtDnoDatYeG1c9Q

#
# Enable automatic date handling
#
__PACKAGE__->add_columns(
    "uploaded",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 0, },
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
