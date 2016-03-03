#!/usr/bin/perl

use strict;
use warnings;
use DateTime;
use DateTime::TimeZone;
use Try::Tiny;
use FindBin qw( $Bin );
use lib "$Bin/../lib";
use Data::Dumper;
use TopTable::Schema;
use Data::Dumper;

my $schema  = TopTable::Schema->connect("dbi:mysql:toptable", "toptable", "toptable");

my $pairs = $schema->resultset("DoublesPair")->search(undef, {
  prefetch => [ qw( person1 person2 ) ],
});

my $pairs_wrong     = 0;
my $averages_wrong  = 0;
while ( my $pair = $pairs->next ) {
  if ( $pair->points_played != $pair->points_won + $pair->points_lost ) {
    printf "%s and %s:\nOfficially played: %d, updated to: %d\n\n", $pair->person1->display_name, $pair->person2->display_name, $pair->points_played, ($pair->points_won + $pair->points_lost);
    
    my $average = ( $pair->points_won + $pair->points_lost ) ? ( ( $pair->points_won / $pair->points_played ) * 100) : 0;
    
    $pair->update({
      points_played       => ( $pair->points_won + $pair->points_lost ),
      average_point_wins  => $average,
    });
    
    $pairs_wrong++;
  } else {
    my $average = ( $pair->points_played ) ? ( ( $pair->points_won / $pair->points_played ) * 100 ) : 0;
    
    if ( $average != $pair->average_point_wins ) {
      $pair->update({average_point_wins => $average});
      $averages_wrong++;
    }
  }
}

print "$pairs_wrong with wrong statistics\n";
print "$averages_wrong with wrong average\n";
