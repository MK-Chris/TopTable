package TopTable::Schema::ResultSet::TeamMatchCountsView;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );


=head2 search_by_name

Return search results based on a supplied full or partial club / team name.

=cut

sub search_by_season {
  my $class = shift;
  my ( $season ) = @_;
  return $class->search({season_id => $season->id}, {
    order_by => [qw( club_full_name team_name )]
  });
}

1;
