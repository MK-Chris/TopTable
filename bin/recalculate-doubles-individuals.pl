#!/usr/bin/perl

use strict;
use warnings;
use DateTime;
use DateTime::TimeZone;
use Try::Tiny;
use FindBin qw( $Bin );
use lib "$Bin/../lib";
use Data::Dumper;
use TopTable::Schema;
use Data::Dumper;

my $schema  = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");

my $people = $schema->resultset("Person")->search({
  #url_key => "chris-welch",
}, {
  prefetch => "person_seasons",
});

my $people_wrong    = 0;
my $averages_wrong  = 0;
while ( my $person = $people->next ) {
  my $team_associations = $person->person_seasons;
  
  while ( my $team_association = $team_associations->next ) {
    # Doubles pairs involving this person for this team
    my @doubles_pairs = $schema->resultset("DoublesPair")->search([{
      person1 => $person->id,
      team    => $team_association->team->id,
    }, {
      person2 => $person->id,
      team    => $team_association->team->id,
    }]);
    
    if ( scalar( @doubles_pairs ) ) { 
      my @pair_ids = map($_->id, @doubles_pairs);
      
      my $games_played = $schema->resultset("TeamMatchGame")->search([{
        doubles_game      => 1,
        started           => 1,
        home_doubles_pair => {
          -in => \@pair_ids,
        }
      }, {
        doubles_game      => 1,
        started           => 1,
        away_doubles_pair => {
          -in => \@pair_ids,
        }
      }]);
      
      my ( $games_won, $games_lost, $games_drawn, $average_game_wins, $legs_played, $legs_won, $legs_lost, $average_leg_wins, $points_played, $points_won, $points_lost, $average_point_wins ) = qw( 0 0 0 0 0 0 0 0 0 0 0 0 );
      
      while( my $game = $games_played->next ) {
        if ( $game->winner->id == $team_association->team->id ) {
          $games_won++;
        } else {
          $games_lost++;
        }
        
        # Legs / points played
        $legs_played    += ( $game->home_team_legs_won    + $game->away_team_legs_won );
        $points_played  += ( $game->home_team_points_won  + $game->away_team_points_won );
        
        # Work out if we're home or away by finding out if the ID we found is the home or away ID - first loop through the possible IDs
        my $this_pair_id;
        foreach my $id ( @pair_ids ) {
          if ( $id == $game->home_doubles_pair->id ) {
            $legs_won     += $game->home_team_legs_won;
            $legs_lost    += $game->away_team_legs_won;
            $points_won   += $game->home_team_points_won;
            $points_lost  += $game->away_team_points_won;
            last;
          } elsif ( $id == $game->away_doubles_pair->id ) {
            $legs_won     += $game->away_team_legs_won;
            $legs_lost    += $game->home_team_legs_won;
            $points_won   += $game->away_team_points_won;
            $points_lost  += $game->home_team_points_won;
            last;
          }
        }
      }
      
      # Work out the averages
      $average_game_wins  = ( $games_played->count ) ? ( ( $games_won / $games_played ) * 100 ) : 0;
      $average_leg_wins   = ( $legs_played ) ? ( ( $legs_won / $legs_played ) * 100 ) : 0;
      $average_point_wins = ( $points_played ) ? ( ( $points_won / $points_played ) * 100 ) : 0;
      
      if ( $games_played->count != $team_association->doubles_games_played or $games_won != $team_association->doubles_games_won or $games_lost != $team_association->doubles_games_lost or $average_game_wins != $team_association->doubles_average_game_wins or $legs_played != $team_association->doubles_legs_played or $legs_won != $team_association->doubles_legs_won or $legs_lost != $team_association->doubles_legs_lost or $average_leg_wins != $team_association->doubles_average_leg_wins or $points_played != $team_association->doubles_points_played or $points_won != $team_association->doubles_points_won or $points_lost != $team_association->doubles_points_lost or $average_point_wins != $team_association->doubles_average_point_wins ) {
        $people_wrong++;
        printf "%s: %s %s\n", $person->display_name, $team_association->team->club->short_name, $team_association->team->name;
        
        my ( $games_changed, $legs_changed, $points_changed ) = qw( 0 0 0 );
        
        ## Games
        if ( $games_played->count != $team_association->doubles_games_played ) {
          $games_changed = 1;
          printf "Officially played: %d games, changed to: %d\n", $team_association->doubles_games_played, $games_played->count;
          $team_association->doubles_games_played( $games_played->count );
        }
        
        if ( $games_won != $team_association->doubles_games_won ) {
          $games_changed = 1;
          printf "Officially won: %d games, changed to: %d\n", $team_association->doubles_games_won, $games_won;
          $team_association->doubles_games_won( $games_won );
        }
        
        if ( $games_lost != $team_association->doubles_games_lost ) {
          printf "Officially lost: %d games, changed to: %d\n", $team_association->doubles_games_lost, $games_lost;
          $team_association->doubles_games_lost( $games_lost );
        }
        
        if ( $average_game_wins != $team_association->doubles_average_game_wins or $games_changed ) {
          printf "Official game average: %d, changed to: %d\n", $team_association->doubles_average_game_wins, $average_game_wins;
          $team_association->doubles_average_game_wins( $average_game_wins );
        }
        
        ## Legs
        if ( $legs_played != $team_association->doubles_legs_played ) {
          $legs_changed = 1;
          printf "Officially played: %d legs, changed to: %d\n", $team_association->doubles_legs_played, $legs_played;
          $team_association->doubles_legs_played( $legs_played );
        }
        
        if ( $legs_won != $team_association->doubles_legs_won ) {
          $legs_changed = 1;
          printf "Officially won: %d legs, changed to: %d\n", $team_association->doubles_legs_won, $legs_won;
          $team_association->doubles_legs_won( $legs_won );
        }
        
        if ( $legs_lost != $team_association->doubles_legs_lost ) {
          printf "Officially lost: %d legs, changed to: %d\n", $team_association->doubles_legs_lost, $legs_lost;
          $team_association->doubles_legs_lost( $legs_lost );
        }
        
        if ( $average_leg_wins != $team_association->doubles_average_leg_wins or $legs_changed ) {
          printf "Official leg average: %d, change to: %d\n", $team_association->doubles_average_leg_wins, $average_leg_wins;
          $team_association->doubles_average_leg_wins( $average_leg_wins );
        }
        
        ## Points
        if ( $points_played != $team_association->doubles_points_played ) {
          $points_changed = 1;
          printf "Officially played: %d points, changed to: %d\n", $team_association->doubles_points_played, $points_played;
          $team_association->doubles_points_played( $points_played );
        }
        
        if ( $points_won != $team_association->doubles_points_won ) {
          $points_changed = 1;
          printf "Officially won: %d points, changed to: %d\n", $team_association->doubles_points_won, $points_won;
          $team_association->doubles_points_won( $points_won );
        }
        
        if ( $points_lost != $team_association->doubles_points_lost ) {
          printf "Officially lost: %d points, changed to: %d\n", $team_association->doubles_points_lost, $points_lost;
          $team_association->doubles_points_lost( $points_lost );
        }
        
        if ( $average_point_wins != $team_association->doubles_average_point_wins or $points_changed ) {
          printf "Official point average: %d, changed to: %d\n", $team_association->doubles_average_point_wins, $average_point_wins;
          $team_association->doubles_average_point_wins( $average_point_wins );
        }
        
        print "\n";
        
        $team_association->update;
      }
    }
  }
}

print "$people_wrong with wrong statistics\n";