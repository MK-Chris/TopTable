use utf8;
package TopTable::Schema::Result::TeamMatchGame;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TeamMatchGame

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

=head1 TABLE: C<team_match_games>

=cut

__PACKAGE__->table("team_match_games");

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
  is_foreign_key: 1
  is_nullable: 0

=head2 scheduled_game_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 individual_match_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 actual_game_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_player

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 home_player_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 away_player

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 away_player_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 home_doubles_pair

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 away_doubles_pair

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 home_team_legs_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_legs_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_points_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_points_won

  data_type: 'smallint'
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

=head2 doubles_game

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 game_in_progress

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 umpire

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 started

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 complete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 awarded

  data_type: 'tinyint'
  is_nullable: 1

=head2 void

  data_type: 'tinyint'
  is_nullable: 1

=head2 winner

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

We need to distinguish the winner if the game has been awarded to either side.

=head2 home_player_missing

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_player_missing

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
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
  {
    data_type => "date",
    datetime_undef_if_invalid => 1,
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "scheduled_game_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "individual_match_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "actual_game_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "home_player",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "home_player_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "away_player",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "away_player_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "home_doubles_pair",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "away_doubles_pair",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "home_team_legs_won",
  {
    data_type => "tinyint",
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
  "home_team_points_won",
  {
    data_type => "smallint",
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
  "doubles_game",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "game_in_progress",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "umpire",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "started",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "complete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "awarded",
  { data_type => "tinyint", is_nullable => 1 },
  "void",
  { data_type => "tinyint", is_nullable => 1 },
  "winner",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "home_player_missing",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_player_missing",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</home_team>

=item * L</away_team>

=item * L</scheduled_date>

=item * L</scheduled_game_number>

=back

=cut

__PACKAGE__->set_primary_key(
  "home_team",
  "away_team",
  "scheduled_date",
  "scheduled_game_number",
);

=head1 RELATIONS

=head2 away_doubles_pair

Type: belongs_to

Related object: L<TopTable::Schema::Result::DoublesPair>

=cut

__PACKAGE__->belongs_to(
  "away_doubles_pair",
  "TopTable::Schema::Result::DoublesPair",
  { id => "away_doubles_pair" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 away_player

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "away_player",
  "TopTable::Schema::Result::Person",
  { id => "away_player" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 home_doubles_pair

Type: belongs_to

Related object: L<TopTable::Schema::Result::DoublesPair>

=cut

__PACKAGE__->belongs_to(
  "home_doubles_pair",
  "TopTable::Schema::Result::DoublesPair",
  { id => "home_doubles_pair" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 home_player

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "home_player",
  "TopTable::Schema::Result::Person",
  { id => "home_player" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 individual_match_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateMatchIndividual>

=cut

__PACKAGE__->belongs_to(
  "individual_match_template",
  "TopTable::Schema::Result::TemplateMatchIndividual",
  { id => "individual_match_template" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 team_match

Type: belongs_to

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->belongs_to(
  "team_match",
  "TopTable::Schema::Result::TeamMatch",
  {
    away_team      => "away_team",
    home_team      => "home_team",
    scheduled_date => "scheduled_date",
  },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 team_match_legs

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchLeg>

=cut

__PACKAGE__->has_many(
  "team_match_legs",
  "TopTable::Schema::Result::TeamMatchLeg",
  {
    "foreign.away_team"             => "self.away_team",
    "foreign.home_team"             => "self.home_team",
    "foreign.scheduled_date"        => "self.scheduled_date",
    "foreign.scheduled_game_number" => "self.scheduled_game_number",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 umpire

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "umpire",
  "TopTable::Schema::Result::Person",
  { id => "umpire" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 winner

Type: belongs_to

Related object: L<TopTable::Schema::Result::Team>

=cut

__PACKAGE__->belongs_to(
  "winner",
  "TopTable::Schema::Result::Team",
  { id => "winner" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-05-12 10:08:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8+qndEG8ts9/aQHMTH5pGQ

use HTML::Entities;

=head2 started

Determine from the first leg whether or not the game was started

=cut

sub started {
  my ( $self ) = @_;
  
  my $leg1 = $self->find_related("team_match_legs", {leg_number => 1});
  return $leg1->started ? 1 : 0;
}

=head2 player_missing

Determine whether there's at least one player missing.

=cut

sub player_missing {
  my ( $self ) = @_;
  
  if ( $self->doubles_game ) {
    return undef;
  } else {
    return $self->home_player_missing || $self->away_player_missing ? 1 : 0;
    
  }
}

=head2 both_players_set

Return 1 if both players are set in the database, otherwise 0.

=cut

sub both_players_set {
  my ( $self ) = @_;
  
  # Set the player objects according to whether it's a doubles game or not
  my ( $home_player, $away_player ) = $self->doubles_game
    ? ( $self->home_doubles_pair, $self->away_doubles_pair )
    : ( $self->team_match->find_related("team_match_players", {player_number => $self->home_player_number})->player, $self->team_match->find_related("team_match_players", {player_number => $self->away_player_number})->player );
  
  # Now check we have both
  return ( defined($home_player) and defined($away_player) ) ? 1 : 0;
}

=head2 get_player_from_number

Get the home player from the numbered home player in this game.  Useful if the one of the players is missing, in which case (depending on the settings), the other one won't be set in the home / away player field.

=cut


sub get_player_from_match_number {
  my ( $self, $params ) = @_;
  
  return undef if $self->doubles_game;
  
  my $location = $params->{location};
  my $location_fld = sprintf("%s_player_number", $location);
  my $match_player = $self->team_match->find_related("team_match_players", {player_number => $self->$location_fld});
  return defined($match_player) ? $match_player->player : undef;
}

=head2 singles_player_membership_type

'location' must be passed in and must be "home" or "away", otherwise undef is returned.

Return either "active", "loan" or "inactive", depending on the player's team membership status.  Loan is returned if the player was playing on loan at the time the match was played, which means they could have later become an active member of the team.

=cut

sub singles_player_membership_type {
  my ( $self, $params ) = @_;
  my $location = $params->{location} || "";
  return undef unless $location eq "home" or $location eq "away";
  
  if ( $self->doubles_game ) {
    return undef;
  } else {
    my ( $player_field, $team_field, $player_number_field ) = $location eq "home"
      ? qw( home_player home_team home_player_number )
      : qw( away_player away_team away_player_number );
    
    if ( defined($self->$player_field) ) {
      if ( defined($self->team_match->find_related("team_match_players", {player_number => $self->$player_number_field})->loan_team) ) {
        # Loan
        return "loan";
      } else {
        # Not a loan player at the time the match was played, check current membership type
        my $match = $self->team_match;
        my $person_season = $self->$player_field->find_related("person_seasons", {season => $match->season->id, team => $match->$team_field});
        
        if ( defined($person_season) ) {
          # Just return the membership type, this will be either "active" or "inactive" (it shouldn't be loan, as we have already checked this above -
          # if they weren't a loan player at the time, they won't be now)
          return $person_season->team_membership_type->id;
        } else {
          # We shouldn't get here, there should always be a person season for this person / season / team if the player is set for that team in a match
          return undef;
        }
      }
    } else {
      # No player set for this game
      return undef;
    }
  }
}

=head2 doubles_player_membership_type

'location' must be passed in and must be "home" or "away"; person must be passed in either as a valid Person object, or an identifying id or url_key for a person.

Return either "active", "loan" or "inactive", depending on the player's team membership status.  Loan is returned if the player was playing on loan at the time the match was played, which means they could have later become an active member of the team.

=cut

sub doubles_player_membership_type {
  my ( $self, $params ) = @_;
  my $location = $params->{location} || "";
  my $person = $params->{person} || undef;
  
  # Ensure we have the right values passed in
  return undef unless $location eq "home" or $location eq "away";
  
  # Check the person is valid
  if ( defined($person) ) {
    $person = $self->result_source->schema->resultset("Person")->find_id_or_url_key($person) unless ref($person) eq "TopTable::Model::DB::Person";
    
    if ( !defined($person) ) {
      # Not valid.
      return undef;
    }
  } else {
    # Person not valid, return undef
    return undef;
  }
  
  if ( $self->doubles_game ) {
    my ( $players_field, $team_field ) = $location eq "home"
      ? qw( home_doubles_pair home_team )
      : qw( away_doubles_pair away_team );
    
    if ( defined($self->$players_field) ) {
      # Get the person ID from the position we're at
      if ( $self->$players_field->person1 != $person->id && $self->$players_field->person2 != $person->id ) {
        # Player is not in this doubles game
        return undef;
      }
      
      my $player = $self->team_match->find_related("team_match_players", {player => $person->id});
      if ( defined($player) and defined($player->loan_team) ) {
        # Loan
        return "loan";
      } else {
        # Not a loan player at the time the match was played, check current membership type
        my $match = $self->team_match;
        my $person_season = $person->find_related("person_seasons", {season => $match->season->id, team => $match->$team_field});
        
        if ( defined($person_season) ) {
          # Just return the membership type, this will be either "active" or "inactive" (it shouldn't be loan, as we have already checked this above -
          # if they weren't a loan player at the time, they won't be now)
          return $person_season->team_membership_type->id;
        } else {
          # We shouldn't get here, there should always be a person season for this person / season / team if the player is set for that team in a match
          return undef;
        }
      }
    } else {
      # No doubles pair set here
      return undef;
    }
  } else {
    # Not a doubles game
    return undef;
  }
}

=head2 noindex_set

Return 1 if one of the people playing are set to noindex, or 0 if no one is.

=cut

sub noindex_set {
  my ( $self ) = @_;
  
  if ( $self->doubles_game ) {
    # Doubles game, check all the doubles pairs
    return ($self->home_doubles_pair->person_season_person1_season_team->person->noindex
      || $self->home_doubles_pair->person_season_person2_season_team->person->noindex
      || $self->away_doubles_pair->person_season_person1_season_team->person->noindex
      || $self->away_doubles_pair->person_season_person2_season_team->person->noindex)
    ? 1 : 0;
  } else {
    # Singles game, check the home and away players
    # Definedness accounts for games with missing players
    return (defined($self->home_player) && $self->home_player->noindex)
      || (defined($self->away_player) && $self->away_player->noindex)
    ? 1 : 0;
  }
}

=head2 update_score

Update the scores for this game.

=cut

sub update_score {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Get the fields and setup the response hash
  my $match = $self->team_match;
  my $season_home_team = $match->team_season_home_team_season;
  my $season_away_team = $match->team_season_away_team_season;
  my $home_team = $season_home_team->team;
  my $away_team = $season_away_team->team;
  my $season = $match->season;
  my ( $home_player, $away_player ) = $self->doubles_game ? ( $self->home_doubles_pair, $self->away_doubles_pair ) : ( $self->home_player, $self->away_player );
  my $awarded = $params->{awarded} || 0;
  my $awarded_winner = $params->{winner} || undef; # Only used if it's been awarded
  my $delete = $params->{delete} || 0;
  my $new_player_location = $params->{new_player};
  my $remove_missing = $params->{remove_missing} || 0; # If update_person called this with a delete flag, remove any player missing flags
  my ( $home_player_missing, $away_player_missing ) = qw( 0 0 );
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  #$logger->("debug", sprintf("Updating game %d; params:", $self->scheduled_game_number));
  #$logger->("debug", np($params));
  
  # Get our season forefeit / void settings
  my $void_unplayed_games_if_both_teams_incomplete = $season->void_unplayed_games_if_both_teams_incomplete;
  my $forefeit_count_averages_if_game_not_started = $season->forefeit_count_averages_if_game_not_started;
  my $missing_player_count_win_in_averages = $season->missing_player_count_win_in_averages;
  
  #$logger->("debug", "Settings: void_unplayed_games_if_both_teams_incomplete: $void_unplayed_games_if_both_teams_incomplete, forefeit_count_averages_if_game_not_started: $forefeit_count_averages_if_game_not_started, missing_player_count_win_in_averages: $missing_player_count_win_in_averages");
  
  # First check the match wasn't cancelled; if it was, we return straight away
  if ( $match->cancelled ) {
    push(@{$response->{errors}}, $lang->maketext("matches.update.error.match-cancelled"));
    return $response;
  }
  
  # These are needed further down when updating matches played for the player as well as for error checking, so need to be declared here.
  my ( $match_home_player, $match_away_player ) = @_;
  
  # Store the template rules
  my $game_rules = $self->individual_match_template;
  
  if ( $self->doubles_game ) {
    # Doubles game - validate that the doubles pair have been entered
    if ( !defined($home_player) or !defined($away_player) ) {
      push(@{$response->{errors}}, $lang->maketext("matches.game.update-score.doubles.error.select-players"));
      return $response;
    }
  } else {
    # Singles game - ensure there are players entered
    # Get the team match players object so that we can update all of them with another match played if this is the first game played
    $match_home_player = $match->find_related("team_match_players", {
      player_number => $self->home_player_number,
      location => "home",
    });
    
    $match_away_player = $match->find_related("team_match_players", {
      player_number => $self->away_player_number,
      location => "away",
    });
    
    # If a player has been set as missing, then it'll already be set in the match player table (not necessarily this table - the game table - this is how we know
    # whether or not to update games played / won statistics - if the player is missing in the player record, but not here, it's been newly set as missing and
    # stats need updating).
    # If we're deleting and the remove_missing flag is set, we need to set it manually as 0; the player will be removed by the update_person routine in the TeamMatchPlayer
    # class (which is what called this)
    $home_player_missing = ($delete and defined($remove_missing) and $remove_missing eq "home") ? 0 : $match_home_player->player_missing;
    $away_player_missing = ($delete and defined($remove_missing) and $remove_missing eq "away") ? 0 : $match_away_player->player_missing;
    #$logger->("debug", "flags: delete: $delete, remove missing: $remove_missing, home missing: $home_player_missing, away missing: $away_player_missing");
    
    if ( !defined($home_player) or !defined($away_player) ) {
      unless ( $delete or $home_player_missing or $away_player_missing ) {
        push(@{$response->{errors}}, $lang->maketext("matches.game.update-score.singles.error.select-players"));
        return $response;
      }
    }
  }
  
  # Get the number of legs required to win the game
  my $legs_required_to_win;
  if ( $game_rules->game_type->id eq "best-of" ) {
    $legs_required_to_win = ( $game_rules->legs_per_game / 2 ) + 1; # Best of x legs - halve it and + 1
    $legs_required_to_win = int($legs_required_to_win); # Truncate any decimal placeas
  }
  
  # Work out if this match was completed / started already
  my $match_originally_complete = $match->complete;
  my $match_originally_started = $match->started;
  
  # If it was, work out who won and who lost
  my ( $original_home_team_score, $original_away_team_score );
  if ( $match_originally_complete ) {
    $original_home_team_score = $match->home_team_match_score;
    $original_away_team_score = $match->away_team_match_score;
  }
  
  # Get all the original values for this game
  my $game_originally_started = $self->started;
  my $game_originally_complete = $self->complete;
  my $game_originally_awarded = $self->awarded;
  my $game_originally_void = $self->void;
  my $game_original_home_team_score = $self->home_team_legs_won;
  my $game_original_away_team_score = $self->away_team_legs_won;
  my $game_original_home_team_points = $self->home_team_points_won;
  my $game_original_away_team_points = $self->away_team_points_won;
  my $home_originally_missing = $self->home_player_missing;
  my $away_originally_missing = $self->away_player_missing;
  my $game_original_winner = defined($self->winner) ? $self->winner->id : undef;
  
  # Originally set, so we can increase games played / won for a newly set player, if the opposition is marked missing
  # (if they were marked missing after we set this player, then it doesn't matter, the games will be updated then anyway)
  my ( $home_originally_set, $away_originally_set );
  
  if ( $delete and !$game_originally_complete ) {
    # Deleting a score that hasn't been entered - nothing to do, so just return success
    $response->{completed} = 1;
    $response->{match_scores} = $match->calculate_match_score;
    push(@{$response->{success}}, $lang->maketext("matches.game.update-score.success-game-reset"));
    return $response;
  }
  
  # These values will hold the new cumulative legs / points scores
  my ( $home_team_points, $away_team_points, $winner_legs, $legs_played ) = qw( 0 0 0 0 );
  
  # Now loop through the legs and make sure we have a valid score
  my $game_winner;
  my %game_scores = ();
  my $legs = $self->team_match_legs;
  
  # Default to not void and not awarded
  my ( $home_legs, $away_legs, $void ) = qw( 0 0 0 );
  my $game_started = 0; # Flag for whether the game's started - if not and it's been awarded, we won't update any averages (unless the season setting forefeit_count_averages_if_game_not_started is set)
  my $game_finished = 0; # Flag (when the game's been awarded) to notify us the game's finished even if the score doesn't look complete.
  while ( my $leg = $legs->next ) {
    my $leg_number = $leg->leg_number;
    
    # Home / away score MUST be zero if we're deleting, so we will force them to be if this flag is set.
    # Otherwise, get them from the passed params (i.e., {"leg1-home" => 11, "leg1-away => 7"})
    my ( $home_score, $away_score ) = ( $delete or $home_player_missing or $away_player_missing ) ? qw( 0 0 ) : ( $params->{sprintf("leg%d-home", $leg->leg_number)} || 0, $params->{sprintf("leg%d-away", $leg->leg_number)} || 0 );
    my ( $winning_score, $losing_score ) = qw( 0 0 );
    my $winner;
    
    # If we have a true value in either of these, assume the game has started (we'll be error checking later on anyway).
    # If the game was started, the averages are updated even if it was awarded because of an early retirement.  If the game
    # wasn't started (because someone pulled out), there are no averages to update, even if there's a player set in that position,
    # unless the season setting forefeit_count_averages_if_game_not_started is turned on.
    $game_started = 1 if ( $home_score or $away_score ) and !$delete;
    
    # Work out if the required number of legs have been won / have completed
    if ( $delete ) {
      # Delete the score
      $game_scores{"leg_$leg_number"} = {
        leg_object => $leg,
        home_score => 0,
        away_score => 0,
        started => 0,
        complete => 0,
        winner => undef,
        void => 0,
        awarded => 0,
        original_home_score => $leg->home_team_points_won,
        original_away_score => $leg->away_team_points_won,
        originally_awarded => $leg->awarded,
      };
    } elsif ( !$self->doubles_game and ( $home_player_missing or $away_player_missing ) ) {
      # There's a player missing, so the game has to be awarded (or voided if both are missing)
      if ( $home_player_missing and $away_player_missing ) {
        # Both players missing, game is void
        undef($winner);
        undef($game_winner);
        $awarded = 0;
        $void = 1;
        #$logger->("debug", sprintf("game %s, both players missing, void", $self->scheduled_game_number));
      } elsif ( $season->void_unplayed_games_if_both_teams_incomplete and (( $home_player_missing and $match->away_players_absent ) or ( $away_player_missing and $match->home_players_absent )) ) {
        # One player missing, but the opposing team has another player missing (not in this game), and we're set to void unplayed games if both teams have players missing so we void
        undef($winner);
        undef($game_winner);
        $awarded = 0;
        $void = 1;
        #$logger->("debug", sprintf("game %s, one player missing, but opposition team also has missing players, void", $self->scheduled_game_number));
      } elsif ( $home_player_missing ) {
        # Home player missing, award to away team
        $game_winner = $away_team->id;
        $winner = $away_team->id;
        $awarded = 1;
        $void = 0;
        #$logger->("debug", sprintf("game %s, home missing, award to away team", $self->scheduled_game_number));
      } else {
        # Away player missing, award to home team
        $game_winner = $home_team->id;
        $winner = $home_team->id;
        $awarded = 1;
        $void = 0;
        #$logger->("debug", sprintf("game %s, home missing, award to home team", $self->scheduled_game_number));
      }
      
      $game_scores{"leg_$leg_number"} = {
        leg_object => $leg,
        home_score => 0,
        away_score => 0,
        started => 0,
        complete => 1,
        winner => $winner,
        awarded => $awarded,
        void => $void,
        original_home_score => $leg->home_team_points_won,
        original_away_score => $leg->away_team_points_won,
        originally_awarded => $leg->awarded,
      };
    } elsif ( $game_finished ) {
      # Finished flag has been set (the game was awarded); disregard the rest of the data passed and set the scores as zero
      $game_scores{"leg_$leg_number"} = {
        leg_object => $leg,
        home_score => 0,
        away_score => 0,
        winner => undef,
        started => 0,
        complete => 0,
        awarded => 0,
        void => 0,
        original_home_score => $leg->home_team_points_won,
        original_away_score => $leg->away_team_points_won,
        originally_awarded => $leg->awarded,
      };
    } else {
      if ( ( defined($legs_required_to_win) && $winner_legs < $legs_required_to_win) || ( !defined($legs_required_to_win) && $legs_played < $game_rules->legs_per_game) ) {
        # There are still legs to play
        # Check the scores are numeric and more than zero
        if ( $home_score !~ m/^\d+$/ or $home_score < 0 or $away_score !~ m/^\d+$/ or $away_score < 0 ) {
          push(@{$response->{errors}}, $lang->maketext("matches.game.update-score.error.home-not-numeric-or-less-than-zero", $leg_number))
              if $home_score !~ m/^\d+$/ or $home_score < 0;
          push(@{$response->{errors}}, $lang->maketext("matches.game.update-score.error.away-not-numeric-or-less-than-zero", $leg_number))
              if $away_score !~ m/^\d+$/ or $away_score < 0;
        } else {
          # Add the to points totals
          $home_team_points += $home_score;
          $away_team_points += $away_score;
          
          # Leg not forefeited 
          # Check the scores are not equal
          if ( $home_score == $away_score and !$awarded ) {
            push(@{$response->{errors}}, $lang->maketext("matches.game.update-score.error.home-and-away-scores-equal", $leg_number));
          } else {
            # Check who's got the higher score
            if ( $home_score > $away_score ) {
              # The current winner is the home team
              $winner = $home_team->id;
              $winning_score = $home_score;
              $losing_score = $away_score;
            } else {
              # The current winner is the away team
              $winner = $away_team->id;
              $winning_score = $away_score;
              $losing_score = $home_score;
            }
            
            my $clear_points = $winning_score - $losing_score;
            
            # Now we have all the information, we can check if the score itself is valid - we either need:
            #   * The winner to have exactly the right number of points for a win and the points difference to be greater than or equal to the minimum points difference required for a win
            #   * The winner to have more than the number of points required for a win and the points difference to be exactly equal to the minimum points difference required for a win  
            if ( ($winning_score == $game_rules->minimum_points_win && $clear_points >= $game_rules->clear_points_win) || ($winning_score > $game_rules->minimum_points_win && $clear_points == $game_rules->clear_points_win) ) {
              # The win is valid
              # Increment the correct player's legs won count and set the $winner_legs, which for convenience holds the winner of the current leg's total legs won count
              if ( $winner eq $home_team->id ) {
                $home_legs++;
                $winner_legs = $home_legs;
              } else {
                $away_legs++;
                $winner_legs = $away_legs;
              }
              
              # See if we've now reached the required number of legs - if so, the winner of this leg is the winner of the game
              if ( defined($legs_required_to_win) && $winner_legs == $legs_required_to_win) {
                # If we've reached the end of the game because the winner has won the required number of legs, the winner of the last leg must have won the game
                $game_winner = $winner;
              } elsif ( !defined($legs_required_to_win) && $legs_played < $game_rules->legs_per_game ) {
                # If we play a static number of games, we need to work out the winner (if there is one)
                if ( $home_legs > $away_legs ) {
                  $game_winner = $home_team->id;
                } elsif ( $home_legs < $away_legs ) {
                  $game_winner = $away_team->id;
                } else {
                  undef($game_winner);
                }
              }
              
              # Get the total legs played
              $legs_played = $home_legs + $away_legs;
              
              # Now store all this information into the $game_scores hash
              $game_scores{"leg_$leg_number"} = {
                leg_object => $leg,
                home_score => $home_score,
                away_score => $away_score,
                winner => $winner,
                started => 1,
                complete => 1,
                awarded => 0,
                void => 0,
                original_home_score => $leg->home_team_points_won,
                original_away_score => $leg->away_team_points_won,
              };
            } elsif ( $awarded and $awarded_winner eq "home" or $awarded_winner eq "away" ) {
              # The game was awarded - work out who to award it to and increase the number of legs if the game was started
              if ( $awarded_winner eq "home" ) {
                $winner = $home_team->id;
                $home_legs++ if $game_started and ( $home_score or $away_score );
              } else {
                $winner = $away_team->id;
                $away_legs++ if $game_started and ( $home_score or $away_score );
              }
              
              
              $winner = $awarded_winner eq "home" ? $home_team->id : $away_team->id;
              $game_winner = $winner;
              
              $game_scores{"leg_$leg_number"} = {
                leg_object => $leg,
                home_score => $home_score,
                away_score => $away_score,
                winner => $winner,
                started => $game_started,
                complete => 1,
                awarded => 1,
                void => 0,
                original_home_score => $leg->home_team_points_won,
                original_away_score => $leg->away_team_points_won,
              };
              
              # Set the finished flag
              $game_finished = 1;
            } else {
              # The score is not valid
              push(@{$response->{errors}}, $lang->maketext("matches.game.update-score.error.score-invalid", $leg_number, $home_score, $away_score, $game_rules->minimum_points_win, $game_rules->clear_points_win));
            }
          }
        }
      } else {
        # We've already reached the right number of games; disregard the rest of the data passed and set the scores as zero
        $game_scores{"leg_$leg_number"} = {
          leg_object => $leg,
          home_score => 0,
          away_score => 0,
          winner => undef,
          started => 0,
          complete => 0,
          awarded => 0,
          void => 0,
          original_home_score => $leg->home_team_points_won,
          original_away_score => $leg->away_team_points_won,
        };
      }
    }
  }
  
  unless ( $delete or $home_player_missing or $away_player_missing or $awarded ) {
    # Make sure we properly finished the game with a winner
    # Error if the required number of games have not been played
    push(@{$response->{errors}}, $lang->maketext("matches.game.update-score.error.score-incomplete", $self->scheduled_game_number))
        if ( defined($legs_required_to_win) && $winner_legs < $legs_required_to_win) || ( !defined($legs_required_to_win) && $legs_played < $game_rules->legs_per_game);
  }
  
  # Don't go any further if we've had an error
  return $response if scalar @{$response->{errors}};
  
  ### ERROR CHECKING FINISHED ###
  #### TRANSACTIONS: LOOK AT https://metacpan.org/dist/DBIx-Class/view/lib/DBIx/Class/ResultSource.pm#schema (schema object has txn_scope_guard)
  # https://metacpan.org/pod/DBIx::Class::Storage::TxnScopeGuard
  # Also see https://metacpan.org/dist/DBIx-Class/view/lib/DBIx/Class/Row.pm#result_source to get the result source, if it's a row object
  # Set up the transaction - we'll only write to the database if there are NO errors
  my $transaction = $schema->txn_scope_guard;
  
  # Now we've looped through and checked our legs, we need to update them
  # Update our legs
  foreach my $update_leg ( keys %game_scores ) {
    $game_scores{$update_leg}{leg_object}->update({
      home_team_points_won => $game_scores{$update_leg}{home_score},
      away_team_points_won => $game_scores{$update_leg}{away_score},
      winner => $game_scores{$update_leg}{winner},
      awarded => $game_scores{$update_leg}{awarded},
      void => $game_scores{$update_leg}{void},
      started => $game_scores{$update_leg}{started},
      complete => $game_scores{$update_leg}{complete},
    });
  }
  
  # Update the game
  my $complete = $delete ? 0 : 1;
  
  $self->update({
    home_team_legs_won => $home_legs,
    home_team_points_won => $home_team_points,
    away_team_legs_won => $away_legs,
    away_team_points_won => $away_team_points,
    winner => $game_winner,
    awarded => $awarded,
    void => $void,
    started => $game_started,
    complete => $complete,
    home_player_missing => $home_player_missing,
    away_player_missing => $away_player_missing,
  });
  
  # Update the match
  my $match_scores = $match->calculate_match_score;
  my $match_started = $match->check_match_started;
  my $match_complete = $match->check_match_complete;
  
  # Loop through our returned array (in reverse) to get the final match score; the first game we come across with a match score, we'll break out
  my ( $current_home_match_score, $current_away_match_score, $current_games_drawn );
  
  foreach my $game_index ( reverse 0 .. $#{$match_scores} ) {
    if ( $match_scores->[$game_index]{home_won} || $match_scores->[$game_index]{away_won} ) {
      $current_home_match_score = $match_scores->[$game_index]{home_won};
      $current_away_match_score = $match_scores->[$game_index]{away_won};
      $current_games_drawn = $match_scores->[$game_index]{drawn};
      last;
    }
  }
  
  # Deal with the first score in the match being deleted, which means we will have undefined (null) values here,
  # when they should be zero.
  $current_home_match_score = 0 unless defined($current_home_match_score);
  $current_away_match_score = 0 unless defined($current_away_match_score);
  $current_games_drawn = 0 unless defined($current_games_drawn);
  
  # Work out the number of legs / points in this match now.  Because we could be editing a previously filled out scorecard, we need to do some maths:
  #   * Take the original value from the $match db object.
  #   * Subtract the original game score / points that we took from the game before we updated it
  #   * Add the new game score / points that we've updated the game with.
  # Remember that:
  #   * In a match, the number of legs is termed as the score in a game (i.e., 3-1).
  #   * In a match / game, the number of points is termed as the score in a leg (i.e., 11-7).
  my $match_home_team_legs_won = ( $match->home_team_legs_won - $game_original_home_team_score ) + $home_legs;
  my $match_away_team_legs_won = ( $match->away_team_legs_won - $game_original_away_team_score ) + $away_legs;
  my $match_home_team_points_won = ( $match->home_team_points_won - $game_original_home_team_points ) + $home_team_points;
  my $match_away_team_points_won = ( $match->away_team_points_won - $game_original_away_team_points ) + $away_team_points;
  
  # Get the ranking rules
  my $ranking_template = $match->division_season->league_table_ranking_template;
  
  my $assign_points = $ranking_template->assign_points;
  my $points_per_win = $ranking_template->points_per_win;
  my $points_per_draw = $ranking_template->points_per_draw;
  my $points_per_loss = $ranking_template->points_per_loss;
  my ( $home_points_adjustment, $away_points_adjustment ) = qw( 0 0 );
  
  # If the match was originally complete or is now complete, we may need to change the number of matches won, lost or drawn for each team
  my $match_original_winner = "";
  my $match_new_winner = "";
  if ( $match_originally_complete ) {
    # If the match was originally complete, we need to check if the winner has changed
    # Get the original winner
    if ( $original_home_team_score > $original_away_team_score ) {
      $match_original_winner = "home";
    } elsif ( $original_away_team_score > $original_home_team_score ) {
      $match_original_winner = "away";
    } else {
      # Equal scores: draw
      $match_original_winner = "draw";
    }
  }
  
  if ( $match_complete ) {
    # To work out who's won, we need to know which value we're checking by the winner type
    if ( $current_home_match_score > $current_away_match_score ) {
      $match_new_winner = "home";
    } elsif ( $current_away_match_score > $current_home_match_score ) {
      $match_new_winner = "away";
    } else {
      # Equal scores: draw
      $match_new_winner = "draw";
    }
  }
  
  # Score adjustments for matches / games played / won / lost / drawn.  Should be -1, 0 or 1 to take 1, make no adjustment or add 1 to that value
  my %matches_adjustments = (
    home => {
      matches_played => 0,
      matches_won => 0,
      matches_drawn => 0,
      matches_lost => 0,
    }, away => {
      matches_played => 0,
      matches_won => 0,
      matches_drawn => 0,
      matches_lost => 0,
    },
  );
  
  my %team_games_adjustments = (
    home => {
      games_played => 0,
      games_won => 0,
      games_lost => 0,
      games_drawn => 0,
    }, away => {
      games_played => 0,
      games_won => 0,
      games_lost => 0,
      games_drawn => 0,
    },
  );
  
  my %player_games_adjustments = (
    home => {
      games_played => 0,
      games_won => 0,
      games_lost => 0,
      games_drawn => 0,
    }, away => {
      games_played => 0,
      games_won => 0,
      games_lost => 0,
      games_drawn => 0,
    },
  );
  
  # Work out the score adjustments for matches
  if ( $match_originally_started and !$match_started ) {
    # If we're deleting the only score we have in this match, the match will revert to not having been started
    # yet and therefore we'll remove one from matches_played
    $matches_adjustments{home}{matches_played} = -1;
    $matches_adjustments{away}{matches_played} = -1;
  } elsif ( !$match_originally_started and $match_started ) {
    # If we're adding the first score, we need to add one to matches played
    $matches_adjustments{home}{matches_played} = 1;
    $matches_adjustments{away}{matches_played} = 1;
  }
  
  if ( ( $match_original_winner or $match_new_winner ) and ( $match_original_winner ne $match_new_winner ) ) {
    # Either the match was originally complete, or it is now and the winner has changed.
    if ( $match_original_winner eq "home" ) {
      # Home team won originally
      if ( $match_new_winner eq "away" ) {
        # Home team originally won, away team has now won
        $matches_adjustments{home}{matches_won} = -1;
        $matches_adjustments{home}{matches_lost} = 1;
        $matches_adjustments{away}{matches_won} = 1;
        $matches_adjustments{away}{matches_lost} = -1;
        
        # If we need to assign points, we add the number of points the home team get for losing, then
        # take off the points they originally had for winning (which should come to a minus figure)
        # and vice versa for away.
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_loss - $points_per_win;
          $away_points_adjustment = $points_per_win - $points_per_loss;
        }
      } elsif ( $match_new_winner eq "draw" ) {
        # Home team originally won, now a draw
        $matches_adjustments{home}{matches_won} = -1;
        $matches_adjustments{home}{matches_drawn} = 1;
        $matches_adjustments{away}{matches_drawn} = 1;
        $matches_adjustments{away}{matches_lost} = -1;
        
        # If we need to assign points, we add the number of points the home and away teams get for drawing,
        # then take off the points the home team originally had for winning and the away team had for losing
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_draw - $points_per_win;
          $away_points_adjustment = $points_per_draw - $points_per_loss;
        }
      } elsif ( $match_new_winner eq "" ) {
        # Home team originally won, now not complete
        $matches_adjustments{home}{matches_won} = -1;
        $matches_adjustments{away}{matches_lost} = -1;
        
        # If we need to assign points, we just need to take off the points each team got originally, since the match
        # is now not complete.
        if ( $assign_points ) {
          $home_points_adjustment -= $points_per_win;
          $away_points_adjustment -= $points_per_loss;
        }
      }
    } elsif ( $match_original_winner eq "away" ) {
      # Away team won originally
      if ( $match_new_winner eq "home" ) {
        # Away team originally won, home team has now won
        $matches_adjustments{home}{matches_won} = 1;
        $matches_adjustments{home}{matches_lost} = -1;
        $matches_adjustments{away}{matches_won} = -1;
        $matches_adjustments{away}{matches_lost} = 1;
        
        # If we need to assign points, we add the number of points the home team get for winning, then
        # take off the points they originally had for losing and vice versa for away.
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_win - $points_per_loss;
          $away_points_adjustment = $points_per_loss - $points_per_win;
        }
      } elsif ( $match_new_winner eq "draw" ) {
        # Away team originally won, now a draw
        $matches_adjustments{home}{matches_drawn} = 1;
        $matches_adjustments{home}{matches_lost} = -1;
        $matches_adjustments{away}{matches_won} = -1;
        $matches_adjustments{away}{matches_drawn} = 1;
        
        # If we need to assign points, we add the number of points the home and away teams get for drawing,
        # then take off the points the home team originally had for winning and the away team had for losing
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_draw - $points_per_loss;
          $away_points_adjustment = $points_per_draw - $points_per_win;
        }
      } elsif ( $match_new_winner eq "" ) {
        # Away team originally won, now not complete
        $matches_adjustments{home}{matches_lost} = -1;
        $matches_adjustments{away}{matches_won} = -1;
        
        # If we need to assign points, we just need to take off the points each team got originally, since the match
        # is now not complete.
        if ( $assign_points ) {
          $home_points_adjustment -= $points_per_loss;
          $away_points_adjustment -= $points_per_win;
        }
      }
    } elsif ( $match_original_winner eq "draw" ) {
      # Originally a draw
      if ( $match_new_winner eq "home" ) {
        # Originally a draw, now a home win
        $matches_adjustments{home}{matches_won} = 1;
        $matches_adjustments{home}{matches_drawn} = -1;
        $matches_adjustments{away}{matches_drawn} = -1;
        $matches_adjustments{away}{matches_lost} = 1;
        
        # If we need to assign points, we add the number of points the home team get for winning, then
        # take off the points they originally had for drawing and vice versa for away.
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_win - $points_per_draw;
          $away_points_adjustment = $points_per_loss - $points_per_draw;
        }
      } elsif ( $match_new_winner eq "away" ) {
        # Originally a draw, now an away win
        $matches_adjustments{home}{matches_drawn} = -1;
        $matches_adjustments{home}{matches_lost} = 1;
        $matches_adjustments{away}{matches_won} = 1;
        $matches_adjustments{away}{matches_drawn} = -1;
        
        # If we need to assign points, we add the number of points the home team get for winning, then
        # take off the points they originally had for drawing and vice versa for away.
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_loss - $points_per_draw;
          $away_points_adjustment = $points_per_win - $points_per_draw;
        }
      } elsif ( $match_new_winner eq "" ) {
        # Originally a draw, now not complete
        $matches_adjustments{home}{matches_drawn} = -1;
        $matches_adjustments{away}{matches_drawn} = -1;
        
        # If we need to assign points, we just take off the number of points each team got for drawing
        if ( $assign_points ) {
          $home_points_adjustment -= $points_per_draw;
          $away_points_adjustment -= $points_per_draw;
        }
      }
    } elsif ( $match_original_winner eq "" ) {
      # Not originally complete
      if ( $match_new_winner eq "home" ) {
        # Originally incomplete, now a home win
        $matches_adjustments{home}{matches_won} = 1;
        $matches_adjustments{away}{matches_lost} = 1;
        
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_win;
          $away_points_adjustment = $points_per_loss;
        }
      } elsif ( $match_new_winner eq "away" ) {
        # Originally incomplete, now an away win
        $matches_adjustments{home}{matches_lost} = 1;
        $matches_adjustments{away}{matches_won} = 1;
        
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_loss;
          $away_points_adjustment = $points_per_win;
        }
      } else {
        # Originally incomplete, now a draw
        $matches_adjustments{home}{matches_drawn} = 1;
        $matches_adjustments{away}{matches_drawn} = 1;
        
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_draw;
          $away_points_adjustment = $points_per_draw;
        }
      }
    }
  }
  
  # Work out the team score adjustments for games
  if ( $game_originally_complete and !$game_originally_void ) {
    # Game was originally complete and not void
    if ( $complete and !$void ) {
      # The game is still complete, need to check if the winner has changed.  No change to games played.
      if ( defined($game_winner) ) {
        # Not a draw, we have a winner
        if ( defined($game_original_winner) ) {
          # Not previously a draw, someone must have won before
          if ( $game_winner != $game_original_winner ) {
            # Winner has changed (there is no 'else' statement to this because if the winner hasn't changed, there are no game fields to alter)
            if ( $game_winner == $home_team->id ) {
              # Home team now won, away team must have previously won
              $team_games_adjustments{home}{games_won} = 1;
              $team_games_adjustments{away}{games_lost} = 1;
              $team_games_adjustments{home}{games_lost} = -1;
              $team_games_adjustments{away}{games_won} = -1;
            } else {
              # Away team now won, home team must have previously won
              $team_games_adjustments{home}{games_won} = -1;
              $team_games_adjustments{away}{games_lost} = -1;
              $team_games_adjustments{home}{games_lost} = 1;
              $team_games_adjustments{away}{games_won} = 1;
            }
          }
        } else {
          # Previously a draw, remove one from games drawn for both and then check who's won
          $team_games_adjustments{home}{games_drawn} = -1;
          $team_games_adjustments{away}{games_drawn} = -1;
          
          if ( $game_winner == $home_team->id ) {
            # Was a draw, now a home win
            $team_games_adjustments{home}{games_won} = 1;
            $team_games_adjustments{away}{games_lost} = 1;
          } else {
            # Was a draw, now an away win
            $team_games_adjustments{home}{games_lost} = 1;
            $team_games_adjustments{away}{games_won} = 1;
          }
        }
      } else {
        # The game was completed, isn't void and there's no winner; it must be a draw
        if ( defined($game_original_winner) ) {
          # Not previously a draw, someone must have won - there is no 'else' statement to this, because going from a draw to a draw doesn't need any adjustments
          $team_games_adjustments{home}{games_drawn} = 1;
          $team_games_adjustments{away}{games_drawn} = 1;
          
          if ( $game_original_winner == $home_team->id ) {
            # Was a home win, now a draw
            $team_games_adjustments{home}{games_won} = -1;
            $team_games_adjustments{away}{games_lost} = -1;
          } else {
            # Was an away win, now a draw
            $team_games_adjustments{home}{games_lost} = -1;
            $team_games_adjustments{away}{games_won} = -1;
          }
        }
      }
    } else {
      # We need to take one from games played, as it's either not complete or void
      $team_games_adjustments{home}{games_played} = -1;
      $team_games_adjustments{away}{games_played} = -1;
      
      if ( defined($game_original_winner) ) {
        if ( $game_original_winner == $home_team->id ) {
          # Was a home win
          $team_games_adjustments{home}{games_won} = -1;
          $team_games_adjustments{away}{games_lost} = -1;
        } else {
          # Was an away win
          $team_games_adjustments{home}{games_lost} = -1;
          $team_games_adjustments{away}{games_won} = -1;
        }
      } else {
        # If the game was completed and wasn't void and there was no winner, it must have been a draw
        $team_games_adjustments{home}{games_drawn} = -1;
        $team_games_adjustments{away}{games_drawn} = -1;
      }
    }
  } else {
    # Game was not originally complete, or was void, so this is a new score or a replacement for a void score, which will be all 0 anyway
    if ( $complete and !$void ) {
      # Game is now complete and not void (if it is void, we don't update any game counts)
      # Increase the games played for both teams
      $team_games_adjustments{home}{games_played} = 1;
      $team_games_adjustments{away}{games_played} = 1;
      
      if ( defined($game_winner) ) {
        if ( $game_winner == $home_team->id ) {
          # Home win
          $team_games_adjustments{home}{games_won} = 1;
          $team_games_adjustments{away}{games_lost} = 1;
        } else {
          # Away win
          $team_games_adjustments{home}{games_lost} = 1;
          $team_games_adjustments{away}{games_won} = 1;
        }
      } else {
        # If the game was completed and isn't void and there's no winner, it must be a draw
        $team_games_adjustments{home}{games_drawn} = 1;
        $team_games_adjustments{away}{games_drawn} = 1;
      }
    }
  }
  
  if ( $self->doubles_game ) {
    # Work out the team score adjustments for the doubles game, if it is one.  This has its own branch because it's more complex than the regular team games, which get updated whether
    # they're started or not (as long as they're not void), so we can't just slip a few if $self->doubles_games into those branches
    if ( $game_originally_started ) {
      # Game was originally started
      if ( $game_started ) {
        # The game has still been started, need to check if the winner has changed.  No change to games played.
        if ( defined($game_winner) ) {
          # Not a draw, we have a winner
          if ( defined($game_original_winner) ) {
            # Not previously a draw, someone must have won before
            if ( $game_winner != $game_original_winner ) {
              # Winner has changed (there is no 'else' statement to this because if the winner hasn't changed, there are no game fields to alter)
              if ( $game_winner == $home_team->id ) {
                # Home team now won, away team must have previously won
                $team_games_adjustments{home}{doubles_games_won} = 1;
                $team_games_adjustments{away}{doubles_games_lost} = 1;
                $team_games_adjustments{home}{doubles_games_lost} = -1;
                $team_games_adjustments{away}{doubles_games_won} = -1;
              } else {
                # Away team now won, home team must have previously won
                $team_games_adjustments{home}{doubles_games_won} = -1;
                $team_games_adjustments{away}{doubles_games_lost} = -1;
                $team_games_adjustments{home}{doubles_games_lost} = 1;
                $team_games_adjustments{away}{doubles_games_won} = 1;
              }
            }
          } else {
            # Previously a draw, remove one from games drawn for both and then check who's won
            $team_games_adjustments{home}{doubles_games_drawn} = -1;
            $team_games_adjustments{away}{doubles_games_drawn} = -1;
            
            if ( $game_winner == $home_team->id ) {
              # Was a draw, now a home win
              $team_games_adjustments{home}{doubles_games_won} = 1;
              $team_games_adjustments{away}{doubles_games_lost} = 1;
            } else {
              # Was a draw, now an away win
              $team_games_adjustments{home}{doubles_games_lost} = 1;
              $team_games_adjustments{away}{doubles_games_won} = 1;
            }
          }
        } else {
          # The game was completed, isn't void and there's no winner; it must be a draw
          if ( defined($game_original_winner) ) {
            # Not previously a draw, someone must have won - there is no 'else' statement to this, because going from a draw to a draw doesn't need any adjustments
            $team_games_adjustments{home}{doubles_games_drawn} = 1;
            $team_games_adjustments{away}{doubles_games_drawn} = 1;
            
            if ( $game_original_winner == $home_team->id ) {
              # Was a home win, now a draw
              $team_games_adjustments{home}{doubles_games_won} = -1;
              $team_games_adjustments{away}{doubles_games_lost} = -1;
            } else {
              # Was an away win, now a draw
              $team_games_adjustments{home}{doubles_games_lost} = -1;
              $team_games_adjustments{away}{doubles_games_won} = -1;
            }
          }
        }
      } else {
        # We need to take one from games played, as it's either not complete or void
        $team_games_adjustments{home}{doubles_games_played} = -1;
        $team_games_adjustments{away}{doubles_games_played} = -1;
        
        if ( defined($game_original_winner) ) {
          if ( $game_original_winner == $home_team->id ) {
            # Was a home win
            $team_games_adjustments{home}{doubles_games_won} = -1;
            $team_games_adjustments{away}{doubles_games_lost} = -1;
          } else {
            # Was an away win
            $team_games_adjustments{home}{doubles_games_lost} = -1;
            $team_games_adjustments{away}{doubles_games_won} = -1;
          }
        } else {
          # If the game was started and there was no winner, it must have been a draw
          $team_games_adjustments{home}{doubles_games_drawn} = -1;
          $team_games_adjustments{away}{doubles_games_drawn} = -1;
        }
      }
    } else {
      # Game was not originally started, so this is a new score or a replacement for a void score, which will be all 0 anyway
      if ( $game_started ) {
        # Game is now complete and not void (if it is void, we don't update any game counts)
        # Increase the games played for both teams
        $team_games_adjustments{home}{doubles_games_played} = 1;
        $team_games_adjustments{away}{doubles_games_played} = 1;
        
        if ( defined($game_winner) ) {
          if ( $game_winner == $home_team->id ) {
            # Home win
            $team_games_adjustments{home}{doubles_games_won} = 1;
            $team_games_adjustments{away}{doubles_games_lost} = 1;
          } else {
            # Away win
            $team_games_adjustments{home}{doubles_games_lost} = 1;
            $team_games_adjustments{away}{doubles_games_won} = 1;
          }
        } else {
          # If the game was completed and isn't void and there's no winner, it must be a draw
          $team_games_adjustments{home}{doubles_games_drawn} = 1;
          $team_games_adjustments{away}{doubles_games_drawn} = 1;
        }
      }
    }
  }
  
  # Player game adjustments use ++ / -- rather than assigning 1 or -1.  This is because we may add to one if a missing player has been updated, but then take it back off again depending
  # on the result.  In reality these are probably separate operations, but play safe.
  #$logger->("debug", "game: " . $self->scheduled_game_number . ", missing_player_count_win_in_averages: $missing_player_count_win_in_averages, home_player_missing: $home_player_missing, home_originally_missing: $home_originally_missing, away_player_missing: $away_player_missing, away_originally_missing: $away_originally_missing, void: $void, complete: $complete, game_originally_void: $game_originally_void, game_originally_complete: $game_originally_complete, delete: $delete");
  if ( ($missing_player_count_win_in_averages and ($home_player_missing or $away_player_missing or $home_originally_missing or $away_originally_missing)) ) {
    # Players missing logic - either there are players missing now, or there were previously
    # The check that this isn't a void game is just to ensure we're not updating stats for a void match (i.e. if both
    # players are missing, or one player is missing and the opposing team has another missing player)
    # This is only used if the missing_player_count_win_in_averages setting is on.
    # We only add to games won here, there are no people to update for games lost.
    #$logger->("debug", sprintf("game: %s - missing players count as a win in the averages, and there are (or were) players missing", $self->scheduled_game_number));
    if ( ($void or $delete) and (!$game_originally_void and $game_originally_complete) ) {
      # Void or delete a previously completed game
      #$logger->("debug", sprintf("game: %s - void or delete, but was originally complete and not void", $self->scheduled_game_number));
      if ( $home_originally_missing and $away_originally_missing ) {
        # Nothing to do - voiding / deleting when the score would have already been void
        #$logger->("debug", sprintf("game: %s - both players originally missing, so game would have been void, nothing to do", $self->scheduled_game_number));
      } elsif ( $home_originally_missing ) {
        # Home originally missing - away would have won this, remove the stats from away
        $player_games_adjustments{away}{games_played}--;
        $player_games_adjustments{away}{games_won}--;
        #$logger->("debug", sprintf("game: %s - home was originally missing, remove games played / won from away", $self->scheduled_game_number));
      } elsif ( $away_originally_missing ) {
        # Away originally missing - home would have won this, remove the stats from away
        $player_games_adjustments{home}{games_played}--;
        $player_games_adjustments{home}{games_won}--;
        #$logger->("debug", sprintf("game: %s - away was originally missing, remove games played / won from home", $self->scheduled_game_number));
      }
    } elsif ( !$void and !$delete ) {
      # Not void, not deleting
      #$logger->("debug", sprintf("game: %s - not void and not deleting", $self->scheduled_game_number));
      if ( $home_player_missing ) {
        # Home player missing - check if anyone was missing before
        #$logger->("debug", sprintf("game: %s - home player missing", $self->scheduled_game_number));
        if ( $home_originally_missing and $away_originally_missing ) {
          # Both players were originally missing, now only the home player is.  Add 1 to games played and won for the away player.
          # No need to check if the opposition has players missing - that's covered by the fact this isn't a void game.
          $player_games_adjustments{away}{games_played}++;
          $player_games_adjustments{away}{games_won}++;
          #$logger->("debug", sprintf("game: %s - both players were originally missing, add 1 to away played / won", $self->scheduled_game_number));
        } elsif ( $home_originally_missing ) {
          # Originally the home player was missing (same as now).  If we now have a player set and didn't before
          #$logger->("debug", sprintf("game: %s - home player was originally missing but away wasn't", $self->scheduled_game_number));
          if ( !$away_originally_set ) {
            # If the away player wasn't originally set, it is now, increase the games played / won count
            $player_games_adjustments{away}{games_played}++;
            $player_games_adjustments{away}{games_won}++;
            #$logger->("debug", sprintf("game: %s - away player wasn't originally set, add 1 to away played / won", $self->scheduled_game_number));
          }
        } else {
          # No players originally missing.  No need to check if just the away player was missing, as that can't be the case - we have to change players one at a time, meaning
          # if the home player is now missing, it was previously either empty or had a player assigned; this means if the away player was originally missing and is now not,
          # that change must have already been done and scores been updated for that.
          # Add 1 to games played / games won for away 
          $player_games_adjustments{away}{games_played}++;
          $player_games_adjustments{away}{games_won}++;
          #$logger->("debug", sprintf("game: %s - no players originally missing, add 1 to away played / won", $self->scheduled_game_number));
        }
      } elsif ( $away_player_missing ) {
        # Away player missing - check if anyone was missing before
        #$logger->("debug", sprintf("game: %s - away player missing", $self->scheduled_game_number));
        if ( $home_originally_missing and $away_originally_missing ) {
          # Both players were originally missing, now only the away player is.  Add 1 to games played and won for the home player.
          # No need to check if the opposition has players missing - that's covered by the fact this isn't a void game.
          $player_games_adjustments{home}{games_played}++;
          $player_games_adjustments{home}{games_won}++;
          #$logger->("debug", sprintf("game: %s - both players were originally missing, add 1 to home played / won", $self->scheduled_game_number));
        } elsif ( $away_originally_missing ) {
          # Originally the home player was missing (same as now).  If we now have a player set and didn't before
          #$logger->("debug", sprintf("game: %s - away player was originally missing but home wasn't", $self->scheduled_game_number));
          if ( !$home_originally_set ) {
            # If the away player wasn't originally set, it is now, increase the games played / won count
            $player_games_adjustments{home}{games_played}++;
            $player_games_adjustments{home}{games_won}++;
            #$logger->("debug", sprintf("game: %s - home player wasn't originally set, add 1 to home played / won", $self->scheduled_game_number));
          }
        } else {
          # No players originally missing.  No need to check if just the away player was missing, as that can't be the case - we have to change players one at a time, meaning
          # if the away player is now missing, it was previously either empty or had a player assigned; this means if the home player was originally missing and is now not,
          # that change must have already been done and scores been updated for that.
          # Add 1 to games played / games won for home 
          $player_games_adjustments{home}{games_played}++;
          $player_games_adjustments{home}{games_won}++;
          #$logger->("debug", sprintf("game: %s - no players originally missing, add 1 to home played / won", $self->scheduled_game_number));
        }
      } elsif ( !$game_originally_void ) {
        # No players missing - there must have been a previous player showing as missing.
        #$logger->("debug", sprintf("game: %s - previously not void", $self->scheduled_game_number));
        if ( $home_originally_missing ) {
          # Home player was missing, so game would have been awarded to away
          $player_games_adjustments{away}{games_played}--;
          $player_games_adjustments{away}{games_won}--;
          #$logger->("debug", sprintf("game: %s - home originally missing, remove 1 from away played / won", $self->scheduled_game_number));
        } elsif ( $away_originally_missing ) {
          # Away player was missing, game would have been awarded to home
          $player_games_adjustments{home}{games_played}--;
          $player_games_adjustments{home}{games_won}--;
          #$logger->("debug", sprintf("game: %s - away originally missing, remove 1 from home played / won", $self->scheduled_game_number));
        }
      }
    } else {
      #$logger->("debug", sprintf("game: %s - not void or delete where it was previously complete, is void or delete (should be impossible)", $self->scheduled_game_number));
    }
  } elsif ( (!$missing_player_count_win_in_averages and ($home_player_missing or $away_player_missing or $home_originally_missing or $away_originally_missing)) ) {
    # Do nothing if we don't count missing players in the averages and we're updating the player missing statuses, or there's already a player missing when we're trying to update a score
  } else {
    #$logger->("debug", sprintf("game: %s - forefeit_count_averages_if_game_not_started: %s, game_originally_complete: %s, game_originally_void: %s, game_originally_started: %s", $self->scheduled_game_number, $forefeit_count_averages_if_game_not_started, $game_originally_complete, $game_originally_void, $game_originally_started));
    #$logger->("debug", sprintf("game: %s - don't count missing players in averages, OR no players missing", $self->scheduled_game_number));
    if ( ($forefeit_count_averages_if_game_not_started and $game_originally_complete and !$game_originally_void) or (!$forefeit_count_averages_if_game_not_started and $game_originally_started) ) {
      #$logger->("debug", sprintf("game: %s - game was previously counted in the averages, because it was completed and not void, or because it wasn't started and awarded, but we count those", $self->scheduled_game_number));
      # Game was originally started (or completed and we're counting forefeits even before the game started)
      # If there are players missing, we'll handle that in a different block; otherwise this gets far to complicated to work out
      if ( (($forefeit_count_averages_if_game_not_started and $complete and !$void)) or (!$forefeit_count_averages_if_game_not_started and $game_started) ) {
        # The game has still been started, need to check if the winner has changed.  No change to games played.
        #$logger->("debug", sprintf("game: %s - game is still to be counted in the averages, because it is completed and not void, or because it hasn't been started started and awarded, but we count those", $self->scheduled_game_number));
        if ( defined($game_winner) ) {
          # Not a draw, we have a winner
          #$logger->("debug", sprintf("game: %s - winner defined", $self->scheduled_game_number));
          if ( defined($game_original_winner) ) {
            # Not previously a draw, someone must have won before
            #$logger->("debug", sprintf("game: %s - previous winner defined", $self->scheduled_game_number));
            if ( $game_winner != $game_original_winner ) {
              # Winner has changed (there is no 'else' statement to this because if the winner hasn't changed, there are no game fields to alter)
              #$logger->("debug", sprintf("game: %s - winner has changed", $self->scheduled_game_number));
              if ( $game_winner == $home_team->id ) {
                # Home team now won, away team must have previously won
                $player_games_adjustments{home}{games_won}++;
                $player_games_adjustments{away}{games_lost}++;
                $player_games_adjustments{home}{games_lost}--;
                $player_games_adjustments{away}{games_won}--;
                #$logger->("debug", sprintf("game: %s - winner has changed - home win", $self->scheduled_game_number));
              } else {
                # Away team now won, home team must have previously won
                $player_games_adjustments{home}{games_won}--;
                $player_games_adjustments{away}{games_lost}--;
                $player_games_adjustments{home}{games_lost}++;
                $player_games_adjustments{away}{games_won}++;
                #$logger->("debug", sprintf("game: %s - winner has changed - away win", $self->scheduled_game_number));
              }
            } else {
              #$logger->("debug", sprintf("game: %s - winner has not changed", $self->scheduled_game_number));
            }
          } else {
            # Previously a draw, remove one from games drawn for both and then check who's won
            $player_games_adjustments{home}{games_drawn}--;
            $player_games_adjustments{away}{games_drawn}--;
            #$logger->("debug", sprintf("game: %s - no previous winner defined, remove draws", $self->scheduled_game_number));
            
            if ( $game_winner == $home_team->id ) {
              # Was a draw, now a home win
              $player_games_adjustments{home}{games_won}++;
              $player_games_adjustments{away}{games_lost}++;
              #$logger->("debug", sprintf("game: %s - home win", $self->scheduled_game_number));
            } else {
              # Was a draw, now an away win
              $player_games_adjustments{home}{games_lost}++;
              $player_games_adjustments{away}{games_won}++;
              #$logger->("debug", sprintf("game: %s - away win", $self->scheduled_game_number));
            }
          }
        } else {
          # The game was completed, isn't void and there's no winner; it must be a draw
          #$logger->("debug", sprintf("game: %s - winner NOT defined", $self->scheduled_game_number));
          if ( defined($game_original_winner) ) {
            # Not previously a draw, someone must have won - there is no 'else' statement to this, because going from a draw to a draw doesn't need any adjustments
            $player_games_adjustments{home}{games_drawn}++;
            $player_games_adjustments{away}{games_drawn}++;
            #$logger->("debug", sprintf("game: %s - previous winner defined, add draws", $self->scheduled_game_number));
            
            if ( $game_original_winner == $home_team->id ) {
              # Was a home win, now a draw
              $player_games_adjustments{home}{games_won}--;
              $player_games_adjustments{away}{games_lost}--;
              #$logger->("debug", sprintf("game: %s - previous winner was home", $self->scheduled_game_number));
            } else {
              # Was an away win, now a draw
              $player_games_adjustments{home}{games_lost}--;
              $player_games_adjustments{away}{games_won}--;
              #$logger->("debug", sprintf("game: %s - previous winner was away", $self->scheduled_game_number));
            }
          } else {
            #$logger->("debug", sprintf("game: %s - no previous winner defined, remains a draw", $self->scheduled_game_number));
          }
        }
      } else {
        # We need to take one from games played, as it's either not complete or void
        #$logger->("debug", sprintf("game: %s - game is no longer to be counted in the averages", $self->scheduled_game_number));
        $player_games_adjustments{home}{games_played}--;
        $player_games_adjustments{away}{games_played}--;
        
        if ( defined($game_original_winner) ) {
          #$logger->("debug", sprintf("game: %s - game is no longer to be counted in the averages, previous winner defined", $self->scheduled_game_number));
          if ( $game_original_winner == $home_team->id ) {
            # Was a home win
            $player_games_adjustments{home}{games_won}--;
            $player_games_adjustments{away}{games_lost}--;
            #$logger->("debug", sprintf("game: %s - game is no longer to be counted in the averages, previous winner was home", $self->scheduled_game_number));
          } else {
            # Was an away win
            $player_games_adjustments{home}{games_lost}--;
            $player_games_adjustments{away}{games_won}--;
            #$logger->("debug", sprintf("game: %s - game is no longer to be counted in the averages, previous winner was away", $self->scheduled_game_number));
          }
        } else {
          # If the game was started and there was no winner, it must have been a draw
          $player_games_adjustments{home}{games_drawn}--;
          $player_games_adjustments{away}{games_drawn}--;
          #$logger->("debug", sprintf("game: %s - game is no longer to be counted in the averages, previously a draw", $self->scheduled_game_number));
        }
      }
    } else {
      # Game was not originally played / completed, so this is a new score or a replacement for a void score, which will be all 0 anyway
      #$logger->("debug", sprintf("game: %s - game was NOT previously counted in the averages", $self->scheduled_game_number));
      if ( (($forefeit_count_averages_if_game_not_started and $complete and !$void)) or (!$forefeit_count_averages_if_game_not_started and $game_started) ) {
        #$logger->("debug", sprintf("game: %s - game is now to be counted in the averages", $self->scheduled_game_number));
        # Game is now complete and not void (if it is void, we don't update any game counts)
        # Increase the games played for both teams
        $player_games_adjustments{home}{games_played}++;
        $player_games_adjustments{away}{games_played}++;
        
        if ( defined($game_winner) ) {
          #$logger->("debug", sprintf("game: %s - winner defined", $self->scheduled_game_number));
          if ( $game_winner == $home_team->id ) {
            # Home win
            $player_games_adjustments{home}{games_won}++;
            $player_games_adjustments{away}{games_lost}++;
            #$logger->("debug", sprintf("game: %s - winner defined: home", $self->scheduled_game_number));
          } else {
            # Away win
            $player_games_adjustments{home}{games_lost}++;
            $player_games_adjustments{away}{games_won}++;
            #$logger->("debug", sprintf("game: %s - winner defined: away", $self->scheduled_game_number));
          }
        } else {
          # If the game was completed and isn't void and there's no winner, it must be a draw
          $player_games_adjustments{home}{games_drawn}++;
          $player_games_adjustments{away}{games_drawn}++;
          #$logger->("debug", sprintf("game: %s - no winner defined: draw", $self->scheduled_game_number));
        }
      } else {
        #$logger->("debug", sprintf("game: %s - game is still not to be counted in the averages", $self->scheduled_game_number));
      }
    }
  }
  
  ### UPDATING
  # Update the match fields
  $match->started($match_started);
  $match->home_team_games_won($current_home_match_score);
  $match->home_team_games_lost($current_away_match_score);
  $match->away_team_games_won($current_away_match_score);
  $match->away_team_games_lost($current_home_match_score);
  $match->games_drawn($current_games_drawn);
  $match->home_team_legs_won($match_home_team_legs_won);
  $match->away_team_legs_won($match_away_team_legs_won);
  $match->home_team_points_won($match_home_team_points_won);
  $match->away_team_points_won($match_away_team_points_won);
  $match->home_team_match_score($current_home_match_score);
  $match->away_team_match_score($current_away_match_score);
  $match->complete($match_complete);
  
  my $total_legs = $match_home_team_legs_won + $match_away_team_legs_won;
  if ( $total_legs ) {
    $match->home_team_average_leg_wins($match_home_team_legs_won / ( $total_legs ) * 100);
    $match->away_team_average_leg_wins($match_away_team_legs_won / ( $total_legs ) * 100);
  } else {
    $match->home_team_average_leg_wins(0);
    $match->away_team_average_leg_wins(0);
  }
  
  my $total_points = $match_home_team_points_won + $match_away_team_points_won;
  if ( $total_points ) {
    $match->home_team_average_point_wins($match_home_team_points_won / ( $total_points ) * 100);
    $match->away_team_average_point_wins($match_away_team_points_won / ( $total_points ) * 100);
  } else {
    $match->home_team_average_point_wins(0);
    $match->away_team_average_point_wins(0);
  }
  
  # Write the field updates to the match
  $match->update;
  
  ### STATISTICS UPDATE ###
  # Check for each stat whether we need to update or not (home or away)
  if ( !$self->doubles_game ) {
    foreach my $location ( qw( home away ) ) {
      my ( $game_player, $orig_score_for, $orig_score_against, $orig_points_for, $orig_points_against, $legs_for, $legs_against, $points_for, $points_against );
      if ( $location eq "home" ) {
        $game_player = $match->find_related("team_match_players", {player_number => $self->home_player_number});
        $orig_score_for = $game_original_home_team_score;
        $orig_score_against = $game_original_away_team_score;
        $orig_points_for = $game_original_home_team_points;
        $orig_points_against = $game_original_away_team_points;
        $legs_for = $home_legs;
        $legs_against = $away_legs;
        $points_for = $home_team_points;
        $points_against = $away_team_points;
      } else {
        $game_player = $match->find_related("team_match_players", {player_number => $self->away_player_number});
        $orig_score_for = $game_original_away_team_score;
        $orig_score_against = $game_original_home_team_score;
        $orig_points_for = $game_original_away_team_points;
        $orig_points_against = $game_original_home_team_points;
        $legs_for = $away_legs;
        $legs_against = $home_legs;
        $points_for = $away_team_points;
        $points_against = $home_team_points;
      }
      
      $game_player->legs_played($game_player->legs_played - ( $orig_score_for + $orig_score_against ) + ( $legs_for + $legs_against ));
      $game_player->legs_won($game_player->legs_won - $orig_score_for + $legs_for);
      $game_player->legs_lost($game_player->legs_lost - $orig_score_against + $legs_against);
      $game_player->points_played($game_player->points_played - ( $orig_points_for + $orig_points_against ) + ( $points_for + $points_against ));
      $game_player->points_won($game_player->points_won - $orig_points_for + $points_for);
      $game_player->points_lost($game_player->points_lost - $orig_points_against + $points_against);
      
      $game_player->legs_played ? $game_player->average_leg_wins(( $game_player->legs_won / $game_player->legs_played ) * 100) : $game_player->average_leg_wins(0);
      $game_player->points_played ? $game_player->average_point_wins(( $game_player->points_won / $game_player->points_played ) * 100) : $game_player->average_point_wins(0);
      
      foreach my $field ( keys %{$player_games_adjustments{$location}} ) {
        $game_player->$field($game_player->$field + $player_games_adjustments{$location}{$field}) if $game_player->result_source->has_column($field) and defined($game_player->player);
      }
      
      # Update all the fields we've modified
      $game_player->update;
    }
  }
  
  # Team match statistics were updated during the match update routine, so we just need to do the season statistics
  if ( defined($match->tournament_round) ) {
    # Tournament stuff to go here
    
  } else {
    # Team season statistics - these are done regardless of whether it's a doubles game or not; doubles contributes to the team's legs / points played
    $season_home_team->legs_played($season_home_team->legs_played - ( $game_original_home_team_score + $game_original_away_team_score ) + ( $home_legs + $away_legs ));
    $season_home_team->legs_won($season_home_team->legs_won - $game_original_home_team_score + $home_legs);
    $season_home_team->legs_lost($season_home_team->legs_lost - $game_original_away_team_score + $away_legs);
    $season_away_team->legs_played($season_away_team->legs_played - ( $game_original_home_team_score + $game_original_away_team_score ) +  ( $home_legs + $away_legs ));
    $season_away_team->legs_won($season_away_team->legs_won - $game_original_away_team_score + $away_legs);
    $season_away_team->legs_lost($season_away_team->legs_lost - $game_original_home_team_score + $home_legs);
    $season_home_team->points_played($season_home_team->points_played - ( $game_original_home_team_points + $game_original_away_team_points ) + ( $home_team_points + $away_team_points ));
    $season_home_team->points_won($season_home_team->points_won - $game_original_home_team_points + $home_team_points);
    $season_home_team->points_lost($season_home_team->points_lost - $game_original_away_team_points + $away_team_points);
    $season_away_team->points_played($season_away_team->points_played - ( $game_original_home_team_points + $game_original_away_team_points ) + ( $home_team_points + $away_team_points ));
    $season_away_team->points_won($season_away_team->points_won - $game_original_away_team_points + $away_team_points);
    $season_away_team->points_lost($season_away_team->points_lost - $game_original_home_team_points + $home_team_points);
    
    # Table points
    if ( $assign_points ) {
      $season_home_team->table_points($season_home_team->table_points + $home_points_adjustment);
      $season_away_team->table_points($season_away_team->table_points + $away_points_adjustment);
    }
    
    # We already know what we need to do to each matches / games won / drawn / lost total, just loop through and do it
    foreach my $stat_team ( keys %matches_adjustments ) {
      # Work out which team we're modifying at the moment
      my $mod_team = $stat_team eq "home" ? $season_home_team : $season_away_team;
      
      foreach my $field ( keys %{$matches_adjustments{$stat_team}} ) {
        $mod_team->$field($mod_team->$field + $matches_adjustments{$stat_team}{$field});
      }
    }
    
    foreach my $stat_team ( keys %team_games_adjustments ) {
      # Work out which team we're modifying at the moment
      my $mod_team = $stat_team eq "home" ? $season_home_team : $season_away_team;
      
      foreach my $field ( keys %{$team_games_adjustments{$stat_team}} ) {
        $mod_team->$field($mod_team->$field + $team_games_adjustments{$stat_team}{$field});
      }
    }
    
    # Work out the averages
    $season_home_team->games_played ? $season_home_team->average_game_wins(( $season_home_team->games_won / $season_home_team->games_played ) * 100) : $season_home_team->average_game_wins(0);
    $season_home_team->legs_played ? $season_home_team->average_leg_wins(( $season_home_team->legs_won / $season_home_team->legs_played ) * 100) : $season_home_team->average_leg_wins(0);
    $season_home_team->points_played ? $season_home_team->average_point_wins(( $season_home_team->points_won / $season_home_team->points_played ) * 100) : $season_home_team->average_point_wins(0);
    $season_away_team->games_played ? $season_away_team->average_game_wins(( $season_away_team->games_won / $season_away_team->games_played ) * 100) : $season_away_team->average_game_wins(0);
    $season_away_team->legs_played ? $season_away_team->average_leg_wins(( $season_away_team->legs_won / $season_away_team->legs_played ) * 100) : $season_away_team->average_leg_wins(0);
    $season_away_team->points_played ? $season_away_team->average_point_wins(( $season_away_team->points_won / $season_away_team->points_played ) * 100) : $season_away_team->average_point_wins(0);
    
    # If it's a doubles game, we work those statistics out too.
    if ( $self->doubles_game ) {
      # Legs and points - these can be calculated regardless of anything else, because if we're deleting or modifying the score, the calculation is the same
      $season_home_team->doubles_legs_played($season_home_team->doubles_legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ));
      $season_away_team->doubles_legs_played($season_away_team->doubles_legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ));
      $season_home_team->doubles_legs_won($season_home_team->doubles_legs_won + ( $home_legs - $game_original_home_team_score ));
      $season_away_team->doubles_legs_won($season_away_team->doubles_legs_won + ( $away_legs - $game_original_away_team_score ));
      $season_home_team->doubles_legs_lost($season_home_team->doubles_legs_lost + ( $away_legs - $game_original_away_team_score ));
      $season_away_team->doubles_legs_lost($season_away_team->doubles_legs_lost + ( $home_legs - $game_original_home_team_score ));
      $season_home_team->doubles_points_played($season_home_team->doubles_points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ));
      $season_away_team->doubles_points_played($season_away_team->doubles_points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ));
      $season_home_team->doubles_points_won($season_home_team->doubles_points_won + ( $home_team_points - $game_original_home_team_points ));
      $season_away_team->doubles_points_won($season_away_team->doubles_points_won + ( $away_team_points - $game_original_away_team_points ));
      $season_home_team->doubles_points_lost($season_home_team->doubles_points_lost + ( $away_team_points - $game_original_away_team_points ));
      $season_away_team->doubles_points_lost($season_away_team->doubles_points_lost + ( $home_team_points - $game_original_home_team_points ));
      
      # Work out the averages
      $season_home_team->doubles_games_played ? $season_home_team->doubles_average_game_wins(( $season_home_team->doubles_games_won / $season_home_team->doubles_games_played ) * 100) : $season_home_team->doubles_average_game_wins(0);
      $season_home_team->doubles_legs_played ? $season_home_team->doubles_average_leg_wins(( $season_home_team->doubles_legs_won / $season_home_team->doubles_legs_played ) * 100) : $season_home_team->doubles_average_leg_wins(0);
      $season_home_team->doubles_points_played ? $season_home_team->doubles_average_point_wins(( $season_home_team->doubles_points_won / $season_home_team->doubles_points_played ) * 100) : $season_home_team->doubles_average_point_wins(0);
      $season_away_team->doubles_games_played ? $season_away_team->doubles_average_game_wins(( $season_away_team->doubles_games_won / $season_away_team->doubles_games_played ) * 100) : $season_away_team->doubles_average_game_wins(0);
      $season_away_team->doubles_legs_played ? $season_away_team->doubles_average_leg_wins(( $season_away_team->doubles_legs_won / $season_away_team->doubles_legs_played ) * 100) : $season_away_team->doubles_average_leg_wins(0);
      $season_away_team->doubles_points_played ? $season_away_team->doubles_average_point_wins(( $season_away_team->doubles_points_won / $season_away_team->doubles_points_played ) * 100) : $season_away_team->doubles_average_point_wins(0);
      
      # Get the person_season objects we need to update for the individual doubles statistics
      my $home_doubles1 = $home_player->person_season_person1_season_team;
      my $home_doubles2 = $home_player->person_season_person2_season_team;
      my $away_doubles1 = $away_player->person_season_person1_season_team;
      my $away_doubles2 = $away_player->person_season_person2_season_team;
      
      # We already know what we need to do to each matches / games won / drawn / lost total, just loop through and do it
      foreach my $stat_team ( keys %player_games_adjustments ) {
        # Work out which objects we're modifying at the moment - home or away
        my ( $mod_pair, $mod_player1, $mod_player2 ) = $stat_team eq "home" ? ( $home_player, $home_doubles1, $home_doubles2 ) : ( $away_player, $away_doubles1, $away_doubles2 );
        
        foreach my $field ( keys %{$player_games_adjustments{$stat_team}} ) {
          # The pair ($mod_pair is $home_player or $away_player, which is always the doubles pair for a doubles game) fields are unchanged - games_played for example
          $mod_pair->$field($mod_pair->$field + $player_games_adjustments{$stat_team}{$field}) if $mod_pair->result_source->has_column($field);
          
          # The individual players - $mod_player1, $mod_player2 - are preceded with doubles - doubles_games_played for example
          my $doubles_field = "doubles_" . $field;
          $mod_player1->$doubles_field($mod_player1->$doubles_field + $player_games_adjustments{$stat_team}{$field}) if $mod_player1->result_source->has_column($doubles_field);
          $mod_player2->$doubles_field($mod_player2->$doubles_field + $player_games_adjustments{$stat_team}{$field}) if $mod_player2->result_source->has_column($doubles_field);
        }
      }
      
      # Legs and points
      $home_player->legs_played($home_player->legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ));
      $away_player->legs_played($away_player->legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ));
      $home_player->legs_won($home_player->legs_won + ( $home_legs - $game_original_home_team_score ));
      $away_player->legs_won($away_player->legs_won + ( $away_legs - $game_original_away_team_score ));
      $home_player->legs_lost($home_player->legs_lost + ( $away_legs - $game_original_away_team_score ));
      $away_player->legs_lost($away_player->legs_lost + ( $home_legs - $game_original_home_team_score ));
      
      $home_player->points_played($home_player->points_played + ( ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ) ));
      $away_player->points_played($away_player->points_played + ( ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ) ));
      $home_player->points_won($home_player->points_won + ( $home_team_points - $game_original_home_team_points ));
      $away_player->points_won($away_player->points_won + ( $away_team_points - $game_original_away_team_points ));
      $home_player->points_lost($home_player->points_lost + ( $away_team_points - $game_original_away_team_points ));
      $away_player->points_lost($away_player->points_lost + ( $home_team_points - $game_original_home_team_points ));
      
      $home_doubles1->doubles_legs_played($home_doubles1->doubles_legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ));
      $home_doubles2->doubles_legs_played($home_doubles2->doubles_legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ));
      $away_doubles1->doubles_legs_played($away_doubles1->doubles_legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ));
      $away_doubles2->doubles_legs_played($away_doubles2->doubles_legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ));
      $home_doubles1->doubles_legs_won($home_doubles1->doubles_legs_won + ( $home_legs - $game_original_home_team_score ));
      $home_doubles2->doubles_legs_won($home_doubles2->doubles_legs_won + ( $home_legs - $game_original_home_team_score ));
      $away_doubles1->doubles_legs_won($away_doubles1->doubles_legs_won + ( $away_legs - $game_original_away_team_score ));
      $away_doubles2->doubles_legs_won($away_doubles2->doubles_legs_won + ( $away_legs - $game_original_away_team_score ));
      $home_doubles1->doubles_legs_lost($home_doubles1->doubles_legs_lost + ( $away_legs - $game_original_away_team_score ));
      $home_doubles2->doubles_legs_lost($home_doubles2->doubles_legs_lost + ( $away_legs - $game_original_away_team_score ));
      $away_doubles1->doubles_legs_lost($away_doubles1->doubles_legs_lost + ( $home_legs - $game_original_home_team_score ));
      $away_doubles2->doubles_legs_lost($away_doubles2->doubles_legs_lost + ( $home_legs - $game_original_home_team_score ));
      $home_doubles1->doubles_points_played($home_doubles1->doubles_points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ));
      $home_doubles2->doubles_points_played($home_doubles2->doubles_points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ));
      $away_doubles1->doubles_points_played($away_doubles1->doubles_points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ));
      $away_doubles2->doubles_points_played($away_doubles2->doubles_points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ));
      $home_doubles1->doubles_points_won($home_doubles1->doubles_points_won + ( $home_team_points - $game_original_home_team_points ));
      $home_doubles2->doubles_points_won($home_doubles2->doubles_points_won + ( $home_team_points - $game_original_home_team_points ));
      $away_doubles1->doubles_points_won($away_doubles1->doubles_points_won + ( $away_team_points - $game_original_away_team_points ));
      $away_doubles2->doubles_points_won($away_doubles2->doubles_points_won + ( $away_team_points - $game_original_away_team_points ));
      $home_doubles1->doubles_points_lost($home_doubles1->doubles_points_lost + ( $away_team_points - $game_original_away_team_points ));
      $home_doubles2->doubles_points_lost($home_doubles2->doubles_points_lost + ( $away_team_points - $game_original_away_team_points ));
      $away_doubles1->doubles_points_lost($away_doubles1->doubles_points_lost + ( $home_team_points - $game_original_home_team_points ));
      $away_doubles2->doubles_points_lost($away_doubles2->doubles_points_lost + ( $home_team_points - $game_original_home_team_points ));
      
      # Work out the averages
      $home_player->games_played ? $home_player->average_game_wins(( $home_player->games_won / $home_player->games_played ) * 100) : $home_player->average_game_wins(0);
      $home_player->legs_played ? $home_player->average_leg_wins(( $home_player->legs_won / $home_player->legs_played ) * 100) : $home_player->average_leg_wins(0);
      $home_player->points_played ? $home_player->average_point_wins(( $home_player->points_won / $home_player->points_played ) * 100) : $home_player->average_point_wins(0);
      $away_player->games_played ? $away_player->average_game_wins(( $away_player->games_won / $away_player->games_played ) * 100) : $away_player->average_game_wins(0);
      $away_player->legs_played ? $away_player->average_leg_wins(( $away_player->legs_won / $away_player->legs_played ) * 100) : $away_player->average_leg_wins(0);
      $away_player->points_played ? $away_player->average_point_wins(( $away_player->points_won / $away_player->points_played ) * 100) : $away_player->average_point_wins(0);
      
      $home_doubles1->doubles_games_played ? $home_doubles1->doubles_average_game_wins(( $home_doubles1->doubles_games_won / $home_doubles1->doubles_games_played ) * 100) : $home_doubles1->doubles_average_game_wins(0);
      $home_doubles2->doubles_games_played ? $home_doubles2->doubles_average_game_wins(( $home_doubles2->doubles_games_won / $home_doubles2->doubles_games_played ) * 100) : $home_doubles2->doubles_average_game_wins(0);
      $home_doubles1->doubles_legs_played ? $home_doubles1->doubles_average_leg_wins(( $home_doubles1->doubles_legs_won / $home_doubles1->doubles_legs_played ) * 100) : $home_doubles1->doubles_average_leg_wins(0);
      $home_doubles2->doubles_legs_played ? $home_doubles2->doubles_average_leg_wins(( $home_doubles2->doubles_legs_won / $home_doubles2->doubles_legs_played ) * 100) : $home_doubles2->doubles_average_leg_wins(0);
      $home_doubles1->doubles_points_played ? $home_doubles1->doubles_average_point_wins(( $home_doubles1->doubles_points_won / $home_doubles1->doubles_points_played ) * 100) : $home_doubles1->doubles_average_point_wins(0);
      $home_doubles2->doubles_points_played ? $home_doubles2->doubles_average_point_wins(( $home_doubles2->doubles_points_won / $home_doubles2->doubles_points_played ) * 100) : $home_doubles2->doubles_average_point_wins(0);
      $away_doubles1->doubles_games_played ? $away_doubles1->doubles_average_game_wins(( $away_doubles1->doubles_games_won / $away_doubles1->doubles_games_played ) * 100) : $away_doubles1->doubles_average_game_wins(0);
      $away_doubles2->doubles_games_played ? $away_doubles2->doubles_average_game_wins(( $away_doubles2->doubles_games_won / $away_doubles2->doubles_games_played ) * 100) : $away_doubles2->doubles_average_game_wins(0);
      $away_doubles1->doubles_legs_played ? $away_doubles1->doubles_average_leg_wins(( $away_doubles1->doubles_legs_won / $away_doubles1->doubles_legs_played ) * 100) : $away_doubles1->doubles_average_leg_wins(0);
      $away_doubles2->doubles_legs_played ? $away_doubles2->doubles_average_leg_wins(( $away_doubles2->doubles_legs_won / $away_doubles2->doubles_legs_played ) * 100) : $away_doubles2->doubles_average_leg_wins(0);
      $away_doubles1->doubles_points_played ? $away_doubles1->doubles_average_point_wins(( $away_doubles1->doubles_points_won / $away_doubles1->doubles_points_played ) * 100) : $away_doubles1->doubles_average_point_wins(0);
      $away_doubles2->doubles_points_played ? $away_doubles2->doubles_average_point_wins(( $away_doubles2->doubles_points_won / $away_doubles2->doubles_points_played ) * 100) : $away_doubles2->doubles_average_point_wins(0);
      
      $home_player->update;
      $away_player->update;
      $home_doubles1->update;
      $home_doubles2->update;
      $away_doubles1->update;
      $away_doubles2->update;
      
      # If there are player matches played / won / lost to update, do it here for all players in the match
      # We also need to do that for the other players in the match
      my $home_players = $match->search_related("team_match_players", {
        "person_seasons.season" => $season->id,
        "person_seasons.team" => $home_team->id,
        location => "home",
      }, {
        prefetch => {player => "person_seasons"}
      });
      
      while ( my $_home_player = $home_players->next ) {
        my $_player = $_home_player->player->person_seasons->first;
        
        foreach my $field ( keys %{$matches_adjustments{home}} ) {
          $_player->$field($_player->$field + $matches_adjustments{home}{$field});
        }
        
        $_player->update;
      }
      
      my $away_players = $match->search_related("team_match_players", {
        "person_seasons.season" => $season->id,
        "person_seasons.team" => $away_team->id,
        location => "away",
      }, {
        prefetch => {player => "person_seasons"}
      });
      
      while ( my $_away_player = $away_players->next ) {
        my $_player = $_away_player->player->person_seasons->first;
        
        foreach my $field ( keys %{$matches_adjustments{away}} ) {
          $_player->$field($_player->$field + $matches_adjustments{away}{$field});
        }
        
        $_player->update;
      }
    } else {
      # Not a doubles game - work out which season stats to update
      # Check for each stat whether we need to update or not (home or away)
      foreach my $location ( qw( home away ) ) {
        my ( $match_player, $for_team, $against_team, $orig_score_for, $orig_score_against, $orig_points_for, $orig_points_against, $legs_for, $legs_against, $points_for, $points_against );
        
        if ( $location eq "home" ) {
          $match_player = $home_player;
          $for_team = $home_team;
          $against_team = $away_team;
          $orig_score_for = $game_original_home_team_score;
          $orig_score_against = $game_original_away_team_score;
          $orig_points_for = $game_original_home_team_points;
          $orig_points_against = $game_original_away_team_points;
          $legs_for = $home_legs;
          $legs_against = $away_legs;
          $points_for = $home_team_points;
          $points_against = $away_team_points;
        } else {
          $match_player = $away_player;
          $for_team = $away_team;
          $against_team = $home_team;
          $orig_score_for = $game_original_away_team_score;
          $orig_score_against = $game_original_home_team_score;
          $orig_points_for = $game_original_away_team_points;
          $orig_points_against = $game_original_home_team_points;
          $legs_for = $away_legs;
          $legs_against = $home_legs;
          $points_for = $away_team_points;
          $points_against = $home_team_points;
        }
        
        # Get the person season object (assuming they're defined - they may not be if we've set a missing player)
        if ( defined($match_player) ) {
          my $season_player = $match_player->find_related("person_seasons", {season => $season->id, team => $for_team->id});
          
          # Create them as a loan player if not already existing (we should never have to do this, as even loan players should
          # be created when added to their match position, before the scores are filled out, but just to triple check).
          # Ensure the player isn't missing, as trying to create will result in an error
          $season_player = $match_player->create_related("person_seasons", {
            season => $season->id,
            team => $for_team->id,
            first_name => $match_player->first_name,
            surname => $match_player->surname,
            display_name => $match_player->display_name,
            team_membership_type => "loan",
          }) unless defined($season_player);
          
          # Update the season stats for the player - games we already know and are stored in %player_games_adjustments
          foreach my $field ( keys %{$player_games_adjustments{$location}} ) {
            $season_player->$field($season_player->$field + $player_games_adjustments{$location}{$field});
          }
          
          # Legs / points
          $season_player->legs_played($season_player->legs_played + ( $legs_for + $legs_against ) - ( $orig_score_for + $orig_score_against ));
          $season_player->legs_won($season_player->legs_won + ( $legs_for - $orig_score_for ));
          $season_player->legs_lost($season_player->legs_lost + ( $legs_against - $orig_score_against ));
          $season_player->points_played($season_player->points_played + ( $points_for + $points_against ) - ( $orig_points_for  + $orig_points_against ));
          $season_player->points_won($season_player->points_won + ( $points_for - $orig_points_for ));
          $season_player->points_lost($season_player->points_lost + ( $points_against - $orig_points_against ));
          
          # Averages
          $season_player->legs_played ? $season_player->average_leg_wins(( $season_player->legs_won / $season_player->legs_played ) * 100) : $season_player->average_leg_wins(0);
          $season_player->points_played ? $season_player->average_point_wins(( $season_player->points_won / $season_player->points_played  ) * 100) : $season_player->average_point_wins(0);
          $season_player->games_played ? $season_player->average_game_wins(( $season_player->games_won / $season_player->games_played ) * 100) : $season_player->average_game_wins(0);
          
          # Do the update
          $season_player->update;
        }
        
        # Update match stats for all players if required - do this whether we're updating the player stats or not
        my $match_players = $match->search_related("team_match_players", {
          "person_seasons.season" => $season->id,
          "person_seasons.team" => $for_team->id,
          location => $location,
        }, {
          prefetch => {player => "person_seasons"}
        });
        
        while ( my $_match_player = $match_players->next ) {
          my $_player = $_match_player->player->person_seasons->first;
          
          foreach my $field ( keys %{$matches_adjustments{$location}} ) {
            $_player->$field($_player->$field + $matches_adjustments{$location}{$field});
          }
          
          $_player->update;
        }
      }
    }
    
    $season_home_team->update;
    $season_away_team->update;
  }
  
  # Finally commit the transaction if there are no errors
  $transaction->commit;
  
  if ( $delete ) {
    push(@{$response->{success}}, $lang->maketext("matches.game.update-score.success-game-reset"));
  } else {
    push(@{$response->{success}}, $lang->maketext("matches.game.update-score.success-game-complete"));
  }
  
  $response->{completed} = 1;
  
  # Return the match object so we can tell whether or not it's complete in the AJAX response
  $response->{match} = $match;
  $response->{match_originally_complete} = $match_originally_complete;
  $response->{match_complete} = $match_complete;
  $response->{match_scores} = $match_scores;
  return $response;
}

=head2 update_doubles_pair

Add or remove a pair of players to a doubles game.

=cut

sub update_doubles_pair {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Get the fields
  my $location = $params->{location} || undef;
  my $players = $params->{players} || [];
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  my $match = $self->team_match;
  my $season = $match->season;
  
  # First check the match wasn't cancelled; if it was, we return straight away
  if ( $match->cancelled ) {
    push(@{$response->{errors}}, $lang->maketext("matches.update.error.match-cancelled"));
    return $response;
  }
  
  if ( $season->complete ) {
    # Error, season is complete
    push(@{$response->{errors}}, $lang->maketext("matches.update.error.season-complete"));
    return $response;
  } else {
    # Check the game we're updating is actually a doubles game
    if ( $self->doubles_game ) {
      # Check we have a location
      if ( defined($location) and ( $location eq "home" or $location eq "away" ) ) {
        # Validate the players or the doubles pair.  Regardless of how specified, we need both the doubles pair and each player, so will look
        # one up from the other.  The doubles pair will be created if it doesn't exist.
        $players = [$players] unless ref($players) eq "ARRAY";
        my ( $doubles_pair, $player1, $player2 );
        my $player_count = scalar @{$players};
        my $action = "add"; # default, unless nothing is supplied in the players list
        if ( $player_count == 0 ) {
          # Remove the doubles pair
          $action = "remove";
        } elsif ( $player_count == 2 ) {
          # Two elements - should be player 1 and player 2 (order doesn't matter)
          ( $player1, $player2 ) = ( $players->[0], $players->[1] );
        } else {
          # More than two elements is an error
          push(@{$response->{errors}}, $lang->maketext("matches.game.update-doubles.error.wrong-number-of-players"));
          return $response;
        }
        
        # Get the team and relevant DB fields for updating
        my $location_team = $location eq "home" ? "team_season_home_team_season" : "team_season_away_team_season";
        my $location_doubles_pair = $location eq "home" ? "home_doubles_pair" : "away_doubles_pair";
        my $team_legs_won = $location eq "home" ? "home_team_legs_won" : "away_team_legs_won";
        my $opposition_legs_won = $location eq "home" ? "away_team_legs_won" : "home_team_legs_won";
        my $team_points_won = $location eq "home" ? "home_team_points_won" : "away_team_points_won";
        my $opposition_points_won = $location eq "home" ? "away_team_points_won" : "home_team_points_won";
        my $team = $match->$location_team->team;
        my $team_name = sprintf("%s %s", $team->club->short_name, $team->name);
        my $enc_team_name = encode_entities($team_name);
        my $original_doubles_pair = $self->$location_doubles_pair;
        
        my $transaction = $self->result_source->schema->txn_scope_guard;
        
        # Check if we are adding or removing - if $player_ids is undefined, we'll remove
        if ( $action eq "add" ) {
          # Add - first check the players are valid people
          if ( defined($player1) ) {
            $player1 = $schema->resultset("Person")->find_id_or_url_key($player1) unless ref($player1) eq "TopTable::Model::DB::Person";
            push(@{$response->{errors}}, $lang->maketext("matches.game.update-doubles.error.$location-player1-invalid")) unless defined($player1);
          } else {
            # We shouldn't get here, but just to make sure
            push(@{$response->{errors}}, $lang->maketext("matches.game.update-doubles.error.$location-player1-blank"));
          }
          
          if ( defined($player2) ) {
            $player2 = $schema->resultset("Person")->find_id_or_url_key($player2) unless ref($player2) eq "TopTable::Model::DB::Person";
            push(@{$response->{errors}}, $lang->maketext("matches.game.update-doubles.error.$location-player2-invalid")) unless defined($player2);
          } else {
            # We shouldn't get here, but just to make sure
            push(@{$response->{errors}}, $lang->maketext("matches.game.update-doubles.error.$location-player2-blank"));
          }
          
          # If either player is invalid, we return at this point, as they are fatal errors
          if ( scalar @{$response->{errors}} ) {
            return $response;
            $transaction->rollback;
          }
          
          my $enc_player1_display = encode_entities($player1->display_name);
          my $enc_player2_display = encode_entities($player2->display_name);
          
          # Check we don't have two references to the same person
          push(@{$response->{errors}}, $lang->maketext("matches.game.update-doubles.error.players-identical", $location)) if $player1->id == $player2->id;
          
          # Return if we have an error here
          return $response if scalar @{$response->{errors}};
          
          # Get person season for this team if there is one so we can search from the doubles pair from that
          
          # Work out if either player is a loan player
          my $person1_season = $player1->find_related("person_seasons", {season => $season->id, team => $team->id});
          my $person2_season = $player2->find_related("person_seasons", {season => $season->id, team => $team->id});
          
          # Now check if there's a doubles pairing with the two players
          my $doubles_pair1 = $person1_season->search_related("doubles_pairs_person1_season_teams", {season => $season->id, person2 => $player2->id, team => $team->id});
          my $doubles_pair2 = $person1_season->search_related("doubles_pairs_person2_season_teams", {season => $season->id, person1 => $player2->id, team => $team->id});
          my $doubles_pair = $doubles_pair1->union_all($doubles_pair2)->first;
          
          # Work out if either player is a loan player
          my $person1_active_season = $player1->search_related("person_seasons", {season => $season->id, team => $team->id, team_membership_type => "active"}, {rows => 1})->single;
          my $person2_active_season = $player2->search_related("person_seasons", {season => $season->id, team => $team->id, team_membership_type => "active"}, {rows => 1})->single;
          my $person1_loan = defined($person1_active_season) ? 0 : 1;
          my $person2_loan = defined($person2_active_season) ? 0 : 1;
          
          # If the doubles pair was returned okay, we don't need to do any more verification, just use the existing one
          unless ( defined($doubles_pair) ) {
            # The doubles pair doesn't exist, so we need to verify the people specified are eligible to play in the
            # doubles game; to do this we first need to get a list of eligible players (which will include all players
            # registered for the team plus any players playing as a loan player if appropriate).
            my @player_list = @{$self->team_match->eligible_players({location => $location})};
            
            # Check each player against the list of eligible players - start off with both eligible flags set to false
            my $player1_eligible = 0;
            my $player2_eligible = 0;
            foreach my $eligible_player ( @player_list ) {
              if ( $eligible_player->id == $player1->id ) {
                # If player 1 is eligible, set the flag to true
                $player1_eligible = 1;
              } elsif ( $eligible_player->id == $player2->id ) {
                # If player 1 is eligible, set the flag to true
                $player2_eligible = 1;
              }
              
              # Don't loop through any more if we've already established both players are eligible
              last if $player1_eligible and $player2_eligible;
            }
          
            # Advise about ineligible players if either are
            push(@{$response->{errors}}, $lang->maketext("matches.game.update-doubles.error.player-ineligible", $enc_player1_display, $enc_team_name)) unless $player1_eligible;
            push(@{$response->{errors}}, $lang->maketext("matches.game.update-doubles.error.player-ineligible", $enc_player2_display, $enc_team_name)) unless $player2_eligible;
            
            return $response if scalar @{$response->{errors}};
            
            # Now do the create
            $doubles_pair = $person1_season->create_related("doubles_pairs_person1_season_teams", {
              person2 => $player2->id,
              season => $season->id,
              team => $team->id,
              person1_loan => $person1_loan,
              person2_loan => $person2_loan,
            });
          }
          
          # Now regardless we have a doubles pair, whether we created or used the existing one, so finally we can set the doubles team for this game
          $self->$location_doubles_pair($doubles_pair);
          
          # Update the statistics for the original doubles pair if it's changed and there was an original doubles pair specified
          if ( $self->is_column_changed($location_doubles_pair) ) {
            # The doubles pair column has changed, so we need to recalculate some values
            
            if ( defined($original_doubles_pair) ) {
              # Get the original player 1 / player 2 objects to update their individual statistics
              my $original_player1 = $original_doubles_pair->person_season_person1_season_team;
              my $original_player2 = $original_doubles_pair->person_season_person2_season_team;
              
              # There is an original doubles pair to take some games off
              if ( $self->complete ) {
                $original_doubles_pair->games_played($original_doubles_pair->games_played - 1);
                $original_player1->doubles_games_played($original_player1->doubles_games_played - 1);
                $original_player2->doubles_games_played($original_player2->doubles_games_played - 1);
              }
              
              # Work out whether we need to take a game won, lost or drawn off
              if ( $self->complete and defined($self->winner) and $self->winner->id == $match->$location_team->id ) {
                # Game won
                $original_doubles_pair->games_won($original_doubles_pair->games_won - 1);
                $original_player1->doubles_games_won($original_player1->doubles_games_won - 1);
                $original_player2->doubles_games_won($original_player2->doubles_games_won - 1);
              } elsif ( $self->complete and defined($self->winner) and $self->winner->id != $match->$location_team->id ) {
                # Game lost
                $original_doubles_pair->games_lost($original_doubles_pair->games_lost - 1);
                $original_player1->doubles_games_lost($original_player1->doubles_games_lost - 1);
                $original_player2->doubles_games_lost($original_player2->doubles_games_lost - 1);
              } elsif ( $self->complete and !defined($self->winner) ) {
                # Game complete but no winner: draw (only relevant for games with a static number of legs)
                $original_doubles_pair->games_drawn($original_doubles_pair->games_drawn - 1);
                $original_player1->doubles_games_drawn($original_player1->doubles_games_drawn - 1);
                $original_player2->doubles_games_drawn($original_player2->doubles_games_drawn - 1);
              }
              
              # Take away the legs that have been played, won and lost in this game from the original pair
              # In each game, we don't have a specific legs_played field, so we have to add the legs won for this team to the legs won for the opposition team,
              # then subtract that figure from the original legs_played value in the doubles pair, which will be the combination of all the legs they've played
              $original_doubles_pair->legs_played($original_doubles_pair->legs_played - ( $self->$team_legs_won + $self->$opposition_legs_won ));
              $original_player1->doubles_legs_played($original_player1->doubles_legs_played - ( $self->$team_legs_won + $self->$opposition_legs_won ));
              $original_player2->doubles_legs_played($original_player2->doubles_legs_played - ( $self->$team_legs_won + $self->$opposition_legs_won ));
              
              $original_doubles_pair->legs_won($original_doubles_pair->legs_won - $self->$team_legs_won);
              $original_player1->doubles_legs_won($original_player1->doubles_legs_won - $self->$team_legs_won);
              $original_player2->doubles_legs_won($original_player2->doubles_legs_won - $self->$team_legs_won);
              
              $original_doubles_pair->legs_lost($original_doubles_pair->legs_lost - $self->$opposition_legs_won);
              $original_player1->doubles_legs_lost($original_player1->doubles_legs_lost - $self->$opposition_legs_won);
              $original_player2->doubles_legs_lost($original_player2->doubles_legs_lost - $self->$opposition_legs_won);
              
              # Take away the points that have been played, won and lost in this game from the original pair
              # In each game, we don't have a specific legs_played field, so we have to add the legs won for this team to the legs won for the opposition team,
              # then subtract that figure from the original legs_played value in the doubles pair, which will be the combination of all the legs they've played
              $original_doubles_pair->points_played($original_doubles_pair->points_played - ( $self->$team_points_won + $self->$opposition_points_won ));
              $original_player1->doubles_points_played($original_player1->doubles_points_played - ( $self->$team_points_won + $self->$opposition_points_won ));
              $original_player2->doubles_points_played($original_player2->doubles_points_played - ( $self->$team_points_won + $self->$opposition_points_won ));
              
              $original_doubles_pair->points_won($original_doubles_pair->points_won - $self->$team_points_won);
              $original_player1->doubles_points_won($original_player1->doubles_points_won - $self->$team_points_won);
              $original_player2->doubles_points_won($original_player2->doubles_points_won - $self->$team_points_won);
              
              $original_doubles_pair->points_lost($original_doubles_pair->points_lost - $self->$opposition_points_won);
              $original_player1->doubles_points_lost($original_player1->doubles_points_lost - $self->$opposition_points_won);
              $original_player2->doubles_points_lost($original_player2->doubles_points_lost - $self->$opposition_points_won);
              
              # Work out the averages again
              $original_doubles_pair->games_played ? $original_doubles_pair->average_game_wins(( $original_doubles_pair->games_won / $original_doubles_pair->games_played ) * 100) : $original_doubles_pair->average_game_wins(0);
              $original_player1->doubles_games_played ? $original_player1->doubles_average_game_wins(( $original_player1->doubles_games_won / $original_player1->doubles_games_played ) * 100) : $original_player1->doubles_average_game_wins(0);
              $original_player2->doubles_games_played ? $original_player2->doubles_average_game_wins(( $original_player2->doubles_games_won / $original_player2->doubles_games_played ) * 100) : $original_player2->doubles_average_game_wins(0);
              
              $original_doubles_pair->legs_played ? $original_doubles_pair->average_leg_wins(( $original_doubles_pair->legs_won / $original_doubles_pair->legs_played ) * 100) : $original_doubles_pair->average_leg_wins(0);
              $original_player1->doubles_legs_played ? $original_player1->doubles_average_leg_wins(( $original_player1->doubles_legs_won / $original_player1->doubles_legs_played ) * 100) : $original_player1->doubles_average_leg_wins(0);
              $original_player2->doubles_legs_played ? $original_player2->doubles_average_leg_wins(( $original_player2->doubles_legs_won / $original_player2->doubles_legs_played ) * 100) : $original_player2->doubles_average_leg_wins(0);
              
              $original_doubles_pair->points_played ? $original_doubles_pair->average_point_wins(( $original_doubles_pair->points_won / $original_doubles_pair->points_played ) * 100) : $original_doubles_pair->average_point_wins(0);
              $original_player1->doubles_points_played ? $original_player1->doubles_average_point_wins(( $original_player1->doubles_points_won / $original_player1->doubles_points_played ) * 100) : $original_player1->doubles_average_point_wins(0);
              $original_player2->doubles_points_played ? $original_player2->doubles_average_point_wins(( $original_player2->doubles_points_won / $original_player2->doubles_points_played ) * 100) : $original_player2->doubles_average_point_wins(0);
              
              # Do the actual update after everything's been calculated
              $original_doubles_pair->update;
              $original_player1->update;
              $original_player2->update;
            }
            
            my $player1_season = $doubles_pair->person_season_person1_season_team;
            my $player2_season = $doubles_pair->person_season_person2_season_team;
            
            # Now add those values on to the current doubles pair
            # Add one to the games played
            if ( $self->complete ) {
              $doubles_pair->games_played($doubles_pair->games_played + 1);
              $player1_season->doubles_games_played($player1_season->doubles_games_played + 1);
              $player2_season->doubles_games_played($player2_season->doubles_games_played + 1);
            }
            
            # Work out whether we need to take a game won, lost or drawn off
            if ( $self->complete and defined($self->winner) and $self->winner->id == $match->$location_team->id ) {
              # Game won
              $doubles_pair->games_won($original_doubles_pair->games_won + 1);
              $player1_season->doubles_games_won($player1_season->doubles_games_won + 1);
              $player2_season->doubles_games_won($player2_season->doubles_games_won + 1);
              
              # Change the winner
              $self->winner($match->$location_team->id);
            } elsif ( $self->complete and defined($self->winner) and $self->winner->id != $match->$location_team->id ) {
              # Game lost
              $doubles_pair->games_lost($original_doubles_pair->games_lost + 1);
              $player1_season->doubles_games_lost($player1_season->doubles_games_lost + 1);
              $player2_season->doubles_games_lost($player2_season->doubles_games_lost + 1);
            } elsif ( $self->complete and !defined( $self->winner ) ) {
              # Game complete but no winner: draw (only relevant for games with a static number of legs)
              $doubles_pair->games_drawn($original_doubles_pair->games_drawn + 1);
              $player1_season->doubles_games_drawn($player1_season->doubles_games_drawn + 1);
              $player2_season->doubles_games_drawn($player2_season->doubles_games_drawn + 1);
            }
            
            # Add away the legs that have been played, won and lost in this game to the new pair
            # In each game, we don't have a specific legs_played field, so we have to add the legs won for this team to the legs won for the opposition team,
            # then subtract that figure from the original legs_played value in the doubles pair, which will be the combination of all the legs they've played
            my $team_legs_won_val = defined($self->$team_legs_won) ? $self->$team_legs_won : 0;
            my $opposition_legs_won_val = defined($self->$opposition_legs_won) ? $self->$opposition_legs_won : 0;
            $doubles_pair->legs_played($doubles_pair->legs_played + ( $team_legs_won_val + $opposition_legs_won_val ));
            $player1_season->doubles_legs_played($player1_season->doubles_legs_played + ( $team_legs_won_val + $opposition_legs_won_val ));
            $player2_season->doubles_legs_played($player2_season->doubles_legs_played + ( $team_legs_won_val + $opposition_legs_won_val ));
              
            $doubles_pair->legs_won($doubles_pair->legs_won + $team_legs_won_val);
            $player1_season->doubles_legs_won($player1_season->doubles_legs_won + $team_legs_won_val);
            $player2_season->doubles_legs_won($player2_season->doubles_legs_won + $team_legs_won_val);
            
            $doubles_pair->legs_lost($doubles_pair->legs_lost + $opposition_legs_won_val);
            $player1_season->doubles_legs_lost($player1_season->doubles_legs_lost + $opposition_legs_won_val);
            $player2_season->doubles_legs_lost($player2_season->doubles_legs_lost + $opposition_legs_won_val);
            
            # Add the points that have been played, won and lost in this game to the new pair
            # In each game, we don't have a specific legs_played field, so we have to add the legs won for this team to the legs won for the opposition team,
            # then subtract that figure from the original legs_played value in the doubles pair, which will be the combination of all the legs they've played
            my $team_points_won_val = defined($self->$team_points_won) ? $self->$team_points_won : 0;
            my $opposition_points_won_val = defined($self->$opposition_points_won) ? $self->$opposition_points_won : 0;
            $doubles_pair->points_played($doubles_pair->points_played + ( $team_points_won_val + $self->$opposition_points_won ));
            $player1_season->doubles_points_played($player1_season->doubles_points_played + ( $team_points_won_val + $opposition_points_won_val ));
            $player2_season->doubles_points_played($player2_season->doubles_points_played + ( $team_points_won_val + $opposition_points_won_val ));
            
            $doubles_pair->points_won($doubles_pair->points_won + $self->$team_points_won);
            $player1_season->doubles_points_won($player1_season->doubles_points_won + $team_points_won_val);
            $player2_season->doubles_points_won($player2_season->doubles_points_won + $team_points_won_val);
            
            $doubles_pair->points_lost($doubles_pair->points_lost + $opposition_points_won_val );
            $player1_season->doubles_points_lost($player1_season->doubles_points_lost + $opposition_points_won_val);
            $player2_season->doubles_points_lost($player2_season->doubles_points_lost + $opposition_points_won_val);
            
            # Work out the averages again
            $doubles_pair->games_played ? $doubles_pair->average_game_wins(( $doubles_pair->games_won / $doubles_pair->games_played ) * 100) : $doubles_pair->average_game_wins(0);
            $player1_season->doubles_games_played ? $player1_season->doubles_average_game_wins(( $player1_season->doubles_games_won / $player1_season->doubles_games_played ) * 100) : $player1_season->doubles_average_game_wins(0);
            $player2_season->doubles_games_played ? $player2_season->doubles_average_game_wins(( $player2_season->doubles_games_won / $player2_season->doubles_games_played ) * 100) : $player2_season->doubles_average_game_wins(0);
            
            $doubles_pair->legs_played ? $doubles_pair->average_leg_wins(( $doubles_pair->legs_won / $doubles_pair->legs_played ) * 100) : $doubles_pair->average_leg_wins(0);
            $player1_season->doubles_legs_played ? $player1_season->doubles_average_leg_wins(( $player1_season->doubles_legs_won / $player1_season->doubles_legs_played ) * 100) : $player1_season->doubles_average_leg_wins(0);
            $player2_season->doubles_legs_played ? $player2_season->doubles_average_leg_wins(( $player2_season->doubles_legs_won / $player2_season->doubles_legs_played ) * 100) : $player2_season->doubles_average_leg_wins(0);
            
            $doubles_pair->points_played ? $doubles_pair->average_point_wins(( $doubles_pair->points_won / $doubles_pair->points_played ) * 100) : $doubles_pair->average_point_wins(0);
            $player1_season->doubles_points_played ? $player1_season->doubles_average_point_wins(( $player1_season->doubles_points_won / $player1_season->doubles_points_played ) * 100) : $player1_season->doubles_average_point_wins(0);
            $player2_season->doubles_points_played ? $player2_season->doubles_average_point_wins(( $player2_season->doubles_points_won / $player2_season->doubles_points_played ) * 100) : $player2_season->doubles_average_point_wins(0);
            
            # Do the actual update after everything's been calculated
            $doubles_pair->update;
            $player1_season->update;
            $player2_season->update;
          }
          
          # Update our column if needed - we've already 'changed' the value, but not committed it
          $self->update;
          
          # Delete the original doubles pair IF:
          #  * There was a doubles pair set previously AND
          #  * it's different to the submitted doubles pair AND
          #  * there are no games played for the original doubles pair AND
          #  * either player for the original doubles pair are loan players
          $original_doubles_pair->delete if defined($original_doubles_pair) and $original_doubles_pair->id != $doubles_pair->id and $original_doubles_pair->games_played == 0 and ( $person1_loan or $person2_loan );
          
          # Complete
          $response->{completed} = 1;
          push(@{$response->{success}}, $lang->maketext("matches.game.update-doubles.add.success", $enc_player1_display, $enc_player2_display, $location, $self->scheduled_game_number));
        } elsif ( $action eq "remove" ) {
          # Remove
          if ( defined($original_doubles_pair) ) {
            # There is an original doubles pair, we need to delete the score - this will handle the statistics for that doubles pair too
            $self->update_score({delete => 1});
          }
          
          # Blank the doubles pair in this game
          $self->update({$location_doubles_pair => undef});
          
          # Delete the original doubles pair IF:
          #  * There was a doubles pair set previously AND
          #  * it's different to the submitted doubles pair AND
          #  * there are no games played for the original doubles pair
          $original_doubles_pair->delete if defined($original_doubles_pair) and $original_doubles_pair->games_played == 0;
          
          # Complete
          $response->{completed} = 1;
          push(@{$response->{success}}, $lang->maketext("matches.game.update-doubles.remove.success", $location, $self->scheduled_game_number));
        }
        
        $transaction->commit;
      } else {
        # Invalid location
        push(@{$response->{errors}}, $lang->maketext("matches.game.update-doubles.error.location-invalid"));
      }
    } else {
      # Error, game is not a doubles game.
      push(@{$response->{errors}}, $lang->maketext("matches.game.update-doubles.error.not-doubles-game", $self->scheduled_game_number));
    }
  }
  
  return $response;
}

=head2 result

Returns a hashref (keys: id = the msgid to use in maketext in the controller; parameters = an arrayref of parameters passed to maketext) denoting who won / lost / drew the game.

=cut

sub result {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Get the fields
  my $location = $params->{location} || undef;
  my $players = $params->{players} || [];
  my $response = {};
  my $match = $self->team_match;
  my $season = $match->season;
  my ( $home_team, $away_team ) = ( $match->team_season_home_team_season, $match->team_season_away_team_season );
  
  # Game is complete, select the correct winner, home and away players and game type based on whether it's singles or doubles
  #my ( $winner, $home_player, $away_player, $game_type, $match_home_player, $match_away_player, $home_player_missing, $away_player_missing );
  my ( $home_player_missing, $away_player_missing );
  my $winner = defined( $self->winner ) ? $self->winner->id : undef;
  my $doubles = $self->doubles_game;
  
  my @player_names = ();
  my @player_links = (); # This will hold placeholder text for the controller to replace, so we don't have to bring in Catalyst methods for getting the URI into the model.  Not ideal, but I can't think of anything better at the moment
  if ( $doubles ) {
    #@player_names = ( encode_entities($self->home_doubles_pair->person_season_person1_season_team->display_name), encode_entities($self->home_doubles_pair->person_season_person2_season_team->display_name), $self->away_doubles_pair->person_season_person1_season_team->display_name), encode_entities($self->away_doubles_pair->person_season_person2_season_team->display_name) );
    #@player_links = ( qw( {home_player1_link} {home_player2_link} {away_player1_link} {away_player2_link} ) );
  } else {
    # Need to get the person_season object, but there is no season column in this table, so it needs to be looked up
    my $home_player = $home_team->find_related("person_seasons", {person => $self->home_player->id});
    my $away_player = $away_team->find_related("person_seasons", {person => $self->away_player->id});
    #@player_names = ( encode_entities($home_player->display_name), encode_entities($away_player->display_name) );
    #@player_links = ( qw( {home_player_link} {away_player_link} ) );
  }
  
  my $game_type = $self->doubles_game ? "doubles" : "singles";
  
  # Work out if the home / away player is missing
  if ( $self->doubles_game ) {
    # Players can't be missing in the doubles
    $home_player_missing  = 0;
    $away_player_missing  = 0;
  } else {
    $home_player_missing  = $match->find_related("team_match_players", {player_number => $self->home_player_number})->player_missing;
    $away_player_missing  = $match->find_related("team_match_players", {player_number => $self->away_player_number})->player_missing;
  }
  
  # Check if the game is complete
  if ( $self->complete ) {
    if ( defined($winner) and !$self->awarded ) {
      # There is a winner
      # Check if the winner is home or away
      if ( $winner == $home_team->team->id ) {
        # Home winner
        $response->{message} = $lang->maketext("matches.game.result.home-$game_type-win");
      } else {
        # Away winner
        $response->{message} = $lang->maketext("matches.game.result.away-$game_type-win");
      }
    } elsif ( !$self->awarded ) {
      # Either a draw, or we have a player missing
      if ( $home_player_missing or $away_player_missing ) {
        if ( $home_player_missing and $away_player_missing ) {
          # Both players missing
          $response->{message} = $lang->maketext("matches.game.result.both-players-missing");
        } elsif ( $home_player_missing ) {
          # Home player missing
          $response->{message} = $lang->maketext("matches.game.result.home-player-missing");
        } else {
          # Away player missing
          $response->{message} = $lang->maketext("matches.game.result.away-player-missing");
        }
      } else {
        $response->{message} = $lang->maketext("matches.game.result.$game_type-draw");
      }
    } elsif ( $self->awarded ) {
      # Awarded - work out whether the game is started or not.
      my $leg1 = $self->find_related("team_match_legs", {leg_number => 1});
      
      if ( $leg1->started ) {
        if ( $winner == $home_team->id ) {
          # Home won, away player retired
          $response->{message} = $lang->maketext("matches.game.result.away-$game_type-player-retired");
        } else {
          # Away won, home player retired
          $response->{message} = $lang->maketext("matches.game.result.home-$game_type-player-retired");
        }
      } else {
        # If the game wasn't started, someone forefeited before it started
        if ( $home_player_missing and $away_player_missing ) {
          $response->{message} = $lang->maketext("matches.game.result.both-players-missing");
        } elsif ( $home_player_missing ) {
          $response->{message} = $lang->maketext("matches.game.result.home-player-missing");
        } elsif ( $away_player_missing ) {
          $response->{message} = $lang->maketext("matches.game.result.away-player-missing");
        } else {
          if ( $winner == $home_team->id ) {
            # Home won, away player retired
            $response->{message} = $lang->maketext("matches.game.result.away-$game_type-player-forefeited");
          } else {
            # Away won, home player retired
            $response->{message} = $lang->maketext("matches.game.result.home-$game_type-player-forefeited");
          }
        }
      }
    }
  } else {
    # Game not yet played
    $response->{message} = $lang->maketext("matches.game.score.not-yet-updated");
  }
  
  $response->{winner} = $winner;
  return $response;
}

=head2 summary_score

Returns a hashref with two keys ('home' and 'away'), which will have a value of the home and away team score for the game respectively.  If the match winner type is 'points', this will be the number of points each has won; otherwise it'll be legs.

=cut

sub summary_score {
  my ( $self ) = @_;
  
  if ( $self->team_match->team_match_template->winner_type->id eq "points" ) {
    # Return the number of points each has won
    return {
      home => $self->home_team_points_won,
      away => $self->away_team_points_won,
    };
  } else {
    # Return the number of legs each has won
    return {
      home => $self->home_team_legs_won,
      away => $self->away_team_legs_won,
    };
  }
}

=head2 detailed_scores

Returns an arrayref of leg scores.  Each array element has an hashref with keys 'home' and 'away'.

=cut

sub detailed_scores {
  my ( $self ) = @_;
  
  # Initialise the string we'll return
  my @scores = ();
  
  # Search for the legs
  my $legs = $self->search_related("team_match_legs", undef, {
    where  => [{
      home_team_points_won => {">" => 0}
    }, {
      away_team_points_won => {">" => 0}
    }],
    order_by => {-asc => "leg_number"},
  });
  
  # Loop through each leg
  if ( $legs->count ) {
    while ( my $leg = $legs->next ) {
      # Push this score on to the array
      #push(@scores, sprintf("%d-%d", $leg->home_team_points_won, $leg->away_team_points_won) );
      push(@scores, {leg_number => $leg->leg_number, home => $leg->home_team_points_won, away => $leg->away_team_points_won});
    }
    
    # Now return the values in an array ref
    return \@scores;
  } else {
    # No legs with scores in yet
    return undef;
  }
}

=head2 home_player_season

Retrieve the person season object associated with the home player, season and home team that the match is associated with.

=cut

sub home_player_season {
  my ( $self ) = @_;
  my $match = $self->team_match;
  
  # Nothing to return if this is a doubles game
  return undef if $self->doubles_game;
  
  return $self->home_player->find_related("person_seasons", {
    season => $match->season->id,
    team => $match->team_season_home_team_season->team->id,
  }) if defined($self->home_player);
}

=head2 away_player_season

Retrieve the person season object associated with the home player, season and home team that the match is associated with.

=cut

sub away_player_season {
  my ( $self ) = @_;
  my $match = $self->team_match;
  
  # Nothing to return if this is a doubles game
  return undef if $self->doubles_game;
  
  return $self->away_player->find_related("person_seasons", {
    season => $match->season->id,
    team => $match->team_season_away_team_season->team->id,
  }) if defined($self->away_player);
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
