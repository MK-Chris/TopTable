#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw( $Bin );
use lib "$Bin/../../lib";
use Data::Dumper;
use TopTable::Schema;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );

my $schema    = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");
my $season    = $schema->resultset("Season")->find( 2 );
my $division  = $schema->resultset("Division")->find_url_key( "division-three" );

my $config = {
  season    => $season,
  division  => $division,
};

my @singles_averages = $schema->resultset("PersonSeason")->get_people_in_division_in_singles_averages_order( $config );

my $i = 0;
foreach my $person_season ( @singles_averages ) {
  $i++;
  printf( "%02d. %-20s - %03d|%02d|%02d|%s\n", $i, $person_season->display_name, $person_season->person->id, $person_season->season->id, $person_season->team->id, $person_season->team_membership_type->id )
}