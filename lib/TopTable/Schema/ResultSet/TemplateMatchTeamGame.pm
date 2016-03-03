package TopTable::Schema::ResultSet::TemplateMatchTeamGame;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Data::Dumper;

=head2 individual_game_templates

A predefined search to find and return the individual games and their templates for each team match game in a team match.

=cut

sub individual_game_templates {
  my ( $self, $team_match_template ) = @_;
  
  return $self->search({
    team_match_template => $team_match_template->id
  }, {
    order_by  => {
      -asc    => "match_game_number"
    },
    prefetch  => "individual_match_template"
  });
}

=head2 division_averages_list

A predefined search to find and return the players within a division in the order in which they should appear in the full league averages.

=cut

sub division_averages_list {
  my ( $self, $season, $division, $minimum_matches_played ) = @_;
  
  $minimum_matches_played = 0 if !$minimum_matches_played;
  
  return $self->search({
    "person_seasons.matches_played" => {
      ">="  => $minimum_matches_played
    },
    "person_seasons.division" => $division,
    "person_seasons.season"   => $season,
  }, { join   => "person_seasons",
    order_by  =>  {
      -desc => [
        "person_seasons.average_game_wins",
        "person_seasons.matches_played",
        "person_seasons.games_won",
        "person_seasons.games_played",
        "person_seasons.average_point_wins",
        "person_seasons.points_played",
        "person_seasons.points_won",
      ]
    },
  });
}



=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a club.

=cut

sub create_or_edit {
  my ( $self, $action, $parameters ) = @_;
  my ( $number_of_games, $loop_end );
  my $return_value = {error => []};
  
  my $id          = $parameters->{id} || undef;
  my $tt_template = $parameters->{tt_template} || undef;
  
  # Check the team match template
  unless ( defined( $tt_template ) and ref( $tt_template ) eq "TopTable::Model::DB::TemplateMatchTeam" ) {
    # Invalid template
    push(@{ $return_value->{error} }, {id => "templates.individual-match.form.error.template-invalid"});
    return $return_value;
  }
  
  my $team_match_template_id    = $tt_template->id;
  $return_value->{tt_template}  = $tt_template;
  
  # Check if we have an array of values (multiple games) or not (just a single game).
  if ( ref($parameters->{individual_match_template}) eq "ARRAY" ) {
    my $individual_match_templates  = scalar @{ $parameters->{individual_match_template} };
    
    # Store the number of games we're trying to create
    $number_of_games = scalar @{ $parameters->{individual_match_template} };
    $loop_end = $number_of_games - 1;
  } else {
    $number_of_games  = 1;
    $loop_end         = 0;
  }
  
  # Populate will be used to do the creation
  my $populate = [];
  
  # Values to flash if we need - empty arrayrefs at the moment; we'll push on to them as we go through the loop.
  my $flash = {
    individual_match_template   => [],
    doubles_game                => [],
    singles_home_player_number  => [],
    singles_away_player_number  => [],
  };
  
  # Now loop through our parameters
  for my $i (0 .. $loop_end) {
    my $game_number = $i + 1;
    my ( $individual_match_template, $individual_match_template_id, $doubles_game, $singles_home_player_number, $singles_away_player_number );
    
    # The first bit is easy; just take the entry from the original parameters
    # and assign it to the new destination.
    if ($number_of_games == 1) {
      $individual_match_template = $parameters->{individual_match_template};
      
      # If it's a doubles match, we'll have a checkbox called "doubles_game"; otherwise there will be dropdown
      # boxes with player numbers selected for home and away players.
      if ( $parameters->{doubles_game} ) {
        # It's a doubles game, set that key to 1 and the home / away players to undef
        $doubles_game               = 1;
        $singles_home_player_number = undef;
        $singles_away_player_number = undef;
      } else {
        # It's not a doubles game, set that key to 0 and the home / away players to the
        # submitted values
        $doubles_game               = 0;
        $singles_home_player_number = $parameters->{singles_home_player_number};
        $singles_away_player_number = $parameters->{singles_away_player_number};
      }
    } else {
      $individual_match_template = $parameters->{individual_match_template}[$i];
      
      # If it's a doubles match, we'll have a checkbox called "doubles_game"; otherwise there will be dropdown
      # boxes with player numbers selected for home and away players.
      if ( $parameters->{doubles_game}[$i] ) {
        # It's a doubles game, set that key to 1 and the home / away players to undef
        $doubles_game               = 1;
        $singles_home_player_number = undef;
        $singles_away_player_number = undef;
      } else {
        # It's not a doubles game, set that key to 0 and the home / away players to the
        # submitted values
        $doubles_game               = 0;
        $singles_home_player_number = $parameters->{singles_home_player_number}[$i];
        $singles_away_player_number = $parameters->{singles_away_player_number}[$i];
      }
    }
    
    # Now we've set our variables up, do some error checking
    if ( defined( $individual_match_template ) and ref( $individual_match_template ) eq "TopTable::Model::DB::TemplateMatchIndividual" ) {
      # This saves errors when trying to call ->id on an undefined value further down if it's invalid.
      $individual_match_template_id = $individual_match_template->id;
    } else {
      $return_value->{error} .= "The individual match template in game $game_number is not valid; please select one from the list.\n";
    }
    
    if ( $doubles_game ) {
      # Sanity check - if true, set to 1
      $doubles_game = 1;
    } else {
      # Check for invalid player numbers
      push(@{ $return_value->{error} }, {
        id          => "templates.team-match.games.error.home-player-number-invalid",
        parameters  => [$game_number, $tt_template->singles_players_per_team],
      }) if !defined( $singles_home_player_number ) or $singles_home_player_number !~ m/\d{1,2}/ or $singles_home_player_number > $tt_template->singles_players_per_team;
      
      push(@{ $return_value->{error} }, {
        id          => "templates.team-match.games.error.away-player-number-invalid",
        parameters  => [$game_number, ($tt_template->singles_players_per_team + 1), ($tt_template->singles_players_per_team * 2)],
      }) if !defined( $singles_home_player_number ) or $singles_away_player_number !~ m/\d{1,2}/ or $singles_away_player_number < ($tt_template->singles_players_per_team + 1) or $singles_away_player_number > ($tt_template->singles_players_per_team * 2);
    }
    
    # Finally push on to our populate array
    push( @{ $populate }, {
      team_match_template         => $team_match_template_id,
      individual_match_template   => $individual_match_template_id,
      match_game_number           => $game_number,
      doubles_game                => $doubles_game,
      singles_home_player_number  => $singles_home_player_number,
      singles_away_player_number  => $singles_away_player_number,
    });
    
    # Push on to the flash hash of arrays just in case we need to flash them
    push( @{ $flash->{individual_match_template} }, $individual_match_template_id );
    push( @{ $flash->{doubles_game} }, $doubles_game );
    push( @{ $flash->{singles_home_player_number} }, $singles_home_player_number );
    push( @{ $flash->{singles_away_player_number} }, $singles_away_player_number );
    
    if ( scalar( @{ $return_value->{error} } ) == 0 ) {
      # No errors, so we need to delete any existing games, as these new ones will overwrite.
      my $existing_games = $self->search({team_match_template => $team_match_template_id,})->delete;
      $self->populate( $populate );
      $return_value->{tt_template} = $tt_template;
    }
  }
  
  $return_value->{number_of_games}  = $number_of_games;
  $return_value->{flash}            = $flash;
  return $return_value;
}

1;