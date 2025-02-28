use utf8;
package TopTable::Schema::Result::TeamSeason;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TeamSeason

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

=head1 TABLE: C<team_seasons>

=cut

__PACKAGE__->table("team_seasons");

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

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 club

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 division

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 captain

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 matches_played

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 matches_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 matches_drawn

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 matches_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 table_points

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 games_played

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_drawn

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_game_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_difference

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 legs_played

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_lost

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_leg_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_difference

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 points_played

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_won

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_lost

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_point_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 total_handicap

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 points_difference

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 doubles_games_played

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_games_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_games_drawn

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_games_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_average_game_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_games_difference

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 doubles_legs_played

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_legs_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_legs_lost

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_average_leg_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_legs_difference

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 doubles_points_played

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_points_won

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_points_lost

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_average_point_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_points_difference

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 home_night

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 grid_position

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 last_updated

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 matches_cancelled

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

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
  "name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "club",
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
  "captain",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "matches_played",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "matches_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "matches_drawn",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "matches_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "table_points",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "games_played",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_drawn",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_game_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_difference",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "legs_played",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_won",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_lost",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_leg_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_difference",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "points_played",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "points_won",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "points_lost",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_point_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "total_handicap",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "points_difference",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "doubles_games_played",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_games_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_games_drawn",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_games_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_average_game_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_games_difference",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "doubles_legs_played",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_legs_won",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_legs_lost",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_average_leg_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_legs_difference",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "doubles_points_played",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_points_won",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_points_lost",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_average_point_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_points_difference",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "home_night",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "grid_position",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "last_updated",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "matches_cancelled",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</team>

=item * L</season>

=back

=cut

__PACKAGE__->set_primary_key("team", "season");

=head1 RELATIONS

=head2 captain

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "captain",
  "TopTable::Schema::Result::Person",
  { id => "captain" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "RESTRICT",
  },
);

=head2 club_season

Type: belongs_to

Related object: L<TopTable::Schema::Result::ClubSeason>

=cut

__PACKAGE__->belongs_to(
  "club_season",
  "TopTable::Schema::Result::ClubSeason",
  { club => "club", season => "season" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 division_season

Type: belongs_to

Related object: L<TopTable::Schema::Result::DivisionSeason>

=cut

__PACKAGE__->belongs_to(
  "division_season",
  "TopTable::Schema::Result::DivisionSeason",
  { division => "division", season => "season" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 doubles_pairs

Type: has_many

Related object: L<TopTable::Schema::Result::DoublesPair>

=cut

__PACKAGE__->has_many(
  "doubles_pairs",
  "TopTable::Schema::Result::DoublesPair",
  { "foreign.season" => "self.season", "foreign.team" => "self.team" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 home_night

Type: belongs_to

Related object: L<TopTable::Schema::Result::LookupWeekday>

=cut

__PACKAGE__->belongs_to(
  "home_night",
  "TopTable::Schema::Result::LookupWeekday",
  { weekday_number => "home_night" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 person_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::PersonSeason>

=cut

__PACKAGE__->has_many(
  "person_seasons",
  "TopTable::Schema::Result::PersonSeason",
  { "foreign.season" => "self.season", "foreign.team" => "self.team" },
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

=head2 team_matches_away_team_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches_away_team_seasons",
  "TopTable::Schema::Result::TeamMatch",
  {
    "foreign.away_team" => "self.team",
    "foreign.season"    => "self.season",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_matches_chosen_winner_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches_chosen_winner_seasons",
  "TopTable::Schema::Result::TeamMatch",
  {
    "foreign.chosen_winner" => "self.team",
    "foreign.season"        => "self.season",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_matches_home_team_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches_home_team_seasons",
  "TopTable::Schema::Result::TeamMatch",
  {
    "foreign.home_team" => "self.team",
    "foreign.season"    => "self.season",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_matches_winner_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches_winner_seasons",
  "TopTable::Schema::Result::TeamMatch",
  { "foreign.season" => "self.season", "foreign.winner" => "self.team" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_points_adjustments

Type: has_many

Related object: L<TopTable::Schema::Result::TeamPointsAdjustment>

=cut

__PACKAGE__->has_many(
  "team_points_adjustments",
  "TopTable::Schema::Result::TeamPointsAdjustment",
  { "foreign.season" => "self.season", "foreign.team" => "self.team" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentTeam>

=cut

__PACKAGE__->has_many(
  "tournament_teams",
  "TopTable::Schema::Result::TournamentTeam",
  { "foreign.season" => "self.season", "foreign.team" => "self.team" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-02-28 10:30:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vJioYl4OU+/ERVGYZRCZYg

__PACKAGE__->add_columns(
    "last_updated",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 1, datetime_undef_if_invalid => 1, is_nullable => 1, },
);

=head2 full_name

Return the club season's (short) name with the team name.

=cut

sub full_name {
  my $self = shift;
  return sprintf("%s %s", $self->club_season->short_name, $self->name);
}

=head2 abbreviated_name

Return the club season's (abbreviated) name with the team name.

=cut

sub abbreviated_name {
  my $self = shift;
  return sprintf("%s %s", $self->club_season->abbreviated_name, $self->name);
}

=head2 object_name

Used for compatibility with person tournament memberships, so we can refer to object_name regardless of whether we're accessing a tournament or direct team object.

=cut

sub object_name {
  my $self = shift;
  return $self->full_name;
}

=head2 league_position

Returns the team's league position within the season.

=cut

sub league_position {
  my $self = shift;
  
  my $teams_in_division = $self->result_source->schema->resultset("TeamSeason")->get_teams_in_division_in_league_table_order({
    season => $self->season,
    division => $self->division_season->division,
  });
  
  my $pos = 0;
  
  # Now we need to loop throug the array, counting up as we go
  while ( my $division_team = $teams_in_division->next ) {
    # Increment our count
    $pos++;
    
    # Exit the loop once we find this team
    last if $division_team->team->id == $self->team->id;
  }
  
  return $pos;
}

=head2 get_players

Retrieve an arrayref of players registered for this team season.

=cut

sub get_players {
  my $self = shift;
  my ( $parameters ) = @_;
  
  return $self->search_related("person_seasons", undef, {
    prefetch => "person",
    order_by => {-asc => [qw( person.surname person.first_name )]}
  });
}

=head2 cancelled_matches

Return the matches involving this team which have been cancelled.

=cut

sub cancelled_matches {
  my $self = shift;
  
  my $home_matches = $self->search_related("team_matches_home_team_seasons", {cancelled => 1});
  my $away_matches = $self->search_related("team_matches_away_team_seasons", {cancelled => 1});
  
  return $home_matches->union($away_matches);
}

=head2 points_adjustments

Get all the adjustments for the team's season.

=cut

sub points_adjustments {
  my $self = shift;
  
  return $self->search_related("team_points_adjustments");
}

=head2 adjust_points

Perform some error checking and then adjust the team's points.

=cut

sub adjust_points {
  my $self = shift;
  my ( $params ) = @_;
  
  # Setup schema / logging
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Get the fields passed in
  my $action = $params->{action};
  my $points_adjustment = $params->{points_adjustment} || 0;
  my $reason = $params->{reason} || undef;
  
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    completed => 0,
    can_complete => 0, # Default to 0, we'll recreate that key in the overwritten $response from the team season if we get that far.
    fields => {
      # Action and reason don't need sanitising before adding to the fields hash; points adjustment does
      action => $action,
      reason => $reason,
    },
  };
  
  my $season = $self->season;
  
  if ( $season->complete ) {
    push @{$response->{error}}, $lang->maketext("tables.adjustments.error.season-not-current", encode_entities($season->name));
    return $response;
  }
  
  # If we get this far, we can complete
  $response->{can_complete} = 1;
  
  # Check our fields
  push(@{$response->{error}}, $lang->maketext("tables.adjustments.error.invalid-action")) unless defined($action) and ($action eq "award" or $action eq "deduct");
  
  if ( $points_adjustment =~ m/^[1-9]+$/ ) {
    # Points adjustment is fine, set it into the fields to be passed back
    $response->{fields}{points_adjustment} = $points_adjustment;
  } else {
    # Points adjustment is invalid
    push(@{$response->{error}}, $lang->maketext("tables.adjustments.error.invalid-points-adjustment"));
  }
  
  push(@{$response->{error}}, $lang->maketext("tables.adjustments.error.blank-reason")) unless defined($reason) and length($reason) > 0;
  
  if ( scalar @{$response->{error}} == 0 ) {
    # No errors, do the update
    # First get the ranking template in use
    my $division_season = $self->division_season;
    my $rank_template = $division_season->league_table_ranking_template;
    my $match_template = $division_season->league_match_template;
    
    # Now get the fields we're going to update, based on the ranking template
    my ( $points_field, $points_against_field, $diff_field );
    if ( $rank_template->assign_points ) {
      $points_field = "table_points";
    } else {
      if ( $match_template->winner_type->id eq "games" ) {
        $points_field = "games_won";
        $points_against_field = "games_lost";
        $diff_field = "games_difference";
      } else {
        $points_field = "points_won";
        $points_against_field = "points_lost";
        $diff_field = "points_difference";
      }
    }
    
    # Convert points adjustment to a minus if the action is deduct
    $points_adjustment *= -1 if $action eq "deduct";
    
    # Transaction so if we fail, nothing is updated
    my $transaction = $schema->txn_scope_guard;
    
    # Create a new points adjustment record
    my $rec = $self->create_related("team_points_adjustments", {
      adjustment => $points_adjustment,
      reason => $reason,
    });
    
    # Update the team season
    $self->$points_field($self->$points_field + $points_adjustment);
    $self->$diff_field($self->$points_field - $self->$points_against_field) if defined($diff_field);
    $self->update;
    
    # Commit the transaction
    $transaction->commit;
    
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("tables.adjustments.success"));
  }
  
  return $response;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
