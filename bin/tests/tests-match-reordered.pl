#!/usr/bin/perl

use strict;
use warnings;
use DateTime;
use DateTime::TimeZone;
use Try::Tiny;
use lib "lib";
use TopTable::Schema;
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );

my $schema = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");
my $person = $schema->resultset("Person")->find_id_or_url_key( "chris-welch" );
printf "Name: %s.\n", $person->display_name;

$person_seasons = $person->search_related("person_seasons", {
  person                => $person->id,
  "me.season"           => 1,
  team_membership_type  => "active",
}, {
  prefetch => {
    team => [
      "club", {
        "team_seasons" => "division"
      }
    ]
  },
  join => "team_membership_type",
  order_by => {
    -desc => "team_membership_type.display_order"
  },
});