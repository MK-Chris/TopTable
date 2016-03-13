#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw( $Bin );
use lib "$Bin/../../lib";
use Data::Dumper;
use TopTable::Schema;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );

my $schema  = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");
my $person  = $schema->resultset("Person")->find_id_or_url_key( "chris-welch" );

my $games = $person->games_played_in_season;

printf "Person: %s; games: %d\n", $person->display_name, $games->count;

while( my $game = $games->next ) {
  if ( $game->home_player->id == $person->id ) {
    printf "%s - %s - %s %s\n", $game->team_match->actual_date->dmy("/"), $game->away_player->display_name, $game->team_match->away_team->club->short_name, $game->team_match->away_team->name;
  } else {
    printf "%s - %s - %s %s\n", $game->team_match->actual_date->dmy("/"), $game->home_player->display_name, $game->team_match->home_team->club->short_name, $game->team_match->home_team->name;
  }
}

