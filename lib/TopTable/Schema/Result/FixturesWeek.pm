use utf8;
package TopTable::Schema::Result::FixturesWeek;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::FixturesWeek

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

=head1 TABLE: C<fixtures_weeks>

=cut

__PACKAGE__->table("fixtures_weeks");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 week_beginning_date

  data_type: 'date'
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
  "season",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "week_beginning_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 fixtures_season_weeks

Type: has_many

Related object: L<TopTable::Schema::Result::FixturesSeasonWeek>

=cut

__PACKAGE__->has_many(
  "fixtures_season_weeks",
  "TopTable::Schema::Result::FixturesSeasonWeek",
  { "foreign.fixtures_week" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 team_matches

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches",
  "TopTable::Schema::Result::TeamMatch",
  { "foreign.scheduled_week" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_seasons_intervals

Type: has_many

Related object: L<TopTable::Schema::Result::TeamSeasonsInterval>

=cut

__PACKAGE__->has_many(
  "team_seasons_intervals",
  "TopTable::Schema::Result::TeamSeasonsInterval",
  { "foreign.week" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 fixtures_grid_weeks

Type: many_to_many

Composing rels: L</fixtures_season_weeks> -> fixtures_grid_week

=cut

__PACKAGE__->many_to_many(
  "fixtures_grid_weeks",
  "fixtures_season_weeks",
  "fixtures_grid_week",
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-12-31 16:31:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:g3Ko/eu5/liERySgAEpbKw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
