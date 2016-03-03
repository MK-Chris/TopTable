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

my $people_wrong = 0;
while ( my $person = $people->next ) {
  my $team_associations = $person->person_seasons;
  
  while ( my $team_association = $team_associations->next ) {
    my $matches_played = $schema->resultset("TeamMatch")->search([{
      season                        => 1,
      "me.home_team"                => $team_association->team->id,
      "team_match_players.player"   => $person->id,
      "team_match_players.location" => "home",
      "me.started"                  => 1,
    }, {
      season                        => 1,
      "me.away_team"                => $team_association->team->id,
      "team_match_players.player"   => $person->id,
      "team_match_players.location" => "away",
      "me.started"                  => 1,
    }], {
      join      => "team_match_players",
      order_by  => {
        -asc => "scheduled_date"
      }
    });
    
    my ( $matches_won, $matches_lost, $matches_drawn ) = qw( 0 0 0 );
    
    while( my $match = $matches_played->next ) {
      if ( $match->complete ) {
        if ( $match->home_team->id == $team_association->team->id ) {
          # Home team
          if ( $match->home_team_match_score > $match->away_team_match_score ) {
            $matches_won++;
          } elsif ( $match->home_team_match_score < $match->away_team_match_score ) {
            $matches_lost++;
          } else {
            $matches_drawn++;
          }
        } else {
          # Away team
          if ( $match->home_team_match_score > $match->away_team_match_score ) {
            $matches_lost++;
          } elsif ( $match->home_team_match_score < $match->away_team_match_score ) {
            $matches_won++;
          } else {
            $matches_drawn++;
          }
        }
      }
    }
    
    if ( $matches_played->count != $team_association->matches_played or $matches_won != $team_association->matches_won or $matches_drawn != $team_association->matches_drawn or $matches_lost != $team_association->matches_lost ) {
      $people_wrong++;
      printf "%s: %s %s\n", $person->display_name, $team_association->team->club->short_name, $team_association->team->name;
      printf "Officially played: %d, should be: %d\n", $team_association->matches_played, $matches_played->count if $matches_played->count != $team_association->matches_played;
      printf "Officially won: %d, should be: %d\n", $team_association->matches_won, $matches_won if $matches_won != $team_association->matches_won;
      printf "Officially drawn: %d, should be: %d\n", $team_association->matches_drawn, $matches_drawn if $matches_drawn != $team_association->matches_drawn;
      printf "Officially lost: %d, should be: %d\n", $team_association->matches_lost, $matches_lost if $matches_lost != $team_association->matches_lost;
      print "\n";
    }
  }
}

print "$people_wrong with wrong statistics\n";