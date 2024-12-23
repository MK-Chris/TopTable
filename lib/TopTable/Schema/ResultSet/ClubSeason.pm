package TopTable::Schema::ResultSet::ClubSeason;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );

=head2 get_all_seasons_club_entered

Gets a list of seasons that a club has entered teams in.

=cut

sub get_all_seasons_club_entered {
  my $class = shift;
  my ( $club ) = @_;
  
  return $class->search({
    club   => $club->id
  }, {
    prefetch => "season",
    order_by => [{
      -asc => [
        qw( season.complete )
      ]}, {
      -desc => [
        qw( season.start_date season.end_date )
      ]}
    ],
  });
}

1;