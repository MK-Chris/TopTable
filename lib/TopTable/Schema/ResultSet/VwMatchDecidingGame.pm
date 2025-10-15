package TopTable::Schema::ResultSet::VwMatchDecidingGame;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );


=head2 search_by_name

Return search results based on a supplied full or partial club / team name.

=cut

sub search_by_season {
  my $class = shift;
  my ( $season, $params ) = @_;
  my $result = $params->{result};
  my $top_only = $params->{top_only} // 0; # Get the top people only - this could be more than one, we need to get the number of people on the top number of sets.
  my $limit = $params->{limit} // 20;
  
  my %where = (season_id => $season->id);
  $where{result} = $result if defined $result;
  if ( $top_only ) {
    my $top_number = $class->search(\%where)->get_column("number_of_sets")->max;
    $where{number_of_sets} = $top_number;
  }
  
  return $class->search(\%where, {
    order_by => [{
      -desc => [qw( number_of_sets )],
    }, {
      -asc => [qw( player_surname player_first_name )],
    }],
    rows => $limit,
  });
}

1;
