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
my $date = DateTime->new( year => "2015", month => 05, day => 07 );
my $meeting = $schema->resultset("Meeting")->find_by_type_and_date( 1, $date );

if ( defined( $meeting ) ) {
  printf "Success: %d\n", $meeting->id;
} else {
  print "Nothing.\n";
}

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
