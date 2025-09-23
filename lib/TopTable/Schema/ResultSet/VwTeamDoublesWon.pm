package TopTable::Schema::ResultSet::VwTeamDoublesWon;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use Scalar::Util qw( blessed );


=head2 search_by_name

Return search results based on a supplied full or partial club / team name.

=cut

sub search_by_season {
  my $class = shift;
  my ( $season, $params ) = @_;
  my $top_only = $params->{top_only} // 0; # Get the top matches only - this could be more than one, we need to get the number of matches on the highest number of legs played.
  
  my %where = (season_id => $season->id);
  
  if ( $top_only ) {
    my $top_number = $class->search(\%where)->get_column("doubles_games_won")->max;
    $where{doubles_games_won} = $top_number;
  }
  
  return $class->search(\%where, {
    order_by => [{
      -desc => [qw( doubles_games_won )],
    }, {
      -asc => [qw( team_name )],
    }],
  });
}

1;
