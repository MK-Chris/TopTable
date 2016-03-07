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

my $schema    = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");
my $division  = $schema->resultset("Division")->find({url_key => "division-four"});
my $season    = $schema->resultset("Season")->find( 1 );

my $matches = $schema->resultset("TeamMatch")->matches_in_division({
  division  => $division,
  season    => $season,
});

printf "Matches: %d", $matches->count;
