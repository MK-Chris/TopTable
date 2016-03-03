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
my $match = $schema->resultset("TeamMatch")->find( 40, 55, "2015-10-26" );
my $season = $match->season;

my $home_team = $match->home_team->find_related("team_seasons", {season => $season->id});

printf "%s\n", $home_team->name;
