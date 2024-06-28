package TopTable::Schema::ResultSet::DivisionSeason;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 divisions_and_teams_in_season_by_grid_position

A predefined search to find and return the divisions (and the teams in them) within a season.

=cut

sub divisions_and_teams_in_season_by_grid_position {
  my ( $self, $season, $grid ) = @_;
  
  return $self->search({
    "me.season" => $season->id,
    "team_seasons.season" => $season->id,
    "club_season.season" => $season->id,
    "me.fixtures_grid" => $grid->id,
  }, {
    prefetch => [qw( division ), {
        team_seasons => [qw( team ), {
        club_season => "club",
      }]
    }],
    order_by  => {
      -asc => [qw( division.rank team_seasons.grid_position )]
    }
  });
}

1;