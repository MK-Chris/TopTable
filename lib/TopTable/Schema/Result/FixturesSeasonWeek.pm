use utf8;
package TopTable::Schema::Result::FixturesSeasonWeek;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::FixturesSeasonWeek

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

=head1 TABLE: C<fixtures_season_weeks>

=cut

__PACKAGE__->table("fixtures_season_weeks");

=head1 ACCESSORS

=head2 grid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 grid_week

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 fixtures_week

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "grid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "grid_week",
  {
    data_type => "tinyint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "fixtures_week",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</grid>

=item * L</grid_week>

=item * L</fixtures_week>

=back

=cut

__PACKAGE__->set_primary_key("grid", "grid_week", "fixtures_week");

=head1 RELATIONS

=head2 fixtures_grid_week

Type: belongs_to

Related object: L<TopTable::Schema::Result::FixturesGridWeek>

=cut

__PACKAGE__->belongs_to(
  "fixtures_grid_week",
  "TopTable::Schema::Result::FixturesGridWeek",
  { grid => "grid", week => "grid_week" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 fixtures_week

Type: belongs_to

Related object: L<TopTable::Schema::Result::FixturesWeek>

=cut

__PACKAGE__->belongs_to(
  "fixtures_week",
  "TopTable::Schema::Result::FixturesWeek",
  { id => "fixtures_week" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-04 12:04:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FB2oL67a7wvk7+16Mtzp2w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
