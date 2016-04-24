#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw( $Bin );
use lib "$Bin/../../lib";
use Data::Dumper;
use TopTable::Schema;

my $schema  = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");
my $user    = $schema->resultset("User")->find( 1 );

my $sysadmin_role = $schema->resultset("Role")->find({
  sysadmin => 1,
  id => {
    -in => [ qw( 1 2 3 4 ) ],
  }
});

printf "Found: %s\n", $sysadmin_role->name;

my $users = $sysadmin_role->search_related("user_roles")->search_related("user", {
  id => {
    "!=" => $user->id,
  }
});

printf "Found %d users: %s.\n", $users->count, ref( $users );
