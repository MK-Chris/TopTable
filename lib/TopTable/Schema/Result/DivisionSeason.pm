use utf8;
package TopTable::Schema::Result::DivisionSeason;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::DivisionSeason

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

=head1 TABLE: C<division_seasons>

=cut

__PACKAGE__->table("division_seasons");

=head1 ACCESSORS

=head2 division

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 fixtures_grid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 league_match_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 league_table_ranking_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 promotion_places

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=head2 relegation_places

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "division",
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
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "fixtures_grid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "league_match_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "league_table_ranking_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "promotion_places",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
  "relegation_places",
  { data_type => "tinyint", default_value => 0, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</division>

=item * L</season>

=back

=cut

__PACKAGE__->set_primary_key("division", "season");

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

=head2 fixtures_grid

Type: belongs_to

Related object: L<TopTable::Schema::Result::FixturesGrid>

=cut

__PACKAGE__->belongs_to(
  "fixtures_grid",
  "TopTable::Schema::Result::FixturesGrid",
  { id => "fixtures_grid" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 league_match_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateMatchTeam>

=cut

__PACKAGE__->belongs_to(
  "league_match_template",
  "TopTable::Schema::Result::TemplateMatchTeam",
  { id => "league_match_template" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 league_table_ranking_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateLeagueTableRanking>

=cut

__PACKAGE__->belongs_to(
  "league_table_ranking_template",
  "TopTable::Schema::Result::TemplateLeagueTableRanking",
  { id => "league_table_ranking_template" },
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

=head2 team_matches

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches",
  "TopTable::Schema::Result::TeamMatch",
  {
    "foreign.division" => "self.division",
    "foreign.season"   => "self.season",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::TeamSeason>

=cut

__PACKAGE__->has_many(
  "team_seasons",
  "TopTable::Schema::Result::TeamSeason",
  {
    "foreign.division" => "self.division",
    "foreign.season"   => "self.season",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-02-03 10:04:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XP6XPWCZnyfGiG3Hu+HsmA

=head2 league_table

Get the teams in this division / season in league table order.

=cut

sub league_table {
  my $self = shift;
  
  return $self->search_related("team_seasons", {}, {
    prefetch  => ["team", {
      club_season => "club",
    }],
    order_by  => [{
      -desc => [qw( games_won matches_won matches_drawn )],
    }, {
      -asc  => [qw( games_lost matches_lost )],
    }, {
      -desc => [qw( legs_won )],
    }, {
      -asc => [qw( club_season.short_name me.name )],
    }],
  });
}

=head2 table_last_updated

For a given season and division, return the last updated date / time.

=cut

sub table_last_updated {
  my $self = shift;
  
  my $last_updated_team = $self->find_related("team_seasons", {}, {
    rows => 1,
    order_by => {-desc => "last_updated"}
  });
  
  return $last_updated_team->last_updated if defined($last_updated_team);
}

=head2 points_adjustments

Get a list of all points adjustments for this division/season from the team_seasons relation.

=cut

sub points_adjustments {
  my $self = shift;
  return $self->search_related("team_seasons")->search_related("team_points_adjustments");
}

=head2 matches

Return a list of matches for the division in this season.

=cut

sub matches {
  my $self = shift;
  
  return $self->search_related("team_matches");
}

=head2 table_complete

Return 1 if the season is complete, or all matches are complete; 0 otherwise.

=cut

sub table_complete {
  my $self = shift;
  my $season = $self->season;
  
  return ($season->complete or $self->matches->incomplete_and_not_cancelled->count == 0) ? 1 : 0;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
