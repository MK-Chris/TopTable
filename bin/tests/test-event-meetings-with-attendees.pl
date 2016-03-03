#!/usr/bin/perl

use strict;
use warnings;
use DateTime;
use DateTime::TimeZone;
use Try::Tiny;
use FindBin qw( $Bin );
use lib "$Bin/../../lib";
use TopTable;
use TopTable::Schema;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );

my $schema = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");
my $meeting = $schema->resultset("Event")->find(1);

my $meetings_attended = $meeting->search_related("event_seasons", {}, {
  select => [ "name", {count => "meeting_attendees.person"} ],
  as => [ qw( name attendees ) ],
  join => {
    meetings => "meeting_attendees",
  },
  group_by => "id",
  rows => 1,
})->single;

printf "%s: %d\n", $meetings_attended->name, $meetings_attended->get_column("attendees");
