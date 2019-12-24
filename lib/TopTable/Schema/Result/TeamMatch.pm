use utf8;
package TopTable::Schema::Result::TeamMatch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TeamMatch

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

=head1 TABLE: C<team_matches>

=cut

__PACKAGE__->table("team_matches");

=head1 ACCESSORS

=head2 home_team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 away_team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 scheduled_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 scheduled_start_time

  data_type: 'time'
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 tournament_round

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 division

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 venue

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 scheduled_week

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 played_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 start_time

  data_type: 'time'
  is_nullable: 1

=head2 played_week

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 team_match_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 started

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 updated_since

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 home_team_games_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_games_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_games_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_games_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_drawn

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_legs_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_average_leg_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_legs_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_average_leg_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_points_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_average_point_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_points_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_average_point_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_match_score

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_match_score

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 player_of_the_match

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 fixtures_grid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 complete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 league_official_verified

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 home_team_verified

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 away_team_verified

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 cancelled

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "home_team",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "away_team",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "scheduled_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "scheduled_start_time",
  { data_type => "time", is_nullable => 0 },
  "season",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "tournament_round",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "division",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "venue",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "scheduled_week",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "played_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "start_time",
  { data_type => "time", is_nullable => 1 },
  "played_week",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "team_match_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "started",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "updated_since",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "home_team_games_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team_games_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_games_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_games_lost",
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
  "home_team_legs_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team_average_leg_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_legs_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_average_leg_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team_points_won",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team_average_point_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_points_won",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_average_point_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team_match_score",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_match_score",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "player_of_the_match",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "fixtures_grid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "complete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "league_official_verified",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "home_team_verified",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "away_team_verified",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "cancelled",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</home_team>

=item * L</away_team>

=item * L</scheduled_date>

=back

=cut

__PACKAGE__->set_primary_key("home_team", "away_team", "scheduled_date");

=head1 RELATIONS

=head2 away_team

Type: belongs_to

Related object: L<TopTable::Schema::Result::Team>

=cut

__PACKAGE__->belongs_to(
  "away_team",
  "TopTable::Schema::Result::Team",
  { id => "away_team" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 away_team_verified

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "away_team_verified",
  "TopTable::Schema::Result::Person",
  { id => "away_team_verified" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

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
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 home_team

Type: belongs_to

Related object: L<TopTable::Schema::Result::Team>

=cut

__PACKAGE__->belongs_to(
  "home_team",
  "TopTable::Schema::Result::Team",
  { id => "home_team" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 home_team_verified

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "home_team_verified",
  "TopTable::Schema::Result::Person",
  { id => "home_team_verified" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 league_official_verified

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "league_official_verified",
  "TopTable::Schema::Result::Person",
  { id => "league_official_verified" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 played_week

Type: belongs_to

Related object: L<TopTable::Schema::Result::FixturesWeek>

=cut

__PACKAGE__->belongs_to(
  "played_week",
  "TopTable::Schema::Result::FixturesWeek",
  { id => "played_week" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 player_of_the_match

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "player_of_the_match",
  "TopTable::Schema::Result::Person",
  { id => "player_of_the_match" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 scheduled_week

Type: belongs_to

Related object: L<TopTable::Schema::Result::FixturesWeek>

=cut

__PACKAGE__->belongs_to(
  "scheduled_week",
  "TopTable::Schema::Result::FixturesWeek",
  { id => "scheduled_week" },
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

=head2 system_event_log_team_matches

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTeamMatch>

=cut

__PACKAGE__->has_many(
  "system_event_log_team_matches",
  "TopTable::Schema::Result::SystemEventLogTeamMatch",
  {
    "foreign.object_away_team"      => "self.away_team",
    "foreign.object_home_team"      => "self.home_team",
    "foreign.object_scheduled_date" => "self.scheduled_date",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_games

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchGame>

=cut

__PACKAGE__->has_many(
  "team_match_games",
  "TopTable::Schema::Result::TeamMatchGame",
  {
    "foreign.away_team"      => "self.away_team",
    "foreign.home_team"      => "self.home_team",
    "foreign.scheduled_date" => "self.scheduled_date",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_players

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchPlayer>

=cut

__PACKAGE__->has_many(
  "team_match_players",
  "TopTable::Schema::Result::TeamMatchPlayer",
  {
    "foreign.away_team"      => "self.away_team",
    "foreign.home_team"      => "self.home_team",
    "foreign.scheduled_date" => "self.scheduled_date",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_reports

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchReport>

=cut

__PACKAGE__->has_many(
  "team_match_reports",
  "TopTable::Schema::Result::TeamMatchReport",
  {
    "foreign.away_team"      => "self.away_team",
    "foreign.home_team"      => "self.home_team",
    "foreign.scheduled_date" => "self.scheduled_date",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateMatchTeam>

=cut

__PACKAGE__->belongs_to(
  "team_match_template",
  "TopTable::Schema::Result::TemplateMatchTeam",
  { id => "team_match_template" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 tournament_round

Type: belongs_to

Related object: L<TopTable::Schema::Result::TournamentRound>

=cut

__PACKAGE__->belongs_to(
  "tournament_round",
  "TopTable::Schema::Result::TournamentRound",
  { id => "tournament_round" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 venue

Type: belongs_to

Related object: L<TopTable::Schema::Result::Venue>

=cut

__PACKAGE__->belongs_to(
  "venue",
  "TopTable::Schema::Result::Venue",
  { id => "venue" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-12-09 23:22:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lr1clfEqNN83TqtojwT1Fw

use Try::Tiny;
use DateTime::Duration;
use Set::Object;

#
# Enable automatic date handling
#
__PACKAGE__->add_columns(
    "updated_since",
    { data_type => "datetime", timezone => "UTC", set_on_create => 0, set_on_update => 1, },
);

=head2 url_keys

Returns a hashref with the URL keys in the order we need to use them to generate URLs.

=cut

sub url_keys {
  my ( $self ) = @_;
  return [ $self->home_team->club->url_key, $self->home_team->url_key, $self->away_team->club->url_key, $self->away_team->url_key, $self->scheduled_date->year, sprintf("%02d", $self->scheduled_date->month), sprintf("%02d", $self->scheduled_date->day) ];
}

=head2 actual_start_time

Return the match start time.  Uses start_time by default, or scheduled_start_time if that's null.

=cut

sub actual_start_time {
  my ( $self ) = @_;
  return ( defined( $self->start_time ) ) ? substr($self->start_time, 0, 5) : substr($self->scheduled_start_time, 0, 5);
}

=head2 actual_date

Row-level helper method to get the match played date if there is one, or the scheduled date if not.

=cut

sub actual_date {
  my ( $self ) = @_;
  
  if ( defined( $self->played_date ) ) {
    return $self->played_date;
  } else {
    return $self->scheduled_date;
  }
}

=head2 rescheduled

Returns a simple true or false value based on whether played_date is defined (and if so whether or not it matches scheduled_date).

=cut

sub rescheduled {
  my ( $self ) = @_;
  
  # Return 1 if played date is defined and different from the scheduled date.
  return ( defined( $self->played_date ) and $self->played_date->ymd ne $self->scheduled_date->ymd ) ? 1 : 0;
}

=head2 games_reordered

Checks whether any 'actual_game_number' fields in games for this match differ from the 'scheduled_game_number' - if so, returns 1, else 0.

=cut

sub games_reordered {
  my ( $self ) = @_;
  
  my $reordered_games = $self->search_related("team_match_games", undef, {
    where => {
      actual_game_number => \'!= scheduled_game_number',
    },
  })->count;
  
  return ( $reordered_games ) ? 1 : 0;
}

=head2 get_team_seasons

Retrieve the team season objects for the home and away teams in the season that the match took place.  This returns a hashref with 'home' and 'away' keys.

=cut

sub get_team_seasons {
  my ( $self ) = @_;
  my $season = $self->season;
  my %team_seasons = ();
  
  $team_seasons{home} = $self->home_team->search_related("team_seasons", {
    season => $season->id,
  }, {
    rows => 1,
  })->single;
  
  $team_seasons{away} = $self->away_team->search_related("team_seasons", {
    season => $season->id,
  }, {
    rows => 1,
  })->single;
  
  return \%team_seasons;
}

=head2 get_division_season

Retrieve the division season object for the division and season that this match takes place in.

=cut

sub get_division_season {
  my ( $self ) = @_;
  return $self->division->search_related("division_seasons", {
    season => $self->season->id,
  }, {
    rows => 1
  })->single;
}

=head2 update_played_date

Validate and update the played date.

=cut

sub update_played_date {
  my ( $self, $played_date ) = @_;
  my ( $date_day, $date_month, $date_year ) = split("/", $played_date);
  my $error = [];
  
  try {
    $played_date = DateTime->new(
      year  => $date_year,
      month => $date_month,
      day   => $date_day,
    );
  } catch {
    push(@{ $error }, {id => "matches.update-match-date.error.date-invalid"});
  };
  
  if ( scalar( @{ $error } ) == 0 ) {
    my $ok = $self->update({played_date => $played_date});
    push(@{ $error }, {id => "matches.update-match-date.error.database-update-failed"}) if !$ok;
  }
  
  return $error;
}

=head2 update_venue

Validate and update the venue for a match.

=cut

sub update_venue {
  my ( $self, $venue ) = @_;
  my $error = [];
  
  if ( defined( $venue ) and ref( $venue ) eq "TopTable::Model::DB::Venue" ) {
    # All good, venue is valid
    my $ok = $self->update({venue => $venue->id});
    push(@{ $error }, {id => "matches.update-match-date.error.database-update-failed"}) unless $ok;
  } else {
    # Error, invalid venue
    push(@{ $error }, {id => "matches.update-venue.error.venue-invalid"});
  }
  
  return $error;
}

=head2 update_playing_order

Updates the playing order (i.e., re-orders the the games within a match from the scheduled order).

=cut

sub update_playing_order {
  my ( $self, $parameters ) = @_;
  my $return_value = {error => []};
  
  # Get the games
  my @games = $self->team_match_games;
  
  # Get the total number of games so we can check we don't go over this number
  my $total_games = scalar( @games );
  
  # Store the numbers we've seen
  my %game_numbers;
  
  # Loop through and get the new order for each game.
  foreach my $game ( @games ) {
    # Get the new game number
    my $actual_game_number = $parameters->{ "game-" . $game->scheduled_game_number };
    
    if ( $actual_game_number =~ m/^\d{1,2}$/ and $actual_game_number > $total_games ) {
      # Number invalid
      push(@{ $return_value->{error} }, {
        id          => "matches.update-playing-order.error.game-number-invalid",
        parameters  => [$actual_game_number, $game->scheduled_game_number, $total_games],
      });
    } elsif ( exists( $game_numbers{$actual_game_number} ) ) {
      # Number already specified
      push(@{ $return_value->{error} }, {
        id          => "matches.update-playing-order.error.game-specified-multiple",
        parameters  => [$actual_game_number, $game->scheduled_game_number, $game_numbers{$actual_game_number}],
      });
    } else {
      $game_numbers{$actual_game_number} = $game->scheduled_game_number;
    }
  }
  
  if ( scalar( @{ $return_value->{error} } ) == 0 ) {
    # If we get no errors, loop through again and this time update it
    foreach my $game ( @games ) {
      # Get the new game number
      my $actual_game_number = $parameters->{ "game-" . $game->scheduled_game_number };
      
      $game->update({actual_game_number => $actual_game_number,});
    }
    
    # Stash the new match scores
    $return_value->{match_scores} = $self->calculate_match_score;
  }
  
  return $return_value;
}

=head2 calculate_match_score

Generate the home and away score of the given match based on the game scores.  Also updates the running game scores if they are incorrect.

=cut

sub calculate_match_score {
  my ( $self ) = @_;
  my $match_scores = [];
  
  # The first two $home_won and $away_won will hold the score to be put against each game number, so 0 if it hasn't been played.
  # The internal ones ($_home_won and $_away_won) will be hold the calculated score for each game that's been played and will
  # hold the running score each way through, so if the game hasn't been played this is ignored.
  my ( $home_won, $away_won, $drawn, $_home_won, $_away_won, $_drawn ) = qw( 0 0 0 0 0 0 );
  my $winner_type = $self->team_match_template->winner_type->id;
  
  # Home and away teams to check the winner against in the even of walkovers
  my $home_team = $self->home_team;
  my $away_team = $self->away_team;
  
  # Get the games for the given match
  my @games = $self->search_related("team_match_games", undef, {
    prefetch  => qw( individual_match_template ),
    order_by  => {
      -asc  => "actual_game_number",
    }
  });
  
  # Now loop through the games
  foreach my $game ( @games ) {
    if ( $winner_type eq "games" ) {
      # Match scores are determined by the number of games won
      if ( $game->complete ) {
        # If the game is complete, but wasn't started, it must be a walkover - check the winner field.
        if ( defined( $game->winner ) ) {
          if ( $game->winner->id == $home_team->id ) {
            # Awarded to the home team
            $_home_won++;
          } else {
            # Awarded to the away team
            $_away_won++;
          }
        } else {
          # Winner not specified, game is void, no scores are incremented.  Do nothing here
        }
      } else {
        # Game not played or in progress, don't increment anything
      }
        
      ( $home_won, $away_won ) = ( $_home_won, $_away_won );
    } elsif ( $winner_type eq "points" ) {
      # Match scores are determined by the number of points won
      if ( $game->started and $game->complete ) {
        # Add the legs won for each team to the total
        $_home_won += $game->home_team_points_won;
        $_away_won += $game->away_team_points_won;
        ( $home_won, $away_won ) = ( $_home_won, $_away_won );
      } elsif ( $game->complete ) {
        # If the game is complete, but wasn't started, it must be a walkover - check the winner field.
        if ( defined( $game->winner ) ) {
          # Get the number of points required to win a leg - this will be added to the winner's score for each leg
          my $game_rules = $game->individual_match_template;
          my $minimum_points_win  = $game_rules->minimum_points_win;
          my $legs_per_game       = $game_rules->legs_per_game;
          
          if ( $game_rules->game_type->id eq "best-of" ) {
            $legs_per_game = ( $game_rules->legs_per_game / 2 ) + 1; # Best of x legs - halve it and + 1
            $legs_per_game = int( $legs_per_game ); # Truncate any decimal placeas
          }
          
          if ( $self->winner->id == $home_team->id ) {
            # Awarded to the home team - current home points plus the points we need for a win multiplied by the number of legs
            $_home_won += ( $legs_per_game * $minimum_points_win );
          } else {
            # Awarded to the away team - current away points plus the points we need for a win multiplied by the number of legs
            $_away_won += ( $legs_per_game * $minimum_points_win );
          }
          
          ( $home_won, $away_won ) = ( $_home_won, $_away_won );
        } else {
          # If no winner is defined, the match is void
          ( $home_won, $away_won ) = qw( 0 0 );
        }
      } else {
        # Not played yet
        ( $home_won, $away_won ) = qw( 0 0 );
      }
    }
    
    # Add the score after this match to the array
    push( @{ $match_scores }, {
      scheduled_game_number => $game->scheduled_game_number,
      home_won              => $home_won,
      away_won              => $away_won,
      drawn                 => $drawn,
    });
    
    # Check if the database running score is correct; if not, update it
    $game->update({
      home_team_match_score => $home_won,
      away_team_match_score => $away_won,
    });
  }
  
  return $match_scores;
}

=head2 games_in_scheduled_order

Returns all the games associated with this match in scheduled order.

=cut

sub games_in_scheduled_order {
  my ( $self ) = @_;
  
  return $self->search_related("team_match_games", {}, {
    prefetch => ["umpire", {
      individual_match_template => [
        qw( game_type serve_type )
      ],
      team_match_legs => [
        qw( first_server next_point_server )
      ]},
    ]
  });
}

=head2 check_match_started

Check whether a match has started by whether at least one game is marked as complete or not - this can be used to determine whether or not to mark the match itself as started.  Returns true if at least one game is complete, or false if no games are.

=cut

sub check_match_started {
  my ( $self ) = @_;
  
  # Find games in this match that have been both started and completed (if they are complete but haven't been
  # started, that means at least one of the players is missing, so it technically can't denote that the match
  # is started).
  my $complete_games = $self->search_related("team_match_games", {
    started   => 1,
    complete  => 1,
  })->count;
  
  if ( $complete_games ) {
    # We have found some completed games, so return true
    return 1;
  } else {
    # No games are complete, so return false
    return 0;
  }
}

=head2 check_match_complete

Check whether a match is complete by whether all of the games are marked complete or not - this can be used to determine whether or not to mark the match itself as complete.  Returns true if all games are complete, or false if one or more game is not.

=cut

sub check_match_complete {
  my ( $self ) = @_;
  
  # Loop through the current resultset and push into the array of incomplete games if this one is not complete yet
  my $incomplete_games = $self->search_related("team_match_games", {
    complete => 0,
  })->count;
  
  if ( $incomplete_games ) {
    # We have found some incomplete games, so return false
    return 0;
  } else {
    # All games are complete, so return true
    return 1;
  }
}

=head2 eligible_players

Return the list of players who are able to play in this match as an array reference; this includes all registered players for either team and any loan players who have been set in a position.

Takes an optional $location parameter, which can specify whether only home or away players are returned.

=cut

sub eligible_players {
  my ( $self, $parameters ) = @_;
  my $location = $parameters->{location} || undef;
  undef( $location ) if defined( $location ) and $location ne "home" and $location ne "away";
  my ( @home_players, @away_players );
  
  # Check whether we need to get the home players
  if ( !defined( $location ) or $location eq "home" ) {
    # Get the registered home players
    @home_players = $self->home_team->search_related("person_seasons", {
      season => $self->season->id,
    }, {
      order_by => {
        -asc => [ qw/surname first_name/ ],
      }
    })->all;
    
    # Get players set for the match and push them on to the array if they've played up
    my @set_players = $self->search_related("team_match_players", {
      location => "home",
      loan_team => {
        "!=" => undef,
      },
      "person_seasons.season" => $self->season->id,
    }, {
      prefetch => {
        player => "person_seasons"
      },
    });
    
    push(@home_players, $_->player->person_seasons) foreach ( @set_players );
  }
  
  # Check whether we need to get the home players
  if ( !defined( $location ) or $location eq "away" ) {
    # Get the registered away players
    @away_players = $self->away_team->search_related("person_seasons", {
      season => $self->season->id,
    }, {
      order_by => {
        -asc => [ qw/surname first_name/ ],
      }
    })->all;
    
    # Get players set for the match and push them on to the array if they've played up
    my @set_players = $self->search_related("team_match_players", {
      location => "away",
      loan_team => {
        "!=" => undef,
      },
      "person_seasons.season" => $self->season->id,
    }, {
      prefetch => {
        player => "person_seasons"
      },
    });
    
    push(@away_players, $_->player->person_seasons) foreach ( @set_players );
  }
  
  # Decide what to return
  if ( defined( $location ) and $location eq "home" ) {
    # Home team only
    return \@home_players;
  } elsif ( defined( $location ) and $location eq "away" ) {
    # Away team only
    return \@away_players;
  } else {
    # Both teams
    my @return_array = ( @home_players, @away_players );
    return \@return_array;
  }
}

=head2 players

Returns a list of players in the match, along with their 'person' and 'person_seasons' objects.

=cut

sub players {
  my ( $self, $parameters ) = @_;
  my $location = $parameters->{location} || undef; # home or away
  my $where = {
    "person_seasons.season" => $self->season->id,
  };
  
  $where->{location} = $location if defined( $location );
  
  return $self->search_related("team_match_players", $where, {
    prefetch => {
      player => "person_seasons"
    },
  });
}

=head2 update_scorecard

Validates and then updates the details given in the scorecard.

=cut

sub update_scorecard {
  my ( $self, $parameters ) = @_;
  my %game_scores   = ();
  my $return_value = {error => []};
  my $log = $parameters->{logger};
  
  # Single game if the 'game' and 'leg' parameters are provided
  my $single_game = ( exists( $parameters->{game} ) ) ? 1 : 0;
  
  # Initial error check that the match is in the current season
  if ( $self->season->complete ) {
    push(@{ $return_value->{error} }, {id => "matches.update.error.season-complete"});
    return $return_value;
  }
  
  # Store the season into a more easily accessible variable
  my $season = $self->season;
  
  # The following are needed to get the original scores from this match; if we're editing rather than updating for the first time,
  # we can't just add the scores on to the team / player statistics, as that will add on to the old scores.
  my ( $original_home_team_score, $original_away_team_score, $original_home_team_legs, $original_away_team_legs, $original_home_team_points, $original_away_team_points ) = ( $self->home_team_match_score, $self->away_team_match_score, $self->home_team_legs_won, $self->away_team_legs_won, $self->home_team_points_won, $self->away_team_points_won );
  
  # Check if we're just updating a single leg or a full match
  my $game;
  if ( $single_game ) {
    my $game_number = delete $parameters->{game};
    my $game = $self->team_match_games->find({
      scheduled_game_number => $game_number,
    }, {
      prefetch => [qw( team_match_legs individual_match_template )],
    });
    
    if ( defined( $game ) ) {
      # Update the game
      $return_value = $game->update_score( $parameters );
    } else {
      push(@{ $return_value->{error} }, {id => "matches.update-single.error.game-invalid"});
    }
  } else {
    my $games = $self->team_match_games;
    while ( my $game = $games->next ) {
      my $game_result = $game->update_score({
        
      });
      
      # Push the errors from this game on if there are any.
      push( @{ $return_value->{error} }, $game_result->{error} ) if scalar( @{ $game_result->{error} } );
    }
  }
  
  return $return_value;
}

=head2 cancel

Cancels the match, removing any previous scores and players.

=cut

sub cancel {
  my ( $self, $parameters ) = @_;
  my $return_value = {
    error => [],
    cancellation_allowed => 1, # Default to allowed, set to 0 if the season is complete
  };
  
  # Can't cancel a completed match
  if ( $self->season->complete ) {
    push(@{ $return_value->{error} }, {id => "matches.cancel.error.season-complete"});
    $return_value->{cancellation_allowed} = 0;
    return $return_value;
  }
  
  # Grab and error check the points
  my $home_points_awarded = $parameters->{home_points_awarded} || 0;
  my $away_points_awarded = $parameters->{away_points_awarded} || 0;
  
  push(@{ $return_value->{error} }, {id => "matches.cancel.error.home-points-not-numeric"}) if $home_points_awarded !~  /^-?\d+$/;
  push(@{ $return_value->{error} }, {id => "matches.cancel.error.away-points-not-numeric"}) if $away_points_awarded !~  /^-?\d+$/;
  
  # Return with errors if we have them
  return $return_value if scalar( @{ $return_value->{error} } );
  
  # Loop through all the games and delete the scores
  my $games = $self->team_match_games;
  while ( my $game = $games->next ) {
    my $game_result = $game->update_score({delete => 1}) if $game->complete;
  }
  
  
  # If the match was previously cancelled and we're just changing the values, we need to alter the awarded points
  if ( $self->cancelled ) {
    $home_points_awarded -= $self->home_team_match_score;
    $away_points_awarded -= $self->away_team_match_score;
  }
    
  # Get a list of the players in this match and remove them; this includes the action of removing the score as well.
  my $players = $self->search_related("team_match_players");
  
  # Transaction so if we fail, nothing is updated
  my $transaction = $self->result_source->schema->txn_scope_guard;
  
  while ( my $player = $players->next ) {
    $player->update_person({action => "remove"});
  }
  
  # Update the match score and cancelled flag
  $self->update({
    home_team_match_score => $home_points_awarded,
    away_team_match_score => $away_points_awarded,
    cancelled             => 1,
  });
  
  # Get and update the team season objects
  my $season    = $self->season;
  my $home_team = $self->home_team->find_related("team_seasons", {season => $season->id});
  my $away_team = $self->away_team->find_related("team_seasons", {season => $season->id});
  
  my $league_table_ranking_template = $self->division->find_related("division_seasons", {
    season => $season->id,
  }, {
    prefetch => "league_table_ranking_template",
  })->league_table_ranking_template;
  
  # Fields to update the points values for - depends on whether we assign points for win / loss / draw or
  my ( $points_field, $points_against_field );
  if ( $league_table_ranking_template->assign_points ) {
    $points_field         = "table_points";
  } else {
    $points_field         = "games_won";
    $points_against_field = "games_lost";
  }
  
  # Update the awarded points in the relevant field - also points against if required - the points against should be awarded what the opposite team have been awarded
  # i.e., the away team's points against will be $home_points_awarded
  $home_team->$points_field( $home_team->$points_field + $home_points_awarded );
  $away_team->$points_field( $away_team->$points_field + $away_points_awarded );
  
  if ( defined( $points_against_field ) ) {
    $home_team->$points_against_field( $home_team->$points_against_field + $away_points_awarded );
    $away_team->$points_against_field( $away_team->$points_against_field + $home_points_awarded );
  }
  
  # Update the values we know what to update straight off
  $home_team->matches_played( $home_team->matches_played + 1 );
  $away_team->matches_played( $away_team->matches_played + 1 );
  
  if ( $home_points_awarded > $away_points_awarded ) {
    # Home points awarded are more than away points awarded, so the home team has "won"
    $home_team->matches_won( $home_team->matches_won + 1 );
    $away_team->matches_lost( $away_team->matches_lost + 1 );
  } elsif ( $home_points_awarded < $away_points_awarded ) {
    # Away points awarded are more than home points awarded, so the away team has "won"
    $away_team->matches_won( $away_team->matches_won + 1 );
    $home_team->matches_lost( $home_team->matches_lost + 1 );
  } else {
    # Points awarded are equal, so this is a draw
    $away_team->matches_drawn( $away_team->matches_drawn + 1 );
    $home_team->matches_drawn( $home_team->matches_drawn + 1 );
  }
  
  # Do the update
  $home_team->update;
  $away_team->update;
  
  # Commit the transaction
  $transaction->commit;
  
  return $return_value;
}

=head2 uncancel

Undo a match cancellation, remove the points awarded.

=cut

sub uncancel {
  my ( $self ) = @_;
  my $return_value = {
    error => [],
    cancellation_allowed => 1, # Default to allowed, set to 0 if the season is complete
  };
  
  # Can't cancel a completed match
  if ( $self->season->complete ) {
    push(@{ $return_value->{error} }, {id => "matches.uncancel.error.season-complete"});
    $return_value->{cancellation_allowed} = 0;
    return $return_value;
  }
  
  # Grab the points that were previously awarded so we can remove them from the home team / away team season totals
  my $home_points_awarded = $self->home_team_match_score;
  my $away_points_awarded = $self->away_team_match_score;
  
  # Transaction so if we fail, nothing is updated
  my $transaction = $self->result_source->schema->txn_scope_guard;
  
  # Remove the match score and cancelled flag
  $self->update({
    home_team_match_score => 0,
    away_team_match_score => 0,
    cancelled             => 0,
  });
  
  # Get and update the team season objects
  my $season    = $self->season;
  my $home_team = $self->home_team->find_related("team_seasons", {season => $season->id});
  my $away_team = $self->away_team->find_related("team_seasons", {season => $season->id});
  
  my $league_table_ranking_template = $self->division->find_related("division_seasons", {
    season => $season->id,
  }, {
    prefetch => "league_table_ranking_template",
  })->league_table_ranking_template;
  
  # Fields to update the points values for - depends on whether we assign points for win / loss / draw or
  my ( $points_field, $points_against_field );
  if ( $league_table_ranking_template->assign_points ) {
    $points_field         = "table_points";
  } else {
    $points_field         = "games_won";
    $points_against_field = "games_lost";
  }
  
  # Update the awarded points in the relevant field - also points against if required - the points against should be awarded what the opposite team have been awarded
  # i.e., the away team's points against will be $home_points_awarded
  $home_team->$points_field( $home_team->$points_field - $home_points_awarded );
  $away_team->$points_field( $away_team->$points_field - $away_points_awarded );
  
  if ( defined( $points_against_field ) ) {
    $home_team->$points_against_field( $home_team->$points_against_field - $away_points_awarded );
    $away_team->$points_against_field( $away_team->$points_against_field - $home_points_awarded );
  }
  
  # Update the values we know what to update straight off
  $home_team->matches_played( $home_team->matches_played - 1 );
  $away_team->matches_played( $away_team->matches_played - 1 );
  
  if ( $home_points_awarded > $away_points_awarded ) {
    # Home points awarded are more than away points awarded, so the home team has "won"
    $home_team->matches_won( $home_team->matches_won - 1 );
    $away_team->matches_lost( $away_team->matches_lost - 1 );
  } elsif ( $home_points_awarded < $away_points_awarded ) {
    # Away points awarded are more than home points awarded, so the away team has "won"
    $away_team->matches_won( $away_team->matches_won - 1 );
    $home_team->matches_lost( $home_team->matches_lost - 1 );
  } else {
    # Points awarded are equal, so this is a draw
    $away_team->matches_drawn( $away_team->matches_drawn - 1 );
    $home_team->matches_drawn( $home_team->matches_drawn - 1 );
  }
  
  # Do the update
  $home_team->update;
  $away_team->update;
  
  # Commit the transaction
  $transaction->commit;
  
  return $return_value;
}

=head2 result

Return a hash of details containing various results.  If a location is supplied ("home" or "away"), an extra key "team_result" will contain information regarding whether the team has won, lost, drawn or is winning, losing or drawing.

=cut

sub result {
  my ( $self, $location ) = @_;
  my %return_value = ();
  
  # Check the match status
  if ( $self->started ) {
    # Match has at least been started
    $return_value{score}  = sprintf( "%d-%d", $self->home_team_match_score, $self->away_team_match_score );
    
    # Check if we're complete or not
    if ( $self->complete ) {
      # Complete - result is win, loss or draw
      if ( $self->home_team_match_score > $self->away_team_match_score and defined( $location ) ) {
        # Home win
        if ( $location eq "home" ) {
          # Team specified is home, so this is a win
          $return_value{result} = {id => "matches.result.win"};
        } elsif ( $location eq "away" ) {
          # Team specified is away, so this is a loss
          $return_value{result} = {id => "matches.result.loss"};
        }
      } elsif ( $self->away_team_match_score > $self->home_team_match_score and defined( $location ) ) {
        # Away win
        if ( $location eq "home" ) {
          # Team specified is home, so this is a loss
          $return_value{result} = {id => "matches.result.loss"};
        } elsif ( $location eq "away" ) {
          # Team specified is away, so this is a win
          $return_value{result} = {id => "matches.result.win"};
        }
      } elsif ( $self->home_team_match_score == $self->away_team_match_score ) {
        # Draw - regardless of which team is specified
        $return_value{result} = {id => "matches.result.draw"};
      }
    } else {
      # Not complete - result is winning, losing or drawing
      # Complete - result is win, loss or draw
      if ( $self->home_team_match_score > $self->away_team_match_score and defined( $location ) ) {
        # Home winning
        if ( $location eq "home" ) {
          # Team specified is home, so they're winning
          $return_value{result} = {id => "matches.result.winning"};
        } elsif ( $location eq "away" ) {
          # Team specified is away, so they're losing
          $return_value{result} = {id => "matches.result.losing"};
        }
      } elsif ( $self->away_team_match_score > $self->home_team_match_score and defined( $location ) ) {
        # Away win
        if ( $location eq "home" ) {
          # Team specified is home, so they're losing
          $return_value{result} = {id => "matches.result.losing"};
        } elsif ( $location eq "away" ) {
          # Team specified is away, so they're winning
          $return_value{result} = {id => "matches.result.winning"};
        }
      } elsif ( $self->home_team_match_score == $self->away_team_match_score ) {
        # Draw - regardless of which team is specified
        $return_value{result} = {id => "matches.result.drawing"};
      }
    }
  } elsif ( $self->cancelled ) {
    # Match was cancelled
    $return_value{result} = {id => "matches.result.cancelled"};
    $return_value{score}  = sprintf( "%d-%d", $self->home_team_match_score, $self->away_team_match_score );
  } else {
    # Match hasn't been updated yet
    return undef;
  }
  
  return \%return_value;
}

=head2 generate_ical_data

Generate a hashref of data that can be easily manipulated into iCal format.  Takes a get_uri, get_versus_abbreviation parameter as a hostname to generate things this model can't know about.

=cut

sub generate_ical_data {
  my $self = shift;
  my %parameters = @_;
  
  # Get the versus abbreviation
  my $lang = &{ $parameters{get_language_components} };
  
  # Split the start time for setting the hour and minute
  my ( $start_hour, $start_minute ) = split( ":", $self->actual_start_time );
  
  # Get the URI
  my $uri = $parameters{get_uri}->($self->url_keys);
  
  my $description = ( defined( $self->tournament_round ) )
    ? undef
    : sprintf( "%s: %s\n%s: %s\n%s: %s\n%s", $lang->{competition_heading}, $lang->{competition_league}, $lang->{division_heading}, $self->division->name, $lang->{season_heading}, $self->season->name, $uri );
  
  return {
    uid             => sprintf( "matches.team.%s-%s.%s-%s.%s@%s", $self->home_team->club->url_key, $self->home_team->url_key, $self->away_team->club->url_key, $self->away_team->url_key, $self->actual_date->ymd("-"), &{ $parameters{get_host} } ),
    summary         => sprintf( "%s %s %s %s %s", $self->home_team->club->short_name, $self->home_team->name, $lang->{versus}, $self->away_team->club->short_name, $self->away_team->name ),
    status          => ( $self->cancelled ) ? "CANCELLED" : "CONFIRMED",
    description     => $description,
    date_start_time => $self->actual_date->set( hour => $start_hour, minute => $start_minute ),
    duration        => DateTime::Duration->new( minutes => &{ $parameters{get_duration} } ),
    venue           => $self->venue,
    url             => $uri,
    timezone        => $self->season->timezone,
  };
}

=head2 get_reports

Retrieve the reports for this match (reports is plural because it also retrieves previous edits of the report).  The live report (most recent edit) will always be the first record (if there are any); subsequent reports if there are any will be edits in descending date published order.

=cut

sub get_reports {
  my ( $self ) = @_;
  
  return $self->search_related("team_match_reports", {}, {
    prefetch => "author",
    order_by => {
      -desc => "published",
    },
  });
}

=head2 get_original_report

Retrieve the original report for this match (useful for getting the author of the original report).

=cut

sub get_original_report {
  my ( $self ) = @_;
  
  return $self->search_related("team_match_reports", {}, {
    prefetch  => "author",
    order_by  => {
      -asc    => "published",
    },
    rows      => 1,
  })->single;
}

=head2 get_original_report

Retrieve the original report for this match (useful for getting the author of the original report).

=cut

sub get_latest_report {
  my ( $self ) = @_;
  
  return $self->search_related("team_match_reports", {}, {
    prefetch  => "author",
    order_by  => {
      -desc   => "published",
    },
    rows      => 1,
  })->single;
}

=head2 can_report

Test whether a match can be reported on.  If a user parameter is not passed, this just checks whether the match is in the current season and returns true if so and false if not; if a user and the authorisation check from the main app is passed, this will also perform an additional check (if the match is in the current season, otherwise it's pointless) that the user is authorised to submit reports for the team.

=cut

sub can_report {
  my ( $self, $user ) = @_;
  my $season = $self->season;
  
  # Just return false if the season is complete - no one can submit or edit a report in a completed season.
  return 0 if $season->complete or !defined( $user ) or ref( $user ) ne "Catalyst::Authentication::Store::DBIx::Class::User";
  
  # Check the user is authorised to do this - first of all we check if there are any reports already
  my $original_report = $self->get_original_report;
  
  # The roles the user has will always be the same regardless of the original; need roles depends on the situation
  my $have_roles = Set::Object->new( $user->roles );
  my @need_roles;
  
  if ( defined( $original_report ) ) {
    # We have an original report, so we need to check if the current user is the original author before we can get the
    # roles that will be allowed to edit.
    
    # Work out which field name we're looking for
    my $auth_column = ( $original_report->author->id == $user->id ) ? "match_report_edit_own" : "match_report_edit_all";
    
    @need_roles = $self->result_source->schema->resultset("Role")->search({
      $auth_column => 1
    }, {
      order_by => {
        -asc => [ qw( name ) ],
      },
    });
  } else {
    # There is no report yet, so we need to check if the user is associated with any clubs or teams before we can get the
    # roles that will be allowed to edit.
    my $home_team = $self->home_team;
    my $away_team = $self->away_team;
    my $home_club = $self->home_team->club;
    my $away_club = $self->away_team->club;
    
    my $auth_column = ( $user->plays_for({team => $home_team, season => $season}) or
      $user->captain_for({team => $home_team, season => $season}) or
      $user->plays_for({team => $away_team, season => $season}) or
      $user->captain_for({team => $away_team, season => $season}) or
      $user->secretary_for({club => $home_club}) or
      $user->secretary_for({club => $away_club})
      ) ? "match_report_create_associated"
        : "match_report_create";
    
    @need_roles = $self->result_source->schema->resultset("Role")->search({
      $auth_column => 1
    }, {
      order_by => {
        -asc => [ qw( name ) ],
      },
    });
  }
  
  # Extract the name column for each returned value
  @need_roles = map( $_->name, @need_roles );
  
  my $need_roles = Set::Object->new( @need_roles );
  if ( $have_roles->intersection( $need_roles )->size > 0 ) {
    return 1;
  } else {
    return 0;
  }
}

=head2 add_report

Add a report to the match.

=cut

sub add_report {
  my ( $self, $parameters ) = @_;
  my %return_value = (errors => []);
  my $report  = $parameters->{report};
  my $user    = $parameters->{user};
  my $lang    = $parameters->{lang};
  my $raw_report = TopTable->model("FilterHTML")->filter( $report );
  $raw_report =~ s/^\s+|\s+$//g;
  
  push( @{ $return_value{errors} }, $lang->("matches.report.error.not-authorised", $user->username) ) unless $self->can_report( $user );
  push( @{ $return_value{errors} }, $lang->("matches.report.error.report-blank") ) unless $raw_report;
  
  # No errors so far, try and add a report
  unless ( scalar( @{ $return_value{errors} } ) ) {
    # Determine whether we're creating or editing
    my $original_report = $self->get_original_report;
    $return_value{action} = ( defined( $original_report ) ) ? "edit" : "create";
    
    my $report = $self->create_related("team_match_reports", {
      author  => $user->id,
      report  => TopTable->model("FilterHTML")->filter( $report, "textarea" ),
    });
  }
  
  return \%return_value;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
