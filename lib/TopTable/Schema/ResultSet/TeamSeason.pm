package TopTable::Schema::ResultSet::TeamSeason;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 get_teams_in_division_in_league_table_order

Retrieve people in a given season / division in averages order.  If the $criteria hashref is given, these will be added to the query.

=cut

sub get_teams_in_division_in_league_table_order {
  my ( $self, $season, $division ) = @_;
  
  return $self->search({
    season    => $season->id,
    division  => $division->id,
  }, {
    prefetch  => {
      "team" => "club",
    },
    order_by  => [
      {
        -desc => [
          qw( games_won matches_won matches_drawn matches_played )
        ],
      }, {
        -asc  => [
          qw( games_lost matches_lost )
        ],
      }, {
        -desc => [
          qw( games_won )
        ],
      }, {
        -asc  => [
          qw( club.short_name team.name )
        ],
      },
    ],
  });
}

=head2 get_doubles_teams_in_division_in_averages_order

Retrieve doubles teams in a given season / division in averages order.

=cut

sub get_doubles_teams_in_division_in_averages_order {
  my ( $self, $parameters ) = @_;
  my $division        = $parameters->{division};
  my $season          = $parameters->{season};
  my $criteria_field  = $parameters->{criteria_field} || undef;
  my $operator        = $parameters->{operator} || undef;
  my $criteria        = $parameters->{criteria} || undef;
  
  my $where = {
    "me.season"   => $season->id,
    "me.division" => $division->id,
  };
  
  if ( defined( $criteria_field ) and defined( $operator ) and defined( $criteria ) and ( $operator eq "<" or $operator eq "<=" or $operator eq "=" or $operator eq ">=" or $operator eq ">" ) and $criteria =~ /^\d+$/ ) {
    $where->{ sprintf( "me.doubles_games_%s", $criteria_field ) } = {
      $operator => $criteria,
    };
  }
  
  return $self->search($where, {
    prefetch  => [ qw( team club ) ],
    order_by  => [{
      -desc => [ qw( doubles_average_game_wins games_played doubles_games_won ) ],
    }, {
      -asc  => [ qw( club.short_name team.name ) ],
    }],
  });
}

=head2 grid_positions_filled

Loop through a resultset and if any positions are filled with a number, return 1, else return 0.

=cut

sub grid_positions_filled {
  my ( $self ) = @_;
  my $count = $self->search({
    grid_position => {
      "!=" => undef,
    }
  })->count;
  
  if ( $count ) {
    return 1;
  } else {
    return 0;
  }
}

=head2 grid_positions_empty

Loop through a resultset and if any positions are NOT filled with a number, return 1, else return 0.

=cut

sub grid_positions_empty {
  my ( $self ) = @_;
  my $count = $self->search({
    grid_position => undef,
  })->count;
  
  if ( $count ) {
    return 1;
  } else {
    return 0;
  }
}

1;