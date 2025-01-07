package TopTable::Schema::ResultSet::TournamentTeam;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );

=head2 find_with_tournament_and_season

Find a round by primary key (ID), but provide some prefetches.

=cut

sub find_with_tournament_and_season {
  my $class = shift;
  my ( $id ) = @_;
  
  return $class->find($id, {
    prefetch => {
      tournament => {
        event_season => [qw( event season )],
      },,
    }
  });
}

1;