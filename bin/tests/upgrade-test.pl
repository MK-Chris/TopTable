#!/usr/bin/perl

use strict;
use warnings;
# use DateTime;
# use DateTime::TimeZone;
# use Try::Tiny;
use lib "lib";
# use TopTable::Schema;
use Data::Dumper;

#my $schema = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");
#my $season  = $schema->resultset("Season")->get_current;
#
# printf( "%s\n", $season->name );
# my @divisions = $schema->resultset("Division")->all;
# 
# foreach my $division ( @divisions ) {
#   my $this_season = $division->division_seasons->find({
#     season  => $season->id,
#   }, {});
#   
#   if ( defined( $this_season ) ) {
#     printf( "%s has an association with %s\n", $division->name, $season->name );
#   } else {
#     printf( "%s has NO association with %s\n", $division->name, $season->name );
#   }
#}

# my $season = $schema->resultset("Season")->last_season_with_team_entries;
# my @teams = $schema->resultset("Team")->all_teams_by_club_by_team_name_with_season({season => $season});
# print scalar( @teams );

# my $date = DateTime->new( year => 2014, month => 9, day => 17 );
# my $match = $schema->resultset("LeagueTeamMatch")->find({
#   home_team => 33,
#   away_team => 43,
#   scheduled_date => "2014-09-17",
# }, {
#   prefetch => "league_team_match_games",
#   order_by => {
#     -asc => "league_team_match_games.actual_game_number",
#   },
# });

# Loop through games pre-update
# my $games = $match->league_team_match_games;
# while ( my $game = $games->next ) {
#   printf( "Actual: %d; scheduled: %d.\n", $game->actual_game_number, $game->scheduled_game_number );
# }
# 
# # Perform an update on the result
# my $dt_updated = DateTime->now;
# $match->update({
#   updated_since => sprintf( "%s %s", $dt_updated->ymd, $dt_updated->hms ),
# });
# 
# # Loop through games pre-update
# $games = $match->league_team_match_games;
# while ( my $game = $games->next ) {
#   printf( "Actual: %d; scheduled: %d.\n", $game->actual_game_number, $game->scheduled_game_number );
# }

# my $club = $schema->resultset("Club")->find_id_or_url_key("milton-keynes");
# printf "%s\n", $club->full_name;
# my $seasons = $schema->resultset("Season")->page_club_seasons({
#   club              => $club,
#   page_number       => 1,
#   results_per_page  => 25,
# });
# 
# printf "%d\n", $seasons->count;

print "Hello world\n";

