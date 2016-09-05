use utf8;
package TopTable::Schema::Result::TeamSeasonsInterval;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TeamSeasonsInterval

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

=head1 TABLE: C<team_seasons_intervals>

=cut

__PACKAGE__->table("team_seasons_intervals");

=head1 ACCESSORS

=head2 team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 week

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 division

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 league_table_points

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 matches_played

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 matches_won

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 matches_lost

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 matches_drawn

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_played

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_won

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_lost

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_drawn

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_game_wins

  data_type: 'float'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_played

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_won

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_lost

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_leg_wins

  data_type: 'float'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_played

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_won

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_lost

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_point_wins

  data_type: 'float'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 table_points

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "team",
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
  "week",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "division",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "league_table_points",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "matches_played",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "matches_won",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "matches_lost",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "matches_drawn",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "games_played",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "games_won",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "games_lost",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "games_drawn",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "average_game_wins",
  { data_type => "float", extra => { unsigned => 1 }, is_nullable => 0 },
  "legs_played",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "legs_won",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "legs_lost",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "average_leg_wins",
  { data_type => "float", extra => { unsigned => 1 }, is_nullable => 0 },
  "points_played",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "points_won",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "points_lost",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "average_point_wins",
  { data_type => "float", extra => { unsigned => 1 }, is_nullable => 0 },
  "table_points",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</team>

=item * L</season>

=item * L</week>

=back

=cut

__PACKAGE__->set_primary_key("team", "season", "week");

=head1 RELATIONS

=head2 division

Type: belongs_to

Related object: L<TopTable::Schema::Result::Division>

=cut

__PACKAGE__->belongs_to(
  "division",
  "TopTable::Schema::Result::Division",
  { id => "division" },
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

=head2 team

Type: belongs_to

Related object: L<TopTable::Schema::Result::Team>

=cut

__PACKAGE__->belongs_to(
  "team",
  "TopTable::Schema::Result::Team",
  { id => "team" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 week

Type: belongs_to

Related object: L<TopTable::Schema::Result::FixturesWeek>

=cut

__PACKAGE__->belongs_to(
  "week",
  "TopTable::Schema::Result::FixturesWeek",
  { id => "week" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-09-05 16:36:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FHjEs4ZgTDCOm0A7pYMTtQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
