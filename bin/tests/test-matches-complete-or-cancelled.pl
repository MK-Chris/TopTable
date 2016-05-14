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

my $schema  = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");
my $season = $schema->resultset("Season")->find( 1 );

my $matches = $schema->resultset("TeamMatch")->incomplete_and_not_cancelled({season => $season})->count;

printf "Incomplete matches: %d\n", $matches;
