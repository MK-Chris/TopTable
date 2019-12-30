use utf8;
package TopTable::Schema::Result::FixturesGridWeek;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::FixturesGridWeek

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

=head1 TABLE: C<fixtures_grid_weeks>

=cut

__PACKAGE__->table("fixtures_grid_weeks");

=head1 ACCESSORS

=head2 grid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 week

  data_type: 'tinyint'
  extra: {unsigned => 1}
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
  "week",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</grid>

=item * L</week>

=back

=cut

__PACKAGE__->set_primary_key("grid", "week");

=head1 RELATIONS

=head2 fixtures_grid_matches

Type: has_many

Related object: L<TopTable::Schema::Result::FixturesGridMatch>

=cut

__PACKAGE__->has_many(
  "fixtures_grid_matches",
  "TopTable::Schema::Result::FixturesGridMatch",
  { "foreign.grid" => "self.grid", "foreign.week" => "self.week" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 fixtures_season_weeks

Type: has_many

Related object: L<TopTable::Schema::Result::FixturesSeasonWeek>

=cut

__PACKAGE__->has_many(
  "fixtures_season_weeks",
  "TopTable::Schema::Result::FixturesSeasonWeek",
  { "foreign.grid" => "self.grid", "foreign.grid_week" => "self.week" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 grid

Type: belongs_to

Related object: L<TopTable::Schema::Result::FixturesGrid>

=cut

__PACKAGE__->belongs_to(
  "grid",
  "TopTable::Schema::Result::FixturesGrid",
  { id => "grid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 fixtures_weeks

Type: many_to_many

Composing rels: L</fixtures_season_weeks> -> fixtures_week

=cut

__PACKAGE__->many_to_many("fixtures_weeks", "fixtures_season_weeks", "fixtures_week");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-12-26 23:42:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:CwjEWYes7STbefSFLTNaPw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
