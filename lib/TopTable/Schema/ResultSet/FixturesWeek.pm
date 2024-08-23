package TopTable::Schema::ResultSet::FixturesWeek;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );

=head2 season_weeks

A predefined search to get the weeks for a season in date order.

=cut

sub season_weeks {
  my $class = shift;
  my ( $season ) = @_;
  
  return $class->search({
    season => $season->id
  }, {
    order_by => {-asc => "week_beginning_date"}
  });
}

1;