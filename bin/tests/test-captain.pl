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
my $season  = $schema->resultset("Season")->find( 1 );
my $team    = $schema->resultset("Team")->find( 1 );

my $captain = $team->get_captain({season => $season});

printf "%s\n", $captain->display_name;
