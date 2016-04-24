#!/usr/bin/perl

use strict;
use warnings;
use lib "lib";

use TopTable::Schema;

my $schema = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");

my @users = $schema->resultset("User")->all;

printf "Found %d users.\n", scalar( @users );

foreach my $user (@users) {
  printf "Found user: %s.\n", $user->username;
  $user->update({password => "password"});
}