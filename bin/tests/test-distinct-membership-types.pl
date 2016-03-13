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
my $season  = $schema->resultset("Season")->find( 1 );
my $types   = [ $schema->resultset("PersonSeason")->get_team_membership_types_for_person_in_season({
  person  => $person,
  season  => $season,
}) ];

foreach my $type ( @$types ) {
  printf "Type: %s\n", $type->team_membership_type->id;
}

printf "Types: %d\n", scalar @$types;

