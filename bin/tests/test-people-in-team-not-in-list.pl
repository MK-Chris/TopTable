#!/usr/bin/perl

use strict;
use warnings;
use DateTime;
use DateTime::TimeZone;
use Try::Tiny;
use FindBin qw( $Bin );
use lib "$Bin/../../lib";
use Data::Dumper;
use TopTable::Schema;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );

my $schema  = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");
my $team    = $schema->resultset("Team")->find({url_key => "cavaliers"});
my $season  = $schema->resultset("Season")->find( 1 );
my @players = $schema->resultset("Person")->search({
  url_key => {
    -in => [ qw( chris-welch john-bradley ) ]
  },
});

foreach my $player ( @players ) {
  printf "Person: %s\n", $player->display_name;
}

my @player_ids = map( $_->id, @players);

my @other_players = $team->search_related("person_seasons", {
  season  => $season->id,
  team_membership_type => "active",
  person  => {
    -not_in => \@player_ids,
  }
});

print "OTHERS:\n\n";

foreach my $player ( @other_players ) {
  printf "Person: %s\n", $player->display_name;
}

