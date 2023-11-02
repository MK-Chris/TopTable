use utf8;
package TopTable::Schema::Result::OfficialSeason;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::OfficialSeason

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

=head1 TABLE: C<official_seasons>

=cut

__PACKAGE__->table("official_seasons");

=head1 ACCESSORS

=head2 official

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 position_name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 position_order

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 position_holder

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "official",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "season",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "position_name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "position_order",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "position_holder",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<official_season_order>

=over 4

=item * L</season>

=item * L</position_order>

=back

=cut

__PACKAGE__->add_unique_constraint("official_season_order", ["season", "position_order"]);

=head1 RELATIONS

=head2 official

Type: belongs_to

Related object: L<TopTable::Schema::Result::Official>

=cut

__PACKAGE__->belongs_to(
  "official",
  "TopTable::Schema::Result::Official",
  { id => "official" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 position_holder

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "position_holder",
  "TopTable::Schema::Result::Person",
  { id => "position_holder" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 season

Type: belongs_to

Related object: L<TopTable::Schema::Result::Season>

=cut

__PACKAGE__->belongs_to(
  "season",
  "TopTable::Schema::Result::Season",
  { id => "season" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-08-21 20:27:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LIeShVfgunYNwXz6AL/38A


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
