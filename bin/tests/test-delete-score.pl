#!/usr/bin/perl

use strict;
use warnings;
use DateTime;
use DateTime::TimeZone;
use Try::Tiny;
use lib "lib";
use TopTable::Schema;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );

my $schema = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");
#my $game_number = 1;
my $match   = $schema->resultset("TeamMatch")->find( 23, 45, "2014-10-15" );

foreach my $game_number ( 1 .. 10 ) {
  my $game    = $match->find_related("team_match_games", {scheduled_game_number => $game_number});
  my $update_result = $game->update_score({delete => 1});
  print "Updated game $game_number.\n";
}

#print Dumper( $update_result ) . "\n";

#printf "Took: %s\n", tv_interval( $start );

# Loop through games pre-update
# my $games = $match->league_team_match_games;
# while ( my $game = $games->next ) {
#   printf( "Actual: %d; scheduled: %d.\n", $game->actual_game_number, $game->scheduled_game_number );
# }
# 
# # Loop through games pre-update
# $games = $match->league_team_match_games;
# while ( my $game = $games->next ) {
#   printf( "Actual: %d; scheduled: %d.\n", $game->actual_game_number, $game->scheduled_game_number );
# }
# my $seasons = $schema->resultset("Season")->page_club_seasons({
#   club              => $club,
#   page_number       => 1,
#   results_per_page  => 25,
# });
# 
# printf "%d\n", $seasons->count;