#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw( $Bin );
use lib "$Bin/../../lib";
use Data::Dumper;
use TopTable::Schema;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );

my $schema        = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");
my $person        = $schema->resultset("Person")->find_id_or_url_key( "chris-welch" );
my $club          = $schema->resultset("Club")->find_id_or_url_key( "milton-keynes" );
my $team          = $schema->resultset("Team")->find_url_key( $club, "cavaliers" );
my $season        = $schema->resultset("Season")->find( 1 );
my $person_season = $schema->resultset("PersonSeason")->find( $person->id, $season->id, $team->id );

printf "Person: %s; position: %d\n", $person_season->display_name, $person_season->averages_position;

