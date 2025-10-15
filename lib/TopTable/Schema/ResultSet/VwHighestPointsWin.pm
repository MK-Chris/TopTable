package TopTable::Schema::ResultSet::VwHighestPointsWin;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use Scalar::Util qw( blessed );


=head2 search_by_name

Return search results based on a supplied full or partial club / team name.

=cut

sub search_by_season {
  my $class = shift;
  my ( $season, $comp, $params ) = @_;
  my $top_only = $params->{top_only} // 0; # Get the top people only - this could be more than one, we need to get the number of people on the top number of sets.
  my $limit = $params->{limit} // 20;
  
  my %where = (season_id => $season->id);
  
  if ( defined($comp) and blessed($comp) ) {
    if ( $comp->isa("TopTable::Schema::Result::Tournament") ) {
      $where{tourn_id} = $comp->id;
    } elsif ( $comp->isa("TopTable::Schema::Result::Division") ) {
      $where{division_id} = $comp->id;
    } else {
      # Default to league (division_id isn't null)
      $where{division_id} = {"!=" => undef};
    }
  } else {
    # Default to league (division_id isn't null)
    $where{division_id} = {"!=" => undef};
  }
  
  if ( $top_only ) {
    my $top_number = $class->search(\%where)->get_column("winning_points")->max;
    $where{winning_points} = $top_number;
  }
  
  return $class->search(\%where, {
    order_by => [{
      -desc => [qw( winning_points )],
    }, {
      -asc => [qw( player_surname player_first_name opponent_surname opponent_first_name )],
    }],
    rows => $limit,
  });
}

1;
