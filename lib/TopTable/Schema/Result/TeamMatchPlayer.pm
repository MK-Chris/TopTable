use utf8;
package TopTable::Schema::Result::TeamMatchPlayer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TeamMatchPlayer

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

=head1 TABLE: C<team_match_players>

=cut

__PACKAGE__->table("team_match_players");

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

=head2 player_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

Releates to the internal player number (1-6 if there are three players per team)

=head2 location

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

Home or away

=head2 player

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 player_missing

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 loan_team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

Team ID the player currently has active membership for so we know what was the active membership at the time of the match, even if that changes later on

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

=head2 games_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_drawn

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_played

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_leg_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_played

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_lost

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_point_wins

  data_type: 'float'
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
  "player_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "location",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "player",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "player_missing",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "loan_team",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
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
  "games_lost",
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
  "legs_played",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_lost",
  {
    data_type => "tinyint",
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
  "points_played",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "points_won",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "points_lost",
  {
    data_type => "smallint",
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
);

=head1 PRIMARY KEY

=over 4

=item * L</home_team>

=item * L</away_team>

=item * L</scheduled_date>

=item * L</player_number>

=back

=cut

__PACKAGE__->set_primary_key("home_team", "away_team", "scheduled_date", "player_number");

=head1 RELATIONS

=head2 loan_team

Type: belongs_to

Related object: L<TopTable::Schema::Result::Team>

=cut

__PACKAGE__->belongs_to(
  "loan_team",
  "TopTable::Schema::Result::Team",
  { id => "loan_team" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 location

Type: belongs_to

Related object: L<TopTable::Schema::Result::LookupLocation>

=cut

__PACKAGE__->belongs_to(
  "location",
  "TopTable::Schema::Result::LookupLocation",
  { id => "location" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 player

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "player",
  "TopTable::Schema::Result::Person",
  { id => "player" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-01-08 00:07:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:von89kVsRSbStDgfrI8W0w

use HTML::Entities;

=head2 person_season

Get the person season object for this player / team / season combination.  We can't link directly to that table from here, because the season column is in the match table, not this one, so we use this helper method instead.

=cut

sub person_season {
  my ( $self ) = @_;
  
  # Get the team season
  my $match = $self->match;
  my $team = $self->location->location eq "home" ? $match->team_season_home_team_season : $match->team_season_away_team_season;
  
  # Look for the person
  return $team->find_related("person_seasons", {person => $self->player->id});
}

=head2 update_person

Add or remove a person from this playing position.

=cut

sub update_person {
  my ( $self, $action, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  #$logger->("debug", "update_person, action: $action, params:");
  #$logger->("debug", np($params));
  
  # Get the fields
  my $loan_player = $params->{loan_player} || 0;
  my $person = $params->{person};
  my $location = $self->location->id;
  my $match = $self->team_match;
  my $season = $match->season;
  my ( $active_season, $loan_team );
  my $originally_missing = 0;
  my $game_scores_deleted = 0;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  # Get our season forefeit / void settings
  my $void_unplayed_games_if_both_teams_incomplete = $season->void_unplayed_games_if_both_teams_incomplete;
  my $missing_player_count_win_in_averages = $season->missing_player_count_win_in_averages;
  
  # First check the match wasn't cancelled; if it was, we return straight away
  if ( $match->cancelled ) {
    push(@{$response->{errors}}, $lang->maketext("matches.update.error.match-cancelled"));
    return $response;
  }
  
  # Log the original person in case of errors
  my ( $original_id, $original_name );
  if ( defined($self->player) ) {
    $original_id = $self->player->id;
    $original_name = $self->player->display_name;
  } elsif ( $self->player_missing ) {
    $originally_missing = 1;
  }
  
  $response->{original_player} = {
    id => $original_id,
    name => $original_name,
    loan_team => $self->loan_team,
  };
  
  # Check whether or not we have a person specified
  my $enc_display_name;
  if ( $action eq "add" ) {
    if ( defined($person) ) {
      # Lookup the person if we need to
      $person = $schema->resultset("Person")->find_id_or_url_key($person) unless ref($person) eq "TopTable::Model::DB::Person";
      
      if ( !defined($person) ) {
        push(@{$response->{errors}}, $lang->maketext("matches.add-player.error.person-invalid"));
        return $response;
      }
      
      $enc_display_name = encode_entities($person->display_name);
      my $enc_first_name = encode_entities($person->first_name);
      
      # If the person is available, get the season and division for this season
      $active_season = $person->find_related("person_seasons", {
        person => $person->id,
        "me.season" => $match->season->id,
        team_membership_type => "active",
      }, {
        prefetch => {
          team_season => [{
            division_season => "division",
            club_season => "club",
          }]
        },
        join => "team_membership_type",
        order_by => {-desc => qw( team_membership_type.display_order )},
      });
      
      if ( defined($active_season) ) {
        # Encode the text we need for messages back
        my $enc_active_team = encode_entities(sprintf("%s %s", $active_season->team_season->club_season->short_name, $active_season->team_season->name));
        
        # Check it's active to be safe
        if ( $loan_player ) {
          # Grab the loan player rules
          my $match_division = $match->division_season->division;
          my $enc_match_division = encode_entities($match_division->name);
          
          my $loan_allow_div_below = $season->allow_loan_players_below;
          my $loan_allow_div_above = $season->allow_loan_players_above;
          my $loan_allow_div_same = $season->allow_loan_players_across;
          my $loan_allow_club_same_only = $season->allow_loan_players_same_club_only;
          my $loan_allow_player_limit = $season->loan_players_limit_per_player;
          my $loan_allow_player_limit_per_team = $season->loan_players_limit_per_player_per_team;
          my $loan_allow_player_limit_per_opposition = $season->loan_players_limit_per_player_per_opposition;
          my $loan_allow_team_limit = $season->loan_players_limit_per_team;
          my $loan_allow_div_multi_team = $season->allow_loan_players_multiple_teams_per_division;
          
          # If it's a loan player, there's an initial check to ensure they are not actively playing for either of the teams involved in the match
          if ( $active_season->team_season->team->id == $match->team_season_home_team_season->team->id or $active_season->team_season->team->id == $match->team_season_away_team_season->team->id ) {
            # Can't use this person as a sub in a match involving their active team
            push(@{$response->{errors}}, $lang->maketext("matches.loan-player.add.error.player-active-for-team", $enc_display_name, $enc_active_team));
          } else {
            # Get the loan player's active team
            $loan_team = $active_season->team_season->team;
            
            # Get the name of the team this person is playing on loan for / against
            my $playing_for_team = $location eq "home" ? $match->team_season_home_team_season->team : $match->team_season_away_team_season->team;
            my $enc_playing_for_team_name = $location eq "home" ? encode_entities(sprintf("%s %s", $match->team_season_home_team_season->team->club->short_name, $match->team_season_home_team_season->team->name)) : encode_entities(sprintf("%s %s", $match->team_season_away_team_season->team->club->short_name, $match->team_season_away_team_season->team->name));
            
            my $playing_against_team = $location eq "home" ? $match->team_season_away_team_season->team : $match->team_season_home_team_season->team;
            my $enc_playing_against_team_name = $location eq "home" ? encode_entities(sprintf("%s %s", $match->team_season_away_team_season->team->club->short_name, $match->team_season_away_team_season->team->name)) : encode_entities(sprintf("%s %s", $match->team_season_home_team_season->team->club->short_name, $match->team_season_home_team_season->team->name));
            
            # Check if we have a limit on the number of times a player can play up
            if ( $loan_allow_player_limit > 0 ) {
              # Get the number of times this person has played up
              my $loan_times_played = $person->matches_on_loan({season => $season})->count;
              
              # Error if the person has already played up the maximum number of times
              push(@{$response->{errors}}, $lang->maketext("matches.loan-player.add.error.played-too-many-times", $enc_display_name, $loan_allow_player_limit, $enc_first_name, $enc_playing_for_team_name))
                  if $loan_times_played >= $loan_allow_player_limit;
            }
            
            # Check there's a limit on the number of times a player can play FOR a team
            if ( $loan_allow_player_limit_per_team ) {
              my $loan_played_this_team = $person->matches_on_loan({
                season => $season,
                for_team => $playing_for_team,
              })->count;
              
              # Error if this person has already played on loan for this team the maximum number of times
              push(@{$response->{errors}}, $lang->maketext("matches.loan-player.add.error.played-too-many-times-for-team", $enc_display_name, $enc_playing_for_team_name, $loan_allow_player_limit_per_team, $enc_first_name))
                  if $loan_played_this_team >= $loan_allow_player_limit_per_team;
            }
            
            # Check if there's a limit on the number of times a person can play AGAINST a team
            if ( $loan_allow_player_limit_per_opposition ) {
              my $loan_played_against_this_team = $person->matches_on_loan({
                season => $season,
                against_team => $playing_against_team,
              })->count;
              
              # Error if this person has played on loan against this team the maximum number of times
              push(@{$response->{errors}}, $lang->maketext("matches.loan-player.add.error.played-too-many-times-against-opposition", $enc_display_name, $enc_playing_against_team_name, $loan_allow_player_limit_per_opposition))
                  if $loan_played_against_this_team >= $loan_allow_player_limit_per_opposition;
            }
            
            # Check if there's a limit on the number of times a team can play loan players
            if ( $loan_allow_team_limit ) {
              my $matches_with_loan_players = $playing_for_team->loan_players({season => $season})->count;
              
              # Error if this team has already played the maximum number of loan players
              push(@{$response->{errors}}, $lang->maketext("matches.loan-player.add.error.team-played-too-many-loan-players", $enc_playing_for_team_name, $loan_allow_team_limit))
                  if $matches_with_loan_players >= $loan_allow_team_limit;
            }
            
            # Check if there's a stipulation that a player can only play on loan for one team per division
            unless ( $loan_allow_div_multi_team ) {
              my $matches_with_loan_players = $playing_for_team->loan_players({season => $season})->count;
              
              # Error if this person has already played on loan for a different team in this division
              push(@{$response->{errors}}, $lang->maketext("matches.loan-player.add.error.cannot-play-for-more-than-one-team-in-division", $enc_display_name, $enc_match_division))
                  if $person->matches_on_loan({
                    season => $season,
                    division => $match_division,
                    not_for_team => $playing_for_team,
                  })->count > 1;
            }
            
            # Get the active division so we can check the player is authorised to play on loan in this division
            my $loan_division = $active_season->team_season->division_season->division;
            my $enc_loan_division = encode_entities($loan_division->name);
            
            # Check if we can allow people from lower divisions to play on loan
            unless ( $loan_allow_div_below ) {
              # Error if this player is from a division below
              push(@{$response->{errors}}, $lang->maketext("matches.loan-player.add.error.cant-add-from-division-below", $enc_display_name, $enc_loan_division, $enc_match_division))
                  if $loan_division->rank > $match_division->rank;
            }
            
            # Check if we can allow people from higher divisions to play on loan
            unless ( $loan_allow_div_above ) {
              # Error if this player is from a division above
              push(@{$response->{errors}}, $lang->maketext("matches.loan-player.add.error.cant-add-from-division-above", $enc_display_name, $enc_loan_division, $enc_match_division))
                  if $loan_division->rank < $match_division->rank;
            }
            
            # Check if we can allow people from the same divisional rank to play on loan
            unless ( $loan_allow_div_same ) {
              # Error if this player is from the same divisional rank
              push(@{$response->{errors}}, $lang->maketext("matches.loan-player.add.error.cant-add-from-same-division", $enc_display_name, $enc_loan_division))
                  if $loan_division->rank == $match_division->rank;
            }
          }
          
          # Check if we can allow people to play on loan from different clubs
          if ( $loan_allow_club_same_only ) {
            my $loan_club = $active_season->team_season->team->club;
            my $playing_club = $location eq "home" ? $match->team_season_home_team_season->team->club : $match->team_season_away_team_season->team->club;
            
            # Error if this person plays for a different club
            push(@{$response->{errors}}, $lang->maketext("matches.loan-player.add.error.cant-play-for-different-clubs", $enc_display_name, encode_entities($playing_club->full_name), encode_entities($loan_club->full_name)))
                if $loan_club->id != $playing_club->id;
          }
        }
        
        # Check that we have not got this person set in a position for this match already
        my $player_already_set = $match->search_related("team_match_players", undef, {
          where => {
            player_number => {"!=" => $self->player_number},
            player => $person->id,
          },
          rows => 1,
        })->single;
        
        push(@{$response->{errors}}, $lang->maketext("matches.add-player.error.player-already-set", $enc_display_name, $player_already_set->player_number))
            if defined($player_already_set);
        
      } else {
        # No teams for this person this season
        push(@{$response->{errors}}, $lang->maketext("matches.loan-player.add.error.player-not-active", $enc_display_name, encode_entities($match->season->name)));
      }
    } else {
      # No player specified
      push(@{$response->{errors}}, $lang->maketext("matches.add-player.error.person-blank"));
      return $response;
    }
  } else {
    # Action is not add - make sure we undef the person, just in case it was passed
    undef($person);
  }
  
  # Get the original player in this position
  my $match_team_field = $location eq "home" ? "team_season_home_team_season" : "team_season_away_team_season";
  my $original_player_season = $self->player->search_related("person_seasons", {
    season => $match->season->id,
    team => $match->$match_team_field->team->id,
  }, {
    rows => 1,
  })->single if defined($self->player);
  
  # Check that the original player (i.e., the one being either removed or replaced) is A) not a loan player AND B) not set as a player in a doubles match; if so,
  # this is an error, as loan players can only play doubles in games that they are playing in; to remove the player from the match, the user must first remove
  # them from any doubles game(s).
  if ( defined($original_player_season) and $original_player_season->team_membership_type->id eq "loan" ) {
    # First find doubles pairs with this person where they're playing for this team (either as player 1 or player 2), then map them to their IDs so we can
    # use them in an IN statement
    my @doubles_pairs = $original_player_season->search_related("doubles_pairs_person1_season_teams")->all;
    push(@doubles_pairs, $original_player_season->search_related("doubles_pairs_person2_season_teams")->all);
    my @doubles_pairs_ids = map($_->id, @doubles_pairs);
    
    # Find any doubles games in this match with this player in
    my $doubles_games = $match->search_related("team_match_games", {
      doubles_game => 1,
      sprintf("%s_doubles_pair", $location) => {-in => \@doubles_pairs_ids},
    });
    
    if ( $doubles_games->count ) {
      # This player is set in at least one doubles pairing in this match.  We need to work out which error message to display depending on:
      #  * whether there's one or more doubles games with them set.
      #  * whether we're trying to add a player (therefore replace this player) or delete the player.
      # What we can do first of all regardless is encode the display name, as we know we will use it in one of the error messages
      my $enc_original_player_name = encode_entities($original_player_season->display_name);
      
      if ( $doubles_games->count == 1 ) {
        # One doubles game
        my $game_number = $doubles_games->first->scheduled_game_number;
        
        if ( $action eq "add" ) {
          # Adding a player
          push(@{$response->{errors}}, $lang->maketext("matches.add-player.error.cant-replace-loan-player-set-in-doubles-game", $enc_original_player_name, $game_number));
        } else {
          # Deleting the player
          push(@{$response->{errors}}, $lang->maketext("matches.remove-player.error.loan-player-set-in-doubles-game", $enc_original_player_name, $game_number));
        }
      } elsif ( $doubles_games->count > 1 ) {
        # More than one doubles game
        my @games = $doubles_games->all;
        
        # Get the last element from the list, as we don't want this to have commas before it
        my $last = pop(@games);
        
        # Now join all the remaining elements with ", " and add " and $last" to the end of it
        my $game_numbers = sprintf("%s %s %s", join(", ", @games), $lang->maketext("msg.and"), $last);
        
        if ( $action eq "add" ) {
          # Adding a player
          push(@{$response->{errors}}, $lang->maketext("matches.add-player.error.cant-replace-loan-player-set-in-doubles-games", $enc_original_player_name, $game_numbers));
        } else {
          # Deleting the player
          push(@{$response->{errors}}, $lang->maketext("matches.remove-player.error.loan-player-set-in-doubles-games", $enc_original_player_name, $game_numbers));
        }
      }
    }
  }
  
  # Check if we got an error
  #$logger->("debug", "check for errors");
  if ( scalar @{$response->{errors}} == 0 ) {
    #$logger->("debug", "no errors");
    # Wrap all our database writing into a transaction
    my $transaction = $self->result_source->schema->txn_scope_guard;
    
    # Get the opposition missing players
    my $opposition_missing_players = $location eq "home"
      ? $match->away_players_absent
      : $match->home_players_absent if $void_unplayed_games_if_both_teams_incomplete;
    
    # We need to search the games involving this player to see which ones have an opponent player set against them - the ones who have an opponent player set,
    # we will set both players into the game so the system knows the game is ready to be completed.
    my $games_to_update = $match->search_related("team_match_games", {sprintf("%s_player_number", $location) => $self->player_number});
    
    # Loop through and check we have an opposition player for each game we've returned
    while( my $player_game = $games_to_update->next ) {
      my ( $opposition_location, $opposition_player_num_fld ) = $location eq "home"
        ? ( "away", "away_player_number" )
        : ( "home", "home_player_number" );
      
      # Grab the opposition player
      my $opposition_player = $match->find_related("team_match_players", {
        player_number => $player_game->$opposition_player_num_fld,
      }, {
        prefetch => "player",
      });
      
      # If we're removing a player, we need to zero their score for each game, as we can't have
      # scores without players.
      # If we're adding a player where they were previously missing, we also call the delete routine
      # to unvoid / unaward the game and remove the missing flag.
      if ( !defined($person) or ( defined($person) and $originally_missing ) ) {
        #$logger->("debug", sprintf("deleting game %s", $player_game->scheduled_game_number));
        my $remove_missing = $originally_missing and $action ne "set-missing" ? $location : undef; # Remove the missing flag if the person was marked missing and is now not
        my $delete_result = $player_game->update_score({delete => 1, remove_missing => $remove_missing, logger => $logger});
        
        # Slightly misleading name in this instance, but discard_changes refreshes the match from the DB, so that if the changes to the game
        # resulted in the match not being started, we can detect that now with $match->started.  discard_changes refers to discarding any individual
        # field changes made prior to calling ->update.
        $match->discard_changes;
        
        # Game scores are deleted, so the update_score() routine for each game will udpate the player_season statistics - flag this,
        # so we don't try and do it again.
        $game_scores_deleted = 1;
      }
      
      # Now we ensure the person objects are correct or are cleared - we have to do this after the above delete,
      # as that routine will fail if a player isn't set and in any case, it needs to know which person to subtract
      # the statistics from
      if ( $action eq "add" ) {
        # Adding
        # Grab the opposition missing flag according to whether the person we're updating is home or away
        my $opposition_missing = $location eq "home" ? $player_game->away_player_missing : $player_game->home_player_missing;
        
        if ( defined($opposition_player->player) and defined($person) ) {
          # If the opposition player is also set, then set both players to this game
          $player_game->update({
            sprintf("%s_player", $location) => $person->id,
            sprintf("%s_player", $opposition_location) => $opposition_player->player->id,
          });
        } elsif ( $opposition_missing ) {
          $player_game->update({
            sprintf("%s_player", $location) => $person->id,
            sprintf("%s_player", $opposition_location) => undef,
          });
        }
      } elsif ( $action eq "set-missing" ) {
        # Set missing - depends on a couple of the season rules
        if ( $void_unplayed_games_if_both_teams_incomplete and $opposition_missing_players ) {
          # Missing players, and missing players on the other team, so any unplayed games are void - do not set the players in the game
          $player_game->update({
            sprintf("%s_player", $location) => undef,
            sprintf("%s_player", $opposition_location) => undef,
          });
        } elsif ( $missing_player_count_win_in_averages and defined($opposition_player->player) ) {
          # Player is missing and there's an opposition player set, set them in this game because we count wins with missing players
          $player_game->update({
            sprintf("%s_player", $location) => undef,
            sprintf("%s_player", $opposition_location) => $opposition_player->player->id,
          });
        }
      } else {
        # If the opposition player is not set, make sure we remove both players from this game if they are set.
        $player_game->update({
          home_player => undef,
          away_player => undef,
        });
      }
    }
    
    # We need to update the season statistics for both the old person (if they were set) and the new
    my ( $new_player_season );
    if ( defined($person) ) {
      # Look for a person_season row for this player, team and season; create one if it's not there.
      $new_player_season = $person->search_related("person_seasons", {
        season => $match->season->id,
        team => $match->$match_team_field->team->id,
      }, {
        rows => 1,
      })->single;
      
      # Create a new season object for the new person if there isn't one already - this will 
      $new_player_season = $person->create_related("person_seasons", {
        season => $match->season->id,
        team => $match->$match_team_field->team->id,
        team_membership_type => "loan",
        first_name => $person->first_name,
        surname => $person->surname,
        display_name => $person->display_name,
      }) unless defined($new_player_season);
    }
    
    if ( defined($original_player_season) ) {
      # We have a player already, so we're replacing (or removing)
      if ( $match->started ) {
        # If the match has been started, we need to update the statistics
        
        # Add a match played if the match has started
        $new_player_season->matches_played($new_player_season->matches_played + 1) if defined $new_player_season;
        $original_player_season->matches_played($original_player_season->matches_played - 1);
        
        if ( $match->complete and !$game_scores_deleted ) {
          # Matches won / lost / drawn need to be worked out if the match is complete
          if ( $match->home_team_match_score > $match->away_team_match_score ) {
            # Home win
            if ( $location eq "home" ) {
              # Home player, add a match won to new, remove from old
              $original_player_season->matches_won($original_player_season->matches_won - 1);
              $new_player_season->matches_won($new_player_season->matches_won + 1) if defined($new_player_season);
            } else {
              # Away player, add a match lost to new, remove from old
              $original_player_season->matches_lost($original_player_season->matches_lost - 1);
              $new_player_season->matches_lost($new_player_season->matches_lost + 1) if defined($new_player_season);
            }
          } elsif ( $match->home_team_match_score < $match->away_team_match_score ) {
            # Away win
            if ( $location eq "home" ) {
              # Home player, add a match lost to new, remove from old
              $original_player_season->matches_lost($original_player_season->matches_lost - 1);
              $new_player_season->matches_lost($new_player_season->matches_lost + 1) if defined($new_player_season);
            } else {
              # Away player, add a match won to new, remove from old
              $original_player_season->matches_won($original_player_season->matches_won - 1);
              $new_player_season->matches_won($new_player_season->matches_won + 1) if defined($new_player_season);
            }
          } else {
            # Draw, regardless of home or away, add a match drawn to new, remove from old
            $original_player_season->matches_drawn($original_player_season->matches_drawn - 1);
            $new_player_season->matches_drawn($new_player_season->matches_drawn + 1) if defined($new_player_season);
          }
        }
        
        if ( !$game_scores_deleted ) {
          # Transfer the games statistics
          $original_player_season->games_played($original_player_season->games_played - $self->games_played);
          $new_player_season->games_played($new_player_season->games_played + $self->games_played) if defined($new_player_season);
          $original_player_season->games_won($original_player_season->games_won - $self->games_won);
          $new_player_season->games_won($new_player_season->games_won + $self->games_won) if defined($new_player_season);
          $original_player_season->games_lost($original_player_season->games_lost - $self->games_lost);
          $new_player_season->games_lost($new_player_season->games_lost + $self->games_lost) if defined($new_player_season);
          $original_player_season->games_drawn($original_player_season->games_drawn - $self->games_drawn);
          $new_player_season->games_drawn($new_player_season->games_drawn + $self->games_drawn) if defined($new_player_season);
          
          # Transfer the legs statistics
          $original_player_season->legs_played($original_player_season->legs_played - $self->legs_played);
          $new_player_season->legs_played($new_player_season->legs_played + $self->legs_played) if defined($new_player_season);
          $original_player_season->legs_won($original_player_season->legs_won - $self->legs_won);
          $new_player_season->legs_won($new_player_season->legs_won + $self->legs_won) if defined($new_player_season);
          $original_player_season->legs_lost($original_player_season->legs_lost - $self->legs_lost);
          $new_player_season->legs_lost($new_player_season->legs_lost + $self->legs_lost) if defined($new_player_season);
          
          # Transfer the points statistics
          $original_player_season->points_played($original_player_season->points_played - $self->points_played);
          $new_player_season->points_played($new_player_season->points_played + $self->points_played) if defined($new_player_season);
          $original_player_season->points_won($original_player_season->points_won - $self->points_won);
          $new_player_season->points_won($new_player_season->points_won + $self->points_won) if defined($new_player_season);
          $original_player_season->points_lost($original_player_season->points_lost - $self->points_lost);
          $new_player_season->points_lost($new_player_season->points_lost + $self->points_lost) if defined($new_player_season);
          
          # Work out the averages
          $original_player_season->games_played ? $original_player_season->average_game_wins(( $original_player_season->games_won / $original_player_season->games_played ) * 100)  : $original_player_season->average_game_wins(0);
          defined($new_player_season) and $new_player_season->games_played ? $new_player_season->average_game_wins(( $new_player_season->games_won / $new_player_season->games_played ) * 100) : $new_player_season->average_game_wins(0);
          
          $original_player_season->legs_played ? $original_player_season->average_leg_wins(( $original_player_season->legs_won / $original_player_season->legs_played ) * 100)  : $original_player_season->average_leg_wins(0);
          defined($new_player_season) and $new_player_season->legs_played ? $new_player_season->average_leg_wins(( $new_player_season->legs_won / $new_player_season->legs_played ) * 100) : $new_player_season->average_leg_wins(0);
          
          $original_player_season->points_played ? $original_player_season->average_point_wins(( $original_player_season->points_won / $original_player_season->points_played ) * 100)  : $original_player_season->average_point_wins(0);
          defined($new_player_season) and $new_player_season->points_played ? $new_player_season->average_point_wins(( $new_player_season->points_won / $new_player_season->points_played ) * 100) : $new_player_season->average_point_wins(0);
        }
          
        # Now do the updates.  The exception is if the original player was a loan player and this is the only match
        # they were down as playing for the team, their record for this team will be deleted, as it's blank anyway.
        
        # These are updated regardless of whether or not the scores were deleted earlier, as we still may need to add / remove a match played from the players being swapped.
        $new_player_season->update if defined($new_player_season);
        $original_player_season->update;
      }
      
      my $ok = $original_player_season->delete if $original_player_season->matches_played == 0 and $original_player_season->team_membership_type->id eq "loan";
    } elsif ( $match->started and $action ne "set-missing" and $action ne "remove" ) {
      # We're adding a player where there wasn't previously one (we don't do this for the other way round - removing a player where
      # there was previously one - as that's already handled above by the score deletion).
      
      # Search for the player's season object with this team and create it if it isn't there.
      my $match_team_field = $location eq "home" ? "team_season_home_team_season" : "team_season_away_team_season";
      
      my $new_player_season = $person->search_related("person_seasons", {
        season => $match->season->id,
        team => $match->$match_team_field->team->id,
      }, {
        rows => 1,
      })->single;
      
      # Create a new season object for the new person if there isn't one already
      $new_player_season = $person->create_related("person_seasons", {
        season => $match->season->id,
        team => $match->$match_team_field->team->id,
        team_membership_type => "loan"
      }) unless defined($new_player_season);
      
      $new_player_season->update({matches_played => $new_player_season->matches_played + 1});
      
      if ( $match->complete ) {
        # Matches won / lost / drawn need to be worked out if the match is complete
        if ( $match->home_team_match_score > $match->away_team_match_score ) {
          # Home win
          if ( $location eq "home" ) {
            # Home player, add a match won to new, remove from old
            $new_player_season->matches_won($new_player_season->matches_won + 1) if defined($new_player_season);
          } else {
            # Away player, add a match lost to new, remove from old
            $new_player_season->matches_lost($new_player_season->matches_lost + 1) if defined($new_player_season);
          }
        } elsif ( $match->home_team_match_score < $match->away_team_match_score ) {
          # Away win
          if ( $location eq "home" ) {
            # Home player, add a match lost to new, remove from old
            $new_player_season->matches_lost($new_player_season->matches_lost + 1) if defined($new_player_season);
          } else {
            # Away player, add a match won to new, remove from old
            $new_player_season->matches_won($new_player_season->matches_won + 1) if defined($new_player_season);
          }
        } else {
          # Draw, regardless of home or away, add a match drawn to new, remove from old
          $new_player_season->matches_drawn($new_player_season->matches_drawn + 1) if defined($new_player_season);
        }
      }
    }
    
    # Finally do the update of the person in the match itself
    my $player_missing;
    #$logger->("debug", "set missing flags");
    if ( $action eq "set-missing" ) {
      undef($loan_team); # Can't be a loan player if we're setting a missing player
      $player_missing = 1;
    } else {
      $player_missing = 0;
    }
    
    $self->update({
      player => defined($person) ? $person->id : undef,
      loan_team => $loan_team,
      player_missing => $player_missing,
    });
    
    # If the void_unplayed_games_if_both_teams_incomplete season setting is on and there are missing players on the other team, we may need to delete and re-update those games
    # so they get voided (if this team previously didn't have a missing player, they wouldn't have voided).
    if ( $void_unplayed_games_if_both_teams_incomplete and ($player_missing or $originally_missing) ) {
      # This player is missing; check if the other side has a player missing
      
      if ( $opposition_missing_players ) {
        # Games to update isn't just the games for this player any more, it's any game with a missing player, as they all need voiding.
        # That will include this player's games inherently, as this player is marked missing.
        # We have to search for games where any player is missing.  We can't use the helper methods home_player_missing and away_player_missing sadly,
        # as they're not real DB columns, so we need to do a rather convoluted lookup from the join back to the match, then team_match_players.
        $games_to_update = $match->search_related("team_match_games", [{
          "team_match_players.player_missing" => 1,
          "me.home_player_number" => {"=" => \"team_match_players.player_number"},
          "team_match_players.location" => "home",
        }, {
          "team_match_players.player_missing" => 1,
          "me.away_player_number" => {"=" => \"team_match_players.player_number"},
          "team_match_players.location" => "away",
        }], {
          join => {team_match => "team_match_players"},
          group_by => [qw( me.actual_game_number )],
          order_by => {-asc => [qw( me.actual_game_number )]},
        });
        
        while ( my $game = $games_to_update->next ) {
          # Re-delete - some of these will have already been deleted above (in which case calling this will have no effect),
          # but we need to ensure we're deleting the other scores with missing players too
          #$logger->("debug", sprintf("delete game %s with opposition missing", $game->scheduled_game_number));
          my $delete_result = $game->update_score({delete => 1, logger => $logger});
        }
      }
    }
    
    
    # Go back to the first game - we are going to update the score for each, but couldn't do it in the first loop because we need to remove the person
    # and set the 'missing' flag first (and we can't move that previous loop down here because that would mean we were potentially doing a score deletion
    # after removing the original player, which wouldn't work, as the routine needs to know which player to take the statistics from).
    
    # Note we don't provide scores, as these games aren't actually played, we merely tell the routine to update and it calculates the match scores knowing that
    # one or other of the players are missing.
    $games_to_update->reset;
    #$logger->("debug", "reset games to update and loop through");
    while( my $player_game = $games_to_update->next ) {
      # Get the opposition player to find out if they're missing
      my ( $opposition_location, $opp_player_num_fld, $opposition_missing ) = $location eq "home"
        ? ( "away", "away_player_number", $player_game->away_player_missing )
        : ( "home", "home_player_number", $player_game->home_player_missing );
      
      # Update the score here if either player is missing
      
      #$logger->("debug", "check if we need to update game " . $player_game->scheduled_game_number);
      my $update_result;
      if ( $action eq "set-missing" ) {
        # Update the score based on this player being missing
        #$logger->("debug", sprintf("updating game %s with new missing player", $player_game->scheduled_game_number));
        $update_result = $player_game->update_score({logger => $logger});
      } elsif ( $opposition_missing ) {
        # Action isn't set missing, but there's an opposition player missing
        #$logger->("debug", sprintf("updating game %s as the opposition player is missing", $player_game->scheduled_game_number));
        $update_result = $player_game->update_score({logger => $logger});
      } else {
        #$logger->("debug", sprintf("not updating game %s as no one is marked missing, opposition player number: %s, this player location: %s", $player_game->scheduled_game_number, $player_game->$opp_player_num_fld, $location));
      }
      
      $match->discard_changes;
    }
    
    # Get the games involving this player that also have another player involved
    my $return_player_games = [];
    my @player_games = $games_to_update->all;
    foreach my $game ( @player_games ) {
      push (@{$return_player_games}, $game->scheduled_game_number) if defined($game->home_player) and defined($game->away_player);
    }
    
    $response->{player_games} = $return_player_games;
    
    my $success_msg;
    if ( $action eq "add" ) {
      # Adding a player
      $success_msg = $loan_player ? $lang->maketext("matches.loan-player.add.success", $enc_display_name, $self->player_number) : $lang->maketext("matches.active-player.add.success", $enc_display_name, $self->player_number);
    } elsif ( $action eq "remove" ) {
      # Removing a player
      $success_msg = $lang->maketext("matches.player.remove.success", $self->player_number);
    } else {
      # Set an absent player
      $success_msg = $lang->maketext("matches.player.set-missing.success", $self->player_number);
    }
    
    push(@{$response->{success}}, $success_msg);
    $response->{completed} = 1;
    
    # Finally commit the transaction if there are no errors
    $transaction->commit;
  }
  
  $response->{match_scores} = $match->calculate_match_score;
  return $response;
}

=head2 loan_team_season

Retrieve the season object for a loan player's team if this player has been loaned.

=cut

sub loan_team_season {
  my ( $self ) = @_;
  
  # Return with undefined if the player isn't a loan player
  return undef unless defined($self->loan_team);
  
  my $match = $self->team_match;
  
  # Otherwise, retrieve the season 
  return $self->loan_team->find_related("team_seasons", {
    season => $match->season->id,
    "division_season.season" => $match->season->id,
  }, {
    prefetch => [qw( team ), {
      club_season => "club",
      division_season => "division",
    }],
  });
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
