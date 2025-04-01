package TopTable::Schema::ResultSet::TeamSeason;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use DateTime;

=head2 get_doubles_teams_in_division_in_averages_order

Retrieve doubles teams in a given season / division in averages order.

=cut

sub get_doubles_teams_in_division_in_averages_order {
  my $class = shift;
  my ( $params ) = @_;
  my $division = $params->{division};
  my $season = $params->{season};
  my $criteria_field = $params->{criteria_field} || undef;
  my $operator = $params->{operator} || undef;
  my $criteria = $params->{criteria} || undef;
  
  my $where = {
    "me.season"   => $season->id,
    "me.division" => $division->id,
  };
  
  if ( defined($criteria_field) and defined($operator) and defined($criteria) and ($operator eq "<" or $operator eq "<=" or $operator eq "=" or $operator eq ">=" or $operator eq ">") and $criteria =~ /^\d+$/ ) {
    $where->{sprintf("me.doubles_games_%s", $criteria_field)} = {
      $operator => $criteria,
    };
  }
  
  return $class->search($where, {
    prefetch  => ["team", {
      club_season => "club",
    }],
    order_by  => [{
      -desc => [qw( doubles_average_game_wins games_played doubles_games_won )],
    }, {
      -asc  => [qw( club.short_name team.name )],
    }],
  });
}

=head2 grid_positions_set

Loop through a resultset and if any positions are filled with a number, return 1, else return 0.

=cut

sub grid_positions_set {
  my $class = shift;
  my $count = $class->search({
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
  my $class = shift;
  my $count = $class->search({
    grid_position => undef,
  })->count;
  
  if ( $count ) {
    return 1;
  } else {
    return 0;
  }
}

1;